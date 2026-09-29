# Development Journal Entry 137: Full MPO Employee Hub SSO Integration Alignment

**Date:** 2026-09-22  
**Feature/Module:** Central SSO Integration (MPO Employee Hub $\leftrightarrow$ Knome)  
**Type:** Authentication & Single Sign-On Architecture  

---

## 1. Problem Description & Background
To establish trust and single sign-on (SSO) between Knome and the central MPO Employee Hub (`https://counselling-1.mponline.demo.gov.in:3001`), the full authentication handshake required alignment across 6 core files in both Backend (.NET 10) and Frontend (React/Vite).

---

## 2. Changes Implemented

### Part 1: Backend (.NET Core API)
1. **`Backend/Knome.API/appsettings.json`**:
   - Configured `MPOAuthServer` with `Authority: "https://counselling-1.mponline.demo.gov.in:3001"`, `ClientId: "Knome-2026"`, and `ClientSecret: "secret_olikl9fqskbjuzjg"`.
2. **`Backend/Knome.API/Configuration/MPOAuthServerSettings.cs`**:
   - Strongly typed C# options model for `MPOAuthServer` settings injection.
3. **`Backend/Knome.API/Extensions/ServiceCollectionExtensions.cs`**:
   - Bound `MPOAuthServerSettings` via DI.
   - Configured unified `TokenValidationParameters` with `ValidateAudience = false`, `ValidateIssuer = true`, and comprehensive `ValidIssuers` encompassing the MPO Hub authority endpoints and Knome issuers.
   - Enriched `OnTokenValidated` to extract `email`, `sub`, and `empId` (`employeeId` / `employee_id`), resolve the user in `KnomeDbContext`, and inject internal `uid`, `employeeId`, and RBAC role claims.
4. **`Backend/Knome.API/Controllers/KnomeControllerBase.cs`**:
   - `GetCurrentUserId()` seamlessly parses `uid`, `NameIdentifier`, and `sub` claims across all controllers.

### Part 2: Frontend (React / Vite)
5. **`knomeUI/frontend/src/pages/Login.jsx`**:
   - Automatic registered SSO redirection to `${hubLoginUrl}?client_id=Knome-2026&returnUrl=${returnUrl}&redirect_uri=${encodeURIComponent(knomeBase)}`.
6. **`knomeUI/frontend/src/components/contexts/UserContext.jsx` & `apiService.js`**:
   - Location A: Detects incoming SSO query tokens (`token`, `access_token`, `sso_token`, `employeeId`), preserves tokens directly in `localStorage.setItem('knome_jwt', ssoToken)` and `localStorage.setItem('accessToken', ssoToken)`, fetches profile claims via `profileApi.getMe()` / `authApi.getMe()`, and merges into application state using `mergeProfile(localUser, profile)`.
   - Location B: Global BFF signout flow clears local credentials and redirects to `https://counselling-1.mponline.demo.gov.in:3001/api/bff/signout?returnUrl=...`.

---

## 3. Verification & Deployment
- **Backend**: `dotnet build -nologo` verified with 0 errors.
- **Frontend**: `npm run build` compiled in 1.47s with 0 errors.
- **IIS Deployment**: Deployed production build files to `C:\inetpub\wwwroot\knome` via robocopy (43 files updated).
