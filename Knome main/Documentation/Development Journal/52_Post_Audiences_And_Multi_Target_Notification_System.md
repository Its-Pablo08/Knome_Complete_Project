# Dev Journal 52: Post Audiences (Everyone, Specific Community, Specific Person) & Multi-Target Notification System

**Date:** 2026-09-10  
**Phase:** 52  
**Status:** Complete & Verified  

---

## 1. Goal & Requirements
The user requested:
1. *"use time according to laptop time in everywhere in the project"*
2. *"make all this 3 working everyone, specific community and specific person notification must be there"* (referencing the Create Post modal's audience options shown in the user's screenshot: Everyone, Specific Communities..., Specific Connections...).

### Success Criteria:
1. **Audience 1 — Everyone**:
   - Posts published to all employees in the organization.
   - Generates notifications for organization colleagues: `"{authorName} published a new post: \"{snippet}\""`.
   - Displays `[public] Everyone` badge on post.
2. **Audience 2 — Specific Community**:
   - Chevron subview opens community selector with real-time search across live communities (`DevOps & AI Innovation Hub`, `sql first`, `All department`, `tech`, etc.).
   - Sets blue badge `[groups] {communityName}` on modal and post.
   - Automatically links post to `CommunityPosts` table in SQL Server.
   - Generates notifications for community members: `"{authorName} posted in {communityName}: \"{snippet}\""`.
   - Post appears both on Home feed (for members) and directly on the Community view page.
3. **Audience 3 — Specific Person / Connections**:
   - Chevron subview opens colleague multi-selector with live search across roster and DB users.
   - Sets purple badge `[person] To: {Names}` on modal and post.
   - Restricts post visibility strictly to the author and the targeted colleagues.
   - Generates notifications for each targeted colleague: `"{authorName} shared a post with you: \"{snippet}\""`.
   - Non-targeted colleagues cannot view the private post in their feed.
4. **Time Everywhere Synchronized to Laptop Time**:
   - Backend serializes all `DateTime` responses with ISO 8601 UTC `'Z'` suffix (`UtcDateTimeJsonConverter`).
   - Frontend parses timestamps ensuring proper UTC parsing (`parseLaptopDate`) and displays in user's laptop local timezone formatted as `DD/MM/YYYY, hh:mm AM/PM` or relative format.

---

## 2. Technical Implementation

### A. Backend Architecture & Serialization
1. **UTC JSON Converters (`Backend/Knome.API/Converters/UtcDateTimeJsonConverter.cs`)**:
   - Implemented `UtcDateTimeJsonConverter` and `NullableUtcDateTimeJsonConverter`.
   - Registered in `ServiceCollectionExtensions.cs` via `.AddJsonOptions(...)`.
   - Guarantees all datetime strings emitted by ASP.NET Core end with `'Z'`, eliminating timezone drift.
2. **Post Service (`Backend/Knome.API/Services/PostService.cs`)**:
   - **Community Notification & Linking**:
     - Links post into `CommunityPosts` table.
     - Queries community members with status `"Approved"` or `"Active"`, including community creator.
     - Emits `NotificationTypes.Community` with text: `"{authorName} posted in {comm.Name}: \"{snippet}\""`.
   - **Specific Connections Notification**:
     - Targets selected user IDs from `dto.AudienceUserIds`.
     - Emits `NotificationTypes.Share` with text: `"{authorName} shared a post with you: \"{snippet}\""`.
   - **Everyone Notification**:
     - Broadcasts `NotificationTypes.HrAnnouncement` to followers and active colleagues: `"{authorName} published a new post: \"{snippet}\""`.
   - Enriches `PostDto` with `CommunityId`, `CommunityName`, `SharedWithName`.
3. **Feed Service (`Backend/Knome.API/Services/FeedService.cs`)**:
   - Batch-queries `CommunityPosts` for candidate posts.
   - Populates `CommunityId`, `CommunityName`, `SharedWithName`, and `AudienceUserIds` on `FeedItemDto`.

### B. Frontend Implementation
1. **`CreatePostModal.jsx`**:
   - Wired audience selector popover with 3 options:
     - `Everyone`: resets community and connections, sets `audience = 'Everyone'`.
     - `Specific Communities...`: displays searchable list of live communities loaded via `communitiesApi.getAll()`. Selecting a community displays blue badge with clear button.
     - `Specific Connections...`: displays searchable multi-select list of all colleagues loaded from `users` context and `profileApi.search('')`. Selecting colleagues displays purple badge with clear button.
   - On publish:
     - Sends `audienceType`, `audienceCommunityIds`, and `audienceUserIds` to backend.
     - Generates real-time notifications in `knome_notifications` localStorage for all 3 scenarios.
     - Dispatches `knome_notification_received`, `knome_new_notification`, and `notification-updated` window events for instant bell badge increments.
2. **`PostCard.jsx` & `apiService.js`**:
   - Updated `mapFeedItem` to include `communityId`, `communityName`, `sharedCommunityName`, `sharedWithName`, `audienceUserIds`.
   - Formatted all comment timestamps to `formatToDDMMYYYY(...)` in laptop local time.
   - Audience badges styled with proper icon and colors (`groups` blue badge for community, `person` purple badge for specific connections, `public` for everyone).
3. **`notificationHelpers.js` & `Navbar.jsx`**:
   - Added `' posted in '`, `' shared a new post in '`, and `' published a new post'` to `knownActions` for bold sender parsing.
   - Supported `isEveryone` and `post_everyone` in `isNotificationForUser`.

---

## 3. Verification Results

An automated end-to-end verification script (`scratch/verify_audiences_and_notifs.ps1`) was executed against the live API:

```
=================================================
   TESTING POST AUDIENCE & NOTIFICATIONS         
=================================================

Logged in users:
U1 (EMP001): Aarav Sharma (Id: 1063)
U2 (EMP002): Priya Patel (Id: 1064)
U3 (EMP003): Rohan Verma (Id: 1065)

--- TEST 1: Post to Everyone ---
Post 1 (Everyone) created successfully. PostId: 10151
[PASS] U2 received Everyone post notification: 'Aarav Sharma published a new post: "Announcing company all-hands meeting #5611"'
       Timestamp: 2026-09-10T08:49:16.894Z

--- TEST 2: Post to Specific Community (176) ---
Community 176 members: 4, 2
Post 2 (Community 176) created successfully. PostId: 10152
[PASS] Community member Vishendra received Community post notification: 'Aarav Sharma posted in DevOps & AI Innovation Hub: "DevOps pipeline release notes update #1042"'
       Timestamp: 2026-09-10T08:49:18.163Z

--- TEST 3: Post to Specific Person (EMP002 / Priya Patel) ---
Post 3 (Specific Person) created successfully. PostId: 10153
[PASS] Targeted recipient U2 received Specific Person notification: 'Aarav Sharma shared a post with you: "Private handover notes for Priya Patel only #3605"'
       Timestamp: 2026-09-10T08:49:19.436Z
[PASS] Targeted recipient U2 sees the post in feed. SharedWithName: 'Priya Patel'
[PASS] Privacy verified: Non-targeted user U3 cannot see the private post.

=================================================
   ALL AUDIENCE & NOTIFICATION CHECKS COMPLETE   
=================================================
```

Frontend production build (`npm run build`) succeeded in 3.68s with 0 errors.
Backend build (`dotnet build`) succeeded with 0 errors.
