# Search & Discovery API Documentation

This module implements the unified Search & Discovery engine (Phase 9 — `FR-SD-01`..`FR-SD-05`). It provides a single global search across **Users, Communities, Posts, Articles, Videos, Podcasts, and Jobs**, with filtering, tag/author search, relevance/date/popularity sorting, and per-user search history.

All responses use the standard envelope: `{ "success": true, "statusCode": 200, "message": "...", "data": ... }`.

---

## 1. Global Search

Unified, filtered, paginated search across all entity types. Results are returned as a single merged, cross-type list with per-type hit counts for faceted navigation.

- **URL**: `/api/search`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer Token`)

### Query Parameters

| Param | Type | Required | Notes |
| :--- | :--- | :---: | :--- |
| `query` | string | ✅ | Free-text keyword (partial/contains match). Max 100 chars. |
| `pageNumber` | int | ❌ | Default `1`, max `1000`. |
| `pageSize` | int | ❌ | Default `20`, max `100`. |
| `contentType` | string | ❌ | Restrict to one type: `User`, `Community`, `Post`, `Article`, `Video`, `Podcast`, `Job`. |
| `dateFrom` | datetime | ❌ | Inclusive lower bound on the entity date. |
| `dateTo` | datetime | ❌ | Inclusive upper bound on the entity date. |
| `categoryId` | int | ❌ | Filter by category (Articles, Videos, Podcasts, Communities). |
| `departmentId` | int | ❌ | Filter by department (Users, Jobs, and content authors). |
| `author` | string | ❌ | Filter content by author display name. |
| `tags` | string[] | ❌ | Tag-based search — Articles & Videos that carry any of the given tags. |
| `sortBy` | string | ❌ | `relevance` (default), `date`, or `popularity`. |
| `sortOrder` | string | ❌ | `asc` or `desc` (default `desc`). |

- **Success Response**: `200 OK`
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "Search results retrieved successfully.",
    "data": {
      "items": [
        {
          "contentType": "Article",
          "id": 12,
          "title": "Understanding Gamification",
          "summary": "A deep dive into how Knome scores content.",
          "authorFullName": "Jane Doe",
          "authorEmployeeId": "EMP102",
          "createdDate": "2026-07-09T08:29:00Z",
          "engagementScore": 18,
          "popularityScore": 240,
          "thumbnailUrl": null,
          "authorProfilePhotoUrl": "https://cdn.knome.local/u/102.png",
          "categoryName": "Engineering",
          "departmentName": null
        }
      ],
      "totalCount": 7,
      "pageNumber": 1,
      "pageSize": 20,
      "typeCounts": { "Article": 3, "User": 2, "Community": 1, "Post": 1 }
    }
  }
  ```
- **Notes**:
  - Each successful global search is recorded in the signed-in user's search history (`FR-SD-05`).
  - `engagementScore` is the live reaction/comment total, enriched per returned item. `popularityScore` is a static view-count metric used for popularity sorting.
  - Content IDs are `long`; people/community/job IDs are widened to `long` for a uniform shape.

---

## 2. Search Users

- **URL**: `/api/search/users?query={query}&pageNumber={pageNumber}&pageSize={pageSize}`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer Token`)
- Returns `200 OK` with `data: SearchItemDto[]` of type `User`.

## 3. Search Communities

- **URL**: `/api/search/communities?query={query}&pageNumber={pageNumber}&pageSize={pageSize}`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer Token`)
- Returns `200 OK` with `data: SearchItemDto[]` of type `Community`.

## 4. Search Content

- **URL**: `/api/search/content?query={query}&contentType={contentType}&pageNumber={pageNumber}&pageSize={pageSize}`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer Token`)
- **Query Params**: `contentType` optional (`Post`, `Article`, `Video`, `Podcast`); omitted searches all content types.
- Returns `200 OK` with `data: SearchItemDto[]` of content types only.

## 5. Search History

Retrieves the signed-in user's last 10 distinct recent search terms (`FR-SD-05`).

- **URL**: `/api/search/history?count={count}`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer Token`)
- **Query Params**: `count` (int, default `10`)
- **Success Response**: `200 OK`
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "Search history retrieved successfully.",
    "data": [
      { "searchTerm": "gamification", "searchedDate": "2026-07-09T09:10:00Z" },
      { "searchTerm": "phase 8", "searchedDate": "2026-07-09T08:55:00Z" }
    ]
  }
  ```

---

## Architecture Notes

- **Repository (`SearchRepository`)**: builds a filtered `IQueryable` per enabled type, projecting to `SearchItemDto` in SQL; ordering and pagination of the merged cross-type result set happen in memory.
- **Service (`SearchService`)**: enriches the returned page of content with live engagement metrics via `IContentInteractionService.GetContentSummaryAsync`, and owns search-history recording/retrieval.
- **Search History table** is keyless (as scaffolded), so history inserts are issued as raw SQL rather than through EF change-tracking — no scaffolded model or `DbContext` was modified.
- **Filter applicability**: Department applies to Users/Jobs/authored content; Category applies to Articles/Videos/Podcasts/Communities; Tags apply to Articles & Videos only. When an inapplicable filter is supplied for a given type, that type is excluded from results.
