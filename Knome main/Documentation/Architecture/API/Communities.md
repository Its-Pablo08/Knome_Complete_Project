# API Documentation – Communities & Membership Management (`Phase 5`)

Base URL: `/api/communities`  
Authentication: **Required** (`Bearer JWT`) across all endpoints.  

---

## 1. Community Discovery & Details

### GET `/api/communities?categoryId={id}&type={type}&search={term}&pageNumber=1&pageSize=20`
Retrieves a paginated directory of communities filtered by category, community type (`Public`, `Private`, `Default`), or search keywords matching community name or description (`FR-CM-08`).

#### Response (`200 OK`)
```json
{
  "statusCode": 200,
  "message": "Communities retrieved successfully.",
  "data": [
    {
      "communityId": 1,
      "name": "ASP.NET Core 9 Innovators",
      "description": "Open knowledge sharing on .NET 9 & Microservices",
      "bannerUrl": "/uploads/banners/dotnet9.png",
      "thumbnailUrl": "/uploads/thumbnails/dotnet9.png",
      "categoryId": 1,
      "categoryName": "Engineering & Architecture",
      "rules": "1. Be respectful\n2. Share code examples",
      "faq": "Q: How do I share code?\nA: Use markdown blocks.",
      "communityType": "Public",
      "createdByUserId": 1,
      "createdByUserName": "John Doe",
      "createdDate": "2026-07-09T07:15:00Z",
      "membersCount": 42,
      "postsCount": 15,
      "currentUserMembershipStatus": "Approved",
      "isCurrentUserAdmin": true
    }
  ]
}
```

### GET `/api/communities/my`
Retrieves all communities where the current authenticated user is an `Approved` member or `Community Admin`.

### GET `/api/communities/{communityId}`
Retrieves detailed profile information for a specific community (`FR-CM-08`).
- **Privacy Enforcement**: If `communityType == "Private"`, the user must be an `Approved` member, `Community Admin`, or `System Administrator`. Otherwise, HTTP `403 Forbidden` (`UnauthorizedException`) is returned.

---

## 2. Community Creation & Administration

### POST `/api/communities`
Creates a new community (`Public`, `Private`, `Default`). The creator is automatically added to `CommunityAdmins` and enrolled as an `Approved Moderator` (`FR-CM-01`).
- **Security Screening**: Text and URLs are screened against `BlockedUrls` and `RestrictedKeywords` (`FR-SM-01`).

#### Request Body (`application/json`)
```json
{
  "name": "Cloud Native Architecture",
  "description": "Kubernetes, Docker, and Service Mesh best practices",
  "bannerUrl": "/uploads/banners/k8s.png",
  "thumbnailUrl": "/uploads/thumbnails/k8s.png",
  "categoryId": 1,
  "rules": "Be constructive.",
  "faq": "See our internal wiki.",
  "communityType": "Public"
}
```

### PUT `/api/communities/{communityId}`
**Requires Role**: `Community Admin` (for this community) or `System Administrator` (`FR-CM-05`)  
Updates community details (`Name`, `Description`, `BannerUrl`, `ThumbnailUrl`, `CategoryId`, `Rules`, `Faq`).

---

## 3. Membership & Joining (`FR-CM-02`, `FR-CM-03`, `FR-CM-04`)

### POST `/api/communities/{communityId}/join`
Submits a request to join a community (`FR-CM-03`).
- If `Public`: User is instantly enrolled with `status = "Approved"`.
- If `Private`: User request is queued with `status = "Pending"` for Admin review.
- If user is currently `Banned`: HTTP `400 Bad Request` (`You have been banned from joining this community.`).

#### Response (`200 OK`)
```json
{
  "statusCode": 200,
  "message": "Community join processed successfully.",
  "data": {
    "communityId": 2,
    "userId": 2,
    "employeeId": "EMP002",
    "fullName": "Jane Smith",
    "designation": "Technical Lead",
    "profilePhotoUrl": "/uploads/profiles/emp002.jpg",
    "memberType": "Subscriber",
    "status": "Pending",
    "requestedDate": "2026-07-09T07:20:00Z",
    "decidedDate": null
  }
}
```

