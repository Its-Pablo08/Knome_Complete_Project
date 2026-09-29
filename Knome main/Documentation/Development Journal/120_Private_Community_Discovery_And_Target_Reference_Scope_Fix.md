# Development Journal: Phase 120 — Private Community Discovery & Target Reference Scope Fix

**Date:** September 21, 2026  
**Module:** Communities (`Backend/Knome.API/Services/CommunityService.cs`, `knomeUI/frontend/src/pages/CommunityView.jsx`)  
**Status:** Completed & Verified  

---

## 1. Problem Statement & Incident Analysis

When navigating to a private community (such as Community #188 "Java") as an employee who is not an approved member:
1. **Frontend Crash:**
   ```
   CommunityView.jsx:3738 Uncaught ReferenceError: target is not defined
       at CommunityView.jsx:3738:53
       at Array.map (<anonymous>)
       at CommunityView (CommunityView.jsx:3136:69)
   ```
2. **Backend 403 Forbidden on Metadata:**
   ```
   :5095/api/Communities/188:1  Failed to load resource: the server responded with a status of 403 (Forbidden)
   :5095/api/Communities/188/posts?pageNumber=1&pageSize=50:1  Failed to load resource: the server responded with a status of 403 (Forbidden)
   :5095/api/Communities/188/members?pageNumber=1&pageSize=50:1  Failed to load resource: the server responded with a status of 403 (Forbidden)
   ```

### Root Cause
- **Scope Error in `CommunityView.jsx`:**
  `const target = resolveSharedTarget(post);` was declared inside an inner IIFE (`{(() => { ... })()}`) at line 3208. The action buttons (Like, Comment, Share, and "Open Content") rendered at lines 3700–3750, outside that IIFE. When line 3738 referenced `target?.type === 'Article'`, JavaScript threw an uncaught `ReferenceError`.
- **403 Lockout on `GetCommunityAsync` in `CommunityService.cs`:**
  `GetCommunityAsync(communityId, currentUserId)` was calling `await CheckCanViewCommunityAsync(communityId, currentUserId, community);`. This threw an `UnauthorizedException` whenever a non-member attempted to fetch the basic metadata of a private community. Under FR-CM-02, employees must be able to discover private communities, view their title/banner/description, and submit a "Request to Join" button. Post feeds and member rosters should remain protected, but the community profile itself must be accessible.

---

## 2. Solutions Implemented

### Backend (`CommunityService.cs`)
- Removed `await CheckCanViewCommunityAsync(communityId, currentUserId, community);` from `GetCommunityAsync`.
- Kept `CheckCanViewCommunityAsync` strictly on:
  - `GetCommunityPostsAsync`
  - `GetMembersAsync`
  - `CreateCommunityPostAsync`
- Now, non-members can view community metadata (`GET /api/Communities/{id}`) with `currentUserMembershipStatus` reflecting `null` / `"Pending"`, while posts and members are protected with 403 Forbidden.

### Frontend (`CommunityView.jsx`)
- **Scope Fix:** Declared `const target = resolveSharedTarget(post);` at the top of the `sortedPosts.slice(0, visiblePostCount).map(post => { ... })` function body so that `target` is in scope across both the quote card inside the IIFE and the Action Bar buttons.
- **Private Community Feeds Guard:** For private communities where `membershipStatus !== 'joined' && !isAdmin`:
  - Displays a clean, dedicated lock banner informing the user that discussions are restricted to approved members and provides the "Request to Join" button.
  - Guards the **Members tab** with a restricted notice ("Member Directory Restricted").
  - Guards the **Files & Media tab** with a restricted notice ("Files & Media Restricted").
  - Hides the "Subscribe (View Only)" button on private communities (only available on Public/Org communities).

---

## 3. Verification & Deployment

1. **Backend Verification:**
   - Compiled `Backend/Knome.API` with `dotnet build`: `0 Error(s)`.
   - Tested authenticated request with test user (`EMP002`) to `GET /api/Communities/188`:
     - Returned `HTTP 200 OK`.
     - Community details ("Java", description: "Java is using for backend.", type: "Private", membersCount: 1, currentUserMembershipStatus: null) returned properly.
2. **Frontend Verification:**
   - Compiled frontend with `npm run build`: `✓ built in 2.42s`.
   - Synced distribution artifacts to IIS (`C:\inetpub\wwwroot\knome`).
   - Verified that `ReferenceError: target is not defined` is resolved and `target` is available across all post cards.
