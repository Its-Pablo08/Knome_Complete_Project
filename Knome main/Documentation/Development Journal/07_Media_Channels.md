# Phase 7 — Media Channels (Video & Podcast Channels)

**Date**: 2026-07-09  
**Status**: Completed & Verified (`v0.7.0`)  
**Dependencies**: Phase 1 (Infrastructure), Phase 2 (Authentication Foundation), Phase 3 (User Profile & Management), Phase 4 (Content Foundation & Interaction Engine)

---

## 1. Objectives & Scope

Phase 7 expands the Knome.API platform beyond text-based interaction (`Posts` & `Articles`) into rich multimedia sharing and organized audio series per the Functional Requirements Document (`FR-VC-01..06`, `FR-PD-01..05`). Specifically:
- **Video Channel (`FR-VC-01..06`)**: Enterprise video sharing supporting internal streaming (`Stream`), external embeds (`OneDrive`), or direct file uploads (`LocalUpload`) up to **500 MB**, coupled with multi-tagging (`VideoTags`) and view analytics (`ViewCount + 1`).
- **Podcast Channel (`FR-PD-01..05`)**: Audio episode publishing (`<= 100 MB`) structured into thematic podcast series (`PodcastSeries`), tracking duration, cover imagery, category mapping, and series episode counts.
- **Phase 4 Polymorphic Engagement Delegation**: Real-time comments, reaction summaries, share counts, and bookmarks for all Videos and Podcasts are computed dynamically via `IContentInteractionService.GetContentSummaryAsync(ContentTypes.Video/Podcast, id, currentUserId)`.
- **Content Security Screening (`FR-SM-01`)**: Real-time evaluation of all video/podcast titles, descriptions, source URLs, thumbnail URLs, and cover images against `BlockedUrls` and `RestrictedKeywords`.

---

## 2. Architectural Design & Implementation

### 2.1 Database-First Compliance
All four base EF Core entity classes (`Models/Video.cs`, `Models/VideoTag.cs`, `Models/PodcastSeries.cs`, and `Models/Podcast.cs`) alongside their configurations in `KnomeDbContext.cs` were preserved without manual modification.

### 2.2 Video Channel Engine (`IVideoRepository` & `IVideoService`)
- **Source Validation & Size Limits**: Enforces `SourceType` must equal `Stream`, `OneDrive`, or `LocalUpload` (`VideoSourceTypes.IsValid`). Rejects any video where `FileSizeMb > 500` per `FR-VC-01`.
- **Tag Management**: When creating (`CreateVideoAsync`) or updating (`UpdateVideoAsync`) a video, the repository cleanly manages the `VideoTags` child entity collection (`(VideoId, Tag)`).
- **View Analytics (`FR-VC-04`)**: `GetVideoAsync(videoId, currentUserId)` runs `IncrementViewCountAsync(videoId)` in SQL Server (`ViewCount++`) upon every detail query.

### 2.3 Podcast Series & Episode Engine (`IPodcastRepository` & `IPodcastService`)
- **Admin-Governed Series (`FR-PD-01`)**: Creating, updating, or deleting structured `PodcastSeries` definitions is restricted to users holding `System Administrator` or `Community Admin` roles (`CheckIsAdminAsync`).
- **Episode Size Limits (`FR-PD-02`)**: Enforces `FileSizeMb <= 100 MB` per podcast episode requirements.
- **Series Episode Mapping**: Each `PodcastDto` maps its parent series metadata (`SeriesId`, `SeriesTitle`) while `PodcastSeriesDto` automatically computes `EpisodeCount` directly from `src.Podcasts.Count`.

---

## 3. Verification & Test Execution

Live verification was conducted via `scratch/VerifyMediaChannels` connected directly to SQL Server (`LAPTOP-462`, `Knome`):
1. **Video Upload & Tagging**: Created video with 3 distinct tags (`architecture`, `video`, `dotnet9`) and verified Phase 4 engagement score initialization (`0`).
2. **View Analytics Increment**: Queried video details (`GetVideoAsync`) and confirmed `ViewCount` incremented from `0` to `1` automatically per `FR-VC-04`.
3. **Security & Size Screening**: Attempted upload of a 650 MB video (`> 500 MB`) and a video containing a restricted keyword (`forbidden_media_token`); both were blocked with `BadRequestException` per `FR-VC-01` and `FR-SM-01`.
4. **Podcast Series & Episode Lifecycle**: Created `Cloud Tech Talk Series`, published a 40-minute episode (`45 MB`), and confirmed `EpisodeCount` updated to `1`.
5. **Podcast Size Enforcement**: Attempted upload of a 180 MB audio master (`> 100 MB`); blocked with `BadRequestException` per `FR-PD-02`.

---

## 4. Next Steps
With Phase 7 verified, the platform transitions to **Phase 8 (Dashboard Feed & Gamification)** to integrate the Hot Posts Ranking Engine into personalized feeds and deploy the Karma Points & Threshold Badges engine.
