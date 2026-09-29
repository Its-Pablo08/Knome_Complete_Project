# Dev Journal 27: Comment Likes, Author Like Notifications, and Nested Comment Replies

## Overview
Implemented comment likes for Posts and Articles, author like notifications (for Posts, Articles, and Comments), and verified/fixed the nested comment reply workflow across the Knome enterprise platform.

## Key Changes

### 1. Backend: Knome.API
- **`ContentConstants.cs`**:
  - Added `public const string Comment = "Comment";` to `ContentTypes`.
  - Added `Comment` to `ContentTypes.All`, `Normalize()`, and `IsValid()`.
- **`ContentInteractionRepository.cs`**:
  - Added `ContentTypes.Comment` branch to `GetContentAuthorUserIdAsync` to resolve comment author from `_db.Comments`.
- **`CommentDto.cs`**:
  - Added `LikesCount` (int) and `IsLiked` (bool) properties.
- **`IContentInteractionService.cs` & `InteractionController.cs`**:
  - Added optional `currentUserId` parameter to `GetContentCommentsAsync` to compute user-specific like states.
  - Forwarded `GetCurrentUserId()` from controller.
- **`ContentInteractionService.cs`**:
  - In `GetContentCommentsAsync`: Queried polymorphic `Reactions` table for comment IDs to populate `LikesCount` and `IsLiked` for top-level comments and nested replies.
  - In `ToggleReactionAsync`: Enriched notification message with reactor's name (`"{reactorName} liked your comment."`, `"{reactorName} liked your post."`, `"{reactorName} liked your article."`).
  - In `AddCommentAsync`: Enriched notification message with commenter's name (`"{commenterName} commented on your {contentType}."`, `"{commenterName} replied to your comment on a {contentType}."`).

### 2. Frontend: knomeUI
- **`PostCard.jsx`**:
  - Updated comment fetch and mapping to preserve `likesCount` and `isLiked`.
  - In `CommentThread`: Wired "Like" button to `interactionsApi.toggleReaction('Comment', comment.id, 'Like')` with optimistic UI update and active styling.
  - Added UI Avatars fallback to prevent broken profile pictures.
  - Verified and enhanced inline `submitReply` to pass `parentCommentId` and append optimistic/persisted reply.
- **`ArticleView.jsx`**:
  - Wired article `handleLike` to `interactionsApi.toggleReaction('Article', article.id, 'Like')` so article likes persist and notify authors.
  - Fetched live reaction counts/status on article load.
  - In `ArticleCommentThread`: Wired "Like" button to `interactionsApi.toggleReaction('Comment', comment.id, 'Like')` with active styling and like counter.
  - Wired reply handler with `parentCommentId` and UI Avatars fallback.

## Verification
- Backend compiled with 0 errors (`dotnet build -nologo`).
- Frontend compiled with 0 errors (`npm run build`).
- Live REST and SQL Server verification:
  - Comment like stored in `Reactions` table (`ContentType = 'Comment'`).
  - Comment author received notification: `"Loveneesh Sharma liked your comment."`.
  - Post author received notification: `"Loveneesh Sharma liked your post."`.
  - Article author received notification: `"Loveneesh Sharma liked your article."`.
  - Comment reply created with parentCommentId and parent author notified.
