# Dev Journal 59 — Scroll-Wise Infinite Loading Across Frontend Pages

**Date:** 2026-09-10  
**Focus:** Frontend UX & Infinite Scrolling Standardization  
**Status:** Completed & Verified  

---

## 1. Overview & Context
The user requested scroll-wise loading ("har page pe scroll wise loading dal do") across the entire Knome frontend application. While `Posts.jsx` and `SavedContent.jsx` had earlier implementations of batch-wise scroll loading, other major listing and catalog pages (`Dashboard.jsx`, `Articles.jsx`, `Videos.jsx`, `Podcasts.jsx`, `Communities.jsx`, `Jobs.jsx`, `Network.jsx`, and `Search.jsx`) rendered all retrieved items at once in the DOM.

To deliver a state-of-the-art, high-performance experience with instant initial paint and smooth progressive rendering, we centralized the infinite scroll logic into a reusable hook and unified animated indicator across all pages.

---

## 2. Architectural Design & Implementation

### 2.1 Reusable Scroll Hook (`src/hooks/useScrollLoading.js`)
Created a centralized custom hook `useScrollLoading(totalItemsCount, initialCount = 6, batchSize = 6, offset = 400)`:
- Dynamically attaches a passive scroll listener to `window`.
- Triggers when `window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - offset`.
- Debounces and increments `visibleCount` by `batchSize` while `visibleCount < totalItemsCount`.
- Exposes `reset()` to instantly reset pagination back to `initialCount` when the user switches filters, search queries, or tabs.

### 2.2 Reusable Scroll Loading Indicator (`src/components/ui/ScrollLoadingIndicator.jsx`)
Created an animated spinner badge with dark mode support and `col-span-full` CSS grid compatibility:
- Renders `material-symbols-outlined animate-spin text-indigo-500` with customizable helper text (`Loading more ... on scroll`).

---

## 3. Pages Enhanced

1. **`Dashboard.jsx` (Home Feed)**:
   - Initial count: 6 posts, batch increment: 6.
   - Wired to `posts.slice(0, visibleCount)`.
   - Connected `resetScrollLoading()` to `activeFilter` changes.
   - Displayed `ScrollLoadingIndicator`.

2. **`Articles.jsx` (Article Catalog)**:
   - Initial count: 6 articles, batch increment: 6.
   - Wired to `filteredArticles.slice(0, visibleCount)`.
   - Connected `resetScrollLoading()` to `selectedCategory` and `searchQuery` changes.
   - Displayed `ScrollLoadingIndicator`.

3. **`Videos.jsx` (Video Learning Grid)**:
   - Initial count: 8 videos (2 rows of 4 columns), batch increment: 8.
   - Wired to `filteredVideos.slice(0, visibleCount)`.
   - Connected `resetScrollLoading()` to `activeFilter`, `viewTab`, and `searchQuery` changes.
   - Displayed `ScrollLoadingIndicator`.

4. **`Podcasts.jsx` (Enterprise Audio Directory)**:
   - Initial count: 6 episodes, batch increment: 6.
   - Wired to `displayedEpisodes.slice(0, visibleCount)`.
   - Connected `resetScrollLoading()` to `activeTab`, keyword search, and category changes.
   - Displayed `ScrollLoadingIndicator`.

5. **`Communities.jsx` (Communities Hub)**:
   - Initial count: 8 community cards (2 rows of 4 columns), batch increment: 8.
   - Wired to `filteredCommunities.slice(0, visibleCount)`.
   - Connected `resetScrollLoading()` to `activeTab`, type, category, and search query changes.
   - Displayed `ScrollLoadingIndicator`.

6. **`Jobs.jsx` (Internal Career Opportunities)**:
   - Initial count: 6 roles (2 rows of 3 columns), batch increment: 6.
   - Wired to `displayedJobs.slice(0, visibleCount)`.
   - Connected `resetScrollLoading()` to `activeFilter` changes.
   - Displayed `ScrollLoadingIndicator`.

7. **`Network.jsx` (People & Directory Hub)**:
   - Initial count: 8 colleagues / connections, batch increment: 8.
   - Wired to both `visibleDirectory.slice(0, visibleCount)` and `connectionsList.slice(0, visibleCount)`.
   - Connected `resetScrollLoading()` to `activeTab` and `searchQuery` changes.
   - Displayed `ScrollLoadingIndicator`.

8. **`Search.jsx` (Global Enterprise Search)**:
   - Added window scroll listener triggering `performSearch(true)` automatically when scrolling near the bottom while `hasMore && !isSearching`.
   - Rendered `ScrollLoadingIndicator` during incremental scroll fetching.

---

## 4. Verification & Validation

1. **Vite Production Compilation**:
   - `npm run build` executed in `knomeUI/frontend`.
   - Transformed 522 modules and generated chunks cleanly in 1.30s with zero errors or warnings.
2. **Backend API Validation**:
   - `dotnet build -nologo` executed in `Backend/Knome.API`.
   - Succeeded with `0 Error(s)`.
