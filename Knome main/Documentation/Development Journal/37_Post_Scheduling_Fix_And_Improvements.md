# Development Journal – Phase 37: Post Scheduling Fix and Improvements

**Date**: 9 September 2026  
**Phase**: Phase 37 – Post Scheduling Fix & Enhancements  
**Project**: Knome.API & Knome-Web (MPOnline Limited Enterprise Knowledge Platform)  
**Status**: Completed ✅  

---

## 1. Executive Summary & Objective

In this phase, we addressed the post scheduling lifecycle across both Backend (`Knome.API`) and Frontend (`knomeUI/frontend`):
1. **Feed Query Privacy Leak Resolved**: Fixed `PostRepository.cs` where unreleased scheduled posts were previously queryable by non-authors before their scheduled publish time. Scheduled posts are now strictly private to their author until transition to `Published`.
2. **Validator Messages Aligned**: Corrected error messages in `CreatePostValidator.cs` and `UpdatePostValidator.cs` to accurately mention `'Scheduled'` alongside `'Published'`, `'Draft'`, and `'Archived'`.
3. **Backend Service Hardening**: Updated `PostService.UpdatePostAsync` to handle past-due checks and scheduled date transitions seamlessly.
4. **Author Controls & Immediate Publishing**: Enhanced `PostCard.jsx` to render an amber Scheduled banner with timestamp, an amber dashed border, and a "Publish Now" button enabling authors to bypass the queue and take the post live immediately. Added "Cancel Schedule" action moving the post safely to Drafts.
5. **Scheduled Posts Feed Filter Tab**: Added a dedicated "⏰ Scheduled" filter button with a live count badge in `Posts.jsx` so authors can monitor their upcoming scheduled queue in one click.
6. **Time Picker Validation**: Enforced future timestamp validation in `CreatePostModal.jsx` to eliminate accidental past/immediate submissions.

---

## 2. Key Code Changes

### Backend (`Backend/Knome.API`)
- **`Repositories/PostRepository.cs`**:
  ```csharp
  .Where(p => p.CreatedDate >= retentionCutoff && 
              (string.IsNullOrEmpty(p.Status) || 
               p.Status == "Published" || 
               (p.AuthorUserId == currentUserId)))
  ```
- **`Services/PostService.cs`**:
  Added automated due-check handling in `UpdatePostAsync`.
- **`Validators/Posts/CreatePostValidator.cs` & `UpdatePostValidator.cs`**:
  Aligned validation messages to list `'Scheduled'`.

### Frontend (`knomeUI/frontend`)
- **`utils/apiService.js`**:
  Added `postsApi.update(id, data)` using `PUT /posts/{id}`.
- **`components/widgets/PostCard.jsx`**:
  Added scheduled status badge, subtle styling, "Publish Now" button, and 3-dots "Cancel Schedule" action.
- **`pages/Posts.jsx`**:
  Added "⏰ Scheduled" filter button with count badge and custom empty state.
- **`components/modals/CreatePostModal.jsx`**:
  Added validation ensuring scheduled times are strictly set in the future.

---

## 3. Verification & Build
- `Backend/Knome.API`: `dotnet build -nologo` built with 0 warnings, 0 errors.
- `knomeUI/frontend`: `npm run build` completed with 0 errors in 923ms.
- Background publisher `ScheduledPostHostedService` verified running every 15s.
