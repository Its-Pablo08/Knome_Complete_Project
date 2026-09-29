# Development Journal — Entry 26: Admin Post Deletion & Cascade Hardening

## Overview & Objective
Resolved an issue where administrators (System Administrator, Community Admin, HR Administrator) were unable to delete posts created by other users or faced errors/UI restrictions during post deletion.

## Root Causes Identified
1. **Service Role Restrictions in `PostService.cs`**:
   - `CheckIsAuthorOrAdminAsync` strictly checked only `r.RoleName == Roles.SystemAdmin || r.RoleName == Roles.HRAdmin`.
   - It did not check for `Roles.CommunityAdmin`, role codes (`"SYSADM"`, `"HRADM"`, `"CADM"`), or generic admin roles.
2. **Foreign Key Constraint Violations on Hard Deletion in `PostRepository.cs`**:
   - `DeletePostAsync` did not clean up `PostMentions`, `PostAudienceCommunities`, and `PostAudienceUsers`.
   - Any post with mentioned users or community/user audience bindings failed with SQL Server foreign key constraint errors when attempting to delete the row from `[dbo].[Posts]`.
   - Comment replies (`ParentCommentId`) and comment-level reactions/bookmarks also risked foreign key failures if parent comments were removed first.
3. **Frontend Permission Check & Event Dispatch in `PostCard.jsx`**:
   - `PostCard.jsx` checked `currentUser?.userId === post.author?.userId`, but `mapPost` structures authors with `id` (`post.author.id`), not `userId`.
   - The delete button checked only `currentUser?.role === 'SYSADM' || currentUser?.role === 'HRADM'`, excluding Community Admins and users whose roles are stored as full names or in `roles` arrays.
   - Deleted posts were not optimistically removed from the local feed state or broadcasted via `post-deleted` custom event.

## Key Changes Made

### 1. Backend Service Layer (`Backend/Knome.API/Services/PostService.cs`)
- Updated `CheckIsAuthorOrAdminAsync`:
  ```csharp
  private async Task CheckIsAuthorOrAdminAsync(Post post, int currentUserId)
  {
      if (post.AuthorUserId == currentUserId) return;

      var user = await _db.Users.Include(u => u.Roles).FirstOrDefaultAsync(u => u.UserId == currentUserId);
      if (user == null || !user.Roles.Any(r => 
          r.RoleName == Roles.SystemAdmin || r.RoleCode == "SYSADM" ||
          r.RoleName == Roles.HRAdmin || r.RoleCode == "HRADM" ||
          r.RoleName == Roles.CommunityAdmin || r.RoleCode == "CADM" ||
          (r.RoleName != null && r.RoleName.Contains("Admin")) ||
          (r.RoleCode != null && r.RoleCode.Contains("ADM"))))
      {
          throw new UnauthorizedException("You must be the author of this post or an Administrator to modify/delete it.");
      }
  }
  ```

### 2. Backend Repository Layer (`Backend/Knome.API/Repositories/PostRepository.cs`)
- Updated `DeletePostAsync(Post post)` to atomically clear all referencing foreign key tables before removing the post:
  - Clears `[dbo].[PostMentions]`, `[dbo].[PostAudienceCommunities]`, `[dbo].[PostAudienceUsers]`, `[dbo].[CommunityPosts]`, and `[dbo].[PostAttachments]`.
  - Cleans up child comment reactions, bookmarks, and threaded replies before removing top-level comments.
  - Clears post-level reactions, bookmarks, shares, karma transactions, moderation reports, and notifications.
  - Deletes the post from `[dbo].[Posts]`.

### 3. Frontend UI (`knomeUI/frontend`)
- **`PostCard.jsx`**:
  - Broadened `isUserAdmin` to recognize all admin roles (`SYSADM`, `HRADM`, `CADM`, `System Administrator`, `HR Administrator`, `Community Admin`, `isAdmin`).
  - Corrected author ID comparison (`post.author?.id || post.authorUserId === currentUser?.userId || currentUser?.id`).
  - Improved `handleDeletePost` with fallback `post.id || post.postId`, global `post-deleted` event dispatch, and toast notifications.
- **`Posts.jsx` & `Dashboard.jsx`**:
  - Added listeners for `post-deleted` custom event to immediately filter out deleted posts from local feed state without requiring a manual page refresh.

## Verification
- Verified live deletion via API calls:
  - System Admin (`MP0108` - Loveneesh Sharma) successfully deleted regular employee posts.
  - Community Admin (`MPO102` - Vishendra Sharma) successfully deleted regular employee posts.
  - HR Administrator (`MPO103` - Sourabh Sahu) successfully deleted regular employee posts.
  - Complex post with mentions, attachments, comments, and replies was deleted completely with 0 foreign key constraint errors.
- Verified that deleting a post returns `200 OK` and a subsequent `GET /api/posts/{id}` returns `404 Not Found`.
