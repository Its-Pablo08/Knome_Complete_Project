# Development Journal – Phase 6: Post & Article Engines

**Date**: 9 July 2026  
**Phase**: Phase 6 – Post & Article Engines (`FR-PC-01..07`, `FR-AB-01..07`)  
**Project**: Knome.API (Enterprise Knowledge Sharing & Technical Post Platform)  
**Status**: Completed ✅  

---

## 1. Executive Summary & Objective

Phase 6 implements two core content creation engines of the Knome platform:
1. **Quick-Share Posts (`FR-PC-01..07`)**: Standalone, short-form updates (up to 400 characters per business rules `FR-PC-01`), supporting multi-image attachments, audience targeting (`Everyone`, `Connections`, `Community`), and real-time employee `@mentions` (`PostMentions`).
2. **Technical Blogging Articles (`FR-AB-01..07`)**: Long-form rich text knowledge articles with structured tags (`ArticleTags`), multi-format attachments (`ArticleAttachments`), read-time estimation (`AvgReadTimeSeconds`), view analytics (`ViewCount`, `UniqueReadCount`), and automatic version audit history snapshots (`ArticleVersions`).

By preserving our **Database-First** (`scaffolded EF Core models`) and **Repository + Service** architecture, Phase 6 seamlessly embeds **Phase 4 (`IContentInteractionService`)** into all discovery and feed endpoints (`GetPostsAsync`, `GetArticlesAsync`), enriching every post and article item with real-time comment counts, reaction breakdowns, shares, and bookmark states without code duplication.

---

## 2. Entity & Schema Alignment (`Database-First`)

| Entity / Table | Primary Key | Key Fields & Constraints | Business Purpose & Role |
| :--- | :--- | :--- | :--- |
| **`Posts`** | `PostId` (BIGINT) | `ContentText` (VARCHAR 400), `AudienceType` (`Everyone`, `Connections`, `Community`), `Status` | Quick-share standalone posts (`FR-PC-01`). |
| **`PostAttachments`** | `AttachmentId` (BIGINT) | `PostId` (FK), `FileUrl` (VARCHAR 400), `FileType` (VARCHAR 20) | Stores media items associated with a post. |
| **`PostMentions`** | `(PostId, MentionedUserId)` | Many-to-many join table between `Post` and `User` (`p.MentionedUsers`) | Tracks employees `@mentioned` in posts (`FR-PC-02`). |
| **`Articles`** | `ArticleId` (BIGINT) | `Title` (max 150), `Description` (max 500), `ContentHtml`, `CategoryId`, `Status`, `ViewCount`, `AvgReadTimeSeconds` | Technical deep-dive blogging entity (`FR-AB-01`). |
| **`ArticleTags`** | `(ArticleId, Tag)` | Composite primary key `(ArticleId, Tag VARCHAR 50)` | Categorizes articles for searchable tags (`FR-AB-03`). |
| **`ArticleAttachments`** | `AttachmentId` (BIGINT) | `ArticleId` (FK), `FileUrl` (VARCHAR 400), `FileType` | Stores downloadable files, PDFs, and code bundles. |
| **`ArticleVersions`** | `VersionId` (BIGINT) | `ArticleId` (FK), `ContentHtml`, `EditedByUserId`, `EditedDate` (default `sysutcdatetime()`) | Captures version history snapshots whenever article content is updated (`FR-AB-02`). |

---

## 3. Core Functional & Technical Implementations

### A. Quick-Share Posts & `@Mentions` Engine (`FR-PC-01`, `FR-PC-02`, `FR-PC-03`)
- **Character Limit Enforcement**: `CreatePostValidator` and `UpdatePostValidator` enforce `MaximumLength(400)` on `ContentText` matching exact `FR-PC-01` specifications and database `VARCHAR(400)` column limits.
- **`@Mentions` Dictionary Join**: When a post is created or updated (`CreatePostDto.MentionedUserIds`), the target user IDs are loaded from `_db.Users` and inserted directly into `post.MentionedUsers`. EF Core translates this into clean rows inside `PostMentions` (`(PostId, MentionedUserId)`).
- **Phase 4 Engagement Enrichment**: `IPostService.GetPostsAsync` calls `_interactionService.GetContentSummaryAsync(ContentTypes.Post, post.PostId, currentUserId)` for each item, returning complete reaction and comment metrics (`PostDto.EngagementSummary`).

### B. Technical Blogging & Automatic Version Snapshotting (`FR-AB-01`, `FR-AB-02`, `FR-AB-04`)
- **Estimated Reading Time**: On creation (`CreateArticleAsync`) or update (`UpdateArticleAsync`), `CalculateAvgReadTimeSeconds()` divides word count by `3.33` words per second (~200 words per minute) to populate `AvgReadTimeSeconds`.
- **Automatic Audit Snapshots (`ArticleVersions`)**:
  - When an article is created, `ArticleRepository.AddArticleAsync` inserts the initial `ArticleVersion` snapshot alongside the article record (`VersionsCount = 1`).
  - When `UpdateArticleAsync` is called, `ArticleService` compares `article.ContentHtml != dto.ContentHtml`. If the content changed, a new `ArticleVersion` entity (`ContentHtml = dto.ContentHtml`, `EditedByUserId = currentUserId`, `EditedDate = DateTime.UtcNow`) is passed to `_repo.UpdateArticleAsync` and saved (`VersionsCount = 2+`).
