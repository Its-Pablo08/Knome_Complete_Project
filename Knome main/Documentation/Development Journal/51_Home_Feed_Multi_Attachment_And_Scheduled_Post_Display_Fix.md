# Dev Journal Entry 51: Home Feed Multi-Attachment & Scheduled Post Display Fix

## Context & Objective
The user reported an issue where multiple files attached to a scheduled post (such as Post ID 10130 "hey test 1") were not rendering on the Home page (`/` or `Dashboard.jsx`), but instead displayed a broken dark container with "Knome Enterprise Media Attachment" (fallback SVG) with all other files completely missing.
Strict constraint: **DO NOT PUSH TO GIT**.

## Root Cause Analysis
1. **FeedItemDto Attachment Truncation**:
   - Backend `FeedItemDto.cs` only declared `public string? AttachmentUrl { get; set; }`. It lacked a list of attachments (`Attachments` or `AttachmentUrls`).
   - `FeedService.cs` used `p.PostAttachments.FirstOrDefault()?.FileUrl`. If a post had 4 attachments (e.g. 1 text document, 1 audio file, 1 video, and 1 image), only the first attachment (`.txt`) was sent. The other 3 attachments were completely omitted by the backend API.
2. **Blind Type Hardcoding in Frontend Feed Mapper**:
   - `knomeUI/frontend/src/utils/apiService.js` in `mapFeedItem` contained:
     ```javascript
     if (item.contentType === 'Post') {
         base.attachments = item.attachmentUrl ? [{
             id: 1,
             type: 'image', // simplified for feed item mapping
             url: resolveMediaUrl(item.attachmentUrl) || item.attachmentUrl,
             name: 'attachment'
         }] : [];
     }
     ```
   - This assumed every post attachment was an `image`. When the first attachment was a `.txt` file, `PostCard.jsx` attempted to render it inside an `<img>` tag in `ImageGrid`. The browser failed to decode the text file as an image, triggered `onError`, and displayed `FALLBACK_GRID_SVG` ("Knome Enterprise Media Attachment").
3. **Scheduled Post Retrieval Exclusion for Authors**:
   - `FeedRepository.cs` in `GetCandidatePostsAsync` filtered posts with `Where(p => ... (string.IsNullOrEmpty(p.Status) || p.Status == "Published"))`.
   - Scheduled posts with status `"Scheduled"` were completely excluded from the candidate feed query, preventing authors from viewing their own scheduled posts on the Home feed prior to automated worker publication.
4. **URL & Type Normalization in `PostCard.jsx`**:
   - `PostCard.jsx` relied on raw `att.url` without `resolveMediaUrl(att.url)` for video and audio elements, and did not handle multiple disparate attachment formats gracefully.

## Architectural Resolution

1. **Backend DTO Enhancement (`Backend/Knome.API/DTOs/Feed/FeedItemDto.cs`)**:
   - Introduced `FeedAttachmentDto` with `AttachmentId`, `FileUrl`, and `FileType`.
   - Added `ContentText`, `Status`, `ScheduledDate`, `AttachmentUrls`, and `Attachments` to `FeedItemDto`.

2. **Feed Candidate Query Expansion (`Backend/Knome.API/Repositories/FeedRepository.cs`)**:
   - Updated `GetCandidatePostsAsync` and `GetCandidateArticlesAsync` to include scheduled items for their author:
     ```csharp
     (string.IsNullOrEmpty(p.Status) || p.Status == "Published" || (p.Status == "Scheduled" && p.AuthorUserId == currentUserId))
     ```
   - Maintained privacy so non-authors cannot view future scheduled posts.

3. **Feed Mapping in `FeedService.cs`**:
   - Mapped all `PostAttachments` and `ArticleAttachments` into `FeedItemDto.Attachments` and `FeedItemDto.AttachmentUrls` in both `GetPersonalizedFeedAsync` and `GetHotFeedAsync`.

4. **Frontend Detection & Mapping (`knomeUI/frontend/src/utils/apiService.js`)**:
   - Added `detectFileType(url, fallbackType)` helper that inspects file extensions (`.jpg`/`.png`/`.webp` -> `image`, `.mp4`/`.webm` -> `video`, `.mp3`/`.wav` -> `audio`, `.pdf`/`.txt`/`.docx` -> `doc`).
   - Refactored `mapFeedItem` to dynamically map `attachments` from `item.attachments`, `item.postAttachments`, `item.attachmentUrls`, or `item.attachmentUrl`.
   - Preserved `status`, `scheduledDate`, and `isScheduledFuture`.

5. **`PostCard.jsx` Media Rendering Hardening**:
   - Filtered `imageAttachments` strictly to true image files (preventing `.txt`, `.mp4`, or `.mp3` from being treated as images).
   - In `otherAttachments`, dynamically normalized effective type and applied `resolveMediaUrl(rawUrl)` for video, audio, and doc elements.
   - For documents, added proper file name extraction and `TXT`, `PDF`, `DOC` pill badges.
   - In `ImageGrid` and `ImageLightbox`, resolved image URLs with fallback between `img.url` and `img.fileUrl`.

## Verification & Results
1. **Backend Compilation**: `dotnet build -nologo` completed with **0 errors**.
2. **Frontend Compilation**: `npm --prefix knomeUI/frontend run build` completed with **0 errors** (520 modules transformed).
3. **Live SQL Server & API Verification (`test_feed_attachments.ps1` & `verify_feed_privacy.ps1`)**:
   - Post ID 10130 (`hey test 1`) retrieved via `GET /api/feed/home` with all **4 attachments** (`Document`, `Audio`, `Video`, `Image`).
   - Created new multi-file scheduled post (ID 10132):
     - Author (`EMP001`) can see their scheduled multi-file post in home feed (`[PASS]`).
     - Non-author (`EMP002`) cannot see future scheduled post (`[PASS]`).
     - Non-author can see published post 10130 with all 4 attachments (`[PASS]`).
4. **Git Status Check**: All changes remain local; no push or commit made (`[PASS]`).
