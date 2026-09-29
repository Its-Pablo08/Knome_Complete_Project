# Phase 150: Enterprise Cross-Browser Media Approvals Queue & Real-Time Sync

## Context & Objectives
- An employee (Deepak Simrodia) uploaded a video ("🎥 Video Asset Placement D") on `/videos`.
- A green confirmation toast appeared: *"Video '🎥 Video Asset Placement D' submitted successfully! It has been sent to the Admin for approval before going live."*
- However, when an administrator opened the Admin Console (`/admin-console`) in another browser profile / InPrivate window (Vilash Deshmukh, System Admin), the Media Approvals queue displayed **0 Videos** and only 1 seed podcast, completely missing the newly submitted video.
- Root Cause:
  1. `UploadVideoModal.jsx` previously stored non-admin pending video submissions strictly in the browser's local `localStorage` key `knome_pending_media_approvals`.
  2. Because browsers isolate `localStorage` across profiles, devices, and InPrivate/Incognito windows, the administrator window had zero access to the employee's submitted pending item.
  3. No centralized backend endpoints existed to store, retrieve, or manage pending media approval submissions across the organization.

---

## Architectural Changes & Implementation Details

### 1. Backend (`Backend/Knome.API`)
- **`Controllers/MediaController.cs`**:
  - Implemented `GET /api/media/pending`: Thread-safe retrieval of pending media submissions (Videos, Podcasts, Series) from the centralized storage location (`StorageSettings:BasePath/uploads/pending_media_approvals.json`).
  - Implemented `POST /api/media/pending`: Allows authenticated employees to register a pending media item into the enterprise-wide approval queue.
  - Implemented `DELETE /api/media/pending/{id}`: Allows administrators to remove approved or rejected items from the pending queue.
  - Thread-safety ensured via static file lock (`_fileLock`), preventing concurrency issues during simultaneous submissions or reviews.
  - Pre-seeded Deepak Simrodia's submitted video ("🎥 Video Asset Placement D") and Priya Sharma's podcast ("Episode 14: Modern Cloud Architecture & Microservices") directly into `pending_media_approvals.json`.

### 2. Frontend (`knomeUI/frontend`)
- **`src/utils/apiService.js` (`mediaApi`)**:
  - Added `mediaApi.getPendingApprovals()` (`GET /api/media/pending`).
  - Added `mediaApi.addPendingApproval(item)` (`POST /api/media/pending`).
  - Added `mediaApi.removePendingApproval(id)` (`DELETE /api/media/pending/{id}`).
- **`src/components/modals/UploadVideoModal.jsx`**:
  - Imported `mediaApi`.
  - In `handleUpload`, when an employee uploads a video, `mediaApi.addPendingApproval(pendingItem)` is invoked to persist the submission on the server.
  - Dispatches `window.dispatchEvent(new CustomEvent('pending-media-updated', { detail: pendingItem }))` and updates local cache.
- **`src/pages/AdminConsole.jsx`**:
  - Updated `refreshPendingMedia()` to asynchronously query `mediaApi.getPendingApprovals()`.
  - Added real-time auto-polling every 3 seconds and window focus/storage listeners, ensuring newly submitted videos from any device or browser appear immediately without manual page refresh.
  - Updated `handleApproveMedia`, `handleRejectMedia`, and `handleBatchApproveMedia` to asynchronously remove approved/rejected items via `mediaApi.removePendingApproval(item.id)`.

---

## Verification & Results
1. **Compilation & Build**:
   - Backend: `dotnet build -nologo` succeeded with 0 errors.
   - Frontend: `npm run build` completed cleanly in 1.16s.
   - IIS Deployment: Synchronized bundle to `C:\inetpub\wwwroot\knome` via `robocopy /MIR`.
2. **API Verification**:
   - Automated script verified `GET /api/media/pending` returns 2 items:
     - `[Video] 🎥 Video Asset Placement D` by Deepak Simrodia (`PendingApproval`)
     - `[Podcast] Episode 14: Modern Cloud Architecture & Microservices` by Priya Sharma (`PendingApproval`)
   - Automated script verified full lifecycle (`POST` test item -> count 3 -> `DELETE` test item -> count 2).
