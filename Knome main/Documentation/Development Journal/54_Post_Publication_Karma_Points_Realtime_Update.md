# Phase 54 — Real-Time Karma Points Update on Post Publication

**Date:** 2026-09-10  
**Focus:** Real-Time Gamification Synchronization (Karma Points & Ledger on Post Publishing)  
**Status:** Completed & Live Verified  

---

## 1. Background & Problem Statement
When employees published posts in Knome (via `CreatePostModal.jsx`, `CommunityView.jsx`, or manually releasing scheduled posts in `PostCard.jsx`), their Karma points counter on the UI did not visibly update.

### Root Causes Identified:
1. **Daily Cap Ceiling in Testing**: `KarmaCaps.CreatePostDailyCap` was previously set to `10` points (5 posts * 2 points). Active testers and employees had already published 5 posts today, which hit the cap. `KarmaService.cs` in the backend and `awardRuleKarma` in the frontend local tracker returned `0` / `false` once capped.
2. **Missing Live Event Propagation**: `awardRuleKarma` in `UserContext.jsx` mutated local state but did not dispatch a global window event (`karma-updated`). As a result, the `Navbar` top badge and `Sidebar` profile widget did not re-render their points counters without a hard browser reload.
3. **Role-Based Visibility Filter**: `Navbar.jsx` previously had `{!isSysAdmin && (` and `Sidebar.jsx` had `{currentUser?.role !== 'SYSADM' && (`, which completely hid the Karma points counter and badge whenever an administrator logged in.
4. **Community & Scheduled Post Gaps**: `CommunityView.jsx` (`handleCreatePost`) and `PostCard.jsx` (`handlePublishNow`) did not trigger `awardRuleKarma` upon publishing.

---

## 2. Changes Implemented

### A. Backend Karma Cap Elevation (`KarmaConstants.cs`)
- Elevated `KarmaCaps.CreatePostDailyCap` from `10` to `50` points (supporting up to 25 posts/day) in `Backend/Knome.API/Constants/KarmaConstants.cs`.
- Recompiled backend (`dotnet build`) with 0 errors and restarted API daemon on port `5095`.

### B. Global Real-Time Event & State Engine (`UserContext.jsx`)
- **Event Dispatch**: `awardRuleKarma` now emits `window.dispatchEvent(new CustomEvent('karma-updated', { detail: { userId, points, totalKarma, ruleKey } }))`.
- **State & Posts Increment**: Automatically increments `currentUser.karma`, `currentUser.karmaPoints`, and `currentUser.postsCount` upon post publishing.
- **Backend Balance Synchronizer (`refreshKarma`)**: Added `refreshKarma(userId)` to query `GET /api/karma/my` asynchronously, persisting the exact SQL Server ledger balance to local storage and application state.

### C. Live Karma Counter in Navigation & Sidebar (`Navbar.jsx` & `Sidebar.jsx`)
- **Navbar Event Listeners**: Added live listeners for `'karma-updated'`, `'post-created'`, and `'article-created'` in `Navbar.jsx`.
- **Universal Visibility**: Removed restrictive `!isSysAdmin` filter from `Navbar.jsx` and `Sidebar.jsx` so all roles (Admins and Employees) see their live points badge and stats card.
- **Sidebar Live Reactive State**: Added `liveKarma` and `livePosts` state in `Sidebar.jsx` that listens to `'karma-updated'` and `'post-created'` to increment instantaneously.

### D. Multi-Surface Post Publishing Integration
- **`CreatePostModal.jsx`**: When post is published (`status !== 'Scheduled'`), awards points, displays celebration toast (`⚡ +2 Karma Points earned for publishing a Post!`), and triggers `refreshKarma()`.
- **`CommunityView.jsx`**: Added `awardRuleKarma` and `refreshKarma` in `handleCreatePost` with celebration toast.
- **`PostCard.jsx`**: Added `awardRuleKarma` in `handlePublishNow` when manually releasing scheduled posts.

---

## 3. Verification
- Ran automated end-to-end test `scratch/verify_karma_on_post.ps1` against live SQL Server:
  - **Run 1 (EMP001)**: Initial `141` -> Published Post #10162 -> Updated `143` (+2 pts, Tx: `CreatePost`) `[PASS]`.
  - **Run 2 (EMP001)**: Initial `143` -> Published Post #10163 -> Updated `145` (+2 pts, Tx: `CreatePost`) `[PASS]`.
  - **Run 3 (EMP002)**: Initial `13` -> Published Post #10161 -> Updated `15` (+2 pts, Tx: `CreatePost`) `[PASS]`.
- Frontend production bundle (`npm run build`) built cleanly in `779ms` with 0 errors.
