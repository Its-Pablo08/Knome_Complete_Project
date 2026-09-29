# Development Journal – Phase 4: Content Foundation & Interaction Engine

**Date**: 9 July 2026  
**Phase**: Phase 4 – Content Foundation & Interaction Engine  
**Project**: Knome.API (Enterprise Knowledge Sharing & Technical Post Platform)  
**Status**: Completed ✅  

---

## 1. Executive Summary & Objective

Phase 4 establishes the **Content Foundation & Interaction Engine**, the architectural backbone enabling rich, cross-cutting user engagement (`Comments`, `Reactions`, `Shares`, `Bookmarks`) across all platform content domains (`Posts`, `Articles`, `Videos`, `Podcasts`). 

By adhering strictly to our **Database-First** approach (`41 base tables` on SQL Server instance `LAPTOP-462`), we verified directly from `INFORMATION_SCHEMA.TABLES` that user interactions are NOT consolidated into a single table. Instead, they are distributed across **4 separate entities** (`Comments`, `Reactions`, `Shares`, `Bookmarks`), every single one of which uses a polymorphic `(ContentType, ContentId)` foreign key structure.

To prevent downstream repository explosion across Phases 5 through 8 (`Communities`, `Posts/Articles`, `Videos/Podcasts`, `Dashboard Feed`), Phase 4 encapsulates all four interaction tables alongside security screening (`BlockedUrls`, `RestrictedKeywords`) and governance (`ModerationReports`) into a single, highly performant service facade: **`IContentInteractionService`**.

---

## 2. Polymorphic Schema Alignment & Entities

The `ContentInteractionRepository` abstracts and manages queries across seven distinct database entities without requiring manual schema modifications:

| Entity / Table | Primary Key | Polymorphic Key Fields | Target Domain / Allowed Values |
| :--- | :--- | :--- | :--- |
| **`Comments`** | `CommentId` (BIGINT) | `ContentType` + `ContentId` | `"Post"`, `"Article"`, `"Video"`, `"Podcast"` (`ParentCommentId` for replies) |
| **`Reactions`** | `ReactionId` (BIGINT) | `ContentType` + `ContentId` | `"Post"`, `"Article"`, `"Video"`, `"Podcast"` (`Like`, `Celebrate`, `Support`, `Heart`) |
| **`Shares`** | `ShareId` (BIGINT) | `ContentType` + `ContentId` | `"Post"`, `"Article"`, `"Video"`, `"Podcast"` (`SharedToType`: Timeline, Community, User) |
| **`Bookmarks`** | `(UserId, ContentType, ContentId)` | `ContentType` + `ContentId` | Composite primary key saving items for user profile access |
| **`ModerationReports`**| `ReportId` (BIGINT) | `ContentType` + `ContentId` | User-reported violations (`ActionTaken` strictly bounded to `VARCHAR(40)`) |
| **`BlockedUrls`** | `BlockedUrlId` (INT) | `UrlPattern` | Security table checked before text/comment publishing (`FR-SM-01`) |
| **`RestrictedKeywords`** | `KeywordId` (INT) | `Keyword` | Security table checked against regex boundaries before publishing (`FR-SM-01`) |

---

## 3. Key Functional & Technical Implementations

### A. Real-Time Security Screening (`FR-SM-01`)
- Before any comment, post, or article is saved to the database, `IContentInteractionService.ValidateContentSecurityAsync(text, url)` screens the input against all patterns in `BlockedUrls` and exact regex boundaries in `RestrictedKeywords`.
- If a violation is detected, the transaction is immediately aborted with a `BadRequestException("Comment contains blocked URLs or restricted keywords.")`.

### B. Nested Comments with Exact 2-Level Limit (`FR-CI-02`, `FR-CI-05`)
- `AddCommentAsync` enforces the business rule (`FR-CI-05`) that comments can only nest up to two levels: top-level comments (`ParentCommentId = null`) and direct replies (`ParentCommentId = topLevelId`).
- Attempting to reply to a reply (`ParentCommentId = replyId`) is rejected server-side with `BadRequestException("Comments can only be nested up to 2 levels (Top-level comment and Reply).")`.
- `GetContentCommentsAsync` eagerly joins `Comment.User` and resolves `AuthorFullName`, `AuthorDesignation`, and `AuthorEmployeeId` using AutoMapper to prevent N+1 query overhead.

### C. Seamless Reaction Toggling (`FR-CI-01`)
- `ToggleReactionAsync` provides intuitive single-click engagement:
  1. If the user has **no existing reaction** on `(ContentType, ContentId)`, a new `Reaction` record is inserted.
  2. If the user clicks a **different reaction type** (e.g., switching from `Like` to `Celebrate`), the existing reaction record is updated in place (`UpdateReactionAsync`).
  3. If the user clicks the **same reaction type** again, the reaction is deleted (`RemoveReactionAsync`, un-reacting cleanly).

### D. Bookmarking & Target Sharing (`FR-CI-03`, `FR-CI-04`)
- `ToggleBookmarkAsync` toggles composite records in `Bookmarks` (`UserId, ContentType, ContentId`), returning `true` when saved and `false` when removed.
- `ShareContentAsync` logs share transactions specifying target destinations (`Timeline`, `Community`, `User`, `External`).

### E. Polymorphic Engagement & Hot Posts Formula (`FR-HP-01`)
- `GetContentSummaryAsync(contentType, contentId)` aggregates exact counts across `Comments`, `Reactions`, and `Shares`, computing the standardized Hot Posts Ranking Score in real time:
  $$\text{Engagement Score} = (\text{Reactions} \times 3) + (\text{Comments} \times 5) + (\text{Shares} \times 4)$$
