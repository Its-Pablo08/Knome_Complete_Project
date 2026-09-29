# Development Journal Entry 130: Remove User Directory and Role Requests Buttons from Admin Console

**Date:** 2026-09-22  
**Feature/Module:** Admin Console (`AdminConsole.jsx`)  
**Type:** UI/UX Simplification / Sub-module Navigation Button Removal  

---

## 1. Problem Description & Background
In the Admin Console Domain 2 (`User & Access Governance`), the Tier 2 sub-module bar displayed two navigation buttons:
1. `User Directory (count)`
2. `Role Requests (count)`

The user requested to remove both of these buttons from the navigation bar.

---

## 2. Changes Made
### Frontend:
- **`knomeUI/frontend/src/pages/AdminConsole.jsx`**:
  - Removed both `User Directory` and `Role Requests` sub-tab buttons under `activeDomain === 'governance'`.
  - Added a conditional guard `{activeDomain !== 'governance' && ( ... )}` around the Tier 2 sub-tab navigation wrapper so an empty strip is not rendered when viewing Domain 2.
  - When Domain 2 (`User & Access Governance`) is selected, `activeTab` defaults to `'users'`, and the full User Directory table and search filters render directly beneath the Domain cards.

---

## 3. Verification & Deployment
1. Built frontend with `npm run build` in `knomeUI/frontend`:
   - Built cleanly with 0 errors.
2. Synchronized production bundle to IIS root at `C:\inetpub\wwwroot\knome` using `robocopy`:
   - 43 files updated successfully.
