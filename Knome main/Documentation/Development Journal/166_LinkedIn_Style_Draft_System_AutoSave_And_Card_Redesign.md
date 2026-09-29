# Dev Journal: 166 - LinkedIn-Style Draft System, Auto-Save on Modal Close, Draft Auto-Restoration, and Draft Card Redesign

## Overview
Transformed Knome's post drafting experience from a basic local placeholder into an enterprise-grade, LinkedIn-style drafts and auto-save system. Users never lose uncommitted writing when closing the Create Post modal, existing drafts seamlessly restore with clear visual context, drafts have stable deduplicated identities, and the previously awkward in-feed draft banner has been replaced with a dedicated, polished `DraftCard` component.

---

## Key Problems Addressed
1. **Accidental Work Loss**: Previously, typing in the Create Post modal and closing it without publishing resulted in discarding uncommitted post content.
2. **Duplicate Draft Clutter**: Repeatedly opening, typing, and closing the modal created duplicate draft entries.
3. **No Automatic Draft Restoration**: Reopening Create Post would always present a blank editor, ignoring the user's active unpublished work.
4. **Poor Draft Feed Card UI**: As highlighted in user feedback, the Drafts tab previously used a generic `PostCard` topped with an awkward banner (`DRAFT Saved Draft. Only visible to you. Not published to the feed. [Publish Now]`).
5. **Lack of User Isolation**: Drafts stored globally could leak across user accounts on shared workstations.

---

## Architectural Implementation

### 1. Centralized Draft Manager (`knomeUI/frontend/src/utils/draftManager.js`)
* **User-Scoped Key Isolation**: `knome_user_post_draft_${userId}` isolates drafts per logged-in user account.
* **Auto-Save & Retrieval**:
  - `getUserDraft(userId)`: Fetches active draft and validates non-emptiness.
  - `saveUserDraft(userId, draftData)`: Normalizes draft fields (text, attachments, audience, community, connections, schedule), prevents empty draft creation, assigns/preserves stable identity, synchronizes to `knome_local_posts`, and emits the `knome_drafts_updated` custom event across tabs.
  - `clearUserDraft(userId)`: Removes the user's active draft after publication.
  - `deleteDraft(userId, draftId, postsApi)`: Permanently deletes a draft locally and on SQL Server if backend-persisted.
  - `formatDraftTimeAgo(dateInput)`: Formats human-friendly relative timestamps ("Saved just now", "Saved 2m ago", "Saved 1h ago", "Saved yesterday").

### 2. Modern Redesigned `DraftCard` Component (`knomeUI/frontend/src/components/widgets/DraftCard.jsx`)
* Replaced the awkward draft banner with a dedicated, enterprise-grade card design matching Knome design system tokens.
* **Header**:
  - `DRAFT` status badge with pulsating amber dot (`animate-pulse`).
  - Audience indicator chip (`Public`, `Community: <Name>`, or `Connections`).
  - Relative saved timestamp with clock icon (`Saved 2m ago`).
* **Content Preview**:
  - Rich text preview styled with `line-clamp-3`, clickable to resume editing.
  - Placeholder for attachment-only drafts.
* **Attachment Strip**:
  - Summary row indicating total attachments and categorized pills (`Images`, `Docs`, `Videos`, `Audio`).
  - Visual thumbnail strip showing up to 4 preview thumbnails with overflow counter (`+N`).
* **Action Buttons**:
  - `Continue Editing` (primary action, opens modal with draft loaded).
  - `Publish Now` (in-place promotion to published post).
  - `Delete Draft` (with confirmation modal and instant removal).

### 3. Smart `CreatePostModal` Lifecycle (`knomeUI/frontend/src/components/modals/CreatePostModal.jsx`)
* **Auto-Restore on Open**:
  - On modal mount/open, checks for any existing draft for `currentUserId` (or `draftToEdit`).
  - Restores post text, attachments, audience selection, community, tagged connections, and schedule time.
  - Displays `Editing Draft` badge in modal header along with auto-save status and a `Discard` action.
* **Debounced Typing Auto-Save**:
  - Debounced auto-save runs 1.5s after user stops typing or modifying attachments.
  - Subtle status indicator in header switches between `Auto-saving...` (spinning icon) and `Saved just now` (cloud checkmark).
* **Auto-Save on Modal Close**:
  - `handleClose()` checks if entered content is non-empty. If so, automatically saves/updates the user's active draft and alerts via toast: `"Draft auto-saved"`.
  - Empty drafts are automatically cleaned up.
* **Duplicate Prevention on Publish**:
  - When publishing a draft with an existing numeric backend ID, executes `postsApi.update(activeDraftId, payload)` with `status: 'Published'`.
  - Transitions the post in place rather than creating a duplicate.
  - Clears the active draft and triggers live feed synchronization.

### 4. Feed Integration & Filtering (`knomeUI/frontend/src/pages/Posts.jsx`)
* Added a dedicated **`Drafts`** action button directly in the hero header adjacent to **`Write Post`** with live draft count badge (`authorDraftCount`), active toggle state, and smooth scroll into the drafts feed.
* When `selectedTag === '📝 Drafts'`, renders `DraftCard` instead of `PostCard`.
* Synchronizes the active user draft directly into `loadPosts` so updates are reflected immediately.
* Handlers wired for `onEditDraft`, `onDeleteDraft`, and `onPublishDraft`.
* Broadcast event `knome_drafts_updated` triggers reactive updates across the UI without full page reload.

### 5. Backend Service & DTO Hardening (`Backend/Knome.API`)
* **`PostService.cs`**:
  - In `CreatePostAsync`: Ensures karma is only awarded when `finalStatus == PostStatuses.Published`.
  - In `UpdatePostAsync`: Added transition check so moving from `Draft` to `Published` awards user karma and fires community/connection/network notifications.
* **`UpdatePostDto.cs`**:
  - Added `AudienceUserIds` and `AudienceCommunityIds` collections to support audience preservation when updating drafts.

---

## Verification & Build Results
* **Frontend**: `npm run build` executed cleanly in 1.08s with 0 errors. Static bundle mirrored to IIS at `C:\inetpub\wwwroot\knome` and `C:\inetpub\wwwroot\assets`.
* **Backend**: `dotnet build -nologo -o bin/TestBuild` compiled successfully with 0 errors.
* **HTTP Checks**:
  - `http://localhost/knome/`: HTTP 200 OK.
  - `http://localhost:5173/posts`: HTTP 200 OK.
