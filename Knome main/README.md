# Knome — Enterprise Knowledge Management Platform

[![Backend Status: Frozen v1.2.8](https://img.shields.io/badge/Backend%20Status-Frozen%20v1.2.8-00C853.svg)](#10-current-project-status)
[![ASP.NET Core 10](https://img.shields.io/badge/ASP.NET%20Core-10.0-512BD4.svg)](#2-technology-stack)
[![Architecture: Database--First](https://img.shields.io/badge/Architecture-Database--First%20EF%20Core-0078D4.svg)](#3-architecture-overview)
[![DI Verification: 100% PASS](https://img.shields.io/badge/DI%20Resolution-100%25%20PASS-2E7D32.svg)](#8-build--run-instructions)

**Knome** is an enterprise-grade, internal Knowledge Management & Employee Engagement Portal developed for **MPOnline Limited**. The platform combines professional networking, rich-text technical blogging, multi-media content sharing, peer recognition (gamification), and enterprise collaboration into a unified, secure internal portal inspired by LinkedIn, Medium, and YouTube.

This repository hosts the **production-ready backend API solution (`Backend/Knome.API`)** built on **ASP.NET Core 10 Web API** using a strict **Database-First Entity Framework Core** architecture, the **Repository and Service Pattern**, clean dependency injection, and comprehensive security hardening.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Technology Stack](#2-technology-stack)
3. [Architecture Overview](#3-architecture-overview)
4. [Repository & Backend Folder Structure](#4-repository--backend-folder-structure)
5. [Features / Modules Implemented](#5-features--modules-implemented)
6. [High-Level API Overview](#6-high-level-api-overview)
7. [Security Features](#7-security-features)
8. [Build & Run Instructions](#8-build--run-instructions)
9. [Development Workflow & Repository Guidelines](#9-development-workflow--repository-guidelines)
10. [Current Project Status](#10-current-project-status)
11. [Future Scope](#11-future-scope)
12. [Documentation Guide](#12-documentation-guide)
13. [Documentation Roadmap](#13-documentation-roadmap)
14. [Credits](#14-credits)

---

## 1. Project Overview

Enterprise knowledge silos occur when organizational insights, technical documentation, and peer recognition remain scattered across isolated chat channels and local storage. **Knome** bridges this gap by providing MPOnline Limited employees with a centralized, role-governed internal platform:

- **Unified Discovery**: A single dashboard feed ranking critical enterprise posts, technical articles, training videos, and podcast episodes via custom engagement algorithms (`Hot Posts Ranking Engine`).
- **Structured Governance**: Hierarchical role-based access control enforcing strict separation of concerns across general employees, community administrators, HR administrators, and system governance officers.
- **Audited Operations**: Complete transparency for administrative actions (user suspensions, role modifications, broadcast notifications) via an immutable system audit log (`DPDP Act 2023 compliant`).
- **Gamified Knowledge Sharing**: A peer recognition engine (`Karma Points`) rewarding employees for publishing valuable documentation and fostering active community discussions.

---

## 2. Technology Stack

### Core Backend & Runtime

- **Runtime & Framework**: `.NET 10 SDK` (`ASP.NET Core 10 Web API`)
- **Language**: `C# 13` (`Nullable reference types enabled`, `File-scoped namespaces`)
- **Database Engine**: `Microsoft SQL Server 2022+` (`Database-First EF Core scaffolding`)
- **ORM**: `Microsoft.EntityFrameworkCore 9.0` (`Microsoft.Data.SqlClient`)

### Application Components & Libraries

- **Dependency Injection**: Native `Microsoft.Extensions.DependencyInjection`
- **Data Transfer Mapping**: `AutoMapper 13.0+` (`Assembly scanning across 10 distinct module profiles`)
- **Payload Validation**: `FluentValidation.AspNetCore 11.0+` (`Global automatic DTO interception via ValidationFilter`)
- **Authentication & Security**: `Microsoft.AspNetCore.Authentication.JwtBearer` (`HS256`, environment secret `KNOME_JWT_SECRET`), `BCrypt.Net-Next` (`Work factor 11`), `System.Threading.RateLimiting`
- **Logging & Diagnostics**: `Serilog.AspNetCore 8.0+` (`Console & Rolling File sinks`, `Custom PiiScrubbingEnricher`)
- **API Documentation**: `Swashbuckle.AspNetCore 7.0+` (`OpenAPI/Swagger UI with JWT Authorization support`)

---

## 3. Architecture Overview

Knome follows a pragmatic **Clean Layered Architecture** built around the **Repository + Service Pattern** to ensure separation of concerns, testability, and enterprise maintainability:

```text
+-----------------------------------------------------------------------------------+
|                                 API Controllers                                   |
|   Inherit KnomeControllerBase | Attribute Routing | Return ApiResponse<T> Envelope|
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                            Middleware & Filter Pipeline                           |
|   ExceptionHandling -> SecurityHeaders -> Swagger -> HTTPS -> CORS -> RateLimiting|
|                   -> Authentication -> Authorization -> ValidationFilter          |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                                  Service Layer                                    |
|   Contains 100% of Business Logic | Enforces FRD Rules | DTO <-> Entity Mapping  |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                                Repository Layer                                   |
|   Generic IRepository<T> & Specialized Repositories | Pure Database Access Only   |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                      Entity Framework Core (Database-First)                       |
|   Scaffolded DbContext & Models | Strictly Read-Only (Originates from SQL Server)|
+-----------------------------------------------------------------------------------+
```

### Architectural Principles

1. **Database-First Scaffolding (`EF Core`)**: The MS SQL Server database (`Knome`) is the definitive source of truth for the data structure. `Models/` and `Data/KnomeDbContext.cs` are strictly generated via `dotnet ef dbcontext scaffold`. Manual modifications to scaffolded files are prohibited (`Re-scaffold when DB schema changes`).
2. **Repository Layer (`Repositories/` & `Interfaces/`)**: Repositories (`IRepository<T>`, `IUserRepository`, `IPostRepository`, etc.) encapsulate raw Entity Framework queries, `AsNoTracking()` optimizations, and `Include()` eager loading. Controllers and Services never write raw `LINQ-to-Entities` queries directly.
3. **Service Layer (`Services/` & `Interfaces/`)**: All domain rules (`FRD constraints`, authorization checks, ranking calculations, ownership verification, and notifications) live strictly inside the 16 domain services (`UserService`, `PostService`, `NotificationService`, etc.).
4. **Thin Controllers (`Controllers/`)**: All 14 API Controllers inherit from `KnomeControllerBase`. Controllers handle HTTP routing, delegate directly to the Service layer, and wrap return data inside the standardized `ApiResponse<T>` wrapper (`{ success, message, data }`).
5. **Cross-Cutting Pipeline**:
   - **Validation**: `ValidationFilter` catches invalid DTO requests before controller execution using 28 modular `FluentValidation` classes (`Validators/`).
   - **Mapping**: `AutoMapper` converts domain entities to clean, decoupled DTO objects (`DTOs/`, `Mapping/`).
   - **Exception Handling**: `ExceptionHandlingMiddleware` catches unhandled exceptions (`NotFoundException`, `ForbiddenException`, `ValidationException`) and converts them to uniform HTTP responses (`404`, `403`, `400`, `500`) with zero stack-trace leakage.

---

## 4. Repository & Backend Folder Structure

### Top-Level Repository Structure (`KnomeBackend`)

```text
KnomeBackend/
├── README.md               # Complete repository onboarding guide and system architecture manual
├── AGENTS.md               # Primary operational handbook defining mandatory engineering rules
├── CLAUDE.md               # Core coding standards, Database-First rules, and verification checklists
├── .gitignore              # Git ignore configuration
├── Backend/
│   └── Knome.API/          # ASP.NET Core 9 Web API production backend project
├── Documentation/          # Synchronized enterprise documentation suite
│   ├── FRD/                # Functional Requirements Documents (PDF & Text format)
│   ├── Architecture/       # Architecture design blueprints, API specifications, and baseline findings
│   ├── Audits/             # Audit reports, defect resolution notes, and acceptance verifications
│   ├── Project/            # Project context, status tracking, workflows, and task boards
│   └── Development Journal/# Chronological phase-by-phase execution logs (Phases 1-19)
└── Tools/                  # Local developer utilities and verification console applications (Not for production)
```

### Production Backend Project (`Backend/Knome.API`)

```text
Backend/Knome.API/
├── Background/             # Hosted background services (JobExpiryHostedService for auto-expiring jobs)
├── Configuration/          # Strongly typed configuration models mapped from appsettings.json
├── Constants/              # Core immutable constants (Roles, NotificationTypes, ErrorMessages)
├── Controllers/            # 14 Thin API Controllers inheriting from KnomeControllerBase
├── Data/                   # Scaffolded KnomeDbContext (DO NOT MODIFY MANUALLY)
├── DTOs/                   # Data Transfer Objects organized by domain module (Auth, Users, Posts, etc.)
├── Exceptions/             # Custom domain exceptions (NotFoundException, ForbiddenException, BusinessRuleException)
├── Extensions/             # DI and Middleware extension wiring (ServiceCollectionExtensions, ApplicationBuilderExtensions)
├── Filters/                # ASP.NET Core Action filters (Global ValidationFilter for DTO validation)
├── Helpers/                # Shared utility classes (ISuspensionGuard, File signature helpers)
├── Interfaces/             # Contracts for all domain Services and Repositories (IRepository<T>, IUserService, etc.)
├── Logging/                # Serilog custom enrichers (PiiScrubbingEnricher redacting passwords/tokens/SSNs)
├── Mapping/                # 10 AutoMapper profiles scanning assembly for Entity <-> DTO conversions
├── Middleware/             # Global HTTP middleware (ExceptionHandlingMiddleware, SecurityHeadersMiddleware)
├── Models/                 # 20+ EF Core scaffolded database entities (DO NOT MODIFY MANUALLY)
├── Repositories/           # Concrete Repository implementations (Repository<T>, UserRepository, PostRepository, etc.)
├── Responses/              # Standardized API response wrappers (ApiResponse<T>, PagedResponse<T>)
├── Services/               # 16 Domain Service implementations housing 100% of business & FRD logic
├── Validators/             # 28 FluentValidation rules enforcing DTO boundaries and MaximumLength limits
├── wwwroot/                # Local file storage root for uploaded profile photos, attachments, and media
├── Program.cs              # Application entrypoint calling AddInfrastructure() and UseInfrastructure()
├── appsettings.json        # Production configuration (Connection strings, Serilog sinks, AllowedHosts)
└── Knome.API.csproj        # Project definitions and package dependencies
```

---

## 5. Features / Modules Implemented

The backend fully implements **100% of the 12 Functional Requirements Document (FRD)** modules across 14 API batches:

| Module / Area | FRD Reference | Core Features & Implementation Highlights |
| :--- | :--- | :--- |
| **1. Core Infrastructure** | `NFR-ARC-01` | Generic `IRepository<T>`, `ApiResponse<T>` envelope, and global exception normalization. |
| **2. Authentication Engine** | `FR-DB-08`, `NFR-SEC` | Stateless JWT Bearer (`HS256`) auth, BCrypt password hashing (`work factor 11`), login rate limiting (`5 req/min`), and 4-tier RBAC (`Employee`, `Community Admin`, `HR Administrator`, `System Administrator`). |
| **3. User Profile & Management** | `FR-UP-01..06` | Employee self-service (`Bio`, `Skills`, `Interests`, `Photo upload` with magic byte checking), Indian DPDP Act 2023 visibility masking (`BioVisibility`), and HR Admin lifecycle governance (`Suspend/Activate`, department/role transfers). |
| **4. Content Interactions** | `FR-CI-01..05` | 4 distinct interaction models (`Comments`, `Reactions`, `Shares`, `Bookmarks`), real-time URL/keyword screening (`BlockedUrls`), and `ModerationReports` workflows. |
| **5. Communities & Membership** | `FR-CM-01..09` | Public, Private, and Default communities, join request approval workflows, member governance, sole admin safeguards, and 3-pinned post limits (`FR-CM-06`). |
| **6. Post & Article Engines** | `FR-PC-01..07`, `FR-AB` | Quick-share posts (`<= 400 chars`, multi-media, `@mentions` dictionary), deep-dive rich text blogging (`Articles`, `ArticleTags`), automatic version snapshots (`ArticleVersions`), and read time calculation. |
| **7. Media Channels** | `FR-VC`, `FR-PD` | Video Channel (`MP4/MOV <= 500MB` / OneDrive embeds, `VideoTags`) and Podcast Channel (`MP3/WAV <= 100MB`, `PodcastSeries` definitions with episode tracking). |
| **8. Dashboard Feed & Ranking** | `FR-DB-01..08`, `FR-HP` | Personalized user feeds integrating the **Hot Posts Ranking Engine** (`Score = (Reactions + Comments*2 + Shares*3) / TimeDecay`), plus peer **Karma Points** gamification badges (`Bronze` to `Platinum`). |
| **9. Global Search & Discovery** | `FR-SD-01..05` | Unified search across Users, Communities, Posts, Articles, Videos, Podcasts, and Jobs with dynamic filtering (`category/department`), author/tag lookup, relevance sorting, and user search history. |
| **10. Audit Trail & Governance** | `FR-SM-04..05` | System-wide immutable `AuditLog` tracking user suspensions, role changes, and broadcasts, gated strictly to `System Administrators`, wired with `ISuspensionGuard`. |
| **11. Jobs Board & Notifications** | `FR-JB`, `FR-NT-01..04` | Internal Job Board (`HR/System Admin CRUD`, dynamic skill/department filtering, `JobExpiryHostedService` auto-cleanup) + **Generic Event-Driven Notification Engine** (`INotificationService.Publish/PublishBroadcast`). |
| **12. Producer Wiring & Hardening** | `FR-NT-01` | Full notification producer triggers wired across all interactions, HR Admin broadcast API (`POST /api/notifications/broadcast`), comprehensive DTO validation, and 100% DI validation. |

---

## 6. High-Level API Overview

All endpoints operate under the `/api` prefix and return standard `ApiResponse<T>` JSON envelopes (`{ "success": true/false, "message": "...", "data": ... }`).

| Controller | Route Prefix | Primary Operations & Capabilities | Role Access |
| :--- | :--- | :--- | :--- |
| **`AuthController`** | `/api/auth` | `POST /login` (Rate limited), `POST /register`, `GET /me` | Anonymous / Authenticated |
| **`UserController`** | `/api/users` | `GET /profile/{id}`, `PUT /profile`, `POST /profile-image`, `PUT /suspend`, `PUT /roles` | Employee / HR Admin / System Admin |
| **`PostController`** | `/api/posts` | `GET /`, `POST /`, `GET /{id}`, `PUT /{id}`, `DELETE /{id}`, `GET /my` | Employee / Community Admin |
| **`ArticleController`** | `/api/articles` | `GET /`, `POST /`, `GET /{id}`, `PUT /{id}`, `DELETE /{id}`, `GET /{id}/versions` | Employee / Community Admin |
| **`VideoController`** | `/api/videos` | `GET /`, `POST /`, `GET /{id}`, `DELETE /{id}`, `GET /my` | Employee / Community Admin |
| **`PodcastController`** | `/api/podcasts` | `GET /series`, `POST /series`, `GET /episodes`, `POST /episodes`, `DELETE /episodes/{id}` | Employee / Community Admin |
| **`CommunityController`** | `/api/communities` | `GET /`, `POST /`, `GET /{id}`, `POST /{id}/join`, `PUT /{id}/approve`, `POST /{id}/pin` | Employee / Community Admin |
| **`InteractionController`** | `/api/interactions` | `POST /comments`, `POST /reactions`, `POST /shares`, `POST /bookmarks`, `POST /report` | Authenticated Employees |
| **`FeedController`** | `/api/feed` | `GET /dashboard` (Personalized feed), `GET /hot` (Ranked by Hot Posts algorithm) | Authenticated Employees |
| **`KarmaController`** | `/api/karma` | `GET /my` (Points & Badges), `GET /leaderboard`, `POST /award` | Employee / System Admin |
| **`SearchController`** | `/api/search` | `GET /` (Unified multi-entity search), `GET /history`, `DELETE /history` | Authenticated Employees |
| **`AuditLogController`** | `/api/audit/logs` | `GET /` (Filtered system logs by date range, action, actor, target) | **System Admin Only** |
| **`JobsController`** | `/api/jobs` | `GET /` (Filtered active postings), `GET /{id}`, `POST /` (`201 Created`), `PUT /{id}`, `DELETE /{id}` | Employee / HR Admin |
| **`NotificationsController`** | `/api/notifications` | `GET /` (User alerts), `PUT /mark-read`, `GET /preferences`, `PUT /preferences`, `POST /broadcast` | Employee / HR Admin |

---

## 7. Security Features

Knome implements comprehensive defense-in-depth security hardening verified during pre-deployment audits:

1. **Authentication & Token Governance (`HS256`)**:
   - Uses `JwtBearer` authentication. The secret signing key is dynamically loaded from configuration or environment variable `KNOME_JWT_SECRET` (`throw new InvalidOperationException` if missing or under 32 characters).
   - Passwords are securely hashed with `BCrypt.Net-Next` at work factor `11`.
2. **Brute-Force Protection (`Rate Limiting`)**:
   - Decorated `AuthController.Login` with `[EnableRateLimiting("LoginRateLimiter")]`. Enforces a strict `FixedWindowRateLimiter` allowing maximum **5 requests per minute per client IP**.
3. **MIME / Magic Byte Header Verification**:
   - To prevent file extension spoofing (`.exe` renamed to `.jpg`), `LocalFileStorageService.ValidateMagicBytesAsync` inspects the leading bytes of uploaded files (`FF D8 FF` for `.jpg`, `89 50 4E 47...` for `.png`, `47 49 46 38` for `.gif`, `RIFF...WEBP` for `.webp`).
4. **Security Headers Middleware (`SecurityHeadersMiddleware`)**:
   - Positioned immediately after exception handling in `UseInfrastructure()`, enforcing:
     - `Strict-Transport-Security` (`HSTS`, `max-age=31536000; includeSubDomains`)
     - `Content-Security-Policy` (`default-src 'self'; img-src 'self' data: https:; ...`)
     - `X-Frame-Options: DENY` (Clickjacking prevention)
     - `X-Content-Type-Options: nosniff` (MIME sniffing prevention)
     - `Referrer-Policy: strict-origin-when-cross-origin` & `Permissions-Policy: geolocation=(), microphone=()`
5. **Kestrel Host Filtering (`AllowedHosts`)**:
   - `appsettings.json` enforces strict `"AllowedHosts": "localhost;127.0.0.1;knome-api.internal"`.
6. **PII Logging Redaction (`PiiScrubbingEnricher`)**:
   - Registered in Serilog (`Program.cs`), automatically sanitizing sensitive dictionary keys (`password`, `token`, `secret`, `ssn`, `cookie`) across all log events before writing to console or file sinks.
7. **Strict FK & Payload Validation (`GBV-001` & `ValidationFilter`)**:
   - All mutating DTOs pass through `FluentValidation` checking boundary strings and database constraints before processing.

---

## 8. Build & Run Instructions

### Prerequisites

- [Windows OS / Linux / macOS]
- **.NET 10 SDK** (`net10.0`)
- **Microsoft SQL Server 2022+** (`localhost`, database named `Knome`)

### 1. Database Setup

Ensure SQL Server is running and the `Knome` database schema is provisioned. To populate test users (`EMP001` to `EMP004`) with default password `Password@123`, run the seed script:

```powershell
sqlcmd -S localhost -d Knome -i "Documentation/Architecture/Seed_Test_Credentials.sql"
```

### 2. Optimized Build Workflow

To avoid unnecessary MSBuild restore overhead and achieve lightning-fast builds (`~1-2 seconds`):

```powershell
cd "Backend/Knome.API"
dotnet build --no-restore
```

### 3. Run the API Server

Command:

```powershell
dotnet run --no-build
```

- **API Base URL**: `http://localhost:5095/api`
- **Interactive Swagger UI**: `http://localhost:5095/swagger`

### 4. Verification & DI Health Check (`VerifyDiResolvers`)

The project utilizes specialized console scratch projects to verify runtime DI resolution and database health **without writing unit tests that drift from production schema**:

```powershell
# Run the complete DI resolution audit across all 14 Controllers and 12 Modules (< 3 seconds)
dotnet run --project ..\..\Tools\VerifyDiResolvers\VerifyDiResolvers.csproj --no-build
```

Expected Output:

```text
=== Verifying Runtime DI Resolution across ALL 14 Controllers and 12 Modules ===
Services & Repositories resolved successfully.
All 14 API Controllers constructed cleanly with full DI dependencies.
100% DI Verification PASS.
```

---

## 9. Development Workflow & Repository Guidelines

When contributing to this enterprise monorepo, developers must strictly abide by the rules defined in `AGENTS.md` and `CLAUDE.md`:

1. **Never Modify Scaffolded Database Models (`Models/` & `Data/`)**:
   - Knome is strictly **Database-First**. Never manually add properties, navigation keys, or configurations to files inside `Models/` or `Data/KnomeDbContext.cs`.
   - If a database schema change occurs, execute EF Core re-scaffolding via SQL Server tools (`dotnet ef dbcontext scaffold ...`).
2. **Layer Isolation**:
   - **Controllers stay thin**: Do not write queries, loops, or `LINQ` sorting inside controllers. Delegate directly to the `IService` methods.
   - **Repositories handle data**: Business logic does not belong in repositories. Repositories perform CRUD, tracking management (`AsNoTracking()`), and eager loading (`Include()`).
   - **Services handle rules**: Put 100% of business logic (`FRD` checks, role validations, notifications) inside domain services (`Services/`).
3. **No Dummy Placeholders**:
   - External integrations (`HRMS SSO`, `Corporate SMTP email digests`, `HRMS sync endpoints`) are intentionally **deferred**. Never invent dummy mocks, simulated timers, or fake external HTTP calls.
4. **Mandatory Verification Before Pull Requests**:
   - Run `dotnet build --no-restore` (`Must return 0 warnings, 0 errors`).
   - Run `VerifyDiResolvers --no-build` (`Must return 100% PASS`).
   - Verify modified endpoints via Swagger or Postman against the live SQL Server instance.

---

## 10. Current Project Status

- **Version**: `v1.2.8` (**Phase E Release Activities Completed — Backend Frozen for Frontend Handoff**)
- **Functional Readiness**: ✅ **100% Complete** (`12 / 12 FRD modules implemented across 14 Controllers, 16 Services, and 13 Repositories`).
- **Production Hardening**: ✅ **100% Complete** (`Defect Resolution Pass + Production Hardening Passes 1–6 + Phases A, B, C, and D Security Hardening verified`).
- **Documentation Status**: ✅ **Synchronized** (`Phase E` complete; `Backend_Verification_Findings.md` and `Production_Readiness_Audit_Part1.md` exactly mirror the hardened baseline).
- **Frontend Handoff Readiness**: 🟢 **READY & FROZEN**. API contracts (`ApiResponse<T>`) are locked, CORS/Rate Limiting is active, and DI resolution passes 100%. Ready for React (`knome-web`) integration.

---

## 11. Future Scope

The following items are genuine architectural integrations intentionally deferred per `PROJECT_CONTEXT.md` until corporate infrastructure provisioning is finalized:

1. **HRMS Single Sign-On (`/api/auth/sso-login`)**: Endpoint routing exists; integration pending provisioning of MPOnline Limited's external identity provider (`IDP/SAML/OAuth`).
2. **Email Digest Engine (`FR-NT-02`)**: Notification batching logic is structured; external SMTP dispatch is deferred pending corporate SMTP relay setup.
3. **HRMS Sync Workflows (`FR-SM-04`)**: Internal employee status models ready; live synchronization pending external HRMS webhooks.
4. **Refresh Token Infrastructure (`F-025`)**: Initial rollout utilizes stateless JWT (`HS256`, 8-hour expiry). Implementation of `POST /api/auth/refresh` is deferred post-launch pending an architectural decision on multi-device token storage (`Redis` vs SQL token table blocklist).

---

## 12. Documentation Guide

The repository maintains an authoritative, synchronized documentation suite. Every developer must understand the purpose of each file:

| Document | Purpose & Core Knowledge Contained | When to Read |
| :--- | :--- | :--- |
| **`AGENTS.md`** | **Primary operational handbook**. Defines critical constraints (`Never edit Models/`), command syntax, role matrix, and verification commands (`VerifyDiResolvers`). | **Mandatory First Read** at the start of any work or debugging session. |
| **`CLAUDE.md`** | **Core coding standards**. Outlines the Database-First rules, SOLID guidelines, and required pre-implementation / post-implementation verification checklist. | **Read immediately after `AGENTS.md`** before touching source code. |
| **`Documentation/Project/PROJECT_CONTEXT.md`** | **High-level technical baseline**. Tracks current version (`v1.2.8`), current phase (`Phase E — Frozen`), completed vs pending modules, and architectural decisions. | Read before starting a new feature or phase to understand current architecture state. |
| **`Documentation/Project/PROJECT_STATUS.md`** | **Authoritative task-by-task roadmap**. Detailed milestone tracker detailing exact features delivered across Phases 1–12, Defect passes, Hardening passes, and Phases A–E. | Read when assessing project maturity, checking historical milestones, or verifying test credentials. |
| **`Documentation/FRD/` (`Knome...FRD-V0.1.pdf/.txt`)** | **Functional Requirements Document**. Source of truth for business rules (`FR-UP`, `FR-PC`, `FR-CM`, `FR-HP`, `FR-SD`, `FR-NT`). | Read whenever business logic, ranking formulas, or module requirements need clarification. |
| **`Documentation/Development Journal/`** | **Chronological execution logs**. Numbered markdown records (`01_...md` to `19_Phase_E_Release_And_Backend_Freeze.md`) explaining file changes, design rationales, and exact commands run per phase. | Read the **latest journal entry (`19_Phase_E...md`)** to understand exact recent changes and frontend handoff contracts. |
| **`Documentation/Architecture/Production_Readiness_Consolidated_Findings.md`** | **Master pre-deployment audit inventory**. Tracks all 32 consolidated findings (`F-001..F-032`) across API consistency, security, DTO boundaries, and documentation. (`31 Resolved, 1 Deferred`). | Read when tracking bug fixes, verifying security hardening items, or reviewing audit evidence. |
| **`Documentation/Architecture/Backend_Verification_Findings.md`** | **Historical functional verification baseline**. Records the initial 14-batch functional testing results and confirmed exact resolution of `GBV-001` and `M-001/002`. | Read to review historical functional test coverage across the 140+ endpoints. |
| **`Documentation/Architecture/Backend_Hardening_Implementation_Plan.md`** | **Technical blueprint for hardening passes**. Details the exact architectural steps used to remediate FK checks (`GBV-001`) and implement `ValidationFilter`. | Read when investigating how the validation interceptor or FK existence validation operates. |
| **`Documentation/Audits/VerifyDiResolvers_Optimization_Report.md`** | **Build optimization analysis**. Explains how the verification scratch tool was optimized to run under `< 3 seconds` (`--no-build`) while avoiding MSBuild re-compilation. | Read if modifying `VerifyDiResolvers` or investigating console startup performance. |
| **`Documentation/Architecture/API_Testing_Guide.md`** | **Postman & Swagger testing manual**. Provides step-by-step instructions and request/response payloads for manual API validation. | Read when testing endpoints manually or building integration tests. |
| **`Documentation/Audits/Code_Defect_Resolution_Report.md`** | **Defect resolution technical notes**. Documents the exact fixes applied for local HTTPS redirection, login suspension checks, and `ForbiddenException` mapping. | Read when auditing historical bug remediations. |
| **`Documentation/Audits/RTM_Audit_Report.md`** | **Requirements Traceability Matrix**. Maps every single FRD requirement (`FR-UP-01`, etc.) to its concrete Controller, Service, and Repository implementation. | Read when conducting compliance audits or verifying full FRD coverage. |
| **`Documentation/Architecture/Seed_Test_Credentials.sql`** | **SQL test data seed script**. Creates test accounts (`EMP001`–`EMP004`) with password `Password@123` and appropriate role assignments. | Run when setting up a fresh local database instance. |

---

## 13. Documentation Roadmap

To quickly onboard without getting overwhelmed, new developers, mentors, and code reviewers must follow this exact reading sequence:

```text
[1. README.md] (You are here — Start Here)
       │
       v
[2. AGENTS.md] & [CLAUDE.md] (Understand mandatory constraints & build workflow)
       │
       v
[3. Documentation/Project/PROJECT_CONTEXT.md] (Understand v1.2.8 baseline & frozen backend state)
       │
       v
[4. Documentation/Project/PROJECT_STATUS.md] (Review Phase 1-12 milestones & Phase A-E hardening history)
       │
       v
[5. Documentation/Development Journal/19_Phase_E_Release_And_Backend_Freeze.md] (Read final handoff contracts)
       │
       v
[6. Documentation/FRD v0.1] & [Documentation/Architecture/Production_Readiness_Consolidated_Findings.md] (Deep-dive domain & audit queries)
```

---

## 14. Credits

**Project**: Knome — Enterprise Knowledge Management Platform (`v1.2.8`)  
**Organization**: **MPOnline Limited** (`Enterprise Internship Project`)  
**Architecture & Development**: Developed as an enterprise-grade internal collaboration portal following modern `.NET 9` best practices, strict clean architecture, and thorough production hardening.  
**Copyright**: © 2026 MPOnline Limited. All rights reserved.
