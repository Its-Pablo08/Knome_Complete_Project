# Phase 96 — Community Approval Queue Integration in Admin Console & Catalog

## Objective
Fix the issue where employee-submitted community requests awaiting clearance (e.g. "jkkjk" with "Awaiting HR clearance") were not visible in the Community Approvals queue on the Admin page (`/admin-console`) and in the Communities catalog (`/communities`).

## Root Causes Identified
1. **Admin Console Lack of Community Approvals Queue**: The Admin Console (`/admin-console`) had tabs for Content Moderation, Media Approvals (Videos/Podcasts), AI Rules, and Community Moderation. However, Community Moderation only controlled policy levels (Strict/Standard/Relaxed) for 8 predefined channels and had no queue or UI to review employee submissions from `knome_pending_community_approvals`.
2. **Role Normalization Discrepancy**: Following Phase 95 terminology updates to `"Admin"`, role checking expressions (`isHRorAdmin`, `isSysAdmin`) only matched legacy strings (`'System Administrator'`, `'HR Administrator'`, `'Community Administrator'`), failing to recognize `'HR Admin'`, `'Community Admin'`, and `'System Admin'`. This hid the `"Community Approvals"` tab on the Communities catalog page.
3. **Admin Console Navigation Gating**: In `Sidebar.jsx`, `/admin-console` was strictly restricted to `isSysAdmin`, preventing HR Admins from accessing the central Admin Console.

## Changes Implemented

### 1. Admin Console Approvals Integration ([AdminConsole.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/pages/AdminConsole.jsx))
- **Role Authorization**: Expanded `isAuthorized` to recognize `'HR Admin'`, `'Community Admin'`, `'System Admin'`, and `'Admin'` case-insensitively.
- **State & Event Bus**: Added `pendingCommunityApprovals` backed by `localStorage.getItem('knome_pending_community_approvals')` with listeners for `storage`, `community-approval-requested`, and `community-created`.
- **Domain 1 Header Counter**: Updated pending count badge in the Domain 1 header to aggregate reports, pending media, and pending community creation requests.
- **Tier 2 Sub-Tabs**: Added `Community Approvals ({pendingCommunityApprovals.length})` tab under Domain 1 with an amber pulsing badge.
- **Community Moderation Notice Banner**: Inserted a prominent alert banner at the top of `activeTab === 'communities'` indicating pending community creations with a 1-click transition button.
- **Community Approvals Queue View (`activeTab === 'community_approvals'`)**:
  - Contextual filter cards (All, Public, Private, Org).
  - Search input (by community name, description, category, creator).
  - Community cards with banner, thumbnail, category, date, creator info (avatar, name, designation, department, employee ID), pre-invited count, and description.
  - Full approval (`handleApproveCommunity`) and rejection (`handleRejectCommunity`) workflows dispatching celebratory notifications, creator admin membership, and live state syncing.

### 2. Communities Catalog Multi-Role Compatibility ([Communities.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/pages/Communities.jsx))
- Updated `isHRorAdmin` and `isSysAdmin` to evaluate all Admin role variants case-insensitively, ensuring the `"Community Approvals"` tab is accessible to all administrative users.

### 3. Create Community Modal Authorization ([CreateCommunityModal.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/components/modals/CreateCommunityModal.jsx))
- Updated `isHRorAdmin` to evaluate all Admin role variants case-insensitively, ensuring Admin-created communities are immediately approved while employee submissions route to `knome_pending_community_approvals`.

### 4. Navigation Bar Access ([Sidebar.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/components/layout/Sidebar.jsx))
- Enabled Admin Console (`/admin-console`) in the sidebar for both System Admins and HR Admins (`isSysAdmin || isHrOrSysAdmin`).

## Verification
- Ran Vite build: `npm run build` in `knomeUI/frontend` → exited with code 0 (100% successful with zero syntax errors, 527 modules transformed).
- Synced build output to IIS: `C:\inetpub\wwwroot\knome`.
