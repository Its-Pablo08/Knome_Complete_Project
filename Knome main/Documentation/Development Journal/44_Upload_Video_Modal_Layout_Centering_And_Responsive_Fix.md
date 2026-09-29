# 44. Upload Video Modal Layout Centering and Responsive Fix

## Overview
User reported that the Upload Video popup modal was getting cut off and not properly centered on the screen. Elements like description, thumbnail, and the action buttons were cramped or pushed off the bottom fold, especially on typical 1366x768 and 1536x864 screens.

## Key Changes
1. **Centering & Viewport Fit**:
   - Fixed outer backdrop to use `fixed inset-0 z-[100] flex items-center justify-center p-3 sm:p-4 md:p-6 bg-slate-950/70 backdrop-blur-md overflow-hidden`.
   - Constrained modal card with `max-w-4xl max-h-[92vh] flex flex-col` and rounded corners (`rounded-3xl`).
   - Modal dialog is now guaranteed to remain strictly centered and never overflow screen boundaries.

2. **Fixed Header & Footer (Never Cut Off)**:
   - Header is `shrink-0` with title, subtitle, and close button.
   - Footer is `shrink-0` with status text, Cancel, and Upload Video buttons always pinned and visible.
   - Body is `flex-1 min-h-0 overflow-y-auto custom-scrollbar` allowing smooth internal scrolling without breaking layout.

3. **Streamlined Compact Dropzone**:
   - Redesigned the bulky 250px dropzone into a sleek, modern horizontal banner (~85px) when empty, saving over 150px of vertical height.
   - Added full drag-and-drop interaction (`onDragOver`, `onDragLeave`, `onDrop`) with active visual feedback (`isDragging`).
   - When a video file is selected, it renders a clean card with video icon, file size, auto-duration, and quick Change/Remove controls.
   - Title is pre-filled automatically from file name if left blank.

4. **Enhanced 2-Column Form Layout**:
   - Left Column: Video Title (`*`), Auto-detected Video Duration, Description textarea.
   - Right Column: Category selector, Tag input chips, Video Thumbnail (Auto-extracted or Upload Custom).
   - All fields comfortably fit on screen on standard resolutions.

## Verification
- Frontend production build passed cleanly: `npm run build` completed with 0 errors.
- Both Light & Dark mode styling validated.