- This exact metric powers feed ranking algorithms (`HotPostsScoreCache`) and gamification dashboards (`KarmaBalances`).

### F. Moderation & Governance (`FR-SM-02`, `FR-SM-03`)
- Users submit reports (`ReportContentAsync`) specifying `ReasonCode` (`Spam`, `Harassment`, `Inappropriate`, `Copyright`, `Other`).
- Administrators (`Community Admin`, `HR Administrator`, `System Administrator`) access pending reports via `GetPendingReportsAsync` and resolve them via `ResolveReportAsync`.
- **Database Schema Protection**: Because `ModerationReports.ActionTaken` is scaffolded as `VARCHAR(40)`, `ResolveReportValidator` (`MaximumLength(40)`) and service-level truncation guards ensure 100% protection against SQL `String or binary data would be truncated (Error 2628)` exceptions.

---

## 4. Live Database Verification Results (`scratch/VerifyInteractions`)

We built and ran `VerifyInteractions.exe` against the live SQL Server instance `LAPTOP-462` (`Knome` database). Every single Phase 4 workflow passed:

```text
=== Verifying Knome.API Phase 4 Content Foundation & Interaction Engine ===

[1] Testing Security Screening (FR-SM-01)...
   ✅ [PASS] Safe content validated cleanly.
   ✅ [PASS] Malicious comment blocked by engine: 'Comment contains blocked URLs or restricted keywords.'

[2] Testing Polymorphic Comments & 2-Level Nesting Limit (FR-CI-02, FR-CI-05)...
   -> EMP001 added top-level comment (ID: 5)
   -> EMP002 added reply (ID: 6) to parent ID 5
   ✅ [PASS] 3rd level comment blocked per FR-CI-05: 'Comments can only be nested up to 2 levels (Top-level comment and Reply).'
   ✅ [PASS] Eagerly resolved top-level comment with accurate nested reply count (1).

[3] Testing Polymorphic Reactions & Seamless Toggling (FR-CI-01)...
   -> EMP001 reacted 'Like', EMP002 reacted 'Celebrate'. Total: 2
   -> EMP001 switched to 'Celebrate'. Like count: 0, Celebrate count: 2
   ✅ [PASS] EMP001 un-reacted. Remaining celebrate count: 1, Total count: 1

[4] Testing Bookmarks & Shares (FR-CI-03, FR-CI-04)...
   -> EMP001 toggled bookmark: True (Saved)
   ✅ [PASS] Post successfully listed in EMP001 bookmarks.
   ✅ [PASS] Post shared to Community ID 101 (ShareId: 3).

[5] Testing Polymorphic Summary & Hot Posts Formula (FR-HP-01)...
   -> Comments: 6, Reactions: 1, Shares: 3
   -> Calculated Hot Posts Engagement Score: 45
   ✅ [PASS] Hot Posts formula verified accurately (45) across the 4 separate interaction tables!

[6] Testing Moderation Reporting & Administrator Resolution (FR-SM-02, FR-SM-03)...
   -> EMP002 reported post for 'Spam' (ReportId: 3, Status: Pending)
   ✅ [PASS] Report listed successfully in Administrator pending queue.
   ✅ [PASS] HR Admin Alice resolved report: Status = Resolved, Action = 'Reviewed, no violation found. Dismissed.'

=== All Phase 4 Content Foundation & Interaction workflows verified successfully! ===
```

---

## 5. Files Created & Modified

### New Files Created
- `Constants/ContentConstants.cs`: Defines `ContentTypes`, `ReactionTypes`, `SharedToTypes`, `ReportStatuses`, and `ReportReasonCodes`.
- `Exceptions/UnauthorizedException.cs`: Exception returned for ownership/permission violations (`403 Forbidden`).
- `DTOs/Interactions/*.cs`:
  - `CommentDto.cs`, `CreateCommentDto.cs`, `UpdateCommentDto.cs`
  - `ReactionDto.cs`, `ToggleReactionDto.cs`, `ReactionSummaryDto.cs`
  - `ShareDto.cs`, `CreateShareDto.cs`, `BookmarkDto.cs`
  - `ModerationReportDto.cs`, `CreateReportDto.cs`, `ResolveReportDto.cs`
  - `ContentSummaryDto.cs`, `ContentValidationResultDto.cs`, `ValidateContentRequestDto.cs`
- `Validators/Interactions/*.cs`: FluentValidation rules (`CreateCommentValidator`, `UpdateCommentValidator`, `ToggleReactionValidator`, `CreateShareValidator`, `CreateReportValidator`, `ResolveReportValidator`).
- `Mapping/InteractionProfile.cs`: AutoMapper mappings resolving user navigation properties.
- `Interfaces/IContentInteractionRepository.cs` & `Repositories/ContentInteractionRepository.cs`
- `Interfaces/IContentInteractionService.cs` & `Services/ContentInteractionService.cs`
- `Controllers/InteractionController.cs`: 13 REST API endpoints (`/api/interactions/...`).
- `scratch/VerifyInteractions/VerifyInteractions.csproj` & `Program.cs`: Live DB verification suite.

### Existing Files Modified
- `Middleware/ExceptionHandlingMiddleware.cs`: Added `UnauthorizedException` mapping returning HTTP status `403 Forbidden`.
- `Extensions/ServiceCollectionExtensions.cs`: Registered `IContentInteractionRepository` and `IContentInteractionService`.

---

## 6. Next Steps
With the polymorphic **Content Foundation & Interaction Engine** completed and verified across all four underlying database tables, Phase 5 (**Communities & Membership Management**, `FR-CM-01..09`) can now be implemented rapidly by plugging `IContentInteractionService` directly into community feeds (`CommunityPost`).
