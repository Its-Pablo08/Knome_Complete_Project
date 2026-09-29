# Development Journal: 39 - Community Upload & Feed Post Persistence Across Page Refresh

**Date:** September 9, 2026  
**Module:** Community View & Discussions / Files & Media  
**Author:** Pair Programming Agent  

---

## 1. Problem Statement & Root Cause Analysis
Users reported that after uploading files or creating posts inside communities, refreshing the browser page caused the newly uploaded content to disappear or reset.

### Detailed Root Causes Discovered:
1. **Missing File Rehydration in Custom/Offline Communities:**
   - In `CommunityView.jsx`, file loading (`setFilesList`) was only executed inside the `if (commData)` branch.
   - For all custom-created communities (where `commData` is null or stored in `knome_custom_communities`), the `else` branch did not load `knome_community_files_${targetId}` at all.
   - For API communities, `loadData` did not rehydrate blobs from IndexedDB (`saveFileBlobToIndexedDb`), causing uploaded images or files with large data payloads to lose their URLs on reload.
2. **Post Creation Failures & Storage Gaps:**
   - `handleCreatePost` called `communitiesApi.createPost(targetId, ...)`. For custom communities, this threw an unhandled error, popping a toast and failing to save.
   - Even when it succeeded for seed communities, it never persisted the new post to `knome_community_posts_${targetId}`.
   - In `CreatePostModal.jsx`, posts published targeting a specific community were not prepended to `knome_community_posts_${selectedCommunity.id}`.
3. **Missing Attachment Rendering in Community Feed:**
   - Posts with attachments or images uploaded were not rendering image cards in the community feed discussions.

---

## 2. Changes Implemented

### [CommunityView.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/pages/CommunityView.jsx)
1. **Unified Persistent Files Loading:**
   - Removed the conditional file loading from `if (commData)`.
   - Unified file loading right after community resolution using `resolvedTargetId`.
   - Added asynchronous rehydration via `getFileBlobFromIndexedDb(f.id)` so that user-uploaded files preserve their exact data URLs.
2. **IndexedDB Await Contract:**
   - Updated `saveFileBlobToIndexedDb` to return a Promise that waits for `tx.oncomplete` before returning.
3. **Community Banner & Thumbnail Override:**
   - Checked `knome_custom_communities` to preserve user-uploaded banner and thumbnail images across page refreshes.
4. **Community Feed Post Persistence:**
   - Updated `handleCreatePost` to create `newPostItem` and save to `knome_community_posts_${targetId}` and `knome_local_posts` using `safeSetStorage`.
   - Updated `loadData` to merge `knome_community_posts_${resolvedTargetId}` with matching community posts from `knome_local_posts`.
5. **Feed Image Attachments Rendering:**
   - Added grid card rendering for images attached to community posts.

### [CreatePostModal.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/components/modals/CreatePostModal.jsx)
- Added direct persistence to `knome_community_posts_${selectedCommunity.id}` when publishing a post targeting a community.

---

## 3. Verification & Live Testing
- Build verification: `npm run build` completed cleanly in `692ms`.
- Live Browser Subagent Testing (`comm_persist_test`):
  - Uploaded `Enterprise_Architecture_2026.pdf` in Files & Media -> Refreshed page -> File remained visible.
  - Published post *"Persistent test post across browser refresh!"* -> Refreshed page -> Post remained visible at the top of the feed.
