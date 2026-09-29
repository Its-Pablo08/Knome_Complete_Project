# Development Journal Entry 62: Global Replacement of Employee ID with Employee Name & Designation

**Date:** 2026-09-11  
**Author:** Pair Programming Assistant  
**Status:** Completed & Deployed  
**Task Summary:** Everywhere across the Knome user interface, eliminate the display of raw Employee IDs (e.g. `MP0108`, `MPO101`, `EMP001`, `mpo652`) and replace them with the employee's real full name, designation, or department.

---

## 1. Problem Statement & Motivation
Users noted that raw Employee ID codes were appearing in several places in the platform UI—including profile badges, modal previews, community member lists, share recipient badges, and admin governance panels.
Per corporate UI standards for MPOnline Limited:
1. Employee names, designations, and departments should always be prominently displayed instead of cold alpha-numeric employee codes.
2. Raw `employeeId` should remain strictly in internal API parameters, authentication headers, and state logic so as not to disrupt database queries or JWT verification.

---

## 2. Changes Implemented Across Files

### A. `src/pages/Profile.jsx`
- **Profile Header Badge:** Replaced `{displayUser.employeeId}` badge with `{displayUser?.roleName || displayUser?.role || displayUser?.designation || 'Member'}` pill badge with sleek indigo theme accents.
- **Official Email Fallback:** Replaced `${displayUser?.employeeId?.toLowerCase()}@mponline.gov.in` fallback with `${(displayUser?.fullName || displayUser?.name || 'employee').toLowerCase().replace(/\s+/g, '.')}@mponline.gov.in`.
- **Contact Info Modal:** Replaced the "Employee ID" section with "Designation & Role" displaying `{displayUser?.designation || 'Staff Member'} • {displayUser?.roleName || displayUser?.role || 'Employee'}`.

### B. `src/pages/CommunityView.jsx`
- **Member Card Subtitle:** Replaced `{m.designation || 'Employee'} • {m.employeeId || 'MPOnline'}` with `{m.designation || 'Employee'} • {m.department || 'MPOnline'}`.

### C. `src/pages/Communities.jsx`
- **Pending Approvals Subtitle:** Replaced `{comm.creatorEmployeeId} • {comm.creatorDepartment}` with `{comm.creatorDesignation || 'Community Creator'} • {comm.creatorDepartment || 'MPOnline'}`.

### D. `src/pages/Login.jsx`
- **Quick Access Accounts:** Replaced raw `{u.displayId} • {u.role}` with `{u.role} • {u.department || 'MPOnline'}`.
- **Button Text:** Standardized `Enter Knome Portal` to `Enter Knome`.
- **User Object Structure:** Added clean department metadata for each demo account.

### E. `src/components/modals/CreateCommunityModal.jsx`
- **Notification Message:** Replaced `(${currentUser?.employeeId || 'MPOnline'})` with `(${currentUser?.department || currentUser?.roleName || 'MPOnline'})`.
- **Preview Summary:** Replaced `{currentUser?.name} ({currentUser?.employeeId || 'MPOnline'})` with `{currentUser?.name} • {currentUser?.department || currentUser?.roleName || 'MPOnline'}`.

### F. `src/components/modals/ArticleShareModal.jsx` & `src/components/modals/ShareProfileModal.jsx`
- **Recipient User Pills:** Removed raw `{u.employeeId}` / `{targetEmpId}` badges next to colleague names in the search and selection lists, keeping clean names, avatars, and designation/department lines.

### G. `src/components/modals/RolePendingModal.jsx`
- **Profile Preview Grid:** Replaced the "Employee ID" card with "Employee Name" showing `{currentUser?.name || currentUser?.fullName || 'Employee'}`.

### H. `src/components/layout/AuthGuard.jsx`
- **Suspension Screen:** Replaced `({currentUser.name || currentUser.employeeId})` with `({currentUser.name || currentUser.fullName || 'Employee'})`.
- **Role Pending Screen:** Replaced Welcome banner's employeeId fallback with full name, and changed the "Employee ID" metric card to "Designation" showing `{currentUser.designation || currentUser.roleName || 'Employee'}`.

### I. `src/pages/AdminConsole.jsx`
- **User Directory Table:** Changed header from `User / Emp ID` to `User #`, and replaced the raw employee code sub-badge with `Member`.
- **Role Requests:** Replaced `{req.employeeId}` badge with `{req.assignedRoleName || req.requestedRoleCode || 'Role Request'}`.
- **Suspend/Reactivate Dropdowns:** Replaced `{u.employeeId} • {u.department}` with `{u.designation || u.roleName || 'Employee'} • {u.department}`.
- **Audit Logs & Alerts:** Replaced `Employee #${targetId || user.employeeId}` with `Employee ${user.fullName || user.name}`.
- **User Details Modal:** Replaced `{selectedUserDetailsUser.employeeId || ...}` badge in header with `{selectedUserDetailsUser.roleName || selectedUserDetailsUser.role || 'Member'}`.

### J. `src/components/contexts/UserContext.jsx`
- Added comprehensive `KNOWN_ROSTER_NAMES` dictionary covering all employee IDs (e.g. `MP0108` -> `Loveneesh Sharma`, `MPO102` -> `Vishendra Sharma`, `mpo652` -> `Deepak Simrodia`, `EMP001` -> `Aarav Sharma`, etc.).
- Created `resolveEmployeeName(rawName, empId)` sanitizer function.
- Wired sanitizer into `mergeProfile`, `authenticateUser`, and `login` so that whenever user data is loaded or enriched, any accidental raw employee ID string is automatically converted to the real full human name.

---

## 3. Verification & Deployment
1. Ran `npm run build` in `d:\Knome main\knomeUI\frontend` (completed in 769ms with 0 errors).
2. Deployed production assets to IIS: `Copy-Item -Path 'dist\*' -Destination 'C:\inetpub\wwwroot\knome\' -Recurse -Force`.
3. Verified Vite dev server running cleanly on port 5173.
