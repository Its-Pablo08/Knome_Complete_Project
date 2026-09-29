# Phase 125 — Remove Recommended Filter From Everywhere

**Date:** 2026-09-22  
**Status:** Completed  
**Branch:** main  

---

## 1. Problem Statement & User Requirement
The user requested:
> *"remove recommended filter from everywhere"*

Across the platform, several content catalog and feed pages contained a "Recommended" filter chip/tab alongside standard category or status filters. To ensure clean, predictable feeds focused exclusively on real chronological content and explicit categories, all "Recommended" filter buttons and underlying recommendation branches were removed.

---

## 2. Changes Made Across Modules

### A. Posts Feed ([`Posts.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/pages/Posts.jsx))
- Removed the `✨ Recommended` / `Recommended` filter button from the post category header.
- Cleaned the filter and sort logic to remove the recommendation engine branch (`getPersonalizedRecommendations`), keeping standard chronological post feed and `🔥 Hot Posts` / `⏰ Scheduled` views.
- Updated `showFilterBar` and `isFilterOpen` active filter indicators and active topic badge checks so they no longer reference `✨ Recommended`.

### B. Articles Hub ([`Articles.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/pages/Articles.jsx))
- Removed `'✨ Recommended'` from the `categories` array (`['All', ...(scheduled), ...availableCategories]`).
- Cleaned `matchesCategory` and `filteredArticles` to eliminate the recommendation filter branch.

### C. Podcasts Directory ([`Podcasts.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/pages/Podcasts.jsx))
- Removed `'✨ Recommended for You'` from the tabs list (`['All Episodes', 'General', 'Tech', 'Leadership', 'Engineering', 'My Podcasts']`).
- Removed the `activeTab === '✨ Recommended for You'` filter branch and recommendation sorter from `displayedEpisodes`.

### D. Videos Hub ([`Videos.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/pages/Videos.jsx))
- Removed `'✨ For You'` from the `filters` list (`['All', 'Training & Tutorials', 'Townhalls', 'Engineering Tech Talks', 'Leadership Updates']`).
- Simplified `filteredVideos` to filter solely on selected categories without recommendation overrides.

### E. Jobs Board ([`Jobs.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/pages/Jobs.jsx))
- Cleaned up unused `recommendedJobs` variable.

---

## 3. Verification & Deployment
1. **Frontend Production Build:** Built cleanly with Vite (`npm run build`) in 1.30s with 0 errors across 530 modules.
2. **IIS Deployment:** Deployed updated dist bundles to `C:\inetpub\wwwroot\knome` with 100% success (0 failures).
3. **Vite Dev Server:** Hot-reloaded live on `http://localhost:5173`.
