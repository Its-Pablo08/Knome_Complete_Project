# Dev Journal: 117 — Database & Backend Timestamp Alignment to Indian Standard Time (IST)

**Date:** September 21, 2026  
**Status:** Completed  
**Author:** Antigravity  

---

## 1. Problem Statement & User Intent
Previously, the Knome platform database and backend API were recording timestamps in UTC (`sysutcdatetime()` in SQL Server default constraints, and `DateTime.UtcNow` in .NET backend services).

When an employee created a post or comment at `12:06 PM` (local laptop time, India Standard Time, UTC+05:30) and inspected the SQL Server database directly, the record displayed:
`2026-09-21 06:36:11.1078360`

The user reported this discrepancy via SQL Server table screenshot:
> *"fix overrall database date and time it is taken from local laptop"*
> *(Selected row 53: Comment 10113 "hey" created at 06:36:11)*

The user requested that overall database dates and times must store Indian Standard Time (IST, UTC+05:30) matching their local laptop clock.

---

## 2. Technical Root Cause & Systemic Scope
1. **SQL Server Constraints**: 27 table columns had default constraints using `(sysutcdatetime())` or `(getutcdate())`.
2. **Historical Data**: All existing rows across Posts, Articles, Comments, Videos, Podcasts, Communities, Notifications, Karma, and AuditLogs were stored in UTC.
3. **Backend API Services**: `DateTime.UtcNow` was used across 15+ services and repositories to generate entity timestamps upon creation and update.
4. **Frontend Date Parsing**: `parseLaptopDate` appended `'Z'` to ISO strings lacking timezone indicators, expecting UTC from the database.

---

## 3. Implementation Details

### A. SQL Server Migration (`Migrate_Utc_To_IST.sql`)
1. **Default Constraints**: Dropped all 27 default constraints using `(sysutcdatetime())` or `(getutcdate())` and replaced them with `(sysdatetime())` / `(getdate())` across `Comments`, `Posts`, `Articles`, `Videos`, `Podcasts`, `Communities`, `CommunityMembers`, `Notifications`, `KarmaTransactions`, `AuditLog`, `Reactions`, `Bookmarks`, `Shares`, and `Users`.
2. **Historical Timestamp Shifting**: Atomically adjusted all existing records forward by +330 minutes (`DATEADD(minute, 330, [Column])`):
   - Row 10113 (`hey` comment): Shifted from `06:36:11` to `12:06:11`.
   - All 54 comments, 72 posts, 26 articles, 28 videos, 12 podcasts, 349 notifications, and 615 karma transactions successfully converted to authentic IST.

### B. Backend Enterprise Time Provider (`Common/KnomeTime.cs`)
Created a centralized time provider returning robust Indian Standard Time:
```csharp
namespace Knome.API.Common;

public static class KnomeTime
{
    private static readonly TimeZoneInfo IstZone;
    static KnomeTime() { /* Resolves "India Standard Time" / "Asia/Kolkata" or UTC+05:30 */ }
    public static DateTime Now => TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, IstZone);
    public static DateOnly Today => DateOnly.FromDateTime(Now);
}
```
Replaced `DateTime.UtcNow` with `KnomeTime.Now` across:
- `ContentInteractionService.cs` (Comments, Reactions, Shares, Bookmarks, Reports)
- `PostService.cs` & `PostRepository.cs` (Post creation, publishing, scheduling)
- `ArticleService.cs` & `ArticleRepository.cs` (Article creation, versioning, publishing)
- `VideoService.cs` & `PodcastService.cs` (Media upload timestamps)
- `CommunityService.cs` (Community creation, memberships, community posts)
- `KarmaService.cs` & `KarmaRepository.cs` (Transactions, balances, daily caps)
- `NotificationService.cs` & `NotificationRepository.cs` (Notification publication & retention)
- `UserService.cs` & `UserRepository.cs` (Profile modifications, connection requests, suspension queries)
- `AuthService.cs` (Credential updates, suspension checks)
- `FeedService.cs` & `FeedRepository.cs` (Hot score calculation, retention cutoffs)
- `JobService.cs` & `JobRepository.cs` (Job creation, expiration)
- `AuditLogService.cs` (Audit log timestamps)
- `DataArchivalHostedService.cs` (Log archival timestamps)
- `SuspensionGuard.cs` & `SuspendUserValidator.cs` (Suspension validity checks)
- `CreateJobValidator.cs` (Closing date checks)
- `Mapping/UserProfile.cs` (User suspension mapping)

### C. Frontend Direct Local Parsing (`apiService.js`)
Updated `parseLaptopDate` in `knomeUI/frontend/src/utils/apiService.js`:
- Standardizes space separator to `'T'` without forcing `'Z'`.
- Allows JavaScript `new Date(...)` to interpret database IST timestamps directly as local laptop time without unwanted 5.5-hour double-shifts.

---

## 4. Verification & Results

1. **Database Direct Verification**:
   - `SELECT CommentId, ContentType, ContentId, UserId, CommentText, CreatedDate FROM Comments WHERE CommentId = 10113;`
   - Result: `2026-09-21 12:06:11.1078360` (previously `06:36:11.1078360`).
2. **Live Insertion Verification**:
   - Posted new comment via authenticated API.
   - Result in SQL Server: `2026-09-21 12:29:06.7832468` matching local laptop clock to the millisecond.
3. **Builds**:
   - Backend API: Built cleanly in 2.36s with 0 errors.
   - Frontend UI: Built cleanly in 1.03s with 0 errors, deployed to IIS (`C:\inetpub\wwwroot\knome`).
