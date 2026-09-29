# 🏛️ Knome Platform — ASP.NET Core 9 Backend Architecture & API Specification Guide

> **Enterprise Knowledge Management Platform (LinkedIn/Medium/YouTube Hybrid) for MPOnline Limited**  
> **Backend Service Package**: `Backend/Knome.API` (ASP.NET Core 9, C# 13, Entity Framework Core 9, Live SQL Server)

---

## 📌 1. Technology Stack & Architectural Overview

| Technology Layer | Version / Specification | Architectural Purpose & Implementation Detail |
| :--- | :--- | :--- |
| **Core Framework** | ASP.NET Core 9.0 (C# 13) | Enterprise RESTful Web API framework hosting multi-tenant high-performance controllers. |
| **ORM Layer** | Entity Framework Core 9 (Database-First) | Data mapping engine executing LINQ queries against SQL Server via scaffolded DbContext models. |
| **Database** | Microsoft SQL Server (`localhost`, Database `Knome`) | Production relational database storing users, posts, communities, analytics, karma ledgers, and audit trails. |
| **Authentication** | JWT (HS256) + BCrypt (Work Factor 11) | Stateless token-based security, claims-based access control, and salted password hashing. |
| **Request Validation** | FluentValidation | Strongly-typed DTO validation rules executed prior to service layer dispatching. |
| **Object Mapping** | AutoMapper | Automated mapping between SQL Entity Models and API Request/Response DTOs. |
| **API Documentation** | Swagger / OpenAPI 3.0 | Live interactive API documentation and testing interface (`http://localhost:5095/swagger`). |

---

## 📁 2. Backend Project Directory Structure & Purpose

Below is the complete directory structure of `Backend/Knome.API` detailing why each folder exists within the clean architecture layout:

```
Backend/Knome.API/
├── Background/        # Hosted background workers (e.g., JobExpiryHostedService)
├── Constants/         # Centralized application constants (Roles, Claims, Enums)
├── Controllers/       # REST API Controllers (Thin endpoints exposing HTTP routes)
├── Data/              # EF Core DbContext scaffolded from SQL Server DB
├── DTOs/              # Data Transfer Objects (Separates DB entities from API payloads)
├── Exceptions/        # Custom domain exception types (NotFound, Validation, Forbidden)
├── Extensions/        # DI Service & Middleware pipeline registration extensions
├── Helpers/           # Utility helpers (Claims Principal parsing, Date Math)
├── Interfaces/        # Contracts defining Service & Repository signatures
├── Mapping/           # AutoMapper mapping profiles between Models <-> DTOs
├── Middleware/        # Custom HTTP Pipeline Middlewares (Security headers, Error handling)
├── Models/            # Database-First scaffolded C# Entity classes
├── Repositories/      # Data access layer interfacing directly with EF Core
├── Responses/         # Unified JSON response wrapper (ApiResponse<T>)
├── Services/          # Core Business Logic services implementing business rules
└── Validators/        # FluentValidation rules enforcing data integrity
```

### 🧠 In-Depth Rationale for Each Directory:

#### 1. `Controllers/`
- **Purpose**: Accepts HTTP requests from client applications. Controllers are strictly designed to be **thin** — containing zero business or database logic. They validate inputs, delegate execution to the Service Layer, and return HTTP status codes.
- **Attributes Used**: `[ApiController]`, `[Route("api/[controller]")]`, `[Authorize]`.

#### 2. `Services/`
- **Purpose**: Encapsulates all **Business Logic** and domain rules. Responsibilities include calculating Karma Points, processing community join requests, enforcing moderation rules, and computing HR Analytics.

#### 3. `Repositories/`
- **Purpose**: Implements the **Data Access Layer (DAL)**. Direct LINQ queries against `KnomeDbContext` reside here to decouple business services from database technologies.

#### 4. `Models/` & `Data/KnomeDbContext.cs`
- **Purpose**: **Database-First Single Source of Truth**. Entity classes map 1-to-1 to SQL Server tables.
- **CRITICAL CONSTRAINT**: Scaffolded files must **never** be manually modified. Database schema updates originate from SQL Server and are updated via `dotnet ef dbcontext scaffold`.

#### 5. `DTOs/` (Data Transfer Objects)
- **Purpose**: Prevents exposing internal database schemas or sensitive fields (e.g., password hashes). DTOs define clean contracts for incoming API requests and outgoing JSON responses.

#### 6. `Middleware/`
- **Purpose**: Centralized request/response processing in the ASP.NET Core pipeline:
  - `ExceptionHandlingMiddleware`: Catches unhandled exceptions and formats them into standard 400/404/500 JSON responses.
  - `SecurityHeadersMiddleware`: Enforces security headers (`X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy`).

#### 7. `Extensions/`
- **Purpose**: Modularizes `Program.cs` by separating Dependency Injection registrations (`AddInfrastructure`) and HTTP Middleware pipeline configuration (`UseInfrastructure`).

#### 8. `Validators/`
- **Purpose**: Enforces data integrity rules (e.g., required fields, minimum title length, email formats) before controller execution using FluentValidation.

---

## 🔑 3. C# & ASP.NET Core Technical Concepts & Keywords

| Keyword / Concept | Architectural Explanation & Implementation |
| :--- | :--- |
| **`async` / `await`** | Implements non-blocking asynchronous I/O execution. Web server threads are released to handle incoming requests while waiting for SQL database queries. |
| **`Dependency Injection (DI)`** | Inversion of Control (IoC) pattern where service dependencies are automatically injected into class constructors. |
| **`AddScoped`** | Specifies lifetime: A single object instance is created per HTTP request lifecycle and disposed upon completion. |
| **`AddSingleton`** | Specifies lifetime: A single instance is shared across the entire application lifecycle (used for Background Hosted Services). |
| **`[ApiController]`** | Automates model state validation, error responses, and parameter binding sources (`[FromBody]`, `[FromQuery]`). |
| **`[Authorize(Roles = ...)]`** | Enforces JWT token validation and Role-Based Access Control (RBAC). |
| **`DbContext`** | Represents a combination of the Unit of Work and Repository patterns, holding the SQL Server database session. |
| **`AutoMapper`** | Automatically maps properties between distinct object types (e.g., `_mapper.Map<UserProfileDto>(user)`). |
| **`FluentValidation`** | Provides strongly-typed rules for validating input DTOs outside entity models. |

---

## 📡 4. Complete API Endpoint Catalog (16 Controllers)

The table below documents all 16 REST Controllers in `Backend/Knome.API`:

### 1. `AuthController` (`/api/auth`)
- `POST /api/auth/login` — Authenticates user credentials (`EmployeeId` + `Password`) and returns JWT token + user details.
- `POST /api/auth/refresh` — Generates fresh JWT tokens for active sessions.

### 2. `UserController` (`/api/users`)
- `GET /api/users/profile` — Fetches current user's profile details.
- `PUT /api/users/profile` — Updates bio, phone, location, visibility, and skills.
- `GET /api/users` — Paginated user directory search (Admin restricted).
- `PUT /api/users/{id}/roles` — Updates user administrative roles.
- `PUT /api/users/{id}/suspend` — Suspends user account with reason and duration.
- `PUT /api/users/{id}/activate` — Reactivates suspended user account.

### 3. `PostController` (`/api/posts`)
- `GET /api/posts` — Retrieves paginated feed of posts filtered by audience and query.
- `POST /api/posts` — Creates new post with tags, audience scope, and media attachments.
- `DELETE /api/posts/{id}` — Deletes post (Author or Admin).

### 4. `ArticleController` (`/api/articles`)
- `GET /api/articles` — Fetches technical blogs & articles directory.
- `POST /api/articles` — Publishes new structured technical article.
- `DELETE /api/articles/{id}` — Removes article.

### 5. `VideoController` (`/api/videos`)
- `GET /api/videos` — Retrieves video learning library catalog.
- `POST /api/videos` — Uploads/Publishes new video tutorial with category & tags.

### 6. `PodcastController` (`/api/podcasts`)
- `GET /api/podcasts` — Retrieves audio podcasts and series episodes.
- `POST /api/podcasts` — Publishes new podcast episode.

### 7. `CommunityController` (`/api/communities`)
- `GET /api/communities` — Retrieves Public, Private, and Organization Default communities.
- `POST /api/communities` — Creates community with banner, thumbnail, category, rules & FAQ.
- `POST /api/communities/{id}/join` — Joins or sends join request for a community.
- `POST /api/communities/{id}/leave` — Leaves community.
- `GET /api/communities/{id}/members` — Lists community members & assigned roles.
- `PUT /api/communities/{id}/pin/{postId}` — Pins/Unpins post in community feed (Max 3 pinned posts).

### 8. `InteractionController` (`/api/interactions`)
- `POST /api/interactions/{type}/{id}/like` — Toggles like/reaction on Post/Article/Video/Podcast.
- `POST /api/interactions/{type}/{id}/report` — Submits content report with reason code (Spam, Harassment, Copyright, etc.).
- `GET /api/interactions/reports/pending` — Fetches pending content reports (System & HR Admin).
- `PUT /api/interactions/reports/{reportId}/resolve` — Resolves report (Dismiss or Remove Content).

### 9. `AnalyticsController` (`/api/analytics`)
- `GET /api/analytics/engagement` — Computes platform engagement index, DAU/MAU ratios, and content metrics.
- `GET /api/analytics/department` — Computes department-wise participation and karma breakdown.

### 10. `AuditLogController` (`/api/audit/logs`)
- `GET /api/audit/logs` — Retrieves immutable audit log trail for governance & admin actions.

### 11. `KarmaController` (`/api/Karma`)
- `GET /api/Karma/my-balance` — Fetches current user's dynamic Karma balance.
- `GET /api/Karma/leaderboard` — Retrieves global employee Karma leaderboard rankings.

### 12. `JobsController` (`/api/jobs`)
- `GET /api/jobs` — Retrieves Internal Job Postings (IJP).
- `POST /api/jobs` — Posts new job opening (HR Administrator).

### 13. `FeedController` (`/api/feed`)
- `GET /api/feed/dashboard` — Retrieves unified dashboard summary (Hero metrics, announcements, hot posts).
- `GET /api/feed/hot` — Computes trending posts algorithm.

### 14. `SearchController` (`/api/Search`)
- `GET /api/Search/global` — Unified cross-entity search (Users, Posts, Articles, Videos, Communities).

### 15. `NotificationsController` (`/api/notifications`)
- `GET /api/notifications` — Retrieves real-time user notification feed.
- `PUT /api/notifications/read-all` — Marks notifications as read.

### 16. `MediaController` (`/api/media`)
- `POST /api/media/upload` — Disk storage file upload handler for images & documents.

---

## ❓ 5. Technical Questions & Architectural Deep-Dive

### Q1: Why is a Database-First approach used, and what are its scaffolding rules?
**Answer**: MPOnline's SQL Server database pre-existed with established tables and relationships. Therefore, the **Database-First** approach was adopted following this hierarchy:
`Functional Requirements Document (FRD) -> DB Schema -> Codebase`.
**Rule**: Scaffolded files inside `Models/` and `Data/KnomeDbContext.cs` must **never** be edited manually. Schema modifications originate in SQL Server and are re-scaffolded using `dotnet ef dbcontext scaffold`.

### Q2: Why is business logic separated from Controllers into Services?
**Answer**: This follows the **Separation of Concerns (SoC)** and **Clean Architecture** principles.
- **Controllers**: Handle HTTP routing, parameter binding, authentication attributes, and status code returns.
- **Services**: Execute domain business logic, authorization validation, and calculations. This structure maximizes code reusability and testability.

### Q3: What is the benefit of the `ApiResponse<T>` response envelope?
**Answer**: It enforces a unified output shape across all endpoints:
```json
{
  "statusCode": 200,
  "message": "Operation completed successfully.",
  "data": { ... },
  "errors": null
}
```
This structure ensures consistent client-side response parsing across all frontend modules.

### Q4: How is security and authentication configured?
**Answer**:
- **Passwords**: Hashed via BCrypt (Work Factor 11).
- **Authentication**: Stateless JWT Bearer tokens with HS256 encryption. Claims store User ID, Employee ID, and Roles (`Employee`, `Community Admin`, `HR Administrator`, `System Administrator`).
- **Middleware**: `SecurityHeadersMiddleware` applies strict security headers (`X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy`).

### Q5: How does the Moderation & Reporting system operate?
**Answer**:
When users report any content item:
1. `POST /api/interactions/{type}/{id}/report` is invoked with a Reason Code (`Spam`, `Harassment`, `Copyright`, etc.).
2. A record is inserted into the `ContentReports` database table.
3. System Admins and HR Admins review pending items via the Admin Console (`/admin-console`) using `GET /api/interactions/reports/pending` and execute **Dismiss** or **Remove Content** actions.

---

### 📄 Summary
This specification document outlines the complete architectural design, directory structure rationale, C# keyword usages, 16 REST controller endpoint catalogs, and technical Q&As for the Knome ASP.NET Core 9 API.
