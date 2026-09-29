# Architectural Decision Record (ADR): Implementing Content Foundation Before Communities

**Date**: 9 July 2026  
**Module**: Knome (Knowledge Sharing, Group & Technical Post)  
**Status**: Verified with Live SQL Server Schema & Recommended  
**Context**: Evaluation of Actual Database Schema (`41 Base Tables`) vs. FRD Implementation Order (`Communities` vs. `Content Foundation`)

---

## 1. Executive Summary & Verification Results

By directly interrogating the live SQL Server database (`Server=LAPTOP-462;Database=Knome;...`) via `INFORMATION_SCHEMA.TABLES`, we confirmed the exact structural layout of user interactions and content entities across the **41 base tables**.

### Schema Confirmation: Separate Entities vs. Single Table
We confirm that **interactions are NOT implemented as a single `Content_Interactions` table**.  
Instead, interactions are implemented as **four separate, distinct database tables (entities)**:
1. **`Comments`** (Table #9)
2. **`Reactions`** (Table #30)
3. **`Shares`** (Table #34)
4. **`Bookmarks`** (Table #7)

Furthermore, all four separate interaction tables strictly share the exact same **Polymorphic Foreign Key Design**: every table joins back to the primary content domains (`Posts`, `Articles`, `Videos`, `Podcasts`) via `(ContentType, ContentId)`.

### Architectural Recommendation
We **strongly recommend implementing a common Content Foundation (`Content Interaction & Moderation Engine`) as Phase 4 prior to implementing Communities (`Phase 5`)**.

Because interactions are split across **four separate tables (`Comments`, `Reactions`, `Shares`, `Bookmarks`)**, skipping a Content Foundation would force every downstream service (`CommunityService`, `PostService`, `ArticleService`, `VideoService`, `PodcastService`, `FeedService`) to inject, coordinate, and write redundant queries across 4 separate repositories every time a single post or article is rendered. Creating `IContentInteractionService` in Phase 4 provides a unified, polymorphic facade that cleanly manages all 4 interaction tables behind one service.

---

## 2. Actual SQL Server Schema Analysis (`41 Base Tables`)

The verified schema separates primary content creation from cross-cutting user engagement tables using `(ContentType, ContentId)`:

### Primary Content Domains
- **`Posts`** (`PostId`, `AuthorUserId`, `ContentText`, `AudienceType`, `Status`, `PublishedDate`...)
- **`Articles`** (`ArticleId`, `AuthorUserId`, `Title`, `ContentHtml`, `CategoryId`, `Status`...)
- **`Videos`** (`VideoId`, `UploaderUserId`, `Title`, `SourceUrl`, `ViewCount`...)
- **`Podcasts`** (`PodcastId`, `UploaderUserId`, `Title`, `DurationSeconds`...)

### Separate Interaction Entities (Polymorphic `Content_Master` Pattern)
| Table / Entity | Primary Key | Polymorphic Key Fields | Target Domain / Allowed Values |
| :--- | :--- | :--- | :--- |
| **`Comments`** | `CommentId` (BIGINT) | `ContentType` (NVARCHAR) + `ContentId` (BIGINT) | `"Post"`, `"Article"`, `"Video"`, `"Podcast"` (Supports nested `ParentCommentId`) |
| **`Reactions`** | `ReactionId` (BIGINT) | `ContentType` (NVARCHAR) + `ContentId` (BIGINT) | `"Post"`, `"Article"`, `"Video"`, `"Podcast"` (`Like`, `Celebrate`, `Support`, `Heart`) |
| **`Shares`** | `ShareId` (BIGINT) | `ContentType` (NVARCHAR) + `ContentId` (BIGINT) | `"Post"`, `"Article"`, `"Video"`, `"Podcast"` (`SharedToType`: Timeline, Community, User) |
| **`Bookmarks`** | `(UserId, ContentType, ContentId)` | `ContentType` (NVARCHAR) + `ContentId` (BIGINT) | `"Post"`, `"Article"`, `"Video"`, `"Podcast"` (Composite PK saving items for profile) |
| **`ModerationReports`**| `ReportId` (BIGINT) | `ContentType` (NVARCHAR) + `ContentId` (BIGINT) | `"Post"`, `"Article"`, `"Video"`, `"Podcast"` (User-submitted moderation queue) |

---

## 3. Impact Analysis Across Downstream FRD Verticals

### A. Communities (`FR-CM-01..09` & `FR-CI-01..05`)
- When a user loads a Community Feed (`FR-CM-08`), the API must render recent posts (`CommunityPosts` joined with `Posts`) along with their **reaction counts, user-specific like state, nested comments (`FR-CI-02..05`), share counts, and bookmark state**.
- If we build Communities without `IContentInteractionService`, `CommunityService` must directly query `Comments`, `Reactions`, `Shares`, and `Bookmarks` for every single feed item.

### B. Posts & Articles (`FR-PC-01..07`, `FR-AB-01..07`)
- Quick-share posts and rich-text articles share identical interaction requirements (`FR-CI-01..05`).
- Additionally, `FR-PC-07` and `FR-SM-01` mandate **real-time URL security checks against the `BlockedUrls` table** before publishing any content. A centralized Content Foundation (`IContentInteractionService`) performs this check uniformly.

### C. Videos & Podcasts (`FR-VC-01..06`, `FR-PD-01..05`)
- Videos and Podcasts require displaying view count, likes, comments, and shares per media item (`FR-VC-04`, `FR-PD-04`). They query the exact same `Reactions` and `Comments` tables by passing `ContentType = "Video"` or `"Podcast"`.

### D. Dashboard Feed & Hot Posts Ranking (`FR-DB-01..08`, `FR-HP-01..04`)
- The Hot Posts Ranking Engine (`FR-HP-01`) computes dynamic scores across all 4 content domains using the formula:
  $$\text{Engagement Score} = (\text{Views} \times 1) + (\text{Reactions} \times 3) + (\text{Comments} \times 5) + (\text{Shares} \times 4)$$
- A centralized `IContentInteractionRepository` can aggregate counts across `Reactions`, `Comments`, and `Shares` in a single polymorphic query (`GetEngagementSummaryAsync(contentType, contentId)`), allowing `HotPostsScoreCache` to update rapidly without coordinating 4 separate feature repositories.

---

## 4. Comparison: Ad-Hoc vs. Foundation-First Approach

| Architectural Criteria | Approach A: Communities First (Without Foundation) | Approach B: Content Foundation First (Recommended) |
| :--- | :--- | :--- |
| **Repository Injection Complexity** | **High**: Because `Comments`, `Reactions`, `Shares`, and `Bookmarks` are 4 separate tables, every domain service (`CommunityService`, `PostService`, `ArticleService`) must inject and manage 4 separate interaction repositories (`ICommentRepository`, `IReactionRepository`, `IShareRepository`, `IBookmarkRepository`). | **Clean & Minimal**: Domain services inject exactly one facade (`IContentInteractionService`), which internally coordinates the 4 separate interaction tables via `ContentInteractionRepository`. |
| **Code Duplication (DRY)** | **High**: `CommunityService`, `PostService`, `ArticleService`, `VideoService`, and `PodcastService` each write identical LINQ queries to check if the current user liked, bookmarked, or commented on an item. | **Zero**: Single `GetContentSummaryAsync(contentType, contentId, currentUserId)` method reused across all 5 verticals. |
| **Database Alignment** | **Poor**: Treats the 4 separate polymorphic interaction tables as fragmented vertical concerns. | **Perfect**: Directly embraces the `(ContentType, ContentId)` polymorphic schema by unifying the 4 separate tables under one interaction engine. |
| **Security & Moderation (`FR-SM-01`)** | **Scattered**: URL checking against `BlockedUrls` and reporting (`ModerationReports`) must be duplicated inside every controller that accepts user text. | **Centralized**: `IContentInteractionService.ValidateAndSanitizeAsync()` guarantees all text submitted across all verticals is checked against `BlockedUrls`. |
| **Implementation Velocity** | **Slower Overall**: Initial Community endpoints take slightly less setup, but every subsequent phase (`Phase 5..8`) is bogged down by managing 4 separate interaction repositories. | **Faster Overall**: Builds a clean, reusable facade in Phase 4. All subsequent phases (`Phase 5..8`) become lightweight, highly focused domain implementations. |

---

## 5. Recommended Revised Implementation Roadmap

We recommend inserting the **Content Foundation (`Phase 4`)** immediately before **Communities (`Phase 5`)**:

- **Phase 1**: Core Infrastructure Setup (`Completed ✅`)
- **Phase 2**: Authentication Foundation & SSO Readiness (`Completed ✅`)
- **Phase 3**: User Profile & User Management (`Completed ✅`)
- **Phase 4**: **Content Foundation & Interaction Engine (`Recommended Next`)**
  - Encapsulates the 4 separate interaction entities (`Comments`, `Reactions`, `Shares`, `Bookmarks`), URL security (`BlockedUrls`), and reporting (`ModerationReports`) behind one polymorphic service facade.
  - Deliverables: `IContentInteractionRepository`, `ContentInteractionRepository`, `IContentInteractionService`, `ContentInteractionService`, and `ContentInteractionController`.
- **Phase 5**: **Communities & Membership Management (`FR-CM-01..09`)**
  - Manages `Communities`, `CommunityMembers`, `CommunityAdmins`, and `CommunityPosts`, delegating all post interactions directly to `IContentInteractionService`.
- **Phase 6**: **Posts & Articles Verticals (`FR-PC-01..07`, `FR-AB-01..07`)**
- **Phase 7**: **Video & Podcast Channels (`FR-VC-01..06`, `FR-PD-01..05`)**
- **Phase 8**: **Dashboard Feed, Hot Posts Engine & Gamification (`FR-DB-01`, `FR-HP-01`, `FR-KP-01`)**

---

## 6. Conclusion
By confirming directly with SQL Server that interactions are split across **four separate tables (`Comments`, `Reactions`, `Shares`, `Bookmarks`)**, the architectural need for a centralized **Content Foundation (`Phase 4`)** becomes indisputable. Implementing a unified interaction service next will prevent severe repository sprawl and ensure a clean, production-ready, and maintainable codebase across all remaining phases of the Knome enterprise platform.
