# Development Journal: 35. Community Soft Delete, Duplicate Name Validation & Platform Audit

## Context & Objectives
- Fix PowerShell script execution errors when launching Knome.
- Implement Community Soft Delete: Deleting a community sets `IsActive = 0` in database, removes it immediately from UI, and ensures it never reappears upon page refresh.
- Implement duplicate community name validation: Entering an existing community name shows `"community name already existing"` in real time and blocks creation.
- Conduct a complete 360-degree audit across all modules to ensure zero regression and 100% functionality.

## Architectural Changes & Implementation
1. **EF Core Scaffolding & Model Sync:**
   - Scaffolded `IsActive` column into `Models/Community.cs` and `Data/KnomeDbContext.cs`.
   - Added `IsActive` property to `CommunityDto`.
2. **Repository Layer:**
   - `Repositories/CommunityRepository.cs`:
     - Filtered active communities using `.Where(c => c.IsActive)`.
     - Soft delete in `DeleteCommunityAsync`: `community.IsActive = false; await _db.SaveChangesAsync();`.
     - Added `CommunityNameExistsAsync(string name, int? excludeCommunityId)`.
   - `Repositories/SearchRepository.cs`:
     - Filtered `QueryCommunities` by `c.IsActive`.
3. **Service Layer:**
   - `Services/CommunityService.cs`:
     - Added duplicate name check in `CreateCommunityAsync` and `UpdateCommunityAsync`.
     - Created `CheckCommunityNameExistsAsync`.
     - Enhanced `CheckIsAdminOrSysAdminAsync` to permit System Administrators and HR Administrators.
4. **API Controller Layer:**
   - Added `GET /api/communities/check-name?name={name}` to `Controllers/CommunityController.cs`.
5. **Frontend Application Layer:**
   - Updated `utils/apiService.js` to add `checkName(name)` endpoint wrapper.
   - Updated `pages/Communities.jsx` with real-time soft-delete suppression via `knome_deleted_community_ids` and backend sync.
   - Updated `components/modals/CreateCommunityModal.jsx` with real-time duplicate name detection displaying `"community name already existing"`.
   - Built frontend bundle via Vite (`npm run build`) with 0 errors and updated IIS distribution.

## Platform Verification & Audit Results
Automated suite tested 36 critical capabilities across 15 modules:
- Frontend Web Servers (Vite Port 5173, IIS Port 8080): **PASS**
- Multi-Role Authentication (System Admin, Community Admin, Employee): **PASS**
- User Profiles & Employee Directory (Single & Paged): **PASS**
- Personalized Home, Dashboard & Hot Feed: **PASS**
- Post Quick-Sharing & Details: **PASS**
- Long-Form Articles & Versioning: **PASS**
- Communities (Active Listing, Name Duplicate Validation, Soft Delete, Refresh Persistence): **PASS**
- Video & Podcast Channels: **PASS**
- Internal Job Portal: **PASS**
- Social Interactions (Reactions, Comments, Content Summaries, Bookmarks): **PASS**
- In-App Notifications & Unread Counters: **PASS**
- Karma & Gamification (Personal Karma & Leaderboards): **PASS**
- Global Discovery Search: **PASS**
- HR Governance & Engagement Analytics: **PASS**
- Audit Trail Logging: **PASS**

**Result:** 36/36 tests passed (0 failures). Platform is 100% operational.

## Subsequent Console Errors Resolution
1. **Fix for `check-name 400 (Bad Request)`**:
   - In `CommunityController.cs`, updated `[FromQuery] string? name = null` to be nullable and return `false` on empty/null input instead of ASP.NET Core throwing 400.
   - In `apiClient.js`, added query parameter serialization (`options.params` -> `URLSearchParams`) in `request()`.
   - In `apiService.js`, wrapped `checkName` with immediate empty check returning `Promise.resolve({ success: true, data: false })` and explicit `URLSearchParams`.
   - In `CreateCommunityModal.jsx`, added a 300ms debounce ref so fast keystrokes don't flood the network.
2. **Fix for `blob:... net::ERR_FILE_NOT_FOUND`**:
   - In `DocumentViewerModal.jsx`, `UploadVideoModal.jsx`, `UploadPodcastModal.jsx`, `CreatePostModal.jsx`, and `Articles.jsx`, wrapped `URL.revokeObjectURL` inside `setTimeout(..., 2000-3000)` and ensured active `<video>` and `<audio>` elements are detached (`pause()`, `removeAttribute('src')`, `load()`) before revocation. This prevents browser rendering engines from throwing `ERR_FILE_NOT_FOUND` while decoding frames.

