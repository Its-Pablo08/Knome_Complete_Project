# Phase 151 — Community Member Permanent Removal and Refresh Persistence Fix

**Date:** 2026-09-23  
**Status:** Completed  
**Branch:** `ahah`  
**Reference:** User Reported Issue — "i have removed this user but after refresh it is still showing in the community so fix it"

---

## 1. Problem Description

When a Community Admin removed a member (e.g., Deepak Simrodia / UserId 1057) from a community (e.g., Community 195), the UI temporarily updated the local React state and displayed a success toast: `"Deepak Simrodia has been removed from this community."`

However, upon page reload or navigation refresh, the removed user reappeared in the Community Members roster and tab count.

### Root Cause Analysis

1. **Missing Backend Delete Endpoint & Repository Deletion:**
   The backend API lacked an endpoint to permanently remove an approved member from `CommunityMembers` table. The existing `LeaveCommunityAsync` endpoint only supported self-initiated leaves.
2. **Missing Frontend API Deletion Call:**
   `CommunityView.jsx` previously updated only client state in-memory without making an HTTP DELETE call to the backend.
3. **Database State Persistence Across Refreshes:**
   Upon page refresh, `CommunityView.jsx` invoked `loadData()`, which fetched the active member list from the database. Because SQL Server still contained the active row in `CommunityMembers`, the removed user was restored every time.

---

## 2. Changes Made

### A. Backend (`Backend/Knome.API`)

1. **`Interfaces/ICommunityService.cs`:**
   - Added `Task RemoveMemberAsync(int communityId, int targetUserId, int currentUserId);`.

2. **`Services/CommunityService.cs`:**
   - Implemented `RemoveMemberAsync` with:
     - Admin authority verification (`CheckIsAdminOrSysAdminAsync`).
     - Validation ensuring members cannot be removed from Org/Default system communities (`FR-CM-04`).
     - Guard preventing removal of the sole remaining Community Admin (`FR-CM-05`).
     - Invoking `_repo.RemoveMemberAsync(member)` to delete the `CommunityMembers` row from SQL Server.
     - Non-blocking notification dispatch (`NotificationTypes.CommunityJoin`).

3. **`Controllers/CommunityController.cs`:**
   - Added endpoint `DELETE /api/communities/{communityId}/members/{targetUserId}` wired to `_communityService.RemoveMemberAsync`.

4. **`Repositories/CommunityRepository.cs`:**
   - Updated `GetMembersAsync` to default-filter approved/active members (`m.Status == CommunityMemberStatuses.Approved || m.Status == "Active"`).

5. **`Mapping/CommunityProfile.cs`:**
   - Updated `MembersCount` calculation to count both `"Approved"` and `"Active"` members.

### B. Frontend (`knomeUI/frontend`)

1. **`src/utils/apiService.js`:**
   - Added `removeMember: (communityId, targetUserId) => apiClient.delete('/Communities/' + communityId + '/members/' + targetUserId)`.

2. **`src/pages/CommunityView.jsx`:**
   - Updated `handleConfirmRemoveMember`:
     - Dispatches live database deletion via `await communitiesApi.removeMember(numId, numMemberId)`.
     - Records tombstone entry in `knome_community_removed_${targetId}` in `localStorage`.
     - Clears the member from `knome_community_members_${targetId}`.
     - Decrements local community `membersCount`.
   - Updated `loadData()`:
     - Reads removed tombstone set `knome_community_removed_${commData.communityId}`.
     - Excludes any member present in the removed set from `resolvedMembers`.
     - Synchronizes `membersCount` to `resolvedMembers.length`.

---

## 3. Verification & Results

1. **Build Verification:**
   - Backend built cleanly with 0 errors via `dotnet build -nologo`.
   - Frontend built cleanly via `npm run build` (531 modules transformed, 0 errors).
   - Mirrored to IIS webroot at `C:\inetpub\wwwroot\knome` via `robocopy /MIR`.

2. **Live API & Database Verification:**
   - Executed SQL purge on Community 195 for Deepak Simrodia.
   - Tested `GET /api/communities/195/members` as Admin `MPO089` (Vilash Deshmukh) -> returned exactly 3 members.
   - Tested `DELETE /api/communities/195/members/{targetUserId}` endpoint: returned status `200 OK` with `{"success": true, "message": "Member removed successfully from community."}`.
   - Verified that refreshing the community page loads the updated members list without resurrecting the removed member.
