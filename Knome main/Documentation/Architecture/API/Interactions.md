# API Documentation – Content Interactions & Moderation Engine (`Phase 4`)

Base URL: `/api/interactions`  
Authentication: **Required** (`Bearer JWT`) across all endpoints.  

---

## 1. Security Screening & Screening Verification

### POST `/api/interactions/validate`
Screens text and URLs against the database `BlockedUrls` and `RestrictedKeywords` tables before publishing (`FR-SM-01`).

#### Request Body (`application/json`)
```json
{
  "text": "Check out this awesome new project setup!",
  "url": "https://knome.local/docs/setup"
}
```

#### Response (`200 OK`)
```json
{
  "statusCode": 200,
  "message": "Content screened successfully.",
  "data": {
    "isValid": true,
    "blockedUrlsFound": [],
    "restrictedKeywordsFound": []
  }
}
```

---

## 2. Polymorphic Engagement Summary (`Hot Posts Score`)

### GET `/api/interactions/summary/{contentType}/{contentId}`
Retrieves total comments, aggregated reactions, shares, current user bookmark status, and calculated Hot Posts score (`FR-HP-01`).
- `contentType`: Allowed values: `"Post"`, `"Article"`, `"Video"`, `"Podcast"`

#### Response (`200 OK`)
```json
{
  "statusCode": 200,
  "message": "Content summary retrieved successfully.",
  "data": {
    "contentType": "Post",
    "contentId": 105,
    "commentsCount": 12,
    "reactionSummary": {
      "totalCount": 25,
      "likeCount": 15,
      "celebrateCount": 5,
      "supportCount": 3,
      "heartCount": 2,
      "currentUserReactionType": "Celebrate"
    },
    "sharesCount": 4,
    "isBookmarkedByCurrentUser": true,
    "engagementScore": 151
  }
}
```
*(Formula: `(25 * 3) + (12 * 5) + (4 * 4) = 75 + 60 + 16 = 151`)*

---

## 3. Polymorphic Comments (`FR-CI-02`, `FR-CI-05`)

### GET `/api/interactions/{contentType}/{contentId}/comments`
Retrieves all top-level comments along with their nested replies (`Replies`).

#### Response (`200 OK`)
```json
{
  "statusCode": 200,
  "message": "Comments retrieved successfully.",
  "data": [
    {
      "commentId": 5,
      "contentType": "Post",
      "contentId": 105,
      "userId": 1,
      "authorEmployeeId": "EMP001",
      "authorFullName": "John Doe",
      "authorDesignation": "Senior Engineer",
      "authorProfilePhotoUrl": "/uploads/profiles/emp001.jpg",
      "parentCommentId": null,
      "commentText": "This clean architecture looks fantastic!",
      "imageUrl": null,
      "createdDate": "2026-07-09T07:10:00Z",
      "repliesCount": 1,
      "replies": [
        {
          "commentId": 6,
          "contentType": "Post",
          "contentId": 105,
          "userId": 2,
          "authorEmployeeId": "EMP002",
          "authorFullName": "Jane Smith",
          "authorDesignation": "Technical Lead",
          "authorProfilePhotoUrl": null,
          "parentCommentId": 5,
          "commentText": "Agreed, keeping interactions unified avoids so much boilerplate.",
          "imageUrl": null,
          "createdDate": "2026-07-09T07:12:00Z",
          "repliesCount": 0,
          "replies": []
        }
      ]
    }
  ]
}
```

### POST `/api/interactions/{contentType}/{contentId}/comments`
Creates a top-level comment or a direct reply (`ParentCommentId`). Nesting beyond 2 levels (`top-level -> reply`) is blocked with HTTP `400 Bad Request`.

#### Request Body (`application/json`)
```json
{
  "commentText": "Great point about the polymorphic key!",
  "parentCommentId": 5,
  "imageUrl": null
}
```

### PUT `/api/interactions/comments/{commentId}`
Updates comment text. Restricted to the comment author (`403 Forbidden` if unauthorized).

#### Request Body (`application/json`)
```json
{
  "commentText": "Updated text clarifying the index architecture.",
  "imageUrl": null
}
```

### DELETE `/api/interactions/comments/{commentId}`
Deletes a comment and all nested replies. Restricted to the comment author or Administrators (`Community Admin`, `HR Administrator`, `System Administrator`).

---

## 4. Polymorphic Reactions (`FR-CI-01`)

### GET `/api/interactions/{contentType}/{contentId}/reactions`
Returns aggregated reaction counts (`Like`, `Celebrate`, `Support`, `Heart`) and the authenticated user's current reaction.

### POST `/api/interactions/{contentType}/{contentId}/reactions`
Toggles a reaction (`Like`, `Celebrate`, `Support`, `Heart`).
- Clicking the **same reaction type** un-reacts (removes reaction).
- Clicking a **different reaction type** updates existing reaction.

#### Request Body (`application/json`)
```json
{
  "reactionType": "Celebrate"
}
```

---

## 5. Shares & Bookmarks (`FR-CI-03`, `FR-CI-04`)

### POST `/api/interactions/{contentType}/{contentId}/share`
Logs a content share transaction.
- `sharedToType`: Allowed values: `"Timeline"`, `"Community"`, `"User"`, `"External"`

#### Request Body (`application/json`)
```json
{
  "sharedToType": "Community",
  "sharedToId": 101
}
```

### GET `/api/interactions/bookmarks`
Retrieves all bookmarked items saved by the current authenticated user (`ordered by SavedDate DESC`).

### POST `/api/interactions/{contentType}/{contentId}/bookmark`
Toggles bookmark state. Returns `{ "isBookmarked": true }` when saved, `{ "isBookmarked": false }` when removed.

---

## 6. Moderation & Governance (`FR-SM-02`, `FR-SM-03`)

### POST `/api/interactions/{contentType}/{contentId}/report`
Reports inappropriate or violating content.
- `reasonCode`: Allowed values: `"Spam"`, `"Harassment"`, `"Inappropriate"`, `"Copyright"`, `"Other"`

#### Request Body (`application/json`)
```json
{
  "reasonCode": "Spam"
}
```

### GET `/api/interactions/reports?pageNumber=1&pageSize=20`
**Requires Role**: `Community Admin`, `HR Administrator`, or `System Administrator`  
Retrieves paginated moderation reports that are currently `Pending` or `Under Review`.

### PUT `/api/interactions/reports/{reportId}/resolve`
**Requires Role**: `Community Admin`, `HR Administrator`, or `System Administrator`  
Resolves or updates a moderation report.

#### Request Body (`application/json`)
```json
{
  "status": "Resolved",
  "actionTaken": "Reviewed, no violation found. Dismissed."
}
```
*(Note: `actionTaken` is bounded to `VARCHAR(40)` by database schema and is truncated/validated server-side).*
