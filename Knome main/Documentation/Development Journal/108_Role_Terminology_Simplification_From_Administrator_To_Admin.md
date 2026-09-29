# Dev Journal 108: Role Terminology Simplification from 'Administrator' to 'Admin'

## Context & Objectives
In the Admin Console "Manage User Roles" modal and across user governance interfaces, role labels displayed inconsistent naming conventions:
- "Community Admin (Moderation)" used the concise suffix `Admin`.
- "HR Administrator (HR Governance)" and "System Administrator (Full Platform Control)" used the verbose suffix `Administrator`.
- Additionally, because role lists were normalized to `'HR Admin'` and `'System Admin'`, the checkbox state matching in the modal caused existing assigned roles to not highlight as checked when opened.
- The user requested changing the word "Administrator" to "Admin" throughout this modal and related governance surfaces.

## Changes Implemented

1. **Manage User Roles Modal (`AdminConsole.jsx`)**:
   - Replaced `HR Administrator` with `HR Admin` for both `name` and `title` (`HR Admin (HR Governance)`).
   - Replaced `System Administrator` with `System Admin` for both `name` and `title` (`System Admin (Full Platform Control)`).
   - Enhanced `isSelected` calculation and `onClick` toggle handler to normalize and support both legacy and new role representations, ensuring checkmarks accurately reflect assigned roles.
   - Updated Role Requests dropdown options to `<option value="HR Admin">HR Admin</option>` and `<option value="System Admin">System Admin</option>`.
   - Updated rejection audit comments and restricted portal banners to use `System Admin` and `HR Admin`.
   - Updated user details modal role badge display to dynamically use `getUserAssignedRole` to cleanly display "HR Admin" or "System Admin".

2. **Backend Interoperability (`UserRepository.cs` & `apiService.js`)**:
   - Enhanced `UserRepository.UpdateUserRolesAsync` to recognize `System Admin` and `HR Admin` aliases and map them to database `RoleName` / `RoleCode` without triggering `BadRequestException`.
   - Enhanced `apiService.js` (`changeUserRoles` and `approveRoleRequest`) to map `HR Admin` and `System Admin` cleanly to backend database expectations.

3. **Global User State (`UserContext.jsx`)**:
   - Updated `INITIAL_USERS` seed roster to use `System Admin`, `HR Admin`, and `Community Admin` as standard display role names.
   - Updated `mergeProfile` to normalize incoming roles to concise `Admin` naming conventions.

4. **Community and FAQ Labels (`CommunityView.jsx`, `Communities.jsx`, `RoleFaqModal.jsx`)**:
   - Replaced user-facing text referencing "Community Administrator", "HR Administrator", and "System Administrator" with "Community Admin", "HR Admin", and "System Admin".

## Verification
- Backend build: `dotnet build -nologo` completed with 0 errors.
- Frontend build: `npm run build` completed with 0 errors in 1.56s.
