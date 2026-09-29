# Dashboard Feed & Gamification API Documentation

This module covers the core endpoints for retrieving personalized heterogeneous feeds, accessing the trending Hot Posts ranking engine, and the Gamification system (Karma points, Badges, and Leaderboards).

## Gamification (Karma) Endpoints

### 1. Get Personal Karma Balance
Retrieves the authenticated user's current Karma point balance, active badge level, and historical activity transaction records.
- **URL**: `/api/karma/my`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer Token`)
- **Success Response**: `200 OK`
  ```json
  {
    "statusCode": 200,
    "message": "Personal karma balance retrieved successfully.",
    "data": {
      "userId": 1,
      "totalPoints": 520,
      "badgeLevel": "Gold",
      "transactions": [
        {
          "transactionId": 5,
          "activityType": "ManualAward",
          "pointsAwarded": 500,
          "createdDate": "2026-07-09T08:30:00Z"
        }
      ]
    }
  }
  ```

### 2. Get Karma Leaderboard
Retrieves the enterprise-wide leaderboard ranking based on `TotalPoints`.
- **URL**: `/api/karma/leaderboard?top={top}`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer Token`)
- **Query Params**: `top` (int, default: 10, max: 100)

## Dashboard Feed Endpoints

### 1. Get Personalized Home Feed
Retrieves an aggregated feed comprising Posts, Articles, Videos, and Podcasts from users the current user follows, their community memberships, and enterprise-wide public broadcasts.
- **URL**: `/api/feed/home?contentType={contentType}&pageNumber={pageNumber}&pageSize={pageSize}`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer Token`)
- **Query Params**:
  - `contentType` (optional, filter by specific type: `Post`, `Article`, `Video`, `Podcast`)
  - `pageNumber` (int, default: 1)
  - `pageSize` (int, default: 20)
- **Success Response**: `200 OK`
  ```json
  {
    "statusCode": 200,
    "message": "Personalized home feed retrieved successfully.",
    "data": [
      {
        "contentType": "Post",
        "contentId": 9,
        "title": "",
        "textSummary": "Exploring the new Dashboard Feed in Phase 8!",
        "attachmentUrl": "https://cdn.knome.local/posts/img1.png",
        "authorUserId": 1,
        "authorFullName": "Gamification Master",
        "publishedDate": "2026-07-09T08:29:00Z",
        "hotScore": 1.77,
        "engagementSummary": { ... }
      }
    ]
  }
  ```

### 2. Get Hot Posts (Trending) Feed
Retrieves the highest-ranking content algorithmically calculated based on recent engagement volume and time decay logic.
- **URL**: `/api/feed/hot?window={window}&top={top}`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer Token`)
- **Query Params**:
  - `window` (string, `Daily`, `Weekly`, `Monthly`, default: `Daily`)
  - `top` (int, default: 10)

### 3. Get Dashboard Summary
A unified endpoint designed for the main mobile/web dashboard landing page. Aggregates Karma score, unread notification counts, and preview snippets of the personalized feed and hot posts.
- **URL**: `/api/feed/dashboard`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer Token`)
- **Success Response**: `200 OK`
  ```json
  {
    "statusCode": 200,
    "message": "Dashboard summary retrieved successfully.",
    "data": {
      "currentUserKarma": {
        "totalPoints": 520,
        "badgeLevel": "Gold"
      },
      "unreadNotificationsCount": 3,
      "personalizedFeed": [ ... ],
      "topHotPosts": [ ... ]
    }
  }
  ```
