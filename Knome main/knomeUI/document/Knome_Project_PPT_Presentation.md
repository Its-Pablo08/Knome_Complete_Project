# 📊 Knome Enterprise Knowledge Platform — Project Presentation (PPT)

> **Enterprise Knowledge Management Platform (LinkedIn / Medium / YouTube Hybrid)**  
> **Prepared for**: MPOnline Limited  
> **Monorepo**: Backend (`Backend/Knome.API` ASP.NET Core 10) + Frontend (`knomeUI/frontend` React 18 / Vite 5)  
> **Current Version**: `v1.2.8` (Backend Frozen) → `v1.3.0` (Full Portal Release)

---

# 📌 Slide 1: Executive Summary & Project Vision

## 🚀 Welcome to Knome Platform

**Knome** is an enterprise-grade Knowledge Management & Social Collaboration Portal designed for **MPOnline Limited**. It combines the best capabilities of modern professional platforms:
- **LinkedIn**: Employee networking, activity feed, skills, @mentions, reactions, and internal job board.
- **Medium**: Rich-text technical articles, tag discovery, read-time estimates, and version history.
- **YouTube / Spotify**: Enterprise video streaming channels and persistent global audio podcast player.

### 🎯 Key Objectives & Deliverables
1. **Break Knowledge Silos**: Enable cross-departmental sharing of technical knowledge, ideas, and announcements.
2. **Enterprise Privacy & Security**: Indian DPDP Act 2023 compliance, stateless JWT security, and audit trails.
3. **Employee Engagement**: Gamified Karma points ledger, recognition badges, and trending hot content algorithms.

---

# 🏗️ Slide 2: Full-Stack System Architecture

## 📐 Architecture Blueprint & Technology Stack

```
[React 18 SPA (Vite 5 / TailwindCSS)]
              │  HTTP REST / JSON
              ▼
[ASP.NET Core 10 Web API]
  ├── Middleware Pipeline (JWT Auth / Security Headers / Exception Handling)
  ├── 16 REST API Controllers
  ├── 14 Business Logic Services
  ├── Generic Repositories & Unit of Work
  └── Entity Framework Core 10 (Database-First)
              │  LINQ Queries
              ▼
[Microsoft SQL Server Database (Knome)]
```

