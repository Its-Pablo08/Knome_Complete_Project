# Development Journal Entry 132: Opening Module URL Redirection & MPO SSO Alignment

**Date:** 2026-09-22  
**Feature/Module:** Opening Module (`Login.jsx`, `UserContext.jsx`, `AuthGuard.jsx`) & Openings Module (`Jobs.jsx`, `CreateJobModal.jsx`)  
**Type:** SSO Integration / URL Redirection / Architecture Alignment  

---

## 1. Problem Description & Background
The user provided a 10-page specification detailing the backend and frontend architecture for MPO Employee Hub SSO and URL Redirection integration:
- Target Authority: `https://counselling-1.mponline.demo.gov.in:3001`
- Client ID: `Knome-2026`
- Client Secret: `secret_olikl9fqskbjuzjg`

The request specified: *"do the following changes in opening module and make it redirect to urls"*.
This spans two interconnected areas:
1. **Opening / Login Module & Authentication Lifecyle**:
   - `Login.jsx` previously had a static redirection to `https://counselling-1.mponline.demo.gov.in:3001/login?logout=true`.
   - The specification requires a dynamic host/port detection routine (`getSsoUrls()`) that resolves local dev ports (`5001`/`8081`) or production MPO Hub, and redirects to:
     `${hubLoginUrl}?client_id=Knome-2026&returnUrl=${returnUrl}&redirect_uri=${encodeURIComponent(knomeBase)}`.
   - `UserContext.jsx` requires alignment of incoming token detection and a global BFF signout flow redirecting to:
     `https://counselling-1.mponline.demo.gov.in:3001/api/bff/signout?returnUrl=${encodeURIComponent(myAppLoginUrl)}`.
   - `AuthGuard.jsx` should route unauthenticated users to `/login` to trigger the client-registered SSO flow.
2. **Openings (Jobs) Module URL Redirection**:
   - In `Jobs.jsx`, "Apply Now" buttons redirect users to job application URLs.
   - `Jobs.jsx` previously expected `j.applicationUrl` instead of the database model's `j.applicationLink`, and did not unpack paged API responses (`PagedResultDto`), causing fallback to hardcoded mock entries.
   - External application links must be normalized with valid URL protocols so they do not get routed as internal relative URLs.
   - `CreateJobModal.jsx` payload must match `CreateJobDto` (`applicationLink`, `skillsRequired`, `closingDate`, `status: "Open"`).

---

## 2. Planned Changes

### Frontend:
1. **`knomeUI/frontend/src/pages/Login.jsx`**:
   - Implement `getSsoUrls()` with dynamic local and IIS detection.
   - Update `useEffect` to redirect with `client_id=Knome-2026`, `returnUrl`, and `redirect_uri`.
2. **`knomeUI/frontend/src/components/contexts/UserContext.jsx`**:
   - Implement the global BFF logout flow redirecting to `https://counselling-1.mponline.demo.gov.in:3001/api/bff/signout`.
   - Verify token processing for `token`, `access_token`, `sso_token`, and user identification claims.
3. **`knomeUI/frontend/src/components/layout/AuthGuard.jsx`**:
   - Unauthenticated sessions route cleanly through `/login`.
4. **`knomeUI/frontend/src/pages/Jobs.jsx` & `CreateJobModal.jsx`**:
   - Unpack paged items in `jobsApi.getAll()`.
   - Map `applicationLink` and ensure safe external URL redirection.
   - Fix job creation payload.

### Backend:
1. **`Backend/Knome.API/Extensions/ServiceCollectionExtensions.cs`**:
   - Verify `ValidIssuers` contains `jwtSettings.Issuer`, `"EmployeeHub.Identity"`, and `"Knome.API"`.
   - Ensure claim mapping and token validation match the specification.

---

## 3. Verification Plan
- `dotnet build -nologo` in `Backend/Knome.API`.
- `npm run build` in `knomeUI/frontend`.
- Deploy dist bundle to IIS webroot at `C:\inetpub\wwwroot\knome`.
- Verify URL redirection parameters and link click behaviors.
