# API Documentation – Post & Article Engines (`Phase 6`)

Base URLs: `/api/posts` & `/api/articles`  
Authentication: **Required** (`Bearer JWT`) across all endpoints.  

---

## 1. Quick-Share Posts (`/api/posts`)

### GET `/api/posts?audienceType={audience}&search={term}&pageNumber=1&pageSize=20`
Retrieves paginated standalone quick-share posts (`FR-PC-03`). Filterable by `audienceType` (`Everyone`, `Connections`, `Community`) or text search.
- **Engagement Enriched**: Every post embeds `engagementSummary` (`ContentSummaryDto`) from **Phase 4 Content Foundation**.

#### Response (`200 OK`)
```json
{
  "statusCode": 200,
  "message": "Posts retrieved successfully.",
  "data": [
    {
      "postId": 8,
      "authorUserId": 1,
      "authorEmployeeId": "EMP001",
      "authorFullName": "John Doe",
      "authorDesignation": "Senior Engineer",
      "authorProfilePhotoUrl": "/uploads/profiles/emp001.jpg",
      "contentText": "Exciting milestone reached in .NET 9 API performance optimizations! @Jane Smith check this out!",
      "audienceType": "Everyone",
      "status": "Published",
      "publishedDate": "2026-07-09T07:30:00Z",
      "createdDate": "2026-07-09T07:30:00Z",
      "attachmentUrls": [
        "/uploads/posts/perf-graph.png"
      ],
      "mentionedUsers": [
        {
          "userId": 2,
          "employeeId": "EMP002",
          "fullName": "Jane Smith"
        }
      ],
      "engagementSummary": {
        "contentType": "Post",
        "contentId": 8,
        "commentsCount": 4,
        "reactionSummary": {
          "totalCount": 15,
          "likeCount": 10,
          "celebrateCount": 5,
          "supportCount": 0,
          "heartCount": 0,
          "currentUserReactionType": "Celebrate"
        },
        "sharesCount": 2,
        "isBookmarkedByCurrentUser": false,
        "engagementScore": 76
      }
    }
  ]
}
```

### GET `/api/posts/my`
Retrieves all posts authored by the currently authenticated user (`Draft`, `Published`, `Archived`).

### GET `/api/posts/{postId}`
Retrieves a specific post by its ID (`FR-PC-03`).

### POST `/api/posts`
Creates a new quick-share post (`FR-PC-01`).
- **Character Limit**: `ContentText` can be at most **400 characters** per business rules (`FR-PC-01`).
- **Security Screening**: Screened against `BlockedUrls` and `RestrictedKeywords` (`FR-SM-01`).

#### Request Body (`application/json`)
```json
{
  "contentText": "Rolling out our new clean architecture guidelines today across all engineering pods.",
  "audienceType": "Everyone",
  "status": "Published",
  "attachmentUrls": [
    "/uploads/posts/guidelines-diagram.png"
  ],
  "mentionedUserIds": [ 2, 3 ]
}
```

### PUT `/api/posts/{postId}`
**Requires Role**: Author of the post, `Community Admin`, or `System Administrator` (`FR-PC-04`).  
Updates post content, target audience, status, attachments, or `@mentions`.

### DELETE `/api/posts/{postId}`
**Requires Role**: Author of the post, `Community Admin`, or `System Administrator` (`FR-PC-04`).  
Deletes the post and all associated attachments (`PostAttachments`).

---

## 2. Technical Blogging Articles (`/api/articles`)

### GET `/api/articles?categoryId={id}&tag={tag}&status={status}&search={term}&pageNumber=1&pageSize=20`
Retrieves paginated technical blogging articles (`FR-AB-03`). Filterable by `categoryId`, `tag`, `status` (`Published`), or text search across title and description.
- **Engagement Enriched**: Embeds real-time comment/reaction summary from Phase 4.

