# Development Journal – Phase 48: Enterprise Article Scheduling Workflow & Activation

**Date**: 10 September 2026  
**Phase**: Phase 48 – Enterprise Article Scheduling Workflow & Activation  
**Project**: Knome.API & Knome-Web (MPOnline Limited Enterprise Knowledge Platform)  
**Status**: Completed ✅  

---

## 1. Executive Summary & Objective

In this phase, we activated and integrated complete end-to-end article scheduling across both Frontend (`knomeUI/frontend`) and Backend (`Knome.API`), matching the high-standard enterprise experience established in Phase 47:
1. **Activation of Article Scheduling UI**:
   - `CreateArticleModal.jsx` previously had static, non-functional `"Schedule"` and `"Save Draft"` buttons.
   - Connected the "Schedule" button to an enterprise scheduling popover complete with Indian standard date formatting (`DD/MM/YYYY, hh:mm A`), timezone context banner (`IST (UTC+05:30)`), 6 quick presets (`+1 Min`, `+5 Mins`, `+15 Mins`, `+30 Mins`, `+1 Hour`, `Tomorrow 9 AM`), and a live countdown preview card.
   - Integrated an interactive **Scheduled Pill Chip** (`[ ⏰ Scheduled: DD/MM/YYYY, hh:mm A • in 1m | ✏️ Edit | × ]`) in the modal footer.
   - Dynamically upgraded the primary action button to `"Schedule Article"` with an `event_available` icon and amber/indigo styling when a schedule time is set.
   - Wired the `"Save Draft"` button to submit with `status: "Draft"`.
2. **Full-Page Editor Mode Scheduling in `Articles.jsx`**:
   - Replaced static schedule buttons in `Articles.jsx`'s full-page editor mode with the full scheduling state, popover, scheduled pill chip, and dynamic submit button.
3. **Author Privacy & "⏰ Scheduled" Queue Tab in `Articles.jsx`**:
   - Enforced author-only visibility for future scheduled articles: non-authors are barred from viewing unpublished scheduled articles across lists and categories.
   - Added a dynamic `"⏰ Scheduled (N)"` filter button in the category bar when the logged-in user has scheduled articles awaiting publication.
   - Enhanced article cards with an amber accent border, scheduled status banner with `DD/MM/YYYY` timing, and an immediate **"Publish Now"** manual override button for authors.
4. **Backend Article Scheduling Pipeline**:
   - Added `ScheduledDate` to `CreateArticleDto`, `UpdateArticleDto`, and `ArticleDto`.
   - Updated `CreateArticleValidator` and `UpdateArticleValidator` to validate `'Scheduled'` status.
   - Implemented `IArticleRepository.PublishDueScheduledArticlesAsync()` and updated `GetArticlesAsync` with `currentUserId` filtering so scheduled articles automatically auto-transition to `Published` and respect author privacy.
   - Wired `ScheduledPostHostedService` background worker to run `PublishDueScheduledArticlesAsync()` every 15 seconds alongside posts.

---

## 2. Key Code Changes

### Frontend (`knomeUI/frontend`)

- **`src/utils/articleService.js`**:
  - Imported `formatToDDMMYYYY` and mapped `scheduledDate`, `isScheduledFuture`, `status`, and `authorUserId` for each article.
  - Exported `updateArticle(articleId, articleDto)` and `publishScheduledArticleNow(article)` for manual publication overrides.
- **`src/components/modals/CreateArticleModal.jsx`**:
  - Added scheduling states (`isScheduling`, `scheduledTime`, `schedulePopoverRef`) and helper functions (`getRelativeScheduleText`, `getLocalDatetimeInputValue`, `getTomorrowTime`).
  - Added outside-click dismiss listener to smoothly close popover.
  - Added rich scheduling popover with `IST (UTC+05:30)` banner, `datetime-local` input (`min={+1 Min}`), 6 quick presets, live preview card, and Clear/Apply buttons.
  - Added interactive scheduled pill chip in modal footer and dynamic `"Schedule Article"` button.
  - Wired `handlePublish`: validates `>= 20s` in the future for 1-minute scheduling, supports `Scheduled`, `Draft`, and `Published` statuses with descriptive toasts.
- **`src/pages/Articles.jsx`**:
  - Added scheduling state, popover, and scheduled pill chip to full-page editor mode.
  - Updated article filtering (`rawFiltered`): future scheduled articles are strictly filtered to the author until publication time.
  - Added dynamic `"⏰ Scheduled (${myScheduledArticles.length})"` tab in category filter bar.
  - Highlighted scheduled article cards with an amber border, scheduled timing ribbon, and immediate **"Publish Now"** button.

### Backend (`Backend/Knome.API`)

- **`DTOs/Articles/CreateArticleDto.cs` & `UpdateArticleDto.cs`**:
  - Added `public DateTime? ScheduledDate { get; set; }`.
- **`DTOs/Articles/ArticleDto.cs`**:
  - Added `public DateTime? ScheduledDate { get; set; }`.
- **`Validators/Articles/CreateArticleValidator.cs` & `UpdateArticleValidator.cs`**:
  - Included `'Scheduled'` in status validation message and rules.
- **`Interfaces/IArticleRepository.cs` & `Repositories/ArticleRepository.cs`**:
  - Added `Task<int> PublishDueScheduledArticlesAsync()`.
  - Updated `GetArticlesAsync` to filter future scheduled articles by `currentUserId`, preserving author privacy.
- **`Interfaces/IArticleService.cs` & `Services/ArticleService.cs`**:
  - Updated `CreateArticleAsync` and `UpdateArticleAsync` to handle `ScheduledDate` and UTC comparison.
- **`Background/ScheduledPostHostedService.cs`**:
  - Injected `IArticleRepository` into background service scope and executed `PublishDueScheduledArticlesAsync()` every 15 seconds.

---

## 3. Verification & Results

1. **Frontend Compilation**:
   - `npm run build` completed with **0 errors** in 1.11s.
2. **Backend Compilation**:
   - `dotnet build -nologo` completed with **0 warnings, 0 errors**.
3. **Live Database Verification Script (`scratch/test_schedule_article.ps1`)**:
   - Verified authentication with test accounts `EMP001` (Author) and `EMP002` (Reader).
   - Created an article scheduled +1 minute in the future: returned `status: "Scheduled"`.
   - Verified Author Privacy: `EMP001` could see the scheduled article; `EMP002` could NOT see it.
   - Verified Background Auto-Publisher: After 65 seconds, `ScheduledPostHostedService` transitioned the status to `"Published"` with `PublishedDate` populated.
   - Verified Reader Visibility: Reader `EMP002` could now see the published article in the public feed.
   - Verified Manual Override: Author tested immediate `"Publish Now"` on a future scheduled article, transitioning it instantly to `"Published"`.