### 🛠️ Technology Stack Matrix
| Layer | Framework / Library | Architectural Role |
| :--- | :--- | :--- |
| **Backend API** | ASP.NET Core 10.0 (C# 13) | Enterprise RESTful Web API service delivering high-throughput JSON endpoints |
| **ORM / Data Access** | EF Core 10 (Database-First) | Strongly-typed SQL Server mapping using scaffolded models (`Models/`) |
| **Database Engine** | Microsoft SQL Server | Relational database housing users, posts, media, interactions, karma, & audit logs |
| **Authentication** | JWT (HS256) + BCrypt | Stateless bearer token authentication with salted password hashing (work factor 11) |
| **Frontend SPA** | React 18 + Vite 5 + TailwindCSS | Single Page Application with dynamic context state and glassmorphic UI components |
| **Validation & Mapping**| FluentValidation + AutoMapper | Automatic request DTO validation and entity-to-DTO object mapping |

---

# 📁 Slide 3: Backend Clean Architecture Layout

## 🧱 Layer Separation & Design Patterns

The backend follows **Clean Architecture** principles to separate HTTP transport, business rules, and database operations:

```
Backend/Knome.API/
├── Controllers/       # Thin API Endpoints (Routing, Authorization, Request Dispatching)
├── Services/          # Core Business Logic (Karma math, Moderation, Feed ranking, Audit)
├── Repositories/      # Data Access Layer (EF Core LINQ Queries & DbContext abstraction)
├── Models/            # Single Source of Truth (Database-First Scaffolded Entities)
├── DTOs/              # Data Transfer Objects (Decouples API payloads from DB schema)
├── Validators/        # FluentValidation rules intercepting invalid inputs
├── Middleware/        # Security headers, Login rate limiting, Centralized error handling
└── Extensions/        # Dependency Injection & Middleware pipeline setup
```

### 🧠 Core Architectural Guarantees:
- **Thin Controllers**: Controllers contain zero business logic or raw SQL/LINQ queries.
- **Database-First Integrity**: `Models/` and `KnomeDbContext.cs` are 100% scaffolded from SQL Server. Schema changes originate strictly in SQL.
- **Unified Response Envelope**: All API endpoints return a standardized `ApiResponse<T>` wrapper (`Success`, `Message`, `Data`, `Errors`).

---

# 🔐 Slide 4: Security, Authentication & Role-Based Access Control (RBAC)

## 🛡️ Enterprise Security & Privacy Controls

```
Client (React)  ──►  POST /api/auth/login  ──►  AuthService
                                                   │
                                     Verify Password (BCrypt) & Check Suspension
                                                   │
Client  ◄──  JWT Bearer Token + Role Claims  ◄─────┘
```

### 👥 Role-Based Access Control (4 Tier Hierarchy):
1. **`Employee`**: Self-service profile, content creation, community engagement, interactions.
2. **`Community Admin`**: Community governance, member join request approvals, post pinning (max 3).
3. **`HR Administrator`**: Job board management, HR analytics, department changes, broadcast announcements.
4. **`System Administrator`**: System configuration, moderation queue resolution, user suspension, audit logs.

### 🔒 Indian DPDP Act 2023 Compliance:
- Employee self-service privacy controls (`BioVisibility`, `PhotosVisibility`).
- PII Scrubbing enricher in Serilog preventing credential leaks in server logs.

---

# 📝 Slide 5: Core Content Engines (Posts, Articles & Media)

## 📰 Content Creation & Channel Capabilities

- **Quick-Share Posts (`FR-PC-01..07`)**: Supports `@mentions` dictionary mapping target users directly into EF Core navigation. Max 400 characters limit.
- **Article Engine (`FR-AB-01..07`)**: Automatic `ArticleVersions` audit snapshots generated whenever article HTML content is modified. Read-time calculation & view count.
- **Media Channels (`FR-VC-01..06`, `FR-PD-01..05`)**: Video channel (`MP4/MOV <= 500 MB`) and Podcast channel (`MP3/WAV <= 100 MB`) with series episode tracking.

---

# 💬 Slide 6: Polymorphic Content Interaction & Moderation

## ⚡ Unified Interaction Engine & Screening

All content types (**Post**, **Article**, **Video**, **Podcast**) delegate interaction metrics to a single polymorphic service (`IContentInteractionService`):

- **💬 Comments**: Multi-level discussion threads on any content item.
- **👍 Reactions**: Like, Love, Insightful, Celebrate metrics.
- **🔖 Bookmarks**: Saved content library for quick reference.
- **🔗 Shares**: External and internal re-sharing tracking.
- **🛡️ Real-Time Screening**: Posts, articles, and media titles are screened in real-time against `BlockedUrls` and `RestrictedKeywords`.

---

# 👥 Slide 7: Communities & Governance

## 🏛️ Public, Private & Departmental Workspaces

- **Flexible Workspace Access**: Employees can explore public technical channels or request access to private project groups.
- **Pinned Posts Safeguard**: Limits pinned community posts to a maximum of 3 to keep top feeds clean.
- **Sole Admin Safeguard**: Prevents the last admin of a community from resigning without designating a successor.

---

# 🏆 Slide 8: Gamification Engine & Karma Points

## 🏅 Employee Recognition & Badging System

Knome incentivizes knowledge sharing through a dynamic **Karma Ledger Engine**:

- **Activity Rules**: Automatic points awarded for writing published articles, receiving reactions, and participating in discussions.
- **Tier Badges**: Bronze, Silver, Gold, Platinum achievement badges rendered on employee profiles.
- **System Admin Award**: System Administrators can manually award recognition points to top contributors (`POST /api/karma/award`).

---

# 🔍 Slide 9: Global Search & Discovery Engine

## 🔎 Unified Enterprise Search Engine

- **Multi-Entity Unified Search**: Single query searches across 7 distinct entity types simultaneously (Users, Posts, Articles, Videos, Podcasts, Communities, Jobs).
- **Dynamic Filters**: Filter results by Date Range, Department, Content Category, or Tag.
- **Search History**: Saves user search history (`FR-SD-05`) with one-click clear options.

---

# 🔔 Slide 10: Internal Jobs, Notifications & Governance

## 💼 Mobility Board & Generic Notification Engine

- **Internal Job Board (`FR-JB-01..05`)**: HR/System Admins post internal openings (`201 Created`). Automatic background service (`JobExpiryHostedService`) handles auto-expiry.
- **Generic Notification Engine (`FR-NT-01..04`)**: Event-driven notification publisher handling bell notifications and broadcast announcements.
- **Audit Trail (`FR-SM-05`)**: Immutable system audit log recording all user suspensions, role changes, and admin governance actions.

---

# 💻 Slide 11: Frontend UI Architecture & Global State

## 🎨 Modern SPA Experience (`knomeUI/frontend`)

- **Aesthetic Excellence**: Vibrant HSL colors, dark mode support, glassmorphism, and smooth micro-animations.
- **Global Podcast Bar**: Podcast playback persists seamlessly across page navigation via `AudioContext`.
- **Axios Interceptor Layer**: Unified HTTP client automatically handles `Bearer` token injection and unwraps `ApiResponse<T>`.

---

# 🏁 Slide 12: Production Verification & Release Roadmap

## 🚀 Quality Assurance & Handover Status

- **Backend API (`v1.2.8`)**: 0 Build Errors, 0 Warnings, 100% DI Verification PASS across all 14 controllers and 12 modules.
- **Frontend Integration (`v1.3.0`)**: 15+ Feature Pages, Axios Interceptors, 14-Day Day-by-Day Handoff Plan.
- **Database**: 100% verified against live Microsoft SQL Server database (`Knome`).