#### Response (`200 OK`)
```json
{
  "statusCode": 200,
  "message": "Articles retrieved successfully.",
  "data": [
    {
      "articleId": 2,
      "authorUserId": 1,
      "authorEmployeeId": "EMP001",
      "authorFullName": "John Doe",
      "authorDesignation": "Senior Engineer",
      "authorProfilePhotoUrl": "/uploads/profiles/emp001.jpg",
      "title": "Building High-Throughput Event-Driven Services",
      "description": "Deep dive into clean architecture, outbox pattern, and distributed resilience",
      "categoryId": 1,
      "categoryName": "Engineering & Architecture",
      "status": "Published",
      "publishedDate": "2026-07-09T07:30:00Z",
      "createdDate": "2026-07-09T07:30:00Z",
      "viewCount": 2,
      "uniqueReadCount": 1,
      "avgReadTimeSeconds": 7,
      "tags": [
        "dotnet9",
        "architecture",
        "microservices"
      ],
      "attachmentUrls": [
        "/uploads/articles/arch.pdf"
      ],
      "versionsCount": 2,
      "engagementSummary": {
        "contentType": "Article",
        "contentId": 2,
        "commentsCount": 1,
        "reactionSummary": {
          "totalCount": 8,
          "likeCount": 6,
          "celebrateCount": 2,
          "supportCount": 0,
          "heartCount": 0,
          "currentUserReactionType": "Like"
        },
        "sharesCount": 1,
        "isBookmarkedByCurrentUser": true,
        "engagementScore": 39
      }
    }
  ]
}
```

### GET `/api/articles/my`
Retrieves all articles authored by the currently authenticated user (`Draft`, `Published`, `Archived`).

### GET `/api/articles/{articleId}`
Retrieves complete article details including full **Version History (`Versions`)** (`FR-AB-02`, `FR-AB-04`).
- **Analytics**: Automatically increments `ViewCount + 1` (`FR-AB-04`).

#### Response (`200 OK` - `ArticleDetailDto`)
```json
{
  "statusCode": 200,
  "message": "Article retrieved successfully.",
  "data": {
    "articleId": 2,
    "title": "Building High-Throughput Event-Driven Services",
    "contentHtml": "<h1>Overview v2</h1><p>Our microservices run on .NET 9 using clean architecture, outbox pattern, and distributed Redis caching for high throughput...</p>",
    "viewCount": 3,
    "avgReadTimeSeconds": 7,
    "versionsCount": 2,
    "versions": [
      {
        "versionId": 5,
        "articleId": 2,
        "contentHtml": "<h1>Overview v2</h1><p>Our microservices run on .NET 9 using clean architecture, outbox pattern, and distributed Redis caching for high throughput...</p>",
        "editedByUserId": 1,
        "editedByUserName": "John Doe",
        "editedDate": "2026-07-09T07:31:00Z"
      },
      {
        "versionId": 4,
        "articleId": 2,
        "contentHtml": "<h1>Overview</h1><p>Our microservices run on .NET 9 using clean architecture and outbox patterns to guarantee reliability across bounded contexts...</p>",
        "editedByUserId": 1,
        "editedByUserName": "John Doe",
        "editedDate": "2026-07-09T07:30:00Z"
      }
    ],
    "engagementSummary": {
      "contentType": "Article",
      "contentId": 2,
      "commentsCount": 1
    }
  }
}
```

### POST `/api/articles`
Creates a technical article (`FR-AB-01`).
- **Automatic Audit Snapshot (`FR-AB-02`)**: Inserts the initial `ArticleVersion` record.
- **Read Time Estimation**: `AvgReadTimeSeconds` is calculated automatically.
- **Security Screening (`FR-SM-01`)**: Title, description, and HTML are screened for blocked URLs/keywords.

#### Request Body (`application/json`)
```json
{
  "title": "Distributed Caching Strategies in .NET 9",
  "description": "Comparing Redis, HybridCache, and In-Memory patterns for enterprise APIs",
  "contentHtml": "<h1>Introduction</h1><p>In high-scale systems, effective caching reduces latency...</p>",
  "categoryId": 1,
  "status": "Published",
  "tags": [ "dotnet", "redis", "caching" ],
  "attachmentUrls": [
    "/uploads/articles/caching-benchmarks.pdf"
  ]
}
```

### PUT `/api/articles/{articleId}`
**Requires Role**: Author of the article, `Community Admin`, or `System Administrator` (`FR-AB-06`).  
Updates article title, description, HTML content, category, status, tags, or attachments.
- **Automatic Versioning (`FR-AB-02`)**: If `contentHtml` is modified, the service automatically creates and attaches a new `ArticleVersion` audit snapshot (`EditedByUserId = currentUserId`, `EditedDate = DateTime.UtcNow`).

### DELETE `/api/articles/{articleId}`
**Requires Role**: Author of the article, `Community Admin`, or `System Administrator` (`FR-AB-06`).  
Deletes the article along with all historical `ArticleVersions`, `ArticleTags`, and `ArticleAttachments`.
