# 165. Create Post Dialog Refinements: Anti-Clipping Tooltips, Relocated File Limits, Error Display, Save as Draft, and Cancel Button Removal

## 1. Context & User Objectives

The user requested five specific user experience and interface enhancements for the **Create Post** modal dialog:
1. **Fix Tooltip Clipping**: Tooltips on media attachment buttons (Image, Document, Video, Audio) were being cut off on the left border of the modal.
2. **Relocate File Size Limits to the Bottom**: Remove max file size specifications (e.g., `Max 400 MB`) from hover pop-up tooltips and place them clearly at the bottom of the post dialogue box.
3. **File Size Validation & Error Display**: Enforce maximum file size limits (Images: 100 MB, Documents: 400 MB, Videos: 500 MB, Audio: 100 MB). If an uploaded file exceeds the limit, display an informative error banner and trigger an error toast.
4. **Implement "Save Post as Draft"**: Provide a dedicated option/button to save the post as a private draft (`status = 'Draft'`), skipping public broadcast notifications and karma rewards until publication.
5. **Remove Cancel Button**: Remove the redundant "Cancel" button in the bottom right of the post dialogue box (the top-right close `X` button remains available).

---

## 2. Key Changes Made

### A. Media Attachment Tooltip Anti-Clipping & Simplification (`CreatePostModal.jsx`)
- Tooltip labels were simplified to concise, clear text: `Image`, `Document`, `Video`, `Audio`.
- Replaced `-translate-x-1/2 left-1/2` with `left-0` alignment so the tooltips anchor to the left edge of each button and flow into the modal body rather than bleeding outside the modal container's left border.
- Removed max file size text from tooltips.

### B. Relocated File Size Information Bar (`CreatePostModal.jsx`)
- Added a dedicated, stylized info bar at the very bottom of the post dialogue box with color-coded bullets:
  - `Max file size: Images: 100 MB • Documents: 400 MB • Videos: 500 MB • Audio: 100 MB`
- Styled with subtle borders, muted neutral backgrounds, and matching rounded corners (`rounded-b-2xl sm:rounded-b-3xl`).

### C. File Size Validation & Error Alert (`CreatePostModal.jsx`)
- Added `FILE_LIMITS` configuration constant with exact byte thresholds and display labels:
  - `image`: 100 MB
  - `doc`: 400 MB
  - `video`: 500 MB
  - `audio`: 100 MB
- In `processFiles`, each file's size is checked against its type limit. If exceeded:
  - An inline error state `fileError` is set with the exact file name, actual formatted size, and allowed limit.
  - An error toast is triggered (`addToast(..., 'error')`).
  - An inline alert banner appears above the footer with a dismiss button.
  - The oversized file is rejected.

### D. "Save as Draft" Implementation (`CreatePostModal.jsx`, `Posts.jsx`, `PostCard.jsx`)
- Added a **Save as Draft** secondary button (`<span className="material-symbols-outlined">draft</span> Save as Draft`) in the footer of `CreatePostModal.jsx`.
- When invoked:
  - Passes `status = 'Draft'`.
  - Bypasses public community/colleague notifications.
  - Bypasses automatic karma awarding until actual publication.
  - Displays a dedicated success toast (`Post saved as draft successfully! 📝`).
  - Clears and closes the modal.
- In `Posts.jsx`:
  - Author drafts are filtered to ensure privacy (only visible to the author).
  - Added an author-only `📝 Drafts` tab button showing the exact count of active drafts.
  - Added empty state messaging for drafts.
- In `PostCard.jsx`:
  - Added dashed border styling and a private draft notice banner for the author.
  - Provided a direct **Publish Now** button on the draft card and in the card's actions menu.
  - Added a `Draft` badge in the post header.

### E. Removal of Redundant Cancel Button (`CreatePostModal.jsx`)
- Removed the `Cancel` text button from the modal footer. Users can dismiss the modal using the top-right `X` button, clicking outside the modal, or pressing Escape.

---

## 3. Verification & Deployment

1. **Compilation Check**:
   - `npm run build` executed successfully with 0 errors across all 531 modules in 942ms.
2. **IIS Synchronization**:
   - Built assets copied to `C:\inetpub\wwwroot\knome` for immediate IIS production serving.
3. **Vite Live Server**:
   - Running live on `http://localhost:5173`.
