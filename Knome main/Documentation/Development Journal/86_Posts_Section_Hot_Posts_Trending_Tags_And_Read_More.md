# Development Journal — Phase 86: Posts Section Hot Posts, Trending Tags, and Read More Expanders

**Date:** 2026-09-17  
**Author:** AI Agent & Pair Programmer  
**Status:** Completed & Verified  

---

## 1. Requirement Summary

1. **Hot Posts & Trending Tags in Post Section:**
   - On the Posts page (`/posts`), embed the right sidebar containing `HotPostsWidget` and `TrendingTagsWidget` alongside the post feed.
   - Wire trending tag clicks so clicking any trending tag filters the Posts feed by that hashtag.
   - Add a `🔥 Hot Posts` quick filter button in the topic pills to sort the feed by engagement score.
2. **Read More Button in Content After 2 Lines:**
   - In `PostCard.jsx`, clamp text content exceeding 2 lines (`line-clamp-2` and string truncation) and display an interactive `Read more` button with an `expand_more` icon.
   - When clicked, expand to display full formatted text (clickable links, hashtags, mentions) and provide a `Show less` button with `expand_less`.
3. **Read More Button in Images After 4 Images:**
   - In `ImageGrid` in `PostCard.jsx`, when a post has more than 4 images:
     - Show the first 4 images in a 2x2 grid.
     - Display an overlay on the 4th image (`+{extraCount} Read more`) and a prominent `Read more (+{extraCount} more photos)` button below the grid.
     - Clicking either button expands the grid to display all images with full lightbox zoom access and a `Show less` button.

---

## 2. Changes Implemented

### A. TrendingTagsWidget (`knomeUI/frontend/src/components/widgets/TrendingTagsWidget.jsx`)
- Added optional `onTagClick` prop to `TrendingTagsWidget`.
- When passed, clicking a tag invokes `onTagClick(tag)` to filter in-place without page reload. Otherwise defaults to navigating to `/search?q=#tag`.

### B. Posts Page (`knomeUI/frontend/src/pages/Posts.jsx`)
- Imported `HotPostsWidget` and `TrendingTagsWidget`.
- Created a 2-column responsive layout (`flex-col xl:flex-row gap-8 items-start`) containing the main feed and the right sidebar with both widgets.
- Added `🔥 Hot Posts` filter pill to the top topic filter bar.
- Implemented hot scoring sorting when `🔥 Hot Posts` is active (`likes * 2 + comments * 3 + shares * 4`).
- Wired `onTagClick={(tag) => setSelectedTag(tag)}` on `TrendingTagsWidget`.

### C. PostCard (`knomeUI/frontend/src/components/widgets/PostCard.jsx`)
- Added `isContentExpanded` state hook.
- Implemented 2-line detection and truncation for user commentary.
- Rendered `Read more` button after 2 lines that smoothly unfolds text in place and shows `Show less`.
- Updated `ImageGrid`: added `isImagesExpanded` state.
- When `validImages.length > 4`, renders 4 images initially with `+{extraCount} Read more` overlay and a footer button `Read more ({extraCount} more photos)`. Expanding reveals all images and provides a `Show less` collapse button.

---

## 3. Verification

1. **Build Validation:**
   - Ran `npm run build` in `knomeUI/frontend` — compiled with 0 errors.
   - Copied dist build to IIS `C:\inetpub\wwwroot\knome`.
2. **Subagent Browser Verification:**
   - Navigated to `/posts`.
   - Verified that the right sidebar displays `Hot Posts` widget with Daily/Weekly/Monthly tabs and `Trending Tags` widget.
   - Verified `🔥 Hot Posts` filter button in the topic pills.
   - Published a 4-line test post; verified that only 2 lines are visible initially with `Read more`.
   - Clicked `Read more`: expanded full text and changed label to `Show less`.
   - Clicked `Show less`: collapsed text back to 2 lines.
   - Captured screenshot artifact confirming all features.