### POST `/api/communities/{communityId}/leave`
Leaves a community (`FR-CM-03`).
- **Safeguard 1 (`FR-CM-04`)**: If the community is `Default` (System Mandatory), leaving is blocked (`HTTP 400`).
- **Safeguard 2 (`FR-CM-05`)**: If the user is the **sole remaining Community Admin**, leaving is blocked (`HTTP 400`) until another admin is assigned.

### GET `/api/communities/{communityId}/members?status={status}&pageNumber=1&pageSize=20`
Retrieves community members filtered by status (`Approved`, `Pending`, `Rejected`, `Banned`).
- **Authorization**: If filtering by `Pending`, `Rejected`, or `Banned`, the caller must be a `Community Admin` for the community or `System Administrator`.

### PUT `/api/communities/{communityId}/members/{targetUserId}/decide`
**Requires Role**: `Community Admin` or `System Administrator`  
Approves, rejects, or bans a pending or existing member (`FR-CM-03`).

#### Request Body (`application/json`)
```json
{
  "status": "Approved"
}
```
*(Allowed values: `"Approved"`, `"Rejected"`, `"Banned"`)*

---

## 4. Admin Delegation (`FR-CM-05`)

### POST `/api/communities/{communityId}/admins/{targetUserId}`
**Requires Role**: `Community Admin` or `System Administrator`  
Promotes an existing `Approved` member to `Community Admin` and changes their member type to `Moderator`.

### DELETE `/api/communities/{communityId}/admins/{targetUserId}`
**Requires Role**: `Community Admin` or `System Administrator`  
Demotes an administrator back to a regular member (`Subscriber`). Blocks demotion if `targetUserId` is the sole remaining admin (`HTTP 400`).

---

## 5. Community Feed & Pinning Engine (`FR-CM-06`, `FR-CM-07`)

### GET `/api/communities/{communityId}/posts?pageNumber=1&pageSize=20`
Retrieves all published posts in the community ordered by `IsPinned DESC, PublishedDate DESC`.
- **Engagement Enriched**: Every post embeds `engagementSummary` from the **Phase 4 Content Foundation** (`commentsCount`, `reactionSummary`, `sharesCount`, `isBookmarkedByCurrentUser`, `engagementScore`).

#### Response (`200 OK`)
```json
{
  "statusCode": 200,
  "message": "Community posts retrieved successfully.",
  "data": [
    {
      "communityId": 1,
      "postId": 501,
      "authorUserId": 1,
      "authorEmployeeId": "EMP001",
      "authorFullName": "John Doe",
      "authorDesignation": "Senior Engineer",
      "authorProfilePhotoUrl": "/uploads/profiles/emp001.jpg",
      "contentText": "Important announcement regarding upcoming ASP.NET Core 9 release changes!",
      "attachmentUrls": [
        "/uploads/attachments/release-diagram.png"
      ],
      "publishedDate": "2026-07-09T07:15:00Z",
      "isPinned": true,
      "engagementSummary": {
        "contentType": "Post",
        "contentId": 501,
        "commentsCount": 14,
        "reactionSummary": {
          "totalCount": 32,
          "likeCount": 20,
          "celebrateCount": 12,
          "supportCount": 0,
          "heartCount": 0,
          "currentUserReactionType": "Like"
        },
        "sharesCount": 5,
        "isBookmarkedByCurrentUser": false,
        "engagementScore": 186
      }
    }
  ]
}
```

### POST `/api/communities/{communityId}/posts`
Creates a quick-share post inside the community (`FR-CM-07`). Screened against `BlockedUrls` and `RestrictedKeywords` before saving (`FR-SM-01`).

#### Request Body (`application/json`)
```json
{
  "contentText": "Here is our new architectural pattern for handling distributed interactions.",
  "attachmentUrls": [
    "/uploads/attachments/arch-diagram.png"
  ]
}
```

### PUT `/api/communities/{communityId}/posts/{postId}/pin`
**Requires Role**: `Community Admin` or `System Administrator`  
Pins or unpins a post (`FR-CM-06`). Enforces the strict rule that a community can have a **maximum of 3 pinned posts** at any time (`HTTP 400 Bad Request` if attempting to pin a 4th post).

#### Request Body (`application/json`)
```json
{
  "isPinned": true
}
```
