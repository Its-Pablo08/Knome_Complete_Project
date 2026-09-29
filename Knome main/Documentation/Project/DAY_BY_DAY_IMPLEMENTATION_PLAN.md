# Knome Platform — Day-by-Day Implementation Plan 🗓️

> **Enterprise Knowledge Management Platform (LinkedIn/Medium/YouTube Hybrid) for MPOnline Limited**  
> **Backend Baseline**: `Backend/Knome.API` (`v1.2.8` Frozen & Production-Hardened)  
> **Frontend Baseline**: `knomeUI/frontend` (React + Vite + TailwindCSS + JavaScript/TypeScript)

---

## 🎯 Executive Summary & Objectives

This document details the step-by-step, day-by-day implementation plan to transition the Knome Platform from a frozen, production-ready ASP.NET Core 9 backend into a fully integrated, responsive, and feature-complete enterprise web portal.

---

## 📅 Schedule Overview (14-Day Roadmap)

```
Week 1: Foundation, Auth, User Profiles, Content Feeds & Media Channels
├── Day 01: API Client Layer, Axios Interceptors & Auth State Management
├── Day 02: Auth Flows (Login, Protected Routes, Session Handling)
├── Day 03: Profile Module (Self-Service, DPDP Masking, Photo Uploads)
├── Day 04: Post & Article Creation Engines (Rich Text, @Mentions)
├── Day 05: Polymorphic Content Interaction Engine (Comments, Reactions, Bookmarks, Shares)
├── Day 06: Media Channels (Video Player, Podcast Player, Tags)
└── Day 07: Community Spaces & Member Governance (Public, Private, Pinned Posts)

Week 2: Dashboard, Gamification, Search, Governance & Release
├── Day 08: Dynamic Dashboard Feed & Hot Posts Ranking Engine Integration
├── Day 09: Global Search & Discovery Engine (Unified Filter, Search History)
├── Day 10: Gamification Engine & Karma Points System (Badges, History)
├── Day 11: Internal Job Posting Board & Notification Center
├── Day 12: Audit Trail & Admin Governance Console (System/HR Admin Views)
├── Day 13: End-to-End Integration, Error Boundaries & Polish
└── Day 14: Final Production Verification & Handoff Release (v1.3.0)
```

---

## 📋 Detailed Day-by-Day Breakdown

---

### 🔹 Day 01: API Client Layer & Infrastructure Foundation
* **Goal**: Establish standard API integration layer, Axios instances, error handling, and authentication context.
* **Key Tasks**:
  1. Create `src/api/axiosClient.js` configured with `baseURL: 'http://localhost:5095/api'`.
  2. Implement request interceptors to automatically attach `Authorization: Bearer <JWT_TOKEN>`.
  3. Implement response interceptors to parse `ApiResponse<T>` wrapper and catch global errors (`401 Unauthorized`, `403 Forbidden`, `404 Not Found`).
  4. Create `AuthContext.jsx` for global user authentication state.
* **Verification**: Verify token attachment and interceptor handling via scratch API call to `GET /api/auth/me`.

---

### 🔹 Day 02: Authentication & Protected Routing
* **Goal**: Implement Login page, session persistence, logout, and route protection based on roles.
* **Key Tasks**:
  1. Wire `Login.jsx` form to `POST /api/auth/login`.
  2. Persist JWT token and claims safely in `localStorage`/`sessionStorage`.
  3. Implement `<ProtectedRoute>` component checking user roles (`Employee`, `Community Admin`, `HR Administrator`, `System Administrator`).
  4. Implement session timeout handling and automatic logout on HTTP 401.
* **Verification**: Verify credentials `EMP001`–`EMP004` login successfully and receive role-appropriate navigation access.

---

### 🔹 Day 03: User Profile & Management Module (`FR-UP-01..06`)
* **Goal**: Connect user profile pages, avatar upload, skill management, and DPDP privacy settings.
* **Key Tasks**:
  1. Connect `Profile.jsx` to `GET /api/users/profile` and `GET /api/users/{id}`.
  2. Wire profile edit form to `PUT /api/users/profile` (Bio, Department, Skills, Interests).
  3. Implement avatar upload handling calling `POST /api/users/profile/photo` with magic byte validation support.
  4. Implement Indian DPDP Act 2023 visibility toggles (`BioVisibility`, `PhotosVisibility`).
