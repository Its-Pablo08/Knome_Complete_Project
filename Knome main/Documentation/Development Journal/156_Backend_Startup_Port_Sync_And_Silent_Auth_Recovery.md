# Phase 156 — Backend Startup Port Synchronization & Silent Authentication Recovery

## Overview
Resolved startup connection failure (`net::ERR_CONNECTION_REFUSED`) across backend endpoints followed by `401 (Unauthorized)` on periodic polling endpoints (e.g. `/api/notifications`).

## Root Cause Analysis
1. **Startup Race Condition in Launcher (`START_KNOME.ps1`)**:
   `START_KNOME.ps1` previously launched `dotnet run` in a background job and only slept for 3 seconds before starting the Vite frontend (`http://localhost:5173`) and declaring all services active. On Windows developer machines, `dotnet run` takes 10–15 seconds to compile, resolve DI, and bind Kestrel to port 5095. Opening the browser immediately generated `ERR_CONNECTION_REFUSED` on all initial API requests (`/interactions/restricted-keywords`, `/users/profile`, `/Auth/login`, etc.).

2. **Stale Session Token Retention**:
   During the initial `ERR_CONNECTION_REFUSED` window, `UserContext.jsx` failed to refresh the JWT session via `/api/Auth/login` and retained the previous/expired token in `localStorage.getItem('knome_jwt')`.

3. **Silent Reauth Cooldown & Recovery Blocker**:
   When port 5095 came online 15 seconds later and the periodic notification poller hit `GET /api/notifications`, the server rejected the expired token with `401 Unauthorized`. `apiClient.js` failed to re-authenticate immediately because:
   - `silentReauth()` treated transient network errors (`Failed to fetch`) as auth failures, triggering an immediate 6-second cooldown lockout.
   - `handleResponse()` required `localStorage.getItem('knome_employeeId')` to be pre-existing, preventing token extraction from JWT claims or fallback.

## Key Changes
1. **[START_KNOME.ps1](file:///d:/Knome%20main/START_KNOME.ps1)**:
   - Replaced fixed 3-second sleep with an active polling loop that checks `Get-NetTCPConnection -LocalPort 5095 -State Listen` (up to 30 seconds) before starting the frontend and announcing readiness.

2. **[apiClient.js](file:///d:/Knome%20main/knomeUI/frontend/src/utils/apiClient.js)**:
   - Updated `silentReauth()` to safely decode `employeeId` from `knome_jwt` claims if `knome_employeeId` is absent in `localStorage`.
   - Prevented connection-refused network errors from setting the 6-second cooldown, so reauth runs immediately as soon as the server is online.
   - Dispatched `knome_token_refreshed` event upon successful silent token renewal.
   - Allowed `handleResponse` 401 handler to invoke `silentReauth` regardless of whether `knome_employeeId` was explicitly set.

3. **[UserContext.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/components/contexts/UserContext.jsx)**:
   - Added automatic delayed retry when initial authentication fails due to network unreachable (`Failed to fetch`), so session automatically refreshes when backend comes up.
   - Added event listener for `knome_token_refreshed` to sync profile in real-time.

4. **[Navbar.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/components/layout/Navbar.jsx)**:
   - Changed notification catch error logging to `console.warn` to avoid filling the console with stack traces during transient backend restarts.

## Verification
- Verified port binding and status: Port 5095 and 5173 actively listening.
- Tested `dotnet build Backend/Knome.API` — 0 errors.
- Verified `/api/Auth/login` and authenticated `GET /api/notifications` across test accounts (`EMP001`, `EMP002`).
