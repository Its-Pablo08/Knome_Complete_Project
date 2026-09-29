# Development Journal – Phase 47: Enterprise Post Scheduling Workflow & DD/MM/YYYY Refactor

**Date**: 10 September 2026  
**Phase**: Phase 47 – Enterprise Post Scheduling Workflow & DD/MM/YYYY Refactor  
**Project**: Knome.API & Knome-Web (MPOnline Limited Enterprise Knowledge Platform)  
**Status**: Completed ✅  

---

## 1. Executive Summary & Objective

In this phase, we refactored the post scheduling experience across both Frontend (`knomeUI/frontend`) and Backend (`Knome.API`) to align with MPOnline Knome enterprise standards and direct user requirements:
1. **DD/MM/YYYY Date Formatting**: Replaced default browser locale strings with the Indian enterprise standard `DD/MM/YYYY, hh:mm A` format (e.g. `10/09/2026, 10:20 AM`) across the scheduling popover, live preview card, modal footer chips, success toast notifications, post cards, and feed mappers.
2. **1-Minute Rapid Scheduling**: Added a dedicated `+1 Min` preset and adjusted form constraints (`min` date input attribute and validation guard allowing `>= 20 seconds` in the future) so employees can schedule posts for immediate 1-minute release.
3. **Enterprise UI/UX Overhaul in `CreatePostModal.jsx`**:
   - Replaced prototype/debug copy (*"Set the time on your laptop clock"*, *"Laptop Timing"*) with formal Knome publication scheduling copy (*"Schedule Publication"*, *"Automated Knome platform delivery"*, *"IST (UTC+05:30) • Format: DD/MM/YYYY"*).
   - Upgraded Quick Presets to a 6-item responsive grid: `+1 Min`, `+5 Mins`, `+15 Mins`, `+30 Mins`, `+1 Hour`, `Tomorrow 9 AM`.
   - Added a live schedule preview card displaying the `DD/MM/YYYY` publication timestamp, relative countdown (`⏳ in 1 min`), and target audience confirmation.
   - Added inside-popover action controls (`Clear Schedule` and `Apply Schedule`) with click-outside dismiss listeners.
   - Added an interactive **Scheduled Pill Chip** (`[ ⏰ Scheduled: DD/MM/YYYY, hh:mm A • in 1m | ✏️ Edit | × ]`) in the modal footer.
   - Dynamically styled the primary button: toggles between `"Publish"` with `send` icon and `"Schedule Post"` with `event_available` icon and an amber/indigo gradient.
4. **Timezone Comparison Skew Fix**:
   - Resolved a critical time-skew bug in `PostService.cs` (`CreatePostAsync` and `UpdatePostAsync`) and `PostRepository.PublishDueScheduledPostsAsync()` where UTC timestamps were improperly compared to local server time (`nowLocal`), causing scheduled posts within 5.5 hours to immediately transition to `Published` upon creation.
   - Standardized all database checks strictly to UTC (`p.ScheduledDate <= nowUtc`).

---

## 2. Key Code Changes

### Frontend (`knomeUI/frontend`)

- **`src/utils/apiService.js`**:
  - Exported `formatToDDMMYYYY(dateInput)` helper formatting timestamps to zero-padded `DD/MM/YYYY, hh:mm A`.
  - Updated `mapPost` so `displayTime` uses `formatToDDMMYYYY`.
- **`src/components/modals/CreatePostModal.jsx`**:
  - Added `formatToDDMMYYYY` import and relative countdown helper `getRelativeScheduleText(dateInput)`.
  - Configured `getLocalDatetimeInputValue(offsetMinutes = 1)` defaulting to 1 minute ahead.
  - Added `schedulePopoverRef` with click-outside listener to dismiss popover without losing state.
  - Replaced prototype popover with enterprise gradient header, timezone banner, `DD/MM/YYYY` live preview card, 6 quick presets (`+1 Min` to `Tomorrow 9 AM`), and Apply/Clear buttons.
  - Added interactive scheduled pill chip to modal footer and dynamic `"Schedule Post"` submit button.
  - Updated submission validation allowing `>= 20 seconds` in the future for seamless 1-minute scheduling.
  - Formatted success toast: `"Post scheduled for publication on DD/MM/YYYY, hh:mm A!"`.
- **`src/components/widgets/PostCard.jsx`**:
  - Updated author's scheduled banner to format `post.scheduledDate` using `formatToDDMMYYYY`.
- **`src/pages/Posts.jsx` & `src/pages/Dashboard.jsx`**:
  - Cleaned up informal "laptop" comments and ensured future scheduled posts are strictly filtered to the author until publication time.

### Backend (`Backend/Knome.API`)

- **`Repositories/PostRepository.cs`**:
  - Removed `nowLocal` comparison in `PublishDueScheduledPostsAsync()`. Evaluates `p.ScheduledDate <= nowUtc` so UTC timestamps are accurately compared.
- **`Services/PostService.cs`**:
  - Updated `CreatePostAsync` and `UpdatePostAsync` to compare `scheduledUtc <= DateTime.UtcNow`, eliminating false-positive immediate publishing.

---

## 3. Verification & Results

1. **Frontend Compilation**:
   - `npm run build` completed with **0 errors** in 1.55s.
2. **Backend Compilation**:
   - `dotnet build -nologo` completed with **0 errors**.
3. **Automated End-to-End Verification (`scratch/test_schedule_post.ps1`)**:
   - Logged in as `EMP001` (Author) and `EMP002` (Viewer).
   - Scheduled post with `+1 Min` UTC target.
   - Verified post created with `status: "Scheduled"`.
   - Verified privacy: `EMP001` sees post in feed (`True`), `EMP002` does NOT see post in feed (`False`).
   - Waited 65s for `ScheduledPostHostedService`: verified post automatically transitioned to `"Published"` and became publicly visible to `EMP002`.
