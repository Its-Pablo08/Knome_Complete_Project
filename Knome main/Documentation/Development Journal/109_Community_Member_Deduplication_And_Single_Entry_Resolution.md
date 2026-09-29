# Dev Journal 109: Community Member Deduplication & Single Unique Entry Resolution

## Context & Objectives
In the Community View **"Community Members & Roles"** tab (e.g. for Default/Org communities like "Culture & HR Hub"), an employee—specifically **Deepak Simrodia (`mpo652`)**—appeared twice in consecutive rows:
- **Row 4**: `Deepak ... | mpo652 | Member | Employee • University`
- **Row 5**: `Deepak ... | mpo652 | Member | Software Developer • University`

The user requested: *"yaha deepak ka naam 2 baar kyu aa raha hai yeh 1 baar hi aana chahiye"* (Why does Deepak's name appear twice here? It should appear only once).

## Root Cause Analysis
1. **Auto-Enrollment & Fallback Sync Discrepancy**:
   - In Default (Org) communities or community creation flows, candidate users are enrolled with their profile designation (e.g., `Software Developer` from `INITIAL_USERS` / API).
   - In `CommunityView.jsx`, `loadData()` verified if `currentUser` was present in `resolvedMembers` using:
     ```javascript
     currentUser && !resolvedMembers.some(m => String(m.userId || m.id) === String(currentUser.id))
     ```
   - This check had two flaws:
     1. It checked strictly by numeric `userId` or `id` and did not check `employeeId` (case-insensitively) or `fullName`.
     2. When adding `currentUser`, it assigned `designation: currentUser.roleName || 'Member'` (which defaults to `"Employee"` for non-admins).
   - As a result, a second entry for Deepak with designation `"Employee"` was appended to `resolvedMembers` alongside the existing `"Software Developer"` entry.
2. **Persistent Cache Accumulation**:
   - `resolvedMembers` was saved to `localStorage.setItem('knome_community_members_[id]', JSON.stringify(resolvedMembers))`, persisting both duplicate entries across browser reloads.
3. **No UI-Level Deduplication Filter**:
   - `filteredMembers` previously mapped `membersList` straight into the DOM list without deduplicating by employee, allowing duplicate rows to be rendered.

## Changes Implemented

1. **Global Deduplication Utility (`UserContext.jsx`)**:
   - Implemented and exported `deduplicateMembers(members, contextUsers)`:
     - Normalizes identity keys: `employeeId` / `displayEmpId` (uppercase), `userId` / `id`, and normalized `fullName` / `displayName`.
     - Intelligently merges duplicates when detected:
       - **Role Privilege**: Preserves `Admin` if either entry has Admin status.
       - **Designation**: Retains the specific technical/job designation (e.g. `'Software Developer'`) over generic placeholder designations (`'Employee'`, `'Member'`).
       - **Name**: Prefers the full human name (`Deepak Simrodia`) over generic placeholders or raw IDs.
       - **Avatar & Status**: Preserves approved status and valid avatar URLs.
     - Preserves original list order and updates the record in-place.

2. **Community View Member Loading & Rendering (`CommunityView.jsx`)**:
   - **`normalizeMemberData`**:
     - Enhanced designation resolution: if `m.designation` is generic (`'Employee'` or `'Member'`), it falls back to `matched?.designation` from the live roster/roster database (`'Software Developer'`).
   - **`loadData()`**:
     - Deduplicates `rawMembers` / `localMembersApi` on load using `deduplicateMembers`.
     - Corrected `isMemberInList` check to inspect `userId`, `id`, `employeeId` (case-insensitively), and `name` (case-insensitively).
     - Guarded `currentUser` addition to only push if `!isMemberInList`.
     - Runs `deduplicateMembers` on `resolvedMembers` before `setMembersList` and saves the cleaned array to `localStorage` to heal existing stored duplicates automatically.
     - Applied the exact same deduplication and auto-heal logic to the offline fallback path.
   - **`filteredMembers` useMemo**:
     - Passes the normalized members list through `deduplicateMembers` prior to filtering and sorting. This guarantees that **no employee can ever appear more than once in the rendered DOM**, regardless of cache state.
   - **Community Admin Name & Event Handlers**:
     - `communityAdminDisplay` deduplicates admin members before generating the comma-separated admin contact string.
     - `handleMembersUpdated`, `handleApprove`, and `handleReinstate` invoke `deduplicateMembers` before state update and storage persistence.
   - **Member Card Header**:
     - Added `title={m.displayName}` to the member name `h4` tag for full-name hover visibility.

3. **Community Roster Creation & Management (`Communities.jsx`, `CreateCommunityModal.jsx`, `AdminConsole.jsx`)**:
   - In `Communities.jsx`, updated card member counts to use `deduplicateMembers(localMembers).length`.
   - In `Communities.jsx`, `CreateCommunityModal.jsx`, and `AdminConsole.jsx`, deduplicated `memberList` prior to `localStorage.setItem('knome_community_members_[id]')`.

## Verification
- **Build**: `npm run build` completed with 0 errors in 1.28s.
- **IIS Deployment**: Deployed production bundle to IIS webroot `C:\inetpub\wwwroot\knome` via `robocopy`.
- **Deduplication Verification**:
  - `deduplicateMembers` correctly merges multiple entries for Deepak Simrodia (`mpo652`), retaining designation `Software Developer` and eliminating duplicate cards.
