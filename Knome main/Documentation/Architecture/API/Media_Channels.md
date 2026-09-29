# API Documentation – Media Channels (`Phase 7`: Video & Podcast)

Base URLs: `/api/videos` & `/api/podcasts`  
Authentication: **Required** (`Bearer JWT`) across all endpoints.  

---

## 1. Video Channel (`/api/videos`)

### GET `/api/videos?categoryId={id}&tag={tag}&search={term}&pageNumber=1&pageSize=20`
Retrieves paginated enterprise videos (`FR-VC-03`). Filterable by `categoryId`, exact `tag`, or text search across title and description.
- **Engagement Enriched**: Every video embeds `engagementSummary` (`ContentSummaryDto`) from **Phase 4 Content Foundation**.

#### Response (`200 OK`)
```json
{
  "statusCode": 200,
  "message": "Videos retrieved successfully.",
  "data": [
    {
      "videoId": 1,
      "uploaderUserId": 1,
      "uploaderEmployeeId": "EMP001",
      "uploaderFullName": "John Doe",
      "uploaderDesignation": "Senior Engineer",
      "uploaderProfilePhotoUrl": "/uploads/profiles/emp001.jpg",
      "title": "Architecture Keynote 2026",
      "description": "Deep dive into our enterprise data lakehouse and streaming video pipeline.",
      "categoryId": 2,
      "categoryName": "Engineering & Architecture",
      "thumbnailUrl": "https://stream.knome.internal/thumb/keynote-2026.jpg",
      "sourceType": "Stream",
      "sourceUrl": "https://stream.knome.internal/video/keynote-2026.mp4",
      "fileSizeMb": 250,
      "viewCount": 15,
      "uploadedDate": "2026-07-09T08:00:00Z",
      "tags": [ "architecture", "video", "dotnet9" ],
      "engagementSummary": {
        "contentType": "Video",
        "contentId": 1,
        "commentsCount": 3,
        "reactionSummary": {
          "totalCount": 12,
          "likeCount": 8,
          "celebrateCount": 4,
          "supportCount": 0,
          "heartCount": 0,
          "currentUserReactionType": "Celebrate"
        },
        "sharesCount": 1,
        "isBookmarkedByCurrentUser": true,
        "engagementScore": 54
      }
    }
  ]
}
```

### GET `/api/videos/my`
Retrieves all videos uploaded by the currently authenticated user.

### GET `/api/videos/{videoId}`
Retrieves complete video details including author profile, category name, tags list, and Phase 4 engagement metrics (`FR-VC-04`).
- **Analytics**: Automatically increments `ViewCount + 1` in SQL Server (`FR-VC-04`).

### POST `/api/videos`
Uploads or publishes a new video (`FR-VC-01`).
- **File Size Limit**: `FileSizeMb` cannot exceed **500 MB** (`FR-VC-01`).
- **Source Type**: `SourceType` must be `Stream`, `OneDrive`, or `LocalUpload`.
- **Security Screening**: Title, description, and URLs undergo real-time screening against `BlockedUrls` and `RestrictedKeywords` (`FR-SM-01`).

#### Request Body (`application/json`)
```json
{
  "title": "Microservices Resiliency Workshop",
  "description": "Practical guide to Polly circuit breakers in .NET 9 APIs",
  "categoryId": 2,
  "thumbnailUrl": "https://stream.knome.internal/thumb/workshop.jpg",
  "sourceType": "Stream",
  "sourceUrl": "https://stream.knome.internal/video/workshop.mp4",
  "fileSizeMb": 320,
  "tags": [ "dotnet", "resiliency", "microservices" ]
}
```

### PUT `/api/videos/{videoId}`
**Requires Role**: Uploader of the video, `Community Admin`, or `System Administrator` (`FR-VC-05`).  
Updates video metadata, category, source URLs, or tags list. Re-screens against security restrictions.

### DELETE `/api/videos/{videoId}`
**Requires Role**: Uploader of the video, `Community Admin`, or `System Administrator` (`FR-VC-05`).  
Deletes the video and all associated `VideoTags`.

---

## 2. Podcast Series & Episodes (`/api/podcasts`)

### GET `/api/podcasts/series`
Retrieves all structured podcast series (`FR-PD-01`). Includes dynamic `episodeCount` for each series.

