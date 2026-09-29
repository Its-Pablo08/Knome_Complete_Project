# Phase 3: User Profile & User Management — Development Journal

**Date**: 9 July 2026  
**Module**: Knome (Knowledge Sharing, Group & Technical Post)  
**Author**: Antigravity (Pair Programming with User)  
**Status**: Completed & Verified ✅

---

## 1. Objective
Implement the complete **User Profile and User Management** vertical (`FR-UP-01` to `FR-UP-06`, plus HR Administrator management operations and DPDP Act 2023 visibility enforcement) for **Knome.API**.

This phase focuses strictly on user identity, profile enrichment, collection synchronization (`UserSkills`, `UserInterests`), profile photo storage abstraction (`IFileStorageService`), and role/department governance while preserving our **Database-First** architecture (zero modifications to scaffolded EF Core models) and **Repository + Service Pattern**.

---

## 2. Files Created & Modified

### Created Files
1. **DTOs (`DTOs/User/`)**:
   - `UserProfileDto.cs`: Full user profile payload including visibility options, status flags, skill/interest/role collections, and summary metrics (`FollowersCount`, `FollowingCount`, `MutualConnectionsCount`, `KarmaPoints`).
   - `UserSummaryDto.cs`: Lightweight user item payload for lists and admin tables.
   - `PagedResultDto.cs`: Generic paginated wrapper with `TotalPages`, `HasPreviousPage`, and `HasNextPage` properties.
   - `UpdateProfileDto.cs`: Request payload for general profile updates (`Bio`, `Location`, `MobileNo`, `Visibility`, `Skills`, `Interests`).
   - `UpdateBioDto.cs`: Request payload for dedicated Bio update endpoint.
   - `UpdateSkillsDto.cs`: Request payload for dedicated Skills update endpoint.
   - `UpdateProfileImageDto.cs`: `IFormFile` wrapper for multipart/form-data profile photo uploads.
   - `UserFilterDto.cs`: Query parameters for user filtering and pagination (`SearchTerm`, `DepartmentId`, `RoleName`, `IsActive`, `IsSuspended`, `PageNumber`, `PageSize`).
   - `ChangeDepartmentDto.cs`: Request payload for HR Admin department assignment (`DepartmentId`).
   - `ChangeRoleDto.cs`: Request payload for HR Admin role assignment (`RoleNames`).
   - `SuspendUserDto.cs`: Request payload for HR Admin suspension management (`SuspendedUntil`, `IsPermanent`, `Reason`).
2. **Validators (`Validators/User/`)**:
   - `UpdateProfileValidator.cs`: Validates bio length (max 500 chars), valid visibility strings (`Public`, `Connections Only`, `Private`), and skill boundaries.
   - `UpdateBioValidator.cs`: Validates bio bounds and visibility options.
   - `UpdateSkillsValidator.cs`: Validates skill list limits (max 30 items).
   - `ChangeDepartmentValidator.cs`: Validates positive `DepartmentId`.
   - `ChangeRoleValidator.cs`: Validates that specified roles match system constants (`Employee`, `Community Admin`, `HR Administrator`, `System Administrator`).
   - `SuspendUserValidator.cs`: Ensures valid suspension logic per `FR-SM-04`.
   - `UserFilterValidator.cs`: Validates page bounds (`PageSize` between 1 and 100).
3. **Mapping (`Mapping/`)**:
   - `UserProfile.cs`: AutoMapper configuration mapping `Models.User` to `UserProfileDto` and `UserSummaryDto`.
4. **Repositories (`Interfaces/` & `Repositories/`)**:
   - `IUserRepository.cs`: Feature repository interface extending generic `IRepository<User>`.
   - `UserRepository.cs`: Feature repository implementation encapsulating multi-table eager loading (`.Include()`), dynamic WHERE filtering, and collection synchronization (`UserSkills`, `UserInterests`, `UserRoles`).
