# Dev Journal 163: Fix Post ID Misinterpretation as User Profile ID and Profile 404 Console Error

## Context & Defect Analysis
A console error was observed:
```
:5095/api/users/10203:1 Failed to load resource: the server responded with a status of 404 (Not Found)
Profile.jsx:115 Failed to load user profile: Error: User with ID 10203 not found.
    at Object.handleResponse (apiClient.js:256:25)
    at async executeFetch (apiClient.js:170:32)
(anonymous) @ Profile.jsx:115
```

### Root Cause
1. `10203` is a `PostId` in the `Posts` table (a post where Vilash Deshmukh shared Deepak Simrodia's profile with URL `http://localhost:5173/profile?id=1057`).
2. In `Navbar.jsx`, notification handler `handleNotificationClick` used `msg.includes('profile')` to detect profile shares. When a community notification arrived for post 10203 (`Vilash Deshmukh posted in private community: "Shared Profile: ..."`), `isProfileShare` evaluated to `true`, and it mistakenly used `refId` (which was `PostId = 10203`) as `targetUser.userId`.
3. In `CommunityView.jsx` and `PostCard.jsx`, shared profile fallbacks fell back to `p.id` (the post ID) when parsing failed, propagating `10203` to profile links.
4. When `Profile.jsx` navigated to `activeUserId = 10203`, the backend correctly responded with 404 Not Found, which caused `Profile.jsx:115` to log an unhandled error to the browser console.

## Changes Made
1. **`Navbar.jsx`**:
   - Explicitly guarded `isPostNotif` to ensure posts (`relType === 'post' || notif.isPost || notif.type.includes('post')`) route directly to `/posts?id=${refId}`.
   - Restricted `isProfileShare` to actual profile share notifications (`relType === 'profile' || notif.type === 'profile_share'`) and excluded post notifications.
   - Added regex extraction of `/profile?id=xxx` from the message text if present, preventing the post's `refId` from ever being used as a user ID.
2. **`CommunityView.jsx`**:
   - Removed `(p.id || 1)` fallback from `backendSharedProfile` user ID extraction.
   - Safely navigate to `/profile?id=${profId}` only if `profId` is present.
3. **`PostCard.jsx`**:
   - Replaced fallback `1` with `null` and guarded profile navigation so only valid profile IDs are navigated to.
4. **`Profile.jsx`**:
   - Added smart resolution of embedded `/profile?id=xxx` links from `targetUserObj.content`.
   - Cleanly handled 404 responses from `profileApi.getById` without logging a red `console.error` to the browser console.
5. **Build & Deployment**:
   - Ran `npm run build` with 0 errors (1.14s).
   - Deployed updated assets to IIS (`C:\inetpub\wwwroot\knome\`).
