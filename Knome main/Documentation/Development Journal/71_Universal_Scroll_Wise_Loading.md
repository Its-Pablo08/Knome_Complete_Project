# Dev Journal: 71 - Universal Scroll-Wise Loading Across All Feeds, Catalogs & Modals

**Date:** September 15, 2026  
**Status:** Completed & Verified  
**Package:** Frontend (`knomeUI/frontend`)

---

## 1. Overview & Context

Following Phase 59 (which introduced infinite scroll to primary catalogs: Dashboard, Articles, Videos, Podcasts, Communities, Jobs, Network, and Search), the user requested complete, universal scroll-wise progressive loading across all remaining interfaces:
> *"har jagah scroll wise loading add karo"*

All feeds, catalogs, user profile tabs, administrative management tables, and modal employee pickers that previously rendered their complete datasets at once have been standardized onto the central `useScrollLoading` hook and `ScrollLoadingIndicator` visual component.

---

## 2. Core Hook Enhancement (`useScrollLoading.js`)

The core hook was enhanced with container ref support while preserving full backward compatibility:
- **Dual Scroll Target Support:** Detects whether an optional `containerRef` is passed.
  - If `containerRef` is provided, listens to `target.scrollTop + target.clientHeight >= target.scrollHeight - offset`.
  - If `containerRef` is null, defaults to global window scrolling (`window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - offset`).
- **Debounced Fetch State:** Includes `isFetchingMore` flag and micro-delay to prevent redundant multi-batch triggering.
- **Universal Exports & Aliases:** Exports both named and default `useScrollLoading`, returning `{ visibleCount, isFetchingMore, reset, resetVisibleCount, setVisibleCount }`.

---

## 3. Pages & Modals Standardized

### 3.1 Dedicated Posts Feed (`Posts.jsx`)
- Replaced inline scroll listeners and state with `useScrollLoading(filteredPosts.length, 6, 6)`.
- Renders `<ScrollLoadingIndicator isVisible={visibleCount < filteredPosts.length} text="Loading more posts on scroll..." />`.
- Resets count automatically on search query or hashtag category changes.

### 3.2 Saved Content Catalog (`SavedContent.jsx`)
- Replaced legacy custom scroll handler with `useScrollLoading(categoryFilteredItems.length, 8, 8)`.
- Renders `<ScrollLoadingIndicator isVisible={visibleItemCount < categoryFilteredItems.length} text="Loading more saved items on scroll..." />`.
- Resets count automatically on folder category and media tab switches.

### 3.3 Community View (`CommunityView.jsx`)
- **Community Feed Tab:** `useScrollLoading(sortedPosts.length, 6, 6)` with `<ScrollLoadingIndicator />`.
- **Members & Roles Tab:** `useScrollLoading(filteredMembers.length, 12, 12)` with `<ScrollLoadingIndicator />` and live search query reset.
- **Files & Media Tab:** `useScrollLoading(filteredFiles.length, 9, 9)` with `<ScrollLoadingIndicator />` and category/query reset.

### 3.4 User Profile View (`Profile.jsx`)
- Tracks active tab and slices all catalog lists accordingly:
  - **Posts:** 6 per batch
  - **Articles:** 6 per batch
  - **Videos:** 6 per batch
  - **Podcasts:** 6 per batch
  - **Communities:** 6 per batch
  - **Network Connections:** 6 per batch
- Integrates `<ScrollLoadingIndicator />` at the bottom of each tab, resetting on tab switch and sub-filter change.

### 3.5 Admin Console (`AdminConsole.jsx`)
- **Moderation Reports Table:** Slices 15 reports per batch; attaches `moderationTableRef` to the scrollable table container (`max-h-[calc(100vh-310px)]`).
- **User Governance Table:** Slices 15 users per batch with search filtering reset.
- **Audit Log Trail:** Slices 20 audit log entries per batch with search filtering reset.
- Displays `<ScrollLoadingIndicator />` beneath each table when additional entries remain.

### 3.6 Community Creation Modal (`CreateCommunityModal.jsx`)
- Attaches `employeeGridRef` to the scrollable modal container (`max-h-[340px] overflow-y-auto`).
- Loads 12 candidate employee cards initially and reveals 12 more per scroll trigger with `<ScrollLoadingIndicator />`.

---

## 4. Build & Production Deployment

1. **Frontend Production Build:**
   ```powershell
   cd knomeUI/frontend
   npm run build
   ```
   *Result:* 523 modules transformed, 0 errors, chunks generated cleanly.
2. **IIS Production Webroot Deployment:**
   ```powershell
   Copy-Item -Path "d:\Knome main\knomeUI\frontend\dist\*" -Destination "C:\inetpub\wwwroot\knome\" -Recurse -Force
   ```
   *Result:* Deployed to `http://localhost:8080/`.
3. **Backend API Validation:**
   ```powershell
   dotnet build "Backend\Knome.API\Knome.API.csproj" -nologo
   ```
   *Result:* 0 errors. Daemon running healthy on `http://localhost:5095`.

---

## 5. Verification Checklist

- [x] Dedicated Posts page loads 6 posts, reveals additional posts progressively on window scroll.
- [x] Saved Content page loads 8 items, reveals more on scroll.
- [x] Community View Feed tab loads 6 posts on scroll.
- [x] Community View Members tab loads 12 members on scroll.
- [x] Community View Files tab loads 9 media items on scroll.
- [x] Profile page tabs (Posts, Articles, Videos, Podcasts, Communities, Network) load progressively on scroll.
- [x] Admin Console Moderation, Users, and Audit tables load progressively on scroll.
- [x] Create Community Modal employee grid loads 12 members per batch inside inner scroll container.
- [x] Production build passes with 0 errors and synced to IIS.