- **View Count Analytics (`FR-AB-04`)**: Calling `GetArticleAsync(articleId)` automatically runs `_repo.IncrementViewCountAsync(articleId)`, incrementing `ViewCount` directly in SQL Server.

### C. Security Screening (`FR-SM-01`)
- All post text/attachments (`CreatePostAsync`, `UpdatePostAsync`) and article titles/descriptions/HTML (`CreateArticleAsync`, `UpdateArticleAsync`) are verified via `_interactionService.ValidateContentSecurityAsync()`, blocking domains registered in `BlockedUrls` and forbidden terms in `RestrictedKeywords`.

---

## 4. Live Database Verification Results (`scratch/VerifyPostsArticles`)

We compiled and executed our live verification suite (`VerifyPostsArticles.exe`) against the SQL Server database (`LAPTOP-462`, `Knome`). All 5 workflows verified 100%:

```text
=== Verifying Knome.API Phase 6 Post & Article Engines ===

[1] Testing Quick-Share Posts & @Mentions Engine (FR-PC-01, FR-PC-02, FR-PC-03)...
   -> Created Post ID: 8 by John Doe
   ✅ [PASS] @Mentioned user EMP002 and attachments stored and mapped accurately.

[2] Testing Security Screening & Content Restrictions (FR-PC-01, FR-PC-05)...
   ✅ [PASS] Security screening blocked malicious URL/keywords per FR-SM-01: 'Post content or attachments contain blocked URLs or restricted keywords.'

[3] Testing Technical Blogging & Initial Version Snapshot (FR-AB-01, FR-AB-02)...
   -> Created Article ID: 2 ('High-Throughput Event-Driven Services 639191791260492453')
   ✅ [PASS] Article created with initial version snapshot, tags, and read time estimate (7s).

[4] Testing Article View Analytics & Version Snapshot Audit Trail (FR-AB-02, FR-AB-04)...
   -> EMP002 viewed article. Current ViewCount: 2
   ✅ [PASS] Article ViewCount incremented on read per FR-AB-04.
   -> Updated Article ContentHtml. Total version snapshots: 2
   ✅ [PASS] Article update detected ContentHtml change and generated second audit snapshot per FR-AB-02.

[5] Testing Phase 4 Interaction Enriched Feed Discovery (FR-PC-03, FR-AB-03)...
   ✅ [PASS] Post discovery feed seamlessly enriched with Phase 4 real-time comment and reaction metrics!

=== All Phase 6 Post & Article Engine workflows verified successfully! ===
```

---

## 5. Files Created & Modified

### New Files Created
- `Constants/PostArticleConstants.cs`: Defines `PostAudiences`, `PostStatuses`, `ArticleStatuses`, and `AttachmentTypes`.
- `DTOs/Posts/*.cs`: `MentionedUserDto.cs`, `PostDto.cs`, `CreatePostDto.cs`, `UpdatePostDto.cs`.
- `DTOs/Articles/*.cs`: `ArticleVersionDto.cs`, `ArticleDto.cs`, `ArticleDetailDto.cs`, `CreateArticleDto.cs`, `UpdateArticleDto.cs`.
- `Validators/Posts/*.cs`: `CreatePostValidator.cs`, `UpdatePostValidator.cs`.
- `Validators/Articles/*.cs`: `CreateArticleValidator.cs`, `UpdateArticleValidator.cs`.
- `Mapping/PostArticleProfile.cs`: AutoMapper mappings for `Post`, `MentionedUserDto`, `Article`, `ArticleDetailDto`, and `ArticleVersionDto`.
- `Interfaces/IPostRepository.cs` & `Repositories/PostRepository.cs`: Data access for `Posts`, `PostAttachments`, and `PostMentions` join table.
- `Interfaces/IArticleRepository.cs` & `Repositories/ArticleRepository.cs`: Data access for `Articles`, `ArticleTags`, `ArticleAttachments`, and `ArticleVersions`.
- `Interfaces/IPostService.cs` & `Services/PostService.cs`: Business engine enforcing post limits, security screening, and engagement summaries.
- `Interfaces/IArticleService.cs` & `Services/ArticleService.cs`: Business engine orchestrating technical blogging, automatic audit snapshots, read time estimation, and view counts.
- `Controllers/PostController.cs` & `Controllers/ArticleController.cs`: 12 clean REST API endpoints (`/api/posts/...` & `/api/articles/...`).
- `scratch/VerifyPostsArticles/VerifyPostsArticles.csproj` & `Program.cs`: Live DB verification suite.

### Existing Files Modified
- `Extensions/ServiceCollectionExtensions.cs`: Registered `IPostRepository`, `IPostService`, `IArticleRepository`, and `IArticleService`.

---

## 6. Next Steps
With **Phase 6 (Post & Article Engines)** completed and verified, the platform is now ready to transition into **Phase 7 (Media Channels - Video & Podcast, `FR-VC-01..06`, `FR-PD-01..05`)**, where enterprise video channels (`MP4/MOV <= 500MB`, streaming/OneDrive links) and structured podcast series (`MP3/WAV <= 100MB`) will be implemented.
