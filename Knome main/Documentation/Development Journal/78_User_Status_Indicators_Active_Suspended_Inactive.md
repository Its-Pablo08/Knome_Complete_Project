# Phase 78 — User Status Indicators (Active, Suspended, Inactive)

## Context & Motivation
The platform required a clear, standardized user account status display across user profile widgets, navigation bars, profile pages, and administrative console tables. Users can be in one of three states:
1. **Active**: The user is enabled and not under disciplinary suspension.
2. **Suspended**: The user is under administrative or compliance policy suspension (`isSuspended == true` or `isPermanentlySuspended == true` or `suspendedUntil > UtcNow`).
3. **Inactive**: The user account is deactivated or marked inactive (`isActive == false`).

## Changes Applied

### 1. User Context & Status Helpers (`knomeUI/frontend/src/components/contexts/UserContext.jsx`)
- Added `resolveUserStatus(user)`: Evaluates user object attributes (`status`, `isSuspended`, `isPermanentlySuspended`, `suspendedUntil`, `isActive`) and resolves into `'Active'`, `'Suspended'`, or `'Inactive'`.
- Added `getUserStatusConfig(statusOrUser)`: Provides design-system-aligned tokens:
  - **Active**: Emerald styling (`bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-950/60 dark:text-emerald-400 dark:border-emerald-800/40`), green dot (`bg-emerald-500`), label `"Active"`.
  - **Suspended**: Rose styling (`bg-rose-50 text-rose-700 border-rose-200 dark:bg-rose-950/60 dark:text-rose-400 dark:border-rose-800/40`), red dot (`bg-rose-500`), label `"Suspended"`.
  - **Inactive**: Slate styling (`bg-slate-100 text-slate-600 border-slate-200 dark:bg-slate-800/80 dark:text-slate-400 dark:border-slate-700/50`), gray dot (`bg-slate-400 dark:bg-slate-500`), label `"Inactive"`.
- Updated `mergeProfile` and `mappedApiUsers` to consistently compute `derivedStatus`, `isActive`, and `isSuspended`.
- Added `updateUserStatus(userId, newStatus)` helper to `UserProvider` context.

### 2. Sidebar Profile Card (`knomeUI/frontend/src/components/layout/Sidebar.jsx`)
- Rendered status badge pill (`statusConfig.badgeClass` + mini dot) directly beside the role tag in the user profile card header.
- Made the avatar status indicator dot reactive (`statusConfig.dotClass`) with a tooltip indicating current account status.

### 3. Navigation Bar (`knomeUI/frontend/src/components/layout/Navbar.jsx`)
- Added status indicator dot to the top-right avatar menu trigger.
- Added status pill badge inside the user dropdown header next to user name and role.

### 4. User Profile Page (`knomeUI/frontend/src/pages/Profile.jsx`)
- Rendered status pill badge next to the user's role and designation tag in the profile header banner.

### 5. Admin Console (`knomeUI/frontend/src/pages/AdminConsole.jsx`)
- Upgraded the User Governance table status column to display three distinct states (`Active`, `Suspended`, `Inactive`) using the unified tokens.
- Updated User Details modal with the reactive status dot and status pill.
- Enhanced table search filter to support searching and filtering by `"active"`, `"suspended"`, and `"inactive"`.

## Verification & Deployment
- Ran production build `npm run build` in `knomeUI/frontend` (built cleanly in 937ms with 0 errors).
- Synchronized frontend distribution files to IIS root (`C:\inetpub\wwwroot\knome\`).
