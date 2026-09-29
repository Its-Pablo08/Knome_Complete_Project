# Knome Enterprise Platform — Complete Backend Architecture & API Specification Document

**Organization**: MPOnline Limited  
**Target Framework**: ASP.NET Core 10.0 (`net10.0`)  
**Architecture Pattern**: Clean N-Tier Monolith Architecture  
**Database Engine**: Microsoft SQL Server (`Knome` Database, EF Core 10)  
**Security & Auth**: JWT Bearer Tokens (HS256) + BCrypt (Work Factor 11)  
**Real-Time Push**: ASP.NET Core SignalR (`/hubs/notifications`)  
**Document Generation Date**: July 31, 2026  

---

## 1. Executive Architectural Overview

The backend system of the **Knome Platform** (`Backend/Knome.API`) is built on **ASP.NET Core 10.0**, engineered to support enterprise-grade knowledge management, social collaboration, content publishing, real-time notifications, and strict admin governance for **MPOnline Limited**.

### Core Architecture Layers:
1. **Presentation Layer (`Controllers/`)**: Thin REST API controllers returning unified `ApiResponse<T>` envelopes.
2. **Business Logic Layer (`Services/`)**: Encapsulated service logic enforcing validation, permissions, and moderation workflows.
3. **Data Access Layer (`Repositories/` & `Data/`)**: Generic Repository Pattern over Entity Framework Core 10 `KnomeDbContext`.
4. **Real-Time Communication Layer (`Hubs/`)**: SignalR hubs for instant push notifications.
5. **Background Workers (`Background/`)**: IHostedService for automated maintenance and job expiry.

---

## 2. Technology Stack & Component Specifications

| Layer / Concern | Technology | Implementation Details |
| :--- | :--- | :--- |
| **Framework** | ASP.NET Core Web API | `net10.0` (.NET 10.0 SDK) |
| **Database & ORM** | SQL Server + EF Core 10 | `Microsoft.EntityFrameworkCore.SqlServer 10.0` |
| **Authentication** | JWT Bearer Tokens | `System.IdentityModel.Tokens.Jwt` (HS256) |
| **Password Security** | BCrypt Hashing | `BCrypt.Net-Next 4.0.3` (Work Factor 11) |
| **Real-Time Push** | SignalR Hubs | `/hubs/notifications` Endpoint |
| **Validation** | FluentValidation | Automatic DTO pipeline validators (`Validators/`) |
| **Object Mapping** | AutoMapper | AutoMapper Profiles (`Mapping/`) |
| **File Storage** | Local Disk Storage | `Services/LocalFileStorageService` under `wwwroot/uploads` |

---

## 3. Application Startup & Pipeline Architecture

The application startup workflow resides in `Program.cs`, `Extensions/ServiceCollectionExtensions.cs`, and `Extensions/ApplicationBuilderExtensions.cs`.

### 3.1 Startup Flow (`Program.cs`):
```csharp
var builder = WebApplication.CreateBuilder(args);

// 1. Register Infrastructure Services (Database, Auth, DI, AutoMapper, FluentValidation)
builder.Services.AddInfrastructure(builder.Configuration);

var app = builder.Build();

// 2. Configure HTTP Middleware Pipeline & Hub Routing
app.UseInfrastructure();

app.Run();
```

### 3.2 Middleware Execution Sequence (`UseInfrastructure`):
1. **`ExceptionHandlingMiddleware`**: Global try/catch handler converting unhandled exceptions to standardized `ApiResponse<T>` errors.
2. **`SecurityHeadersMiddleware`**: Injects CSP, X-Frame-Options, X-Content-Type-Options, HSTS, and Referrer Policy.
3. **`UseCors("AllowFrontend")`**: Enables cross-origin calls from React frontend (`http://localhost:5173`).
4. **`UseAuthentication()` & `UseAuthorization()`**: Validates JWT token signatures and role claims.
5. **`SuspensionGuard`**: Verifies if the authenticated account has been suspended by System Admin.
6. **`MapControllers()` & `MapHub<NotificationHub>("/hubs/notifications")`**: Maps endpoints and SignalR sockets.

---

## 4. Controllers & REST API Endpoints Reference

The API layer consists of **16 Controllers** inheriting from `KnomeControllerBase.cs`.

### 4.1 Authentication & User Management
- `POST /api/Auth/login` — Authenticates credentials with BCrypt, returns JWT token.
- `GET /api/User/me` — Fetches current user profile and permissions.
- `PUT /api/User/profile` — Updates bio, phone, location, avatar, and skills.
- `GET /api/User` — Lists directory users with search and department filtering.
- `PUT /api/User/{id}/role` — Changes user role assignment (Admin only).
- `POST /api/User/{id}/suspend` — Suspends employee account for specified duration.

