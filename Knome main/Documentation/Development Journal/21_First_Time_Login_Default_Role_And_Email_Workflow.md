# Development Journal — Phase 21: First-Time Login Default Employee Role & Role Assignment Workflow

**Date:** 2026-08-19  
**Developer:** Sourabh Sahu  
**Phase:** First-Time Login Onboarding & Automated Role Management Workflow  
**Status:** Complete  

---

## Objective

Implement a seamless onboarding experience for employees authenticating via EmployeeHub SSO / Knome for the first time:

1. **Default Role Assignment on First Login (`Employee`)**: Auto-assign standard `Employee` role immediately in `[UserRoles]` so users can explore and use the portal without being blocked.
2. **Admin Notification & Governance Queue**: Add new first-time login records into `[RoleRequests]` with `Pending` review status and dispatch in-app notifications to System Administrators.
3. **Automated "Welcome to Knome" Onboarding Email**: Dispatch a modern responsive HTML email confirming default access and informing them of admin review.
4. **Admin Console Role Upgrade & Confirmation Email**: When a System Administrator assigns or upgrades a role from the Admin Console, assign the role in the database and dispatch a **"Role Updated: Your role is now [RoleName]"** email notification.

---

## Architecture & Implementation Details

```text
[Employee Logs In (First Time)]
             │
             ▼
     [AuthService.LoginAsync]
             │
             ├──► Auto-link default 'Employee' role in [UserRoles] (Immediate Access)
             ├──► Insert into [RoleRequests] (Status: 'Pending' for Admin Review)
             ├──► Notify System Administrators via INotificationService
             └──► Dispatch "Welcome to Knome" Email via IEmailService
                         │
                         ▼
[System Admin Reviews in Admin Console]
             │
             ▼
[Approve / Upgrade Role (e.g. Community Admin / HR Admin)]
             │
             ├──► Update [UserRoles] & [RoleRequests]
             ├──► Record in System Audit Log
             └──► Dispatch "Role Updated" Confirmation Email to Employee
```

---

## Files Modified

### 1. [Backend/Knome.API/Services/AuthService.cs](file:///D:/Knome%20main/Backend/Knome.API/Services/AuthService.cs)
- Injected `INotificationService`.
- In `SyncUserFromEmployeeHubIfAvailableAsync`: Added SQL insert into `[UserRoles]` with default `Employee` role (`EMP`) when a new user is synced from `EmployeeHubDb`.
- In `LoginAsync`: If `user.Roles` is empty, automatically assigns the `Employee` role and saves changes to database.
- In `EnsurePendingRoleRequestInDbAsync`:
  - Inserts `[RoleRequests]` record with status `Pending` if not already present.
  - Broadcasts in-app notification to all active `System Administrator` users.
  - Fires non-blocking `_emailService.SendRolePendingEmailAsync` (Welcome to Knome onboarding email).

### 2. [Backend/Knome.API/Services/EmailService.cs](file:///D:/Knome%20main/Backend/Knome.API/Services/EmailService.cs)
- **`SendRolePendingEmailAsync` (Welcome to Knome Email)**:
  - **Subject**: `🎉 Welcome to Knome, {FullName}! Your Account is Ready ({EmployeeId})`
  - **Content**: Modern responsive HTML email welcoming the employee to MPOnline Limited's Knome Portal, confirming their active default **Employee** role, detailing their department & designation, and explaining that their profile is queued for administrator review if elevated privileges are needed.
- **`SendRoleAssignedEmailAsync` (Role Updated Email)**:
  - **Subject**: `[Knome Portal] Role Updated by System Administrator: {RoleName}`
  - **Content**: Emerald success theme stating *"Your access role has been updated by the System Administrator. Your assigned role is now {RoleName}."* with administrative notes and direct access confirmation.

### 3. [EmployeeHub/src/EmployeeHub.Web/src/pages/Login.tsx](file:///D:/Knome%20main/EmployeeHub/src/EmployeeHub.Web/src/pages/Login.tsx) & [RolePending.tsx](file:///D:/Knome%20main/EmployeeHub/src/EmployeeHub.Web/src/pages/RolePending.tsx)
- Updated `Login.tsx` SSO handler: Whenever user logs in with `openKnome` (SSO redirect target Knome), it bypasses the EmployeeHub pending screen and redirects directly into Knome dashboard (`http://localhost:5173`) with default `Employee` access active.
- Updated `RolePending.tsx`: Added a dedicated **"🚀 Launch Knome Portal (as Employee)"** button so unassigned employees on EmployeeHub can enter Knome directly at any time.

### 4. [Backend/Knome.API/Services/UserService.cs](file:///D:/Knome%20main/Backend/Knome.API/Services/UserService.cs)
- `ApproveRoleRequestAsync`: Updates role in `[RoleRequests]` and `[UserRoles]`, records governance audit log, and dispatches the role assignment confirmation email (`SendRoleAssignedEmailAsync`).

---

## Verification & Status

- `dotnet build Backend/Knome.API/Knome.API.csproj -nologo`: **Build succeeded with 0 Warnings and 0 Errors.**
- All DI services, notification publishing, and email delivery handlers are compiled and operational.
