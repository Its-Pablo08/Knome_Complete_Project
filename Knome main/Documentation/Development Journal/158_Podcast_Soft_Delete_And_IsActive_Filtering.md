# Phase 158 — Podcast Soft Delete & IsActive Database-First Implementation

**Date:** 2026-09-24  
**Author:** Antigravity AI  
**Scope:** SQL Server Database, Backend API (EF Core Scaffold, Repositories, Services, DTOs, Mapping), and Frontend UI (Podcasts, Profile, Analytics).

---

## 1. Requirement & Executive Summary

The objective of this phase was to implement soft deletion for podcasts:
1. **Database Schema Update:** Add an `IsActive BIT NOT NULL DEFAULT 1` column to the `Podcasts` table in SQL Server.
2. **Soft Deletion Behavior:** When a user deletes a podcast from the frontend, set its database `IsActive` column to `0` (soft delete) instead of physically dropping the row.
3. **Active Filtering:** Frontend and backend endpoints must only display and serve active podcasts (`IsActive = 1` / `true`). Inactive podcasts are omitted from feeds, search results, profile tabs, and metrics.
4. **Architectural Compliance:** Adhere strictly to the project's source-of-truth hierarchy and `AGENTS.md` rules:
   - Database schema changes originate directly from SQL Server.
   - EF Core models and context are scaffolded database-first (`dotnet ef dbcontext scaffold`). No manual modifications to `Models/` or `Data/KnomeDbContext.cs`.
   - Business logic resides strictly in `Services/` and `Repositories/`, keeping controllers thin.

---

## 2. Changes Implemented

### 2.1 Database Schema (SQL Server)
- Executed on database `LAPTOP-458\Knome`:
  ```sql
  ALTER TABLE Podcasts ADD IsActive BIT NOT NULL CONSTRAINT DF_Podcasts_IsActive DEFAULT 1;
  ```
- Verified that all existing podcasts defaulted to `IsActive = 1 (true)`.

### 2.2 EF Core Database-First Scaffolding
- Re-scaffolded database models cleanly using EF Core CLI:
  ```powershell
  dotnet ef dbcontext scaffold "Server=LAPTOP-458;Database=Knome;User ID=sa;Password=sa@123;TrustServerCertificate=True;" Microsoft.EntityFrameworkCore.SqlServer -o Models --context-dir Data --context KnomeDbContext --force
  ```
- Scaffolded outputs:
  - `Backend/Knome.API/Models/Podcast.cs`: Added `public bool IsActive { get; set; }`.
  - `Backend/Knome.API/Data/KnomeDbContext.cs`: Added `entity.Property(e => e.IsActive).HasDefaultValue(true);`.

### 2.3 Backend DTOs & Mapping
- **`Backend/Knome.API/DTOs/Podcasts/PodcastDto.cs`**:
  - Added property `public bool IsActive { get; set; } = true;`.
- **`Backend/Knome.API/Mapping/MediaProfile.cs`**:
  - Updated `PodcastSeriesDto.EpisodeCount` to count only active episodes:
    ```csharp
    .ForMember(dest => dest.EpisodeCount, opt => opt.MapFrom(src => src.Podcasts != null ? src.Podcasts.Count(p => p.IsActive) : 0));
    ```

### 2.4 Repositories & Data Access
- **`Backend/Knome.API/Repositories/PodcastRepository.cs`**:
  - `GetSeriesByIdAsync` and `GetAllSeriesAsync`: Eager-loaded episodes filtered by `p.IsActive`.
  - `GetPodcastsAsync`: Appended `.Where(p => p.IsActive)`.
  - `GetMyPodcastsAsync`: Appended `&& p.IsActive`.
  - `AddPodcastAsync`: Explicitly sets `podcast.IsActive = true`.
  - `DeletePodcastAsync`: Replaced `_db.Podcasts.Remove(podcast)` with soft-deletion:
    ```csharp
    podcast.IsActive = false;
    _db.Podcasts.Update(podcast);
    await _db.SaveChangesAsync();
    ```
- **`Backend/Knome.API/Repositories/SearchRepository.cs`**:
  - Filtered podcast searches: `_context.Podcasts.Where(p => p.IsActive)`.
- **`Backend/Knome.API/Repositories/FeedRepository.cs`**:
  - In `GetCandidatePodcastsAsync`, added `p.IsActive &&` to feed candidate retrieval.
- **`Backend/Knome.API/Repositories/ContentInteractionRepository.cs`**:
  - In `GetBookmarkedContentAsync`, marked bookmarked podcasts as unavailable/deleted if `podcast == null || !podcast.IsActive`.
- **`Backend/Knome.API/Controllers/AnalyticsController.cs`**:
  - Total podcasts metric counts only active podcasts: `await _context.Podcasts.CountAsync(p => p.IsActive);`.

### 2.5 Services & Business Logic
- **`Backend/Knome.API/Services/PodcastService.cs`**:
  - `GetPodcastAsync`: Verifies `podcast != null && podcast.IsActive`, throwing `NotFoundException` if inactive.
  - `UpdatePodcastAsync`: Verifies `podcast != null && podcast.IsActive`.
  - `DeletePodcastAsync`: Verifies `podcast != null && podcast.IsActive` prior to triggering soft delete in repository.
  - `IncrementViewCountAsync`: Verifies `exists != null && exists.IsActive`.
  - `CreatePodcastAsync`: Explicitly initializes `IsActive = true`.

### 2.6 Frontend UI
- **`knomeUI/frontend/src/pages/Podcasts.jsx`**:
  - In `fetchPodcastsData`, filtered out podcasts where `isActive === false || isActive === 0`.
  - In `handleDeletePodcast`, immediately removes deleted podcast ID from local state (`setPodcastEpisodes(prev => prev.filter(ep => ep.id !== podcastId))`) before re-fetching data.
  - In `rawEpisodes` filter, explicitly ignores episodes where `ep.isActive === false || ep.isActive === 0`.
- **`knomeUI/frontend/src/pages/Profile.jsx`**:
  - Filtered profile podcast tab to only display active podcasts.

---

## 3. Verification & Results

Automated verification script [verify_podcast_soft_delete.py](file:///d:/Knome%20main/scratch/verify_podcast_soft_delete.py) was executed against the live API and database:
1. **Authentication:** Authenticated as user `EMP001`.
2. **Active Listing:** `GET /api/podcasts` retrieved active podcasts, each having `isActive == true`.
3. **Creation:** `POST /api/podcasts` created a test podcast (`PodcastId: 20017`, `isActive: True`).
4. **Soft Deletion:** `DELETE /api/podcasts/20017` returned `200 OK: Podcast deleted successfully.`
5. **Single Get:** `GET /api/podcasts/20017` returned `404 Not Found`.
6. **List Exclusion:** `GET /api/podcasts` verified that `20017` was excluded from the response.
7. **Database Verification:** Direct SQL Server query `SELECT PodcastId, Title, IsActive FROM Podcasts WHERE PodcastId = 20017` confirmed the record persists in SQL Server with `IsActive = 0`.
8. **Build Validation:**
   - `dotnet build Backend/Knome.API -nologo`: 0 errors.
   - `npm run build` in `knomeUI/frontend`: built successfully, synced to `C:\inetpub\wwwroot\knome`.