* **Verification**: Test profile updates and verify image upload renders correctly across user cards.

---

### 🔹 Day 04: Post & Article Creation Engines (`FR-PC-01..07`, `FR-AB-01..07`)
* **Goal**: Enable quick posts (max 400 chars with `@mentions`) and rich-text technical articles.
* **Key Tasks**:
  1. Build `CreatePostModal.jsx` connected to `POST /api/posts` (400 char limit validation, user autocomplete for `@mentions`).
  2. Create rich text article editor (`CreateArticle.jsx`) integrated with `POST /api/articles`.
  3. Connect Article detail view (`ArticleView.jsx`) with automatic version snapshot display (`ArticleVersions`).
  4. Handle real-time keyword/URL moderation error handling from API (`FR-SM-01`).
* **Verification**: Create a post with `@EMP002` mention and create an article, verifying version creation on update.

---

### 🔹 Day 05: Content Interaction Engine (`FR-CI-01..05`)
* **Goal**: Wire up polymorphic interactions across posts, articles, videos, and podcasts.
* **Key Tasks**:
  1. Connect `PostCard.jsx` and article views to `IContentInteractionService` endpoints:
     - `POST /api/interactions/reactions` (Like, Love, Insightful, Celebrate)
     - `POST /api/interactions/comments` & `GET /api/interactions/comments`
     - `POST /api/interactions/bookmarks`
     - `POST /api/interactions/shares`
  2. Implement state updates for real-time reaction counts and bookmark toggles.
  3. Connect `SavedContent.jsx` to display user bookmarked items (`GET /api/interactions/bookmarks/my`).
* **Verification**: Toggle likes and bookmarks across items; confirm immediate UI state updates and API sync.

---

### 🔹 Day 06: Media Channels — Video & Podcast (`FR-VC-01..06`, `FR-PD-01..05`)
* **Goal**: Implement video player channel and podcast audio player components.
* **Key Tasks**:
  1. Wire `Video.jsx` channel page to `GET /api/videos` with category and tag filtering.
  2. Implement video upload/embed modal (`POST /api/videos`) enforcing `<= 500 MB` limit.
  3. Wire `Podcast.jsx` channel page to `GET /api/podcasts` and series overview (`GET /api/podcasts/series`).
  4. Integrate custom HTML5 / React Audio & Video players with view count triggers (`POST /api/videos/{id}/view`).
* **Verification**: Play video and podcast media; confirm view counts increment on backend.

---

### 🔹 Day 07: Community Spaces & Governance (`FR-CM-01..09`)
* **Goal**: Connect public, private, and default community hubs, join workflows, and admin controls.
* **Key Tasks**:
  1. Connect `Community.jsx` list and detail views (`GET /api/communities`, `GET /api/communities/{id}`).
  2. Implement join request workflow for private communities (`POST /api/communities/{id}/join`).
  3. Wire post pinning controls (`POST /api/communities/{id}/pin/{postId}`, max 3 limit enforcement).
  4. Connect community member management and sole admin safeguard warnings.
* **Verification**: Test joining public/private communities and verify pinned posts appear pinned at feed top.

---

### 🔹 Day 08: Dashboard Feed & Hot Posts Ranking (`FR-DB-01..08`)
* **Goal**: Implement main feed aggregating followed communities, personalized posts, and hot trends.
* **Key Tasks**:
  1. Connect `Dashboard.jsx` to `GET /api/dashboard/feed`.
  2. Integrate Hot Posts ranking engine widget (`GET /api/dashboard/hot-posts`).
  3. Implement feed tab switching (All Posts, Following, Trending, My Department).
  4. Implement infinite scroll / pagination loading for dashboard feed.
* **Verification**: Verify feed updates dynamically and hot posts reflect ranking algorithm outputs.

---

