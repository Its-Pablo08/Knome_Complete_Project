# Phase 23 — Complete First-Time Login, Default Role Assignment & Email Notification Workflow

**Date:** 2026-08-19  
**Phase:** 23  
**Status:** ✅ Completed & Verified

---

## Objective

When any EmployeeHub employee logs into Knome for the first time via SSO, the following must happen automatically:

1. **Default `Employee` role is immediately assigned** — the user is not blocked and gets instant access to Knome.
2. **A "Welcome to Knome" email is dispatched** to the user in professional English.
3. **A pending Role Request is created** in the Admin Console for System Administrator review.
4. **In-app notifications** are sent to all active System Administrators.
5. **When an administrator assigns an elevated role** (e.g. Community Admin, HR Admin), the user receives a "Role Updated" email from the System Administrator in professional English.

---

## Implementation Details

### Backend — `AuthService.cs`

**`SyncUserFromEmployeeHubIfAvailableAsync`** (lines 240–300):  
Cross-database SQL that queries `[EmployeeHubDb].[dbo].[Employees]` and provisions the user into:
- `[Users]` — inserts full profile (FullName, Email, Department, Designation, Location).
- `[UserCredentials]` — syncs the password hash from EmployeeHubDb or falls back to a known default.
- `[UserRoles]` — immediately assigns the default `Employee` (RoleCode `EMP`) role.

**`LoginAsync`** (lines 55–116):  
After sync, if user has no roles, assigns `Employee` role directly via EF navigation property.  
Calls `EnsurePendingRoleRequestInDbAsync` which:
- Inserts a `[RoleRequests]` record with `Status = 'Pending'`, `RequestedRoleCode = 'EMP'` (only on first login, idempotent).
- Sends in-app notifications to all active System Administrators via `INotificationService.PublishAsync`.
- Dispatches Welcome Email (fire-and-forget) via `IEmailService.SendRolePendingEmailAsync`.

---

### Backend — `EmailService.cs`

**`SendRolePendingEmailAsync`** — Welcome to Knome Email:  
- **Subject**: `🎉 Welcome to Knome, {FullName}! Your Account is Ready ({EmployeeId})`
- **Header**: Vibrant Indigo Gradient — "Welcome to Knome!"
- **Body (Professional English)**:
  > *"Your account has been initialized via EmployeeHub Single Sign-On (SSO). You have been assigned the default Employee role so you can start using Knome right away! You can explore the enterprise feed, publish posts, read articles, stream videos, listen to podcasts, and earn Karma points."*
- **Info table**: Employee ID, Department, Designation, Admin Status (Notified for Role Review).
- **Footer**: © 2026 MPOnline Limited.

**`SendRoleAssignedEmailAsync`** — Role Updated Email:  
- **Subject**: `[Knome Portal] Role Updated by System Administrator: {RoleName}`
- **Header**: Emerald/Teal Gradient — "Access Role Updated"
- **Body (Professional English)**:
  > *"Your access role has been updated by the System Administrator. Your assigned role is now {RoleName}. You now have full access with your updated permissions on the Knome platform."*
- **Role Highlight Card**: Shows new role name prominently.
- **Info table**: Employee ID, Department, Approved By (System Administrator), Admin Note (if provided).

---

### Backend — `UserService.cs`

**`ApproveRoleRequestAsync`** (lines 760–937):  
When System Admin approves a Role Request from Admin Console:
- Updates `[RoleRequests]` → `Status = 'Approved'`, `AssignedRoleName`, `ProcessedAt`.
- Updates `[EmployeeHubDb].[dbo].[RoleRequests]` (cross-DB sync).
- Assigns role in `[UserRoles]` via EF navigation.
- Inserts into `[AuditLog]`.
- Dispatches `SendRoleAssignedEmailAsync` (fire-and-forget).

**`ChangeRolesAsync`** (lines 229–306):  
When admin directly changes a user's roles from User Detail panel:
- Updates `[UserRoles]` via repository.
- Updates `[RoleRequests]` to `Approved`.
- Dispatches `SendRoleAssignedEmailAsync` (fire-and-forget).

---

## Live End-to-End Verification (`MPO119 — Rishabh Pandey`)

| Step | Action | Expected | Result |
|------|--------|----------|--------|
| 1 | POST `/api/auth/login` (`MPO119`, `Password@123`) | User auto-synced from EmployeeHubDb, default `Employee` role assigned | ✅ `Login Success: True`, `Roles: Employee` |
| 2 | DB check `[Users]` + `[UserRoles]` | UserId `1053`, role `Employee` | ✅ `UserId: 1053 | Role: Employee` |
| 3 | DB check `[RoleRequests]` | `RequestId: 1025`, `Status: Pending`, `RoleCode: EMP` | ✅ Confirmed |
| 4 | POST `/api/users/role-requests/1025/approve` (as MPO101) | Role assigned to `Community Admin`, email dispatched | ✅ `Approve Success: True` |
| 5 | Welcome Email | Subject: `🎉 Welcome to Knome, Rishabh Pandey! Your Account is Ready (MPO119)` | ✅ `[15:44:35] Email sent to rishabhpandey54321@gmail.com` |
| 6 | Role Updated Email | Subject: `[Knome Portal] Role Updated by System Administrator: Community Admin` | ✅ `[15:44:39] Email sent to rishabhpandey54321@gmail.com` |

---

## Files Modified

| File | Change |
|------|--------|
| `Backend/Knome.API/Services/AuthService.cs` | `SyncUserFromEmployeeHubIfAvailableAsync` + `EnsurePendingRoleRequestInDbAsync` — auto-sync, default role, pending request, admin notification, welcome email |
| `Backend/Knome.API/Services/UserService.cs` | `ApproveRoleRequestAsync` + `ChangeRolesAsync` — role assigned email dispatch |
| `Backend/Knome.API/Services/EmailService.cs` | `SendRolePendingEmailAsync` (Welcome email) + `SendRoleAssignedEmailAsync` (Role Updated email) — full professional English HTML templates |
| `Backend/Knome.API/Controllers/UserController.cs` | `POST /role-requests/{id}/approve` route |
| `EmployeeHub/src/EmployeeHub.Web/src/pages/Login.tsx` | SSO bypass for `openKnome` flag — no `RolePending` block |
| `EmployeeHub/src/EmployeeHub.Web/src/pages/RolePending.tsx` | "Launch Knome Portal (as Employee)" CTA button |

---

## Build Status

- **Backend**: `dotnet build` → ✅ 0 Warnings, 0 Errors
- **Frontend**: `npm run build` → ✅ 515 modules, 0 Errors
- **Backend API**: Running on `http://localhost:5095`
- **Frontend**: Running on `http://localhost:5173`
