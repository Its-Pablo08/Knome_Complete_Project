# Development Journal Entry #139: Unique View Count Per User Enforcement Across All Content (Posts, Articles, Videos, Podcasts)

## Executive Summary
Enforced strict unique view count tracking across all 4 Knome content types: **Posts**, **Articles**, **Videos**, and **Podcasts**. If a user views or re-views an item multiple times across any session, the view count increments exactly once (1 view per user). Subsequent views by the same user return the authoritative view count without incrementing. Distinct users increment the view count by 1.

---

## Changes Implemented

### 1. Database Schema Updates (SQL Server)
- Created the dedicated interaction table `[dbo].[ContentViews]` with composite unique constraint `UK_ContentViews_User_Content(ContentType, ContentId, UserId)` and cascading user foreign key.
- Added `[ViewCount] INT NOT NULL DEFAULT 0` column to `[dbo].[Posts]` to give posts first-class view count parity with Articles, Videos, and Podcasts.
- Added nonclustered indices `IX_ContentViews_Content` and `IX_ContentViews_User` for O(1) existence checks.

### 2. Database-First Scaffolding
- Re-scaffolded via `dotnet ef dbcontext scaffold` strictly complying with architecture constraints:
  - Generated scaffolded model `Models/ContentView.cs`.
  - Updated `Models/Post.cs` with `ViewCount`.
  - Updated `Models/User.cs` with `ContentViews` collection navigation.
  - Updated `Data/KnomeDbContext.cs` entity configurations.

### 3. Core Interaction Repository & Service
- Added `RecordUniqueViewAsync(string contentType, long contentId, int userId)` and `HasUserViewedAsync(string contentType, long contentId, int userId)` to `IContentInteractionRepository` and `ContentInteractionRepository`.
- Added `RecordViewAsync(string contentType, long contentId, int userId)` and `HasUserViewedAsync` to `IContentInteractionService` and `ContentInteractionService`.
- Added `Post` view dictionary retrieval to `ContentInteractionService.GetContentSummariesBatchAsync`.
- Added `Post` view count resolution to `ContentInteractionRepository.GetContentViewCountAsync`.

### 4. Content Services & Endpoints
- **Articles**:
  - In `ArticleService.GetArticleAsync` and `IncrementViewCountAsync`: Replaced unconditional increments with `_interactionService.RecordViewAsync(ContentTypes.Article, articleId, currentUserId)`.
  - In `ArticleController.RecordView`: Passed `GetCurrentUserId()`.
- **Videos**:
  - In `VideoService.GetVideoAsync`: Replaced unconditional increments with `_interactionService.RecordViewAsync(ContentTypes.Video, videoId, currentUserId)`.
  - Added `IncrementViewCountAsync(long videoId, int currentUserId)` to `IVideoService` and `VideoService`.
  - Added `[HttpPost("{videoId:long}/view")]` to `VideoController`.
- **Podcasts**:
  - In `PodcastService.IncrementViewCountAsync`: Replaced unconditional increments with `_interactionService.RecordViewAsync(ContentTypes.Podcast, podcastId, currentUserId)`.
  - In `PodcastController.RecordView`: Passed `GetCurrentUserId()`.
- **Posts**:
  - Added `ViewCount` to `PostDto`.
  - In `PostService.GetPostAsync`: Invoked `_interactionService.RecordViewAsync(ContentTypes.Post, postId, currentUserId)`.
  - Added `IncrementViewCountAsync(long postId, int currentUserId)` to `IPostService` and `PostService`.
  - Added `[HttpPost("{postId:long}/view")]` to `PostController`.

### 5. Frontend Alignment
- `apiService.js`:
  - Added `recordView: (id) => apiClient.post('/posts/' + id + '/view')` to `postsApi`.
  - Added `recordView: (id) => apiClient.post('/Videos/' + id + '/view')` to `videosApi`.
- `Videos.jsx`:
  - Removed naive `localStorage.getItem('knome_video_views_' + id) + 1` local increment.
  - Linked to `videosApi.recordView(activeVideo.id)` to fetch authoritative unique views.
- `AudioContext.jsx`:
  - Removed optimistic client-side increment in `triggerRecordView`. View updates wait for backend unique response.
- `ArticleView.jsx`:
  - Removed optimistic +1 fallback. Displays authoritative unique view count returned by `recordArticleView`.
- `PostCard.jsx`:
  - Added view count display badge with visibility icon next to comment and share counts.
  - Auto-records unique post view once per user session.

---

## Verification Results
Executed automated verification against live SQL Server:
- **Post ID 10186**: User 1 view 1 = 1, User 1 view 2 = 1 (no increment), User 1 view 3 = 1 (no increment), User 2 view 1 = 2 (incremented +1), User 2 view 2 = 2 (no increment).
- **Article ID 10052**: User 1 view 1 = 5, User 1 view 2 = 5 (no increment), User 1 view 3 = 5 (no increment), User 2 view 1 = 6 (incremented +1), User 2 view 2 = 6 (no increment).
- **Video ID 20026**: User 1 view 1 = 1, User 1 view 2 = 1 (no increment), User 1 view 3 = 1 (no increment), User 2 view 1 = 2 (incremented +1), User 2 view 2 = 2 (no increment).
- **Podcast ID 20008**: User 1 view 1 = 4, User 1 view 2 = 4 (no increment), User 1 view 3 = 4 (no increment), User 2 view 1 = 5 (incremented +1), User 2 view 2 = 5 (no increment).
- Frontend bundle compiled and synchronized to `C:\inetpub\wwwroot\knome`.