#### Response (`200 OK`)
```json
{
  "statusCode": 200,
  "message": "Podcast series retrieved successfully.",
  "data": [
    {
      "seriesId": 1,
      "title": "Cloud Tech Talk Series",
      "description": "Weekly episodes interviewing system architects across global pods.",
      "episodeCount": 12
    }
  ]
}
```

### GET `/api/podcasts/series/{seriesId}`
Retrieves metadata for a specific podcast series (`FR-PD-01`).

### POST `/api/podcasts/series`
**Requires Role**: `System Administrator` or `Community Admin` (`FR-PD-01`).  
Creates a new structured podcast series definition.

#### Request Body (`application/json`)
```json
{
  "title": "Security & Governance Spotlight",
  "description": "Exploring DPDP Act compliance and zero-trust API architecture"
}
```

### PUT `/api/podcasts/series/{seriesId}`
**Requires Role**: `System Administrator` or `Community Admin` (`FR-PD-01`).  
Updates podcast series title and description.

### DELETE `/api/podcasts/series/{seriesId}`
**Requires Role**: `System Administrator` or `Community Admin` (`FR-PD-01`).  
Deletes the podcast series definition (`SeriesId` is unlinked on existing episodes).

---

### GET `/api/podcasts?seriesId={id}&categoryId={id}&search={term}&pageNumber=1&pageSize=20`
Retrieves paginated podcast episodes (`FR-PD-03`). Filterable by `seriesId`, `categoryId`, or text search across title and description.
- **Engagement Enriched**: Embeds real-time comment/reaction summary from Phase 4.

#### Response (`200 OK`)
```json
{
  "statusCode": 200,
  "message": "Podcasts retrieved successfully.",
  "data": [
    {
      "podcastId": 1,
      "uploaderUserId": 1,
      "uploaderEmployeeId": "EMP001",
      "uploaderFullName": "John Doe",
      "uploaderDesignation": "Senior Engineer",
      "title": "Ep 1: Resilient Redis Clusters",
      "description": "Discussing hybrid cache strategies and failover metrics.",
      "coverImageUrl": "https://podcast.knome.internal/covers/ep1.jpg",
      "durationSeconds": 2400,
      "categoryId": 2,
      "categoryName": "Engineering & Architecture",
      "seriesId": 1,
      "seriesTitle": "Cloud Tech Talk Series",
      "fileSizeMb": 45,
      "uploadedDate": "2026-07-09T08:00:00Z",
      "engagementSummary": {
        "contentType": "Podcast",
        "contentId": 1,
        "commentsCount": 2,
        "reactionSummary": {
          "totalCount": 6,
          "likeCount": 5,
          "celebrateCount": 1,
          "supportCount": 0,
          "heartCount": 0,
          "currentUserReactionType": "Like"
        },
        "sharesCount": 0,
        "isBookmarkedByCurrentUser": false,
        "engagementScore": 22
      }
    }
  ]
}
```

### GET `/api/podcasts/my`
Retrieves all podcast episodes uploaded by the currently authenticated user.

### GET `/api/podcasts/{podcastId}`
Retrieves complete podcast episode details including `Series` info and author profile (`FR-PD-04`).

### POST `/api/podcasts`
Uploads a new podcast episode (`FR-PD-02`).
- **File Size Limit**: `FileSizeMb` cannot exceed **100 MB** (`FR-PD-02`).
- **Security Screening**: Title, description, and cover image URL are screened for blocked URLs/keywords (`FR-SM-01`).

#### Request Body (`application/json`)
```json
{
  "title": "Ep 2: Uncompressed Audio Master",
  "description": "Discussion on real-time signal processing in .NET",
  "coverImageUrl": "https://podcast.knome.internal/covers/ep2.jpg",
  "durationSeconds": 1800,
  "categoryId": 2,
  "seriesId": 1,
  "fileSizeMb": 55
}
```

### PUT `/api/podcasts/{podcastId}`
**Requires Role**: Uploader of the episode, `Community Admin`, or `System Administrator` (`FR-PD-04`).  
Updates podcast episode metadata, duration, cover image, series linkage, or category. Re-screens against security restrictions.

### DELETE `/api/podcasts/{podcastId}`
**Requires Role**: Uploader of the episode, `Community Admin`, or `System Administrator` (`FR-PD-04`).  
Deletes the podcast episode.
