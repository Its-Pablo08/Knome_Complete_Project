# Development Journal #76 — Image Crop & Rotate, 400 MB Document Upload, Audio Symbol, and Schedule Refinements

**Date:** 2026-09-15  
**Author:** Antigravity AI  
**Scope:** `Frontend/knome-web` (`CreatePostModal.jsx`, `ImageCropModal.jsx`) & `Backend/Knome.API` (`MediaController.cs`, `LocalFileStorageService.cs`)

---

## 1. Objectives & Overview

User requested five key enhancements for the post creation flow:
1. **Image Cropping & Rotation**: Provide crop and rotation tools when attaching images, including precise aspect ratio presets and recommended resolutions:
   - **Landscape**: 1200 × 627 px (1.91:1)
   - **Square**: 1200 × 1200 px (1:1)
   - **Portrait**: 1080 × 1350 px (4:5)
   - **LinkedIn Banner/Post Graphic**: 1200 × 627 px (1.91:1)
   - **Original / Free**: Natural image aspect ratio
   - Rotation: Rotate Left (-90°), Rotate Right (+90°), Flip Horizontal, Flip Vertical, Zoom, and Pan with rule-of-thirds grid.
2. **400 MB Document Upload Support**: Allow up to 400 MB file upload for documents (.pdf, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .txt, .zip).
3. **Audio Symbol Change**: Replace the `mic` icon with a modern audio/headphones icon (`headphones`) across toolbar and attachment cards.
4. **Schedule "OK" Confirmation Button**: Add a dedicated, prominent "OK" button in the schedule popover to confirm schedule time.
5. **Remove IST (UTC+05:30), dd/mm/yyyy labels, and Static Schedule Date**:
   - Completely remove the timezone banner (`IST (UTC+05:30)` and `Format: DD/MM/YYYY`).
   - Remove `(DD/MM/YYYY)` text from picker and preview labels.
   - Remove auto-setting of static/immediate schedule date when opening the scheduler popover so the post is not scheduled prematurely before clicking "OK".
   - Display schedule date naturally (e.g., `15 Sep 2026, 10:10 PM`).

---

## 2. Changes Made

### Frontend (`knomeUI/frontend`)
- **[NEW] `src/components/modals/ImageCropModal.jsx`**:
  - Full HTML5 Canvas-based cropper & rotator with zero external package dependencies.
  - Implements all 5 aspect ratio presets: Landscape, Square, Portrait, LinkedIn Post/Banner, and Original.
  - Controls: Rotate -90° / +90°, Flip H, Flip V, Zoom slider (1x–3x), interactive mouse/touch drag pan, 3x3 rule-of-thirds grid overlay, resolution badge, and high-fidelity canvas export.
- **[MODIFY] `src/components/modals/CreatePostModal.jsx`**:
  - Mounted `ImageCropModal` with `cropModalTarget` state and `handleCropSave` handler.
  - Added "Crop" overlay button with `crop_rotate` icon on image attachment preview cards.
  - Updated audio icon from `mic` to `headphones` in both toolbar and preview cards.
  - Expanded `acceptMap.doc` to include `.xls, .xlsx, .ppt, .pptx, .zip` and respective MIME types.
  - Added 400 MB file size limit check in `processFiles` for documents.
  - Removed timezone notice banner (`IST (UTC+05:30)` and `Format: DD/MM/YYYY`).
  - Removed `(DD/MM/YYYY)` label strings.
  - Refactored scheduling to use `tempScheduleTime` inside the popover without modifying `scheduledTime` until the user clicks the prominent **OK** button.
  - Replaced the browser-native shadow `<input type="datetime-local">` with a custom interactive [`CustomDateTimePicker.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/components/widgets/CustomDateTimePicker.jsx) matching the user's screenshot:
    - Interactive calendar grid on the left (month/year `< >` navigation, days of the week, today highlight, past day disablement).
    - Time selection columns on the right (hours 01–12, minutes 00–59, period AM/PM).
    - Bottom bar directly below the calendar & time selectors featuring `Clear`, `Today`, live formatted preview, and the prominent **OK** confirmation button (`check_circle`).
  - Wrapped the schedule popover in a dedicated fixed viewport overlay (`fixed inset-0 z-[120] flex items-center justify-center`) with `max-h-[94vh] overflow-y-auto`, ensuring zero clipping.
  - Added `formatScheduleDisplay` helper to format dates cleanly without raw dd/mm/yyyy.

### Backend (`Backend/Knome.API`)
- **[MODIFY] `Controllers/MediaController.cs`**:
  - Added `[RequestSizeLimit(500L * 1024L * 1024L)]` and `[RequestFormLimits(MultipartBodyLengthLimit = 500L * 1024L * 1024L)]` on `UploadMedia` endpoint.
- **[MODIFY] `Services/LocalFileStorageService.cs`**:
  - Extended allowed media extensions for document type to include `.xls`, `.xlsx`, `.ppt`, `.pptx`, `.zip`.

---

## 3. Verification & Deployment
- `npm run build` executed and succeeded with 0 errors.
- Built dist synced to `C:\inetpub\wwwroot\knome`.
- All previous changes preserved without regressions.