### 4.2 Content & Media Publishing
- `GET /api/Posts` — Retrieves post feed with attachments and engagement counts.
- `POST /api/Posts` — Creates text/media post with image/video attachments.
- `GET /api/Articles` — Retrieves articles with rich HTML, cover art, and read times.
- `POST /api/Articles` — Publishes long-form article with version tracking.
- `GET /api/Videos` — Aggregates videos (direct uploads, MS Stream/OneDrive embeds).
- `POST /api/Videos` — Uploads video file (Employee uploads trigger Admin Approval Queue).
- `GET /api/Podcasts` — Retrieves podcast episodes, recordings, and series.
- `POST /api/Podcasts` — Uploads audio file or browser recording (Triggers Admin Approval Queue).
- `POST /api/Media/upload` — Stores multipart files to local disk storage.

### 4.3 Communities, Feed & Social Interactions
- `GET /api/Community` — Lists communities with privacy levels and member counts.
- `POST /api/Community` — Creates public/private collaboration hubs.
- `POST /api/Community/{id}/join` — Submits join request or joins public group.
- `POST /api/Interaction/react` — Toggles reactions (Like, Celebrate, Insightful, Support).
- `POST /api/Interaction/comment` — Adds comments or nested replies.
- `GET /api/Feed/hot` — Calculates trending posts via engagement score & time-decay algorithm.
- `GET /api/Karma/balance` — Fetches karma points balance, badge tier, and transaction logs.
- `GET /api/Notifications` — Fetches user notifications with SignalR real-time sync.

---

## 5. Core Business Modules & Logic Architecture

### 5.1 Media Approval & Admin Moderation Workflow
1. **Upload Request**: Employee uploads a Video or Podcast.
2. **Role Evaluation**: If the uploader is an Admin, content is published immediately (`status: 'Approved'`). If non-admin, status is set to `PendingApproval`.
3. **Admin Queueing**: An alert is dispatched to System Admins, and the item is queued in **Media Approvals Queue** in `AdminConsole`.
4. **Admin Review**: Admins review metadata, preview audio/video, and click **Approve & Publish** or **Decline**.
5. **Notification**: Approving media publishes it to public feeds and sends a SignalR alert to the uploader.

### 5.2 Hot Posts Ranking & Time-Decay Engine (`FeedService.cs`)
```csharp
HotScore = (Reactions * 1.0 + Comments * 2.0 + Shares * 3.0 + Bookmarks * 2.5) / Math.Pow(AgeHours + 2, 1.5);
```

### 5.3 Gamification & Karma Points Engine (`KarmaService.cs`)
- **Post Created**: +2 Karma Points (Max 10/day)
- **Article Published**: +10 Karma Points (Max 30/day)
- **Video Uploaded**: +8 Karma Points
- **Comment Added**: +2 Karma Points
- **Reaction Received**: +1 Karma Point
- **Badge Tiers**: Bronze (100+ pts), Silver (500+ pts), Gold (1000+ pts), Platinum (2500+ pts).

---

## 6. Database Schema & Entities

The `KnomeDbContext.cs` manages **38 Entity Models**:
- `User.cs`, `Role.cs`, `Department.cs`, `UserCredential.cs`
- `Post.cs`, `PostAttachment.cs`, `Comment.cs`, `Reaction.cs`, `Share.cs`, `Bookmark.cs`
- `Article.cs`, `ArticleAttachment.cs`, `ArticleVersion.cs`, `Category.cs`
- `Video.cs`, `VideoTag.cs`, `Podcast.cs`, `PodcastSeries.cs`
- `Community.cs`, `CommunityMember.cs`, `CommunityPost.cs`, `ConnectionRequest.cs`, `Follower.cs`
- `KarmaBalance.cs`, `KarmaTransaction.cs`
- `Notification.cs`, `NotificationPreference.cs`
- `AuditLog.cs`, `ModerationReport.cs`, `Job.cs`

---

## 7. Verification & Build Commands

```powershell
# Build Backend Solution (.NET 10.0)
cd Backend/Knome.API
dotnet build -nologo

# Run API Dev Server -> http://localhost:5095/swagger
dotnet run

# Run DI Resolution & Architecture Verification
dotnet run --project "Tools/VerifyDiResolvers/VerifyDiResolvers.csproj"
```
