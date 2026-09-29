# Development Journal: Phase 9 - Global Search & Discovery Engine

## 1. Objective
Implement the unified Search & Discovery engine as per `FR-SD-01`..`FR-SD-05` (the FRD's §5.14 "Search and Discovery" module; tracked in `PROJECT_STATUS` as `FR-GS-01..03`).

## 2. Starting State
A partial scaffold already existed (`SearchController`, `SearchService`, `SearchRepository`, `ISearch*`, DTOs, a FluentValidation validator, `SearchProfile`, and a `scratch/VerifyPhase9` stub). It had significant gaps versus the FRD and **did not compile**:
- `SearchItemDto.Id` was `int`, but `PostId`/`ArticleId`/`VideoId`/`PodcastId` are `long` → `Id = p.PostId` was a compile error. `EngagementScore` was `int` while `ContentSummaryDto.EngagementScore` is `long` → another compile error.
- Only `FR-SD-01` (partial) and partial-match (`FR-SD-03`) were covered. **Filters (`FR-SD-02`)**, **tag/author search (`FR-SD-03`)**, **Jobs in the unified index**, and **search history (`FR-SD-05`)** were unimplemented. `SearchFilterDto` was dead code.

## 3. Approach & Architecture
- **Repository (`SearchRepository`)** — one filtered `IQueryable` per enabled type (Users, Communities, Posts, Articles, Videos, Podcasts, Jobs), projecting to `SearchItemDto` entirely in SQL. All filtering (text, `dateFrom`/`dateTo`, `categoryId`, `departmentId`, `author`, `tags`), `PopularityScore` (view counts), and projection happen server-side; ordering and pagination of the merged cross-type result set happen in memory.
- **Service (`SearchService`)** — enriches the returned page of content items with live engagement via `IContentInteractionService.GetContentSummaryAsync`, and owns search-history `RecordSearchAsync` / `GetSearchHistoryAsync`.
- **Controller (`SearchController`)** — aligned to the Phase 8 convention: `ApiResponse<T>` envelopes, a `GetAuthenticatedUserId()` helper, and a new `GET /api/search/history` endpoint. The global search records history on each successful query.
- **DTOs** — `GlobalSearchRequestDto` gained `DateFrom/DateTo/CategoryId/DepartmentId/Author/Tags/SortBy/SortOrder`; `SearchItemDto.Id` → `long`, added `PopularityScore/CategoryName/DepartmentName`; `GlobalSearchResultDto` carries `Items`, `TotalCount`, pagination, and `TypeCounts` (faceted hit counts). Added `SearchHistoryDto`; removed the unused `SearchFilterDto`.
- **Validation** — enforced via data annotations (`[Required]`, `[Range]`, `[RegularExpression]`), which `[ApiController]` applies automatically (FluentValidation auto-validation is not enabled project-wide).

### Filter applicability
| Filter | Applies to |
| :--- | :--- |
| Department | Users, Jobs, and content authors (Community/Post excluded) |
| Category | Articles, Videos, Podcasts, Communities |
| Tags | Articles & Videos only |
| Author | Content types (Post/Article/Video/Podcast) |

When an inapplicable filter is supplied for a type, that type is excluded from results.

## 4. Key Decisions
1. **No database schema change.** The `SearchHistory` SQL table is **keyless** (as scaffolded in `KnomeDbContext` via `.HasNoKey()`). To honour the strict Database-First rules ("never modify scaffolded Models / DbContext", "DB changes must originate from SQL Server"), history inserts are issued as raw SQL (`ExecuteSqlRawAsync`) rather than altering the table or the scaffolded model. Reads use the existing keyless `SearchHistories` DbSet.
2. **Jobs included in unified search** (`FR-SD-01`) even though `PROJECT_STATUS` listed only People/Communities/Posts/Articles/Videos/Podcasts — the FRD is the primary business source and explicitly includes Jobs; noted as a conflict.
3. **Popularity sort** uses a static `PopularityScore` (Article/Video `ViewCount`; others `0`) to avoid an N+1 engagement query over the full result set — keeping `FR-SD-04` (< 2 s for ≤50-char queries) achievable.
4. **Tag search is AND-combined with text** (an item must match the keyword *and* carry a supplied tag); tags OR-match within the `tags` array.

## 5. Verification
An end-to-end integration harness (`scratch/VerifyPhase9`) mimics the full DI environment and runs against the live SQL Server (`localhost`, `Knome`). All 8 checks passed:
- Unified global search returns Post/Article/Community hits (`FR-SD-01`).
- `contentType` filter restricts results.
- Tag-based search returns the tagged article (`FR-SD-03`).
- Author-based search returns the author's content (`FR-SD-03`).
- Department filter returns the department user and excludes communities (`FR-SD-02`).
- `relevance`/`date`/`popularity` sorting orders correctly (`FR-SD-02`).
- Dedicated `users`/`communities`/`content` endpoints return hits.
- Search history records and de-duplicates the last 10 terms (`FR-SD-05`).

`dotnet build` is clean (0 warnings, 0 errors).

## 6. Next Steps
Phase 9 is complete. The platform is ready for the next phase (currently undefined in the FRD beyond Search & Discovery).