### 🔹 Day 09: Global Search & Discovery Engine (`FR-SD-01..05`)
* **Goal**: Deliver unified instant search bar and search analytics.
* **Key Tasks**:
  1. Wire top navigation search input and `Search.jsx` to `GET /api/search`.
  2. Implement multi-entity tab navigation (Users, Posts, Articles, Videos, Podcasts, Communities, Jobs).
  3. Implement search filters (Date Range, Department, Category, Tag).
  4. Wire search history saving and recent search clear (`GET /api/search/history`, `DELETE /api/search/history`).
* **Verification**: Perform searches for keywords and tags; verify history records and filter updates.

---

### 🔹 Day 10: Gamification Engine & Karma System (`FR-KP-01..04`)
* **Goal**: Display employee karma scores, achievement badges, and reward activity logs.
* **Key Tasks**:
  1. Connect Karma widget on user profile and dashboard (`GET /api/karma/balance`).
  2. Wire `KarmaHistory.jsx` to `GET /api/karma/history`.
  3. Render user tier badges (`Bronze`, `Silver`, `Gold`, `Platinum`) dynamically based on points balance.
  4. Connect HR Admin manual karma award modal (`POST /api/karma/award` - System Admin scope).
* **Verification**: Award points via API; verify badge and balance update instantly in UI.

---

### 🔹 Day 11: Internal Job Board & Notification Engine (`FR-JB-01..05`, `FR-NT-01..04`)
* **Goal**: Connect internal mobility job board and real-time notification drop-down menu.
* **Key Tasks**:
  1. Wire `Jobs.jsx` to `GET /api/jobs` with location, skill, and department filters.
  2. Implement Job creation modal for HR/System Admins (`POST /api/jobs` returning `201 Created`).
  3. Connect Notification bell dropdown (`GET /api/notifications`, unread count endpoint).
  4. Implement mark-as-read and notification preferences settings page.
* **Verification**: Create a new job posting as HR Admin; verify automatic broadcast bell notification received.

---

### 🔹 Day 12: Audit Trail & Admin Governance Console (`FR-SM-04..05`)
* **Goal**: Implement governance console for HR and System Administrators.
* **Key Tasks**:
  1. Connect Admin Console (`AdminConsole.jsx`) to `GET /api/audit/logs` with range and module filters (System Admin role gated).
  2. Wire User Governance controls (Department change, Role assignment, Account Suspension).
  3. Wire moderation report management interface (`GET /api/moderation/reports`, resolve/dismiss actions).
* **Verification**: Perform user suspension as System Admin; confirm action is logged in Audit Trail and user token invalidated.

---

### 🔹 Day 13: End-to-End Integration, Error Handling & Polish
* **Goal**: System-wide hardening, UI responsiveness, toast notifications, and fallback boundaries.
* **Key Tasks**:
  1. Add React Error Boundaries around major route sections.
  2. Implement global toast notification system for success/error feedback.
  3. Ensure dark mode consistency across all pages.
  4. Perform cross-browser responsiveness checks (Desktop, Tablet, Mobile breakpoints).
* **Verification**: Intentionally throw network errors; verify UI degrades gracefully with user-friendly alerts.

---

### 🔹 Day 14: Final Verification, Production Build & Handoff Release (`v1.3.0`)
* **Goal**: Execute full verification suite, build production assets, and declare frontend-backend integration complete.
* **Key Tasks**:
  1. Run `npm run build` in `knomeUI/frontend` to verify 0 build errors.
  2. Execute scratch backend verification scripts (`scratch/VerifyDiResolvers`, `scratch/VerifyAuth`, etc.).
  3. Update `PROJECT_STATUS.md` and `PROJECT_CONTEXT.md` to reflect `v1.3.0` completion status.
  4. Prepare final release notes for MPOnline Limited deployment.
* **Verification**: Clean production build generated; full end-to-end user workflows validated against live SQL Server DB.

---

## 🛠️ Verification Commands

```powershell
# Backend Verification
cd "Backend/Knome.API"
dotnet build -nologo
dotnet run --project "Tools/VerifyDiResolvers/VerifyDiResolvers.csproj"

# Frontend Build Verification
cd "knomeUI/frontend"
npm run build
npm run dev
```
