# Development Journal: 167 — Community Files Cleanup & Cross-Window Approval Synchronization

## Problem Statement

Two distinct issues were identified in the Knome Community module:
1. **Mock Files Listed in Newly Created Communities**: When a user created a new custom community (e.g., ID `202`, `jal`), navigating to the community repository under `Files & Media` automatically populated 4 mock seed files (`Project_Walkthrough_Demo.mp4`, `Database_Schema_Architecture.png`, `API_Integration_Guild_v2.docx`, `System_Architecture_Overview.pdf`) uploaded by Loveneesh Sharma, Vishendra Sharma, Sourabh Sahu, and Rishikesh Ugle, rather than initializing completely empty (`0 assets`).
2. **Approved Community Persisting in Pending Approval Status**: When an employee created a new community and submitted it for HR approval, the creation request was correctly approved by the Community Admin / HR Administrator in the database (`ApprovalStatus = 'Approved'`, `IsActive = 1`). However, the employee's browser view still showed `My Communities (6 Pending)` with yellow dashed cards reading `Under HR Review` / `Awaiting HR clearance`. The approval status in the creator's browser did not synchronize with the server database.

---

## Root Cause Analysis

1. **Mock Seed File Seeding**: In `CommunityView.jsx`, `loadData` previously populated `seedFiles` whenever `localFiles` was empty without restricting the seed data strictly to root demo communities `101` and `1`. Consequently, visiting any newly created community seeded these 4 sample files into `knome_community_files_{targetId}`.
2. **Stale Local Pending Approvals Storage**:
   - In `Communities.jsx` and `AdminConsole.jsx`, `loadPendingApprovals()` and `refreshPendingCommunityApprovals()` queried the backend `GET /api/communities/pending` which returned `[]` (0 pending).
   - However, the local storage fallback logic iterated over `knome_pending_community_approvals` (saved when the employee created the communities on that machine) and re-added every item not present in the backend array (`if (!combined.some(...)) combined.push(l)`).
   - Because the communities were already approved/rejected in SQL Server and no longer in the backend pending list, the condition was true for all entries, re-injecting all 6 stale pending records into state!
   - `myPendingCommunities` filtered `pendingApprovals` by creator ID and displayed them as awaiting HR clearance, despite them already being active in `communities` (`communitiesApi.getAll()`).
   - In multi-window / multi-browser setups (e.g. employee in window 1, admin in window 2), there was no focus listener or polling interval to pick up cross-window database mutations.

---

## Implementation Details

### 1. Pure Empty State for User-Created Community Files
- In `knomeUI/frontend/src/pages/CommunityView.jsx`:
  - Enforced that only root demo communities (`101` / `1`) can ever display the sample seed files.
  - For all other communities (`!isInitialDemoComm`), explicitly filtered out the 4 mock seed files (`Project_Walkthrough_Demo.mp4`, `Database_Schema_Architecture.png`, `API_Integration_Guild_v2.docx`, `System_Architecture_Overview.pdf`) from hydrated files and cache.
  - When empty, `filesList` is set to `[]` and `knome_community_files_{targetId}` is purged, rendering the clean "No Assets Found" empty state with "Upload First Document" button.
  - Also safeguarded `handleMembersUpdated` to prevent re-hydrating mock seed files on membership updates.

### 2. Server Authority & Local Storage Pruning for Pending Approvals
- In `knomeUI/frontend/src/pages/Communities.jsx`:
  - In `loadPendingApprovals`: Treated the backend API response (`apiPending`) as the single source of truth. Any numeric database ID not returned in `apiPending` has been resolved (approved or rejected) and is pruned from `knome_pending_community_approvals`.
  - In `loadCommunities`: Active approved database communities returned by `communitiesApi.getAll()` are matched by ID and name. Any matching records in `knome_pending_community_approvals` are automatically stripped.
  - In `userJoinedList`: Communities present in the active database list have their status upgraded from `pending_approval` to `joined`.
  - In `getStatus`: Added checks so that `isCurrentUserAdmin` or `String(currentUid) === String(createdByUserId)` evaluates to `'Approved'`.
  - In `myPendingCommunities`: Added an exclusion safeguard:
    ```javascript
    const myPendingCommunities = pendingApprovals.filter(p => 
        String(p.creatorUserId) === String(currentUser?.id) &&
        !communities.some(c => String(c.id) === String(p.id) || (c.name || '').toLowerCase().trim() === (p.name || '').toLowerCase().trim())
    );
    ```
    This guarantees that any active/approved community can never be rendered in the pending queue.

### 3. Cross-Window / Multi-Profile Synchronization
- In `Communities.jsx` and `AdminConsole.jsx`:
  - Added window `focus` event listener: switching to or clicking the employee's browser tab immediately refreshes pending approvals and active communities from the backend.
  - Added a 6-second polling interval in `Communities.jsx` so background approval decisions update live without requiring manual page reload.

### 4. Widget & Admin Console Alignment
- In `MyCommunitiesWidget.jsx`: Updated `isJoined` check to handle `c.createdByUserId || c.creatorUserId` and `c.isCurrentUserAdmin`.
- In `AdminConsole.jsx`: Updated `refreshPendingCommunityApprovals` to mirror the server authority pruning logic and added `focus` event listener.

---

## Verification
- Built frontend via `npm run build` (vite v8.1.4, exited code 0 in 1.47s).
- Synced build distribution to IIS webroot `C:\inetpub\wwwroot\knome` and `C:\inetpub\wwwroot\assets`.
- Verified clean empty state for newly created communities (`Files & Media` tab shows 0 assets, no mock files).
- Verified pending queue reconciliation: approved communities (`jal`, `test-d`, etc.) immediately move to active membership in "My Communities", with the "Pending" badge and "Under HR Review" cards cleared.
