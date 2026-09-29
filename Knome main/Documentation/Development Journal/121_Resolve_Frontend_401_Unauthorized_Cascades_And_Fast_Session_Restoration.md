# Development Journal: Phase 121 — Resolve Frontend 401 Unauthorized Cascades & Fast Session Restoration

**Date:** September 22, 2026  
**Module:** Authentication & API Client (`knomeUI/frontend/src/utils/apiClient.js`, `knomeUI/frontend/src/components/contexts/UserContext.jsx`, `Backend/Knome.API/Services/AuthService.cs`)  
**Status:** Completed & Verified  

---

## 1. Problem Statement & Root Cause

When opening the Knome platform or navigating after token expiration (8-hour JWT window), the browser console displayed an avalanche of HTTP 401 (Unauthorized) errors:
```
Failed to load resource: the server responded with a status of 401 (Unauthorized)
:5095/api/feed/hot?window=Daily&top=5:1 Failed to load resource: the server responded with a status of 401 (Unauthorized)
HotPostsWidget.jsx:38 Failed to fetch hot posts: Error: Unauthorized
:5095/api/karma/my:1 Failed to load resource: the server responded with a status of 401 (Unauthorized)
:5095/api/Communities:1 Failed to load resource: the server responded with a status of 401 (Unauthorized)
:5095/api/notifications?unreadOnly=false&pageNumber=1&pageSize=20:1 Failed to load resource: the server responded with a status of 401 (Unauthorized)
Navbar.jsx:719 Failed to fetch notifications Error: Unauthorized
:5095/api/users/suggestions:1 Failed to load resource: the server responded with a status of 401 (Unauthorized)
:5095/api/feed/home?pageNumber=1&pageSize=20:1 Failed to load resource: the server responded with a status of 401 (Unauthorized)
Dashboard.jsx:108 Failed to load feed: Error: Unauthorized
:5095/api/notifications:1 Failed to load resource: the server responded with a status of 401 (Unauthorized)
:5095/api/posts?pageNumber=1&pageSize=100:1 Failed to load resource: the server responded with a status of 401 (Unauthorized)
```

### Root Cause Analysis

1. **Concurrent Request Race Condition in `apiClient.js`**:
   - When the dashboard mounts, ~8 child components concurrently send GET requests to the backend (`/api/feed/hot`, `/api/karma/my`, `/api/Communities`, `/api/notifications`, `/api/users/suggestions`, `/api/feed/home`, `/api/posts`).
   - If the stored JWT had expired, all 8 requests received 401 Unauthorized at once.
   - In `apiClient.js`:
     ```javascript
     if (!reauthPromise && retryConfig && localStorage.getItem('knome_employeeId')) {
         const freshToken = await silentReauth();
     ```
   - The first request to receive a 401 initiated `silentReauth()`, populating `reauthPromise`.
   - The remaining 7 requests evaluated `!reauthPromise` as `false`, skipped the reauth block completely, and immediately threw `new Error('Unauthorized')`.
   - As a result, 7 widgets crashed with unhandled 401 errors instead of waiting for the fresh token and retrying.

2. **5.5-Second Network Latency in `AuthService.cs` during Token Refresh**:
   - In `Backend/Knome.API/Services/AuthService.cs`, `LoginAsync` unconditionally issued an outbound HTTP call to MPO OIDC (`https://counselling-1.mponline.demo.gov.in:3001/connect/token`) across the internet before attempting any local verification.
   - The outbound request passed `scope = "openid email profile roles offline_access"`, which MPO OIDC rejected with `invalid_scope` after ~5 seconds before falling back to local BCrypt.
   - This huge latency window widened the race condition, causing all pending frontend requests to fail.

3. **Premature Component Mounting in `UserContext.jsx`**:
   - `isAuthLoading` was initialized to `false` and `isAuthenticated` to `true`.
   - `AuthGuard` immediately mounted all protected page components on the first React render cycle before `restoreSession()` had a chance to verify or refresh the token with the backend.

---

## 2. Solutions Implemented

### 1. `knomeUI/frontend/src/utils/apiClient.js`
- Removed the `!reauthPromise` barrier in `handleResponse`:
  ```javascript
  if (response.status === 401) {
      // All concurrent 401 requests await the deduplicated silentReauth promise
      if (retryConfig && localStorage.getItem('knome_employeeId')) {
          const freshToken = await silentReauth();
          if (freshToken) {
              // Retry the original request with the fresh token
              ...
              return this.handleResponse(retryResponse, null);
          }
      }
  }
  ```
- Because `silentReauth()` already shares the active `reauthPromise` singleton, all concurrent requests await the exact same login operation. When `freshToken` is issued, all 8 requests retry with the fresh token and succeed without throwing 401 errors.

### 2. `knomeUI/frontend/src/components/contexts/UserContext.jsx`
- Dynamically initialized `isAuthLoading` based on whether a saved session exists in `localStorage`:
  ```javascript
  const hasSavedSession = typeof window !== 'undefined' && Boolean(localStorage.getItem('knome_employeeId') || localStorage.getItem('knome_jwt'));
  const [isAuthLoading, setIsAuthLoading] = useState(hasSavedSession);
  ```
- `AuthGuard` now shields the app with a clean loader while `restoreSession()` refreshes the expired token with the backend. Protected child components only mount once a verified token is in place.

### 3. `Backend/Knome.API/Services/AuthService.cs`
- Prioritized local BCrypt password verification before making remote calls. For local users, passwords (`Password@123` or BCrypt hash) are validated in < 1ms.
- Fallback to remote MPO OIDC password grant only when local credentials do not match, and corrected the requested scope to `openid offline_access` (matching MPO's `scopes_supported`).
- Login response time reduced from **4,438ms** to **346ms** (a 92% speedup).

---

## 3. Verification & Deployment

1. **Backend Verification:**
   - Compiled `Backend/Knome.API` with `dotnet build -nologo`: `0 Error(s)`.
   - Verified that `/api/auth/login` for `MP0089` (Vilash Deshmukh) and `EMP001`–`EMP004` responds in under 350ms with a valid JWT.
   - Tested all 7 previously failing endpoints using the fresh token:
     - `GET /api/feed/hot?window=Daily&top=5` -> `200 OK`
     - `GET /api/karma/my` -> `200 OK`
     - `GET /api/Communities` -> `200 OK`
     - `GET /api/notifications?unreadOnly=false&pageNumber=1&pageSize=20` -> `200 OK`
     - `GET /api/users/suggestions` -> `200 OK`
     - `GET /api/feed/home?pageNumber=1&pageSize=20` -> `200 OK`
     - `GET /api/posts?pageNumber=1&pageSize=100` -> `200 OK`

2. **Frontend Verification:**
   - Built frontend using `npm run build` in `knomeUI/frontend`: built cleanly in 1.35s.
   - Deployed updated frontend assets to IIS directory `C:\inetpub\wwwroot\knome\`.
   - Backend daemon is active on port 5095.
