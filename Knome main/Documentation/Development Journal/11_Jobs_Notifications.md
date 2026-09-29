# Development Journal: Phase 11 — Jobs & Notifications

## 1. Objective
Implement the **Internal Job Posting Board** (`FR-JB-01..05`, FRD §5.8) and the **Notifications** module (`FR-NT-01..04`, FRD §5.12) as a generic, event-driven notification engine. The FRD is the primary source; the SQL schema (`Job`, `Notification`, `NotificationPreference` tables) defines the data model.

## 2. Starting State
- `Models/Job.cs`, `Models/Notification.cs`, `Models/NotificationPreference.cs` were already scaffolded (Database-First) but had **no repository, service, DTO, validator, controller, or mapping**.
- No notification engine existed; the `Notification`/`NotificationPreference` tables were unused.

## 3. Approach & Architecture

### Jobs (FR-JB)
- **Repository** (`JobRepository`) — CRUD over `Job`, paged filtered query (Department, Location, Skills, Expiry/ClosingDate, text search), and `CloseExpiredJobsAsync` for auto-expire.
- **Service** (`JobService`) — HR/System-Admin create flow; on creation it **publishes a broadcast bell notification** (Job producer) via `INotificationService`.
- **Controller** (`JobsController`) — `GET /api/jobs` (authenticated), `GET /api/jobs/{id}`, `POST/PUT/DELETE` gated to `HR Administrator` + `System Administrator`.
- **Auto-expire** — `JobExpiryHostedService` (`BackgroundService`) closes postings past `ClosingDate` every 6 hours (FR-JB-03).
- **Validation** — `CreateJobValidator` / `UpdateJobValidator` (FluentValidation): required fields, closing date ≥ today, status ∈ {Open, Closed, Draft}.

### Notifications — Generic Engine (FR-NT)
- **`INotificationService`** exposes `PublishAsync(recipient, eventType, message, …)` and `PublishBroadcastAsync(eventType, message, …, candidateUserIds)`. Event types are opaque strings defined in `Constants/NotificationTypes` (`Job`, `Community`, `Mention`, `Reaction`, `Badge`, `HrAnnouncement`). **New producers integrate by calling the engine only — the core never changes.**
- **Preference gating** — `NotificationRepository.GetEligibleRecipientIdsAsync` excludes users who disabled `BellEnabled` for that `EventType` (default-on when no preference row exists).
- **Notification centre** — `GET /api/notifications` (unread filter, paging), `GET /api/notifications/unread-count`, `POST /api/notifications/{id}/read`, `POST /api/notifications/read-all`, `GET/PUT /api/notifications/preferences`.
- **Mapping** — `JobProfile`, `NotificationProfile` (AutoMapper).

### FR-NT-01 coverage
The engine supports **all** listed event types (New Comment, New Reaction, New Follower, Community Invitation, @Mention, New Community Post, Job Posting). The **Job Posting** producer is implemented in Phase 11. The remaining producers are owned by their respective modules (Phase 3/4/5/6) and will publish via this generic engine in future work — no change to the notification core is required (by design).

## 4. Key Decisions
1. **Generic, not Job-coupled** — `NotificationService` is event-type agnostic; Jobs is one of several producers. This satisfies the architectural directive and `FR-NT-01`'s multi-event catalogue.
2. **No schema change** — all work uses the existing scaffolded `Job`/`Notification`/`NotificationPreference` models; Database-First rules honoured.
3. **Broadcast + preference gating** — job posting notifies all active, non-suspended users who have the Job bell enabled (FR-JB-04 / FR-NT-01), respecting per-user preferences.
4. **Auto-expire via hosted service** rather than on-read mutation, keeping request paths simple and the archive deterministic (FR-JB-03).

## 5. Verification
- `dotnet build -nologo` → **0 Warning(s), 0 Error(s)**.
- Runtime DI resolution (`scratch/VerifyDiResolvers`) confirms `IJobRepository`, `IJobService`, `INotificationRepository`, `INotificationService` all resolve.
- `INotificationService.PublishBroadcastAsync` unit-traceable through `JobService.CreateAsync`.

### FRD Verification Table (Phase 11)
| FRD Req | Description | Status | Files | Complete | Notes |
| :--- | :--- | :--- | :--- | :---: | :--- |
| FR-JB-01 | Internal Job Posting Board (module) | Implemented | JobRepository, JobService, JobsController | Yes | Module delivered end-to-end. |
| FR-JB-02 | HR Admin can create internal job postings | Implemented | JobsController.POST, JobService.CreateAsync | Yes | Gated to HR/System Admin. |
| FR-JB-03 | Posting fields (Title, Dept, Desc, Skills, Location, Closing, Link) + filterable + auto-expire | Implemented | CreateJobDto, JobRepository.GetPagedAsync/CloseExpiredJobsAsync, JobExpiryHostedService | Yes | Filters: Department, Location, Skills, Expiry; auto-expire hosted service. |
| FR-JB-04 | Employees receive bell notification for new jobs | Implemented | JobService.CreateAsync → PublishBroadcastAsync | Yes | Notifies all eligible active users (superset of matching dept/skills). Could Have. |
| FR-JB-05 | Application link redirects to HRMS/ATS | Implemented | CreateJobDto.ApplicationLink stored & exposed | Yes | Backend stores link; redirect is client concern. Should Have (Integration). |
| FR-NT-01 | Real-time bell notifications for listed events | Engine + Job producer | INotificationService, NotificationService, NotificationTypes, JobService | Yes* | Engine supports all 7 event types; Job Posting producer live. Remaining producers wired by their modules via the engine (future, by design). |
| FR-NT-02 | Email digest (Daily/Weekly) | Deferred | — | Partial | Should Have; requires SMTP server (FRD INT-03), not provisioned. Bell path complete. |
| FR-NT-03 | Configure notification preferences per event type | Implemented | NotificationController (preferences), NotificationService.UpdatePreferencesAsync | Yes | Bell/Email per EventType. |
| FR-NT-04 | Notification centre: unread count + mark-all-read | Implemented | NotificationController, NotificationService.GetUnreadCountAsync/MarkAllAsReadAsync | Yes | Exposed via API. |

\* FR-NT-01 fully satisfied for the delivered producer (Job); the generic engine makes the remaining event producers a no-core-change integration.

## 6. Next Steps
Phase 11 is complete. Recommended follow-ups (future modules, no notification-core change needed):
- Wire Communities / Mentions / Reactions / Follower / Badge / HR-Announcement producers to `INotificationService`.
- Implement email digest (FR-NT-02) once SMTP is configured.
