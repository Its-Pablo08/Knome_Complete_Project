# Phase 123 — Suspended User Login Alert and Logout Workflow

**Date:** 2026-09-22  
**Status:** Completed  
**Branch:** main  

---

## 1. Problem Statement & User Requirement
When an administrator suspends an employee from the Admin Console (`/admin-console`), and that suspended employee attempts to log in (either via Employee Hub SSO at `/sso`, direct access, session restoration, or user switching), they must be presented with an explicit modal alert popup stating:
> *"Your account is suspended by system admin"*

Key workflow requirements:
1. The popup must display clear identification of the suspended employee (Name and Employee ID) and explain that Knome access has been suspended by System Admin.
2. The popup must contain an **"OK"** button.
3. The popup must **NOT** automatically dismiss or auto-redirect on timer; it must remain on screen until the employee acknowledges by clicking **"OK"**.
4. Upon clicking **"OK"**, the user's session must be terminated, tokens and credentials cleared, and the user must be logged out and redirected to the official MPO Employee Hub login destination:  
   `https://counselling-1.mponline.demo.gov.in:3001/login?logout=true`.

---

## 2. Root Cause Analysis
Previously:
1. When a suspended user attempted to log in or restore their session in `UserContext.jsx` (`authenticateUser`), a 403 Forbidden or suspension error was detected, but it immediately executed `setIsAuthenticated(false)` and threw an error.
2. `AuthGuard.jsx` caught `!isAuthenticated` and immediately executed `window.location.href = 'https://counselling-1.mponline.demo.gov.in:3001/login?logout=true'`.
3. Consequently, the user was instantly kicked back to MPO Employee Hub before any modal or alert could ever render.
4. Furthermore, `SsoPage.jsx` had a 2-second timeout error screen that auto-redirected without requiring an explicit "OK" user interaction.

---

## 3. Architecture & Implementation Details

### A. Created Dedicated `SuspendedAlertModal.jsx`
- **Location:** `knomeUI/frontend/src/components/modals/SuspendedAlertModal.jsx`
- Features:
  - Accessible `role="alertdialog"` with high z-index backdrop blur (`z-[99999]`).
  - Top ambient red glow, animated warning badge with ping indicator, and "Access Denied" status chip.
  - Title: *"Your account is suspended by system admin"*.
  - Displays user's full name and monospace Employee ID (`[MPO...]`).
  - Explanatory details box advising the user that platform access is suspended and to contact HR Administrator or System Admin for inquiries.
  - Prominent **"OK"** button with logout icon that triggers the `onOk` callback.

### B. Updated `AuthGuard.jsx`
- Replaced the previous full-page layout override with `SuspendedAlertModal`.
- Checked suspension state across multiple indicators (`isActive === false`, `isSuspended === true`, `isPermanentlySuspended === true`, `status === 'Suspended'`, `suspendedUntil`, and `knome_suspended_accounts` map).
- Wired `onOk={logout}` so clicking "OK" clears the session and routes to `https://counselling-1.mponline.demo.gov.in:3001/login?logout=true`.

### C. Updated `UserContext.jsx`
- In `authenticateUser`: When suspension is detected or 403 is received, sets `currentUser` with `{ isActive: false, isSuspended: true, status: 'Suspended' }` and maintains `setIsAuthenticated(true)` instead of resetting authentication to false. This allows `AuthGuard` to remain mounted and present the `SuspendedAlertModal`.
- In `restoreSession`: Checked `knome_suspended_accounts` and `resolveUserStatus` before attempting network calls or redirects. If the user is suspended, session loading finishes and the suspended `currentUser` is set.
- In `switchUser`: Added `knome_suspended_accounts` check to immediately present the suspension modal if switching to a suspended employee.
- In `toggleUserActiveStatus`: Synchronized suspension entries in `knome_suspended_accounts` by both numeric user ID and alphanumeric Employee ID.

### D. Updated `AdminConsole.jsx`
- In `handleConfirmSuspend`: Ensured the suspension reason is passed to `toggleUserActiveStatus` and immediately saved to `knome_suspended_accounts` under both `numericId` and `employeeId`.
- In `handleToggleUserActive`: Ensured reactivated employees are immediately removed from `knome_suspended_accounts` under both `targetId` and `employeeId`.

### E. Updated `SsoPage.jsx`
- Handled suspension detection directly in SSO verification flow.
- Rendered `<SuspendedAlertModal>` when suspension is identified, eliminating the 2-second auto-redirect.
- On clicking "OK", properly cleared tokens and redirected to MPO Employee Hub login with `logout=true`.

---

## 4. Verification
1. **Frontend Production Build:**  
   Ran `npm run build` in `d:\Knome main\knomeUI\frontend`. Build succeeded with 0 errors (`vite v8.1.4` built in 1.77s).
2. **IIS Deployment:**  
   Robocopy deployed updated bundles to `C:\inetpub\wwwroot\knome` with 100% file transfer success.
3. **Backend API Build:**  
   `dotnet build -nologo` in `Backend/Knome.API` built successfully with 0 errors.
4. **Vite Dev Server:**  
   Verified running live on `http://localhost:5173` (PID 7528).

---

## 5. Artifacts & Changed Files
- `knomeUI/frontend/src/components/modals/SuspendedAlertModal.jsx` [NEW]
- `knomeUI/frontend/src/components/layout/AuthGuard.jsx` [MODIFIED]
- `knomeUI/frontend/src/components/contexts/UserContext.jsx` [MODIFIED]
- `knomeUI/frontend/src/pages/auth/SsoPage.jsx` [MODIFIED]
- `knomeUI/frontend/src/pages/AdminConsole.jsx` [MODIFIED]
- `Documentation/Development Journal/123_Suspended_User_Login_Alert_And_Logout_Workflow.md` [NEW]
