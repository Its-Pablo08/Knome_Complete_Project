# 29. Comment & Content Reaction Notifications (Post, Article, and Comments)

## Executive Summary
This update enhances the real-time notification engine for content reactions (likes and emojis) across Posts, Articles, and Comments. Whenever a user reacts to content, notifications are targeted and dispatched with precise routing URLs and live SignalR events to:
1. **Comment Author**: Receives a notification when another user likes/reacts to their comment (`"{reactorName} liked your comment on a post."` / `"{reactorName} liked your comment on an article."`), with a direct link to the associated post or article.
2. **Post Author**: Receives a notification when another user reacts to their post (`"{reactorName} liked your post."`), and also receives a notification when someone reacts to a comment on their post (`"{reactorName} liked a comment on your post."`).
3. **Article Author**: Receives a notification when another user reacts to their article (`"{reactorName} liked your article."`), and also receives a notification when someone reacts to a comment on their article (`"{reactorName} liked a comment on your article."`).

Self-reaction alerts and duplicate notifications are suppressed.

---

## Changes Implemented

### 1. Backend Service Layer (`ContentInteractionService.cs`)
- **Location**: `Backend/Knome.API/Services/ContentInteractionService.cs:ToggleReactionAsync`
- **Comment Reactions**:
  - When `contentType == ContentTypes.Comment`, the comment record is retrieved via `_repo.GetCommentByIdAsync(contentId)`.
  - **Comment Author Notification**: If `comment.UserId != userId`, the comment author is awarded `ReceiveLike` karma and sent a reaction notification with `relatedContentType: comment.ContentType` and `relatedContentId: comment.ContentId`.
  - **Parent Content Author Notification**: Retrieves the post or article author using `_repo.GetContentAuthorUserIdAsync(comment.ContentType, comment.ContentId)`. If the parent author is distinct from the reactor and the commenter (`parentAuthorId != userId && parentAuthorId != comment.UserId`), they receive a notification alerting them that someone reacted to a comment on their post/article.
- **Direct Post / Article Reactions**:
  - Author of the post receives: `"{reactorName} liked your post."` (`relatedContentType: Post`, `relatedContentId: postId`).
  - Author of the article receives: `"{reactorName} liked your article."` (`relatedContentType: Article`, `relatedContentId: articleId`).

### 2. Frontend Navbar & Notification Center (`Navbar.jsx`)
- **Location**: `knomeUI/frontend/src/components/layout/Navbar.jsx`
- Updated notification mapping (`mapNotificationItem`):
  - Detected `isReaction` using `type.includes('reaction') || type.includes('like') || msg.includes('liked') || msg.includes('reacted')`.
  - Configured icon `favorite`, rose color badge `text-rose-500`, and categorized as `Reactions`.
  - Ensured `targetUrl` fallback checks `relType === 'post'` or `relType === 'article'` in addition to message text.
  - Clicking any notification in the dropdown seamlessly navigates to `/posts?id={postId}` or `/article-view?id={articleId}`.

---

## Verification & Live Database Audit

The workflow was verified end-to-end against live SQL Server (`localhost`, database `Knome`):
1. **User EMP001** published Post `10110`.
2. **User EMP002** commented on Post `10110` (Comment `10102`).
3. **User EMP003** liked Comment `10102`.
   - Result: `EMP002` (comment author) received `EMP003 liked your comment on a post.` (target: `/posts?id=10110`).
   - Result: `EMP001` (post author) received `EMP003 liked a comment on your post.` (target: `/posts?id=10110`).
4. **User EMP003** liked Post `10110` directly.
   - Result: `EMP001` (post author) received `EMP003 liked your post.` (target: `/posts?id=10110`).
5. **User EMP002** commented on Article `10031` (Comment `10103`, authored by User `1057`).
6. **User EMP003** liked Comment `10103`.
   - Result: `EMP002` (comment author) received `EMP003 liked your comment on an article.` (target: `/article-view?id=10031`).
   - Result: User `1057` (article author) received `EMP003 liked a comment on your article.` (target: `/article-view?id=10031`).
7. **User EMP003** liked Article `10031` directly.
   - Result: User `1057` (article author) received `EMP003 liked your article.` (target: `/article-view?id=10031`).

Verified directly in SQL query:
```sql
SELECT TOP 6 NotificationId, UserId, EventType, Message, RelatedContentType, RelatedContentId 
FROM dbo.Notifications ORDER BY NotificationId DESC;
```
All 6 expected rows verified in `dbo.Notifications`.
