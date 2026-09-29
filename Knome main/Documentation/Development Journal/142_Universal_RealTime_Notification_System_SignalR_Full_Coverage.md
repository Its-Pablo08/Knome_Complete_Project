# 142 — Universal Real-Time Notification System: SignalR Full Coverage

**Date:** 22-09-2026  
**Phase:** Notification Engine — Complete Implementation & Hardening  
**Status:** ✅ Complete

---

## Objective

Implement and verify the universal, real-time notification engine for the Knome Enterprise Platform, guaranteeing **instant, real-time push delivery** via SignalR across all enterprise modules — with zero page refreshes, dynamic badge increments, dual-tone harmonic audio chimes, interactive toast popups, and deep-linking.

---

## Architecture Overview

- **Transport:** SignalR Hub (`NotificationHub` at `/hubs/notifications`)
- **Delivery Pattern:** `Clients.Group("User_{recipientId}").SendAsync("ReceiveNotification", dto)`
- **Self-notification Suppression:** Enforced at both backend producer level and frontend (`isSelfNotification` helper)
- **Timestamps:** All formatted as `DD-MM-YYYY, hh:mm A` in IST
- **DB Schema:** `[dbo].[Notifications]` + `[dbo].[NotificationPreferences]` — no manual schema changes

---

## Backend Changes

### 1. Scheduled Content Notifications

**Files:** `IPostRepository.cs`, `PostRepository.cs`, `IArticleRepository.cs`, `ArticleRepository.cs`, `ScheduledPostHostedService.cs`

- Updated `PublishDueScheduledPostsAsync` -> returns `Task<List<Post>>`
- Updated `PublishDueScheduledArticlesAsync` -> returns `Task<List<Article>>`
- `ScheduledPostHostedService` now iterates released entities and calls `INotificationService.PublishAsync` for each author:
  - Post: `"Your scheduled post has successfully gone live."`
  - Article: `"Your scheduled article "{title}" has successfully gone live."`

### 2. Account Activation / Suspension Notifications

**File:** `UserService.cs`

- `ActivateUserAsync`: Notifies user — `"Your Knome account has been reactivated."`
- `SuspendUserAsync`: Notifies user — `"Your Knome account has been permanently suspended."` or `"...suspended until {date}."`

### 3. Role Workflow Notifications

**File:** `UserService.cs`

- `ChangeRolesAsync`: `"Your Knome roles have been updated to: {rolesDisplay}"`
- `ApproveRoleRequestAsync`: `"Your role has been approved and updated to '{roleName}'."`
- `RejectRoleRequestAsync`: `"Your role request was reviewed and declined. Reason: {reason}"`

### 4. Community Join Rejection & Announcement Broadcasts

**File:** `CommunityService.cs`

- `DecideMembershipAsync` (Rejected): `"Your request to join {communityName} was declined."`
- `PinPostAsync` (IsPinned): Broadcasts to all active community members — `"An announcement was pinned in {communityName}."`

### 5. Moderation Advisory Notifications

**File:** `ContentInteractionService.cs`

- `ResolveReportAsync`: Notifies content author — `"A piece of your content ({contentType}) was reviewed by moderators and action was taken: {actionTaken}"`

### 6. @Mention Notifications in Comments

**File:** `ContentInteractionService.cs`

- `AddCommentAsync`: Regex parses @username/@employeeId mentions in comment text. Dispatches `NotificationTypes.Mention` to matched users (excluding commenter and already-notified content author).

### 7. Notification Enrichment

**File:** `NotificationService.cs`

- `EnrichNotificationDtoAsync` updated to map `AdminBroadcast` -> `/admin` and `RoleRequest` -> `/admin` target URLs.

---

## Frontend Changes

### Navbar.jsx

- **Dynamic SignalR URL:** Protocol/host-aware resolution
- **SignalR Lifecycle:** `.withAutomaticReconnect([0, 2000, 5000, 10000, 30000])` with `LogLevel.Warning`
- **ReceiveNotification handler:** Increments unread counter, triggers audio chime, fires interactive toast popup
- **Count update handlers:** `ReactionCountUpdated`, `CommentCountUpdated`, `ShareCountUpdated` dispatched as custom DOM events
- **Dual-tone harmonic chime:** 880Hz sine + 1320Hz triangle wave synthesizer via Web Audio API (zero file dependency)
- **Badge:** Pulse animation glow + `99+` overflow display
- **Connection request mapping:** Distinguishes `follow_request` (inline Accept/Decline) from `connection_accepted` (profile/network link)

### NotificationToast.jsx

- IST-compliant `formatNotificationDate` timestamp badge
- 5s auto-dismiss, smooth slide-in from top-right
- Avatar fallback, deep-link navigation on click

---

## Verification

| Check | Result |
|---|---|
| `dotnet build` | Succeeded — 0 errors |
| Backend API running | http://localhost:5095/swagger |
| Scheduled post/article queries | Firing every cycle (confirmed in logs) |
| SignalR hub registered | /hubs/notifications |
| Frontend Vite dev server | Running |

---

## Notification Coverage Matrix

| Module | Trigger | Recipient | Type |
|---|---|---|---|
| Posts/Articles | Scheduled Published | Author | ScheduledPublished |
| Comments | @mention in text | Mentioned users | Mention |
| Moderation | Report resolved with action | Content author | ModerationAdvisory |
| Community | Join request rejected | Applicant | CommunityUpdate |
| Community | Post pinned/announcement | All active members | CommunityAnnouncement |
| User Account | Account activated | User | AccountStatus |
| User Account | Account suspended | User | AccountStatus |
| Roles | Roles updated by HR Admin | User | RoleRequest |
| Roles | Role request approved | User | RoleRequest |
| Roles | Role request rejected | User | RoleRequest |
| Content Reactions | Like/React | Content author | Reaction |
| Comments | New comment | Content author | Comment |
| Connections | Connection request sent | Recipient | FollowRequest |
| Connections | Connection accepted | Requestor | ConnectionAccepted |
| Jobs | Application submitted | HR Admin | JobApplication |
| Admin Broadcasts | Broadcast published | All employees | AdminBroadcast |

---

## Notes

- Self-notification suppression is enforced at service level (backend) before `PublishAsync` is called.
- All notification messages use IST-formatted timestamps (`DD-MM-YYYY, hh:mm A`).
- Audio chime uses Web Audio API — no external file dependencies, immune to CORS/404 issues.