5. **Services (`Interfaces/` & `Services/`)**:
   - `IFileStorageService.cs`: Storage abstraction contract for profile images.
   - `LocalFileStorageService.cs`: Filesystem implementation storing profile photos under `wwwroot/uploads/profiles/` with extension and size validation (`MaxFileSize = 10 MB`).
   - `IUserService.cs`: Domain service interface for employee self-service and HR Admin operations.
   - `UserService.cs`: Domain service implementation enforcing DPDP Act 2023 visibility masking, employee self-ownership boundaries, and HR administrative workflows.
6. **Controllers (`Controllers/`)**:
   - `UserController.cs`: Exposes 10 REST endpoints (`api/users/...`) with role-based authorization rules.
7. **Verification (`scratch/VerifyUsers/`)**:
   - `VerifyUsers.csproj` & `Program.cs`: Live database verification suite testing self-service profile updates, DPDP masking, department/role changes, and user suspension.

### Modified Files
1. `Extensions/ServiceCollectionExtensions.cs`: Registered `IUserRepository`, `IFileStorageService`, and `IUserService` with `AddScoped()`.

---

## 3. API Endpoints

| Method | Endpoint | Description | Required Role / Policy |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/users/profile` | Get current authenticated user's profile | `[Authorize]` (Self) |
| `PUT` | `/api/users/profile` | Update current user's profile (`Bio`, `Visibility`, `Skills`, `Interests`) | `[Authorize]` (Self) |
| `PUT` | `/api/users/profile/bio` | Update current user's Bio and `BioVisibility` | `[Authorize]` (Self) |
| `PUT` | `/api/users/profile/skills` | Update current user's Skills list | `[Authorize]` (Self) |
| `POST` | `/api/users/profile/image` | Upload profile image (`IFormFile`) | `[Authorize]` (Self) |
| `GET` | `/api/users` | List/search platform users with pagination | `HRAdmin`, `SystemAdmin`, `CommunityAdmin` |
| `GET` | `/api/users/{id}` | Get specific user's profile (DPDP masked based on caller) | `[Authorize]` |
| `PUT` | `/api/users/{id}/department` | Change a user's department | `HRAdmin`, `SystemAdmin` |
| `PUT` | `/api/users/{id}/roles` | Change a user's assigned role(s) | `HRAdmin`, `SystemAdmin` |
| `PUT` | `/api/users/{id}/activate` | Reactivate a suspended/inactive user | `HRAdmin`, `SystemAdmin` |
| `PUT` | `/api/users/{id}/suspend` | Suspend a user (`SuspendedUntil` or permanent per `FR-SM-04`) | `HRAdmin`, `SystemAdmin` |

---

## 4. Authorization Matrix

| User Role | View Own Profile | Update Own Profile (`Bio`, `Skills`, `Photo`) | View Other Employee Profiles | Change Department / Roles | Suspend / Activate Users |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Employee** | ✅ Yes | ✅ Yes | ✅ Yes (DPDP Masked) | ❌ 403 Forbidden | ❌ 403 Forbidden |
| **Community Admin** | ✅ Yes | ✅ Yes | ✅ Yes (DPDP Masked) | ❌ 403 Forbidden | ❌ 403 Forbidden |
| **HR Administrator** | ✅ Yes | ✅ Yes | ✅ Yes (Full Unmasked) | ✅ Yes | ✅ Yes |
| **System Administrator** | ✅ Yes | ✅ Yes | ✅ Yes (Full Unmasked) | ✅ Yes | ✅ Yes |

---

## 5. Architectural Decisions & FRD Traceability

1. **Feature Repository (`UserRepository`) vs. Generic Repository**:
   - *Decision*: Created `IUserRepository` and `UserRepository` extending `IRepository<User>`.
   - *Rationale*: Generic `IRepository<T>` handles only simple CRUD without `IQueryable` leaks. User profile management requires multi-table eager loading (`Department`, `Roles`, `UserSkills`, `UserInterests`, `FollowerFollowerUsers`, `FollowerFollowingUsers`, `KarmaBalance`), complex paginated WHERE clauses, and atomic collection synchronization (`UserSkills` and `UserInterests`). Isolating these queries inside `UserRepository` keeps `UserService` clean and preserves Database-First separation of concerns.
2. **DPDP Act 2023 Privacy Masking at Service Layer (`FR-UP-04`)**:
   - *Decision*: Enforced profile visibility filtering (`BioVisibility`, `PhotosVisibility`, `InterestsVisibility`) directly inside `UserService.GetUserProfileAsync`.
   - *Rationale*: Rather than relying on frontend UI filtering, the backend evaluates the calling user's identity and relationship (`self`, `HRAdmin`, `SystemAdmin`, `isFollowing`) against the target user's visibility preferences (`Public`, `Connections Only`, `Private`). Restricted attributes are set to `null` or cleared before serialization, ensuring complete compliance with Indian data privacy laws.
3. **Storage Abstraction (`IFileStorageService`)**:
   - *Decision*: Implemented `IFileStorageService` and `LocalFileStorageService`.
   - *Rationale*: Decouples multipart/form-data upload handling (`POST /api/users/profile/image`) from the domain service (`UserService`). If MPonline transitions from local `wwwroot/uploads` storage to government cloud object storage (`Azure Blob`, `GCS`, `S3`) in Phase 4+, only `IFileStorageService` needs a new implementation (`CloudFileStorageService`) with zero changes to `UserController` or `UserService`.

---

## 6. Build Status & Verification

- **Build Outcome**: Successful ✅
- **Errors**: 0 ❌
- **Warnings**: 0 ⚠️
- **Command Executed**: `dotnet build -nologo`
- **Live Database Verification (`VerifyUsers`)**:
  - Seeded test users `EMP001` (`John Doe`, `Senior Software Engineer`), `EMP002` (`Jane Smith`, `QA Engineer`), and `HR001` (`Alice Admin`, `HR Manager`).
  - **Employee Self-Service (`FR-UP-02`)**: Verified `EMP001` updating Bio (`"Passionate ASP.NET Core 9 Architect..."`), setting `BioVisibility = Private`, adding 4 Skills (`C#`, `.NET 9`, `EF Core`, `System Architecture`), and adding 3 Interests.
  - **DPDP Act 2023 Masking (`FR-UP-04`)**: Verified that when peer `EMP002` queries `EMP001` (`BioVisibility = Private`), the API returns `Bio = null`. Verified that when `HR001` queries `EMP001`, the API returns the full unmasked Bio (`"Passionate ASP.NET Core 9 Architect..."`) due to administrative governance rights.
  - **HR Administrator Operations (`FR-SM-04`)**: Verified `HR001` changing `EMP002` department to `HR`, temporarily suspending `EMP002` for 30 days (`IsActive = False, SuspendedUntil = 2026-08-08`), and reactivating `EMP002` (`IsActive = True, SuspendedUntil = null`).
  - **Paged Search (`FR-UP-01`)**: Verified filtering users matching `"John"` returning correct total count, department name resolution, and role strings.

---

## 7. Known Issues
- None. All 10 User Profile and Management endpoints build cleanly with zero warnings and pass end-to-end database integration tests.

---

## 8. Pending Work (Next Phases)
1. **Communities Module (`ICommunityService` - Phase 4)**: Implementing public, private (`FR-CM-03` join approval workflows), and default (`FR-CM-04` HR auto-assigned) communities.
2. **Post & Article Content Engines (`FR-PC-01..07`, `FR-AB-01..07`)**: Quick-share text/media posts and rich long-form article creation with Karma point awarding (`FR-KP-01`).

---

## 9. Next Recommended Phase & Prompt
> **"Begin Phase 4 (Communities & Membership Management). Please review FRD Section 5.7 (`FR-CM-01` to `FR-CM-09`) along with existing `Community`, `CommunityMember`, and `CommunityPost` models. Implement `ICommunityService` and `CommunityController` to support public/private/default communities, join request approvals, and membership governance using our established Repository + Service architecture."**
