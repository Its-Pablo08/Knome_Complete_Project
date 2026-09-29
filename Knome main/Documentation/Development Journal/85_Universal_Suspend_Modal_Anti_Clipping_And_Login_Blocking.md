# Phase 85: Universal Suspend Modal, Anti-Clipping Responsive Layout, and Strict Login Blocking

## Overview
Standardized all account and membership suspension actions across Knome into a single modern, anti-clipping popup modal (`SuspendUserModal.jsx`) matching the executive design specifications. Simultaneously enforced strict multi-tier login rejection across SQL Server, the ASP.NET Core backend (`AuthService.cs`), frontend authentication guard (`AuthGuard.jsx`), and session context (`UserContext.jsx`) so that suspended users can neither log in nor bypass their restriction.

## Objectives
1. **Universal Modern Suspend Modal**: Wherever "Suspend" exists in the platform (Community Management, User Governance Table, Disciplinary Quick Actions, Moderation Reports, and User Details Modal), clicking "Suspend" opens the standardized modern popup modal.
2. **Anti-Clipping Responsive Architecture**: Eliminate vertical clipping where the modal header and action buttons were truncated on smaller laptop screen resolutions (1366x768 / 1280x800). Pinned header and pinned footer with internal scrollable body (`max-h-[90vh] flex flex-col overflow-hidden`).
3. **Dual Modal Operation Modes**: Support both targeted user suspension (avatar, name, role badge, department) and searchable user selection mode (search input + active user list) for quick toolbar actions.
4. **Strict Login Rejection**:
   - **Backend API**: `GetCurrentUserAsync` and `GetCurrentUserByIdentifierAsync` in `AuthService.cs` strictly reject suspended users (`IsPermanentlySuspended`, `SuspendedUntil > UtcNow`, or `!IsActive`) with `ForbiddenException` (HTTP 403).
   - **Frontend AuthGuard**: Evaluates `isSuspended` before unauthenticated passthrough and renders the full-screen "ACCESS DENIED — Account Suspended" page with restricted module indicators and a clean logout button.
   - **Frontend UserContext**: In `authenticateUser`, `login`, `restoreSession`, and `switchUser`, caught suspension errors immediately wipe JWT tokens (`knome_jwt`, `knome_refresh`, `knome_employeeId`), set `currentUser` with `{ isActive: false, isSuspended: true, status: 'Suspended' }`, and prevent falling back to an active session.

## Changes Made

### 1. Backend (`Backend/Knome.API`)
- **`Services/AuthService.cs`**:
  - In `GetCurrentUserAsync(int userId)`: Throws `ForbiddenException("This account has been suspended. Please contact HR.")` if the account is suspended or inactive.
  - In `GetCurrentUserByIdentifierAsync(string identifier)`: Throws `ForbiddenException("This account has been suspended. Please contact HR.")` if the account is suspended or inactive.

### 2. Frontend Shared Modals & API (`knomeUI/frontend`)
- **`src/utils/apiService.js`**:
  - Enhanced `adminApi.suspendUser` to calculate exact ISO `suspendedUntil` timestamps based on duration days, presets (`1d`, `3d`, `7d`, `14d`, `30d`, `indefinite`), custom date pickers, and permanent flag.
- **`src/components/modals/SuspendUserModal.jsx`**:
  - Pinned amber header (`shrink-0`) with `person_off` icon, title, subtitle, and close button.
  - Body container with `flex-1 min-h-0 overflow-y-auto space-y-4` ensuring zero modal clipping.
  - Target user card preview with fallback avatar, designation, department, and role badge.
  - User search & selection list if opened without pre-selected user.
  - 6 duration presets + custom reinstatement date picker.
  - Reason category dropdown + note textarea.
  - Pinned footer (`shrink-0`) with Cancel and "Confirm Suspension" action buttons.

### 3. Community Management (`src/pages/CommunityView.jsx`)
- Replaced inline suspension modal with `<SuspendUserModal />`.
- `handleConfirmSuspendMember` calls both `communitiesApi.decideMembership` (community level) and `adminApi.suspendUser` (platform-wide SQL Server level).

### 4. Admin Console & Governance (`src/pages/AdminConsole.jsx`)
- Integrated `<SuspendUserModal />` replacing legacy Modal 1.
- Updated Disciplinary Controls toolbar button to launch modal with searchable employee picker.
- Updated User Governance table "Suspend" action, Moderation Reports table "Suspend User" action, Moderation Report preview modal actions, and User Details modal action to launch `SuspendUserModal`.
- Enhanced `handleConfirmSuspend` and `handleToggleUserActive`.

### 5. Access Security & Auth Pipeline (`src/components/layout/AuthGuard.jsx` & `src/components/contexts/UserContext.jsx`)
- In `AuthGuard.jsx`, positioned suspension guard at top before unauthenticated checks so suspended accounts immediately render the full-screen "ACCESS DENIED" view.
- In `UserContext.jsx`, updated `authenticateUser`, `restoreSession`, `login`, and `switchUser` to detect suspension, wipe storage tokens, set suspended status, and block access.

## Verification
- Built backend via `dotnet build -nologo` — 0 errors.
- Built frontend via `npm run build` — 0 errors, generated `SuspendUserModal` bundle chunk.
- Synced build output to IIS `C:\inetpub\wwwroot\knome\`.
- Tested and verified live backend service and daemon operation.
