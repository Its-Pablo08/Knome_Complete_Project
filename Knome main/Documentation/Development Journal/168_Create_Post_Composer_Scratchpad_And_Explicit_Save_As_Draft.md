# Development Journal: 168 — Create Post Composer Scratchpad & Explicit Save As Draft Separation

## Problem Statement

When an employee was typing in the **Create Post** modal and clicked the **Close (`X`) button** or clicked outside, the auto-save mechanism previously registered the in-progress content directly into the official `Drafts` queue. Consequently:
- The `Drafts (1)` counter button on `/posts` incremented immediately.
- The uncommitted text appeared as a full `DraftCard` inside the **Drafts** feed tab (`selectedTag === '📝 Drafts'`).
- The user expected that closing the modal should save uncommitted text **on Create Post only** (so when reopening Create Post, the text is still restored in the composer), and that only an explicit click on the **"Save as Draft"** button should register it inside the official "Drafts" tab for later use.

---

## Architecture & Implementation

### 1. Dedicated Composer Scratchpad Isolation
Introduced dedicated storage isolation in [`draftManager.js`](file:///d:/Knome%20main/knomeUI/frontend/src/utils/draftManager.js):
- Key: `knome_create_post_scratchpad_${userId}`
- Helper methods:
  - `getActiveComposerScratchpad(userId)`
  - `saveActiveComposerScratchpad(userId, data)`
  - `clearActiveComposerScratchpad(userId)`

This scratchpad keeps uncommitted in-progress post text, attachments, audience, and scheduled time safe on the local device without pushing items to `knome_local_posts` or triggering draft events.

### 2. CreatePostModal Modal Lifecycle Alignment
In [`CreatePostModal.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/components/modals/CreatePostModal.jsx):
- **On Typing / Auto-Save**: If creating a new post (`!activeDraftId`), debounced auto-saves write to `saveActiveComposerScratchpad` only, preventing feed pollution.
- **On Modal Close (`handleClose`)**: If the user has typed content and closes via the `X` button, it calls `saveActiveComposerScratchpad` and closes cleanly. No draft card is created in the Drafts tab, and the Drafts counter does not increment.
- **On Modal Open**: If `draftToEdit` is provided (user explicitly clicked "Continue Editing" from the Drafts tab), it loads the official draft. Otherwise, it checks `getActiveComposerScratchpad` and seamlessly restores the in-progress text and attachments right into Create Post.
- **On Explicit "Save as Draft"**: In `handleSubmit('Draft')`, `saveUserDraft` is called with `savedAsDraft: true`. It writes to the backend/official drafts storage, clears the composer scratchpad, shows `'Draft saved successfully. 📝'`, dispatches `knome_drafts_updated` and `post-created`, and registers the draft inside the "Drafts" tab.
- **On Publish / Discard**: Both actions cleanly purge the composer scratchpad via `clearActiveComposerScratchpad(currentUserId)`.

### 3. Posts Page Draft Filtering
In [`Posts.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/pages/Posts.jsx):
- `knome_local_posts` is sanitized to only include drafts with `savedAsDraft === true`, automatically purging any uncommitted scratchpad entries created by previous auto-saves.
- `getUserDraft` enforces `savedAsDraft === true`, guaranteeing that only explicitly saved drafts appear in the Drafts tab and count.

---

## Verification
- Built frontend via `npm run build` (vite v8.1.4, compiled in 1.77s with 0 errors).
- Synced build distribution to IIS webroot `C:\inetpub\wwwroot\knome` and `C:\inetpub\wwwroot\assets`.
- Verified typing in Create Post and closing with `X` saves in the composer scratchpad without appearing in the Drafts tab or incrementing the Drafts count.
- Verified clicking "Save as Draft" saves the post to the Drafts tab and increments the counter.
