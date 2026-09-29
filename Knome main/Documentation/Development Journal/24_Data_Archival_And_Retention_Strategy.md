# 24. Data Archival & 6-Month Retention Strategy (Hot & Cold Tiering)

## Context & Objectives
To ensure high database query performance, prevent table bloat, and maintain a clean user interface on the Knome platform for MPOnline Limited:
1. **Primary Database (`Knome`):** Holds active transactional records for the current **3 months (90 days)**.
2. **Archive Database (`Knome_Archive`):** Historical data older than 3 months is automatically migrated via nightly batch jobs.
3. **Frontend / API Retention Rule:** Public feeds, user notifications, and active listings enforce a **6-month / 3-month cutoff filter** so historical expired content does not clutter the client UI.

---

## Architectural Implementation

### 1. Database Tier (`Knome_Archive`)
- **Database Created:** `Knome_Archive` on SQL Server.
- **Archive Tables:**
  - `dbo.AuditLogs_Archive`
  - `dbo.Notifications_Archive`
  - `dbo.KarmaTransactions_Archive`
  - `dbo.SearchHistory_Archive`
  - `dbo.Posts_Archive`
- **Stored Procedure:** `Knome.dbo.sp_ArchiveKnomeData` executes transactional 500-record batch migrations with micro-delays (`WAITFOR DELAY '00:00:00.050'`) to prevent table-level locks.
- **Setup Script:** `Documentation/Architecture/Create_Knome_Archive_Database.sql`.

### 2. Backend Background Worker (`Backend/Knome.API`)
- **Hosted Service:** `Backend/Knome.API/Background/DataArchivalHostedService.cs`
  - Inherits from `Microsoft.Extensions.Hosting.BackgroundService`.
  - Runs periodically every 24 hours.
  - Resolves `KnomeDbContext` via `IServiceScopeFactory`.
  - Executes `sp_ArchiveKnomeData` with extended timeout (300s) and full error logging.
- **Registration:** Added to `Program.cs` under Background workers.

### 3. Repository Query Level Retention Filters
- **`FeedRepository.cs`:** `GetCandidatePostsAsync` enforces `p.CreatedDate >= DateTime.UtcNow.AddMonths(-6)`.
- **`PostRepository.cs`:** `GetPostsAsync` enforces `p.CreatedDate >= DateTime.UtcNow.AddMonths(-6)`.
- **`NotificationRepository.cs`:** `GetForUserAsync` & `CountForUserAsync` enforce `n.CreatedDate >= DateTime.UtcNow.AddMonths(-3)`.

---

## Verification & Status
- `Knome_Archive` database verified and active.
- `EXEC Knome.dbo.sp_ArchiveKnomeData;` verified on live SQL Server.
- `Backend/Knome.API` compilation verified with 0 errors.
- Project rule followed: Zero manual edits to scaffolded `Models/` or `KnomeDbContext.cs`.
- Git rule followed: Zero git commands executed.
