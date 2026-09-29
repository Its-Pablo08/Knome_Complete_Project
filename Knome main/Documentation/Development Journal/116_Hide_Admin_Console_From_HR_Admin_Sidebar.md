# Dev Journal: 116 — Hide Admin Console from HR Admin Sidebar Navigation

**Date:** September 21, 2026  
**Status:** Completed  
**Author:** Antigravity  

---

## 1. Problem Statement & User Intent
In the previous implementation, the central **Admin Console** (`/admin-console`) navigation link was displayed in the left navigation sidebar for both System Administrators and HR Administrators via `if (isSysAdmin || isHrOrSysAdmin)`.

The user reported via visual screenshot and directive:
> *"not show admin console"*

Showing the Home dashboard where `Loveneesh Sharma` is logged in under the `HR Admin` role, and the left sidebar displayed both **Admin Console** and **HR Analytics**.

The user requested that **Admin Console** must not be displayed for HR Admins. The navigation entry should be reserved strictly for System Administrators, while HR Administrators retain direct access to their dedicated **HR Analytics** portal.

---

## 2. Analysis & Technical Root Cause
In `knomeUI/frontend/src/components/layout/Sidebar.jsx`:
```javascript
const isSysAdmin = ['SYSADM', 'SYSTEM ADMIN', 'SYSTEM ADMINISTRATOR'].includes(...) ...
const isHrOrSysAdmin = ['SYSADM', 'HRADM', 'SYSTEM ADMIN', 'HR ADMIN', 'ADMIN'].includes(...) ...

if (isSysAdmin || isHrOrSysAdmin) {
    navItems.push({ to: '/admin-console', icon: 'admin_panel_settings', label: 'Admin Console', color: '#f43f5e' });
}
if (isHrOrSysAdmin) {
    navItems.push({ to: '/hr-analytics', icon: 'bar_chart', label: 'HR Analytics', color: '#ef4444' });
}
```

Because `isSysAdmin || isHrOrSysAdmin` evaluated to `true` for users holding the `HR Admin` / `HRADM` role, the **Admin Console** navigation item was appended to `navItems` for HR Administrators as well.

---

## 3. Implementation Details

### File Modified
- `knomeUI/frontend/src/components/layout/Sidebar.jsx`

### Code Changes
Updated lines 70–72 from:
```javascript
if (isSysAdmin || isHrOrSysAdmin) {
    navItems.push({ to: '/admin-console', icon: 'admin_panel_settings', label: 'Admin Console', color: '#f43f5e' });
}
```
to:
```javascript
if (isSysAdmin) {
    navItems.push({ to: '/admin-console', icon: 'admin_panel_settings', label: 'Admin Console', color: '#f43f5e' });
}
```

### Resulting Role Matrix for Sidebar Navigation
- **System Administrator** (`SYSADM`): Displays both **Admin Console** and **HR Analytics**.
- **HR Administrator** (`HRADM`): Displays only **HR Analytics**; **Admin Console** is cleanly hidden.
- **Employee** (`EMP`): Neither is displayed.

---

## 4. Verification & Deployment

1. **Frontend Production Build**:
   ```powershell
   cd "d:\Knome main\knomeUI\frontend"
   npm run build
   ```
   *Result*: Built clean in 2.57s with 0 errors.

2. **IIS Webroot Synchronization**:
   ```powershell
   robocopy "d:\Knome main\knomeUI\frontend\dist" "C:\inetpub\wwwroot\knome" /E /IS /IT
   ```
   *Result*: Deployed successfully with exit code 1.

3. **Backend API Build**:
   ```powershell
   cd "d:\Knome main\Backend\Knome.API"
   dotnet build -nologo
   ```
   *Result*: Build succeeded with 0 errors.
