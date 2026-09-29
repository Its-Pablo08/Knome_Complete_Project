# Phase 149: HR Administrator Broadcast Message Management & Dashboard Announcement Refactor

## Context & Objectives
- The user highlighted that the Dashboard's **HR Broadcast • Organization Announcement** banner was displaying a personal user notification: *"New Comment: Vilash Deshmukh commented on your post."*
- Furthermore, the user explicitly requested: *"hr administartion should have access to send broadcast messgae and edit it"*.
- Root cause:
  1. `dashboardApi.getAnnouncements()` called `/api/notifications`, which returns all personal notifications for the user. When no genuine broadcasts existed, the latest comment notification was mistakenly rendered in the organization announcement banner.
  2. The backend previously only had a single `POST /api/notifications/broadcast` endpoint, without dedicated APIs to fetch active announcements (`GET /broadcasts`), edit an existing broadcast (`PUT /broadcast/{id}`), or delete/archive it (`DELETE /broadcast/{id}`).
  3. No interactive UI existed for HR Administrators to compose, template, edit, or dismiss organization broadcasts from the Dashboard or the HR Analytics portal.

---

## Architectural Changes & Implementation Details

### 1. Backend (`Backend/Knome.API`)

- **DTOs (`DTOs/Notifications/`)**:
  - `BroadcastItemDto.cs`: Represents parsed broadcast announcements with `Id`, `Title`, `Message`, `Content`, `CreatedDate`, `Sender`, and `EventType`.
  - `UpdateBroadcastDto.cs`: Validated payload with optional `Title` (max 150 chars) and required `Message` (max 400 chars).
  - `BroadcastNotificationDto.cs`: Enhanced with optional `Title` property (max 150 chars).
  - `UpdateBroadcastValidator.cs`: FluentValidation validator enforcing length and required rules.

- **Repository & Service Pattern (`Interfaces/` & `Repositories/` & `Services/`)**:
  - `INotificationRepository`: Added `GetRecentBroadcastsAsync(take)`, `UpdateBroadcastMessageAsync(notificationId, newMessage)`, and `DeleteBroadcastBatchAsync(notificationId)`.
  - `NotificationRepository`: Implemented atomic update and delete batches across sibling broadcast notification rows sharing the same message and created within the broadcast window.
  - `INotificationService` & `NotificationService`: Implemented `GetBroadcastAnnouncementsAsync()`, `UpdateBroadcastAsync()`, and `DeleteBroadcastAsync()`. Excluded regular post/article feed notifications (`published a new post`) and personal interactions from broadcast announcements. Integrated SignalR hub broadcasts (`BroadcastUpdated`, `BroadcastDeleted`).

- **API Controller (`NotificationsController.cs`)**:
  - `GET /api/notifications/broadcasts`: Returns clean, deduplicated list of active broadcast announcements for all authenticated employees.
  - `POST /api/notifications/broadcast`: Gated to `Roles.HRAdmin + "," + Roles.SystemAdmin`. Combines `Title | Message` and broadcasts to all active users.
  - `PUT /api/notifications/broadcast/{id:long}`: Gated to `Roles.HRAdmin + "," + Roles.SystemAdmin`. Allows editing an active broadcast announcement with immediate persistence to SQL Server and real-time client updates.
  - `DELETE /api/notifications/broadcast/{id:long}`: Gated to `Roles.HRAdmin + "," + Roles.SystemAdmin`. Allows removing/archiving active announcements.

---

### 2. Frontend (`knomeUI/frontend`)

- **Dedicated Modal (`BroadcastModal.jsx`)**:
  - Enterprise modal portaled to `document.body`.
  - Supports both **New Broadcast** and **Edit Broadcast** modes.
  - Audience indicator: *"All Active MPOnline Employees (Organization-Wide)"*.
  - Subject/Headline input with character counter.
  - Message body textarea with 400-char counter.
  - 4 quick templates: *All-Hands Town Hall*, *Company Holiday Notice*, *System Maintenance*, and *HR Policy Update*.
  - Delete/remove option in edit mode.
  - Dispatches `knome:broadcast-updated` custom event upon completion.

- **Dashboard Announcement Banner (`Dashboard.jsx`)**:
  - Filtered announcements to strictly match `HRAnnouncement` / `AdminBroadcast` and explicitly reject comments, likes, and post notifications.
  - Added **"Edit"** and **"Remove"** action buttons directly on the announcement banner for `isHrOrSysAdmin`.
  - When no broadcast is active, renders an administrative prompt for HR Administrators with a `+ Create Broadcast` CTA button.
  - Event listener for `knome:broadcast-updated` to reload announcements immediately.

- **HR Analytics Hub (`HRAnalytics.jsx`)**:
  - Added a prominent **"Send Broadcast"** / **"Manage Broadcast"** button in the hero controls.
  - Renders a live **HR Broadcast** management banner displaying the active broadcast status with quick **"Edit Message"** and **"Remove Broadcast"** controls.
  - Embedded `BroadcastModal` with immediate refresh callbacks.

- **API Client (`apiService.js`)**:
  - Updated `dashboardApi.getAnnouncements` to call `/notifications/broadcasts`.
  - Added `notificationsApi.broadcasts` wrapper (`getAll`, `send`, `update`, `delete`).

---

## Verification & Validation

1. **Backend Compilation**:
   - `dotnet build -nologo` in `Backend/Knome.API`: 0 warnings, 0 errors.
   - Background API daemon running on port 5095.

2. **Automated Live Integration Test (Python script against SQL Server)**:
   - Login as HR Administrator (`EMP003` / `Password@123`): Status `200 OK`.
   - `GET /api/notifications/broadcasts`: Successfully retrieved broadcasts with zero personal comments.
   - `POST /api/notifications/broadcast`: Published new announcement with title *"Town Hall 2026"*: Status `200 OK`.
   - `PUT /api/notifications/broadcast/{id}`: Edited announcement to *"Town Hall 2026 (Rescheduled)"*: Status `200 OK`.
   - `GET /api/notifications/broadcasts`: Verified updated title and content.
   - `DELETE /api/notifications/broadcast/{id}`: Cleaned up test announcement: Status `200 OK`.

3. **Frontend Production Build & Deployment**:
   - `npm run build` in `knomeUI/frontend`: Built cleanly in 1.39s (0 errors).
   - `robocopy` deployed bundle to IIS webroot at `C:\inetpub\wwwroot\knome`.
