# Code Defect Resolution Report — Knome (MPOnline Limited)

**Date:** July 15, 2026  
**Scope:** `Backend/Knome.API` Production Code Defect Resolution Pass  
**Source of Truth:** Codebase Implementation & Traceability Audit Matrix (`RTM_Audit_Report.md`)

---

## Executive Summary

A systematic, production-quality defect resolution pass was executed across the `Backend/Knome.API` codebase. Per architectural constraints and user instructions:

- No new features or external integrations (HRMS SSO, Email Digests, HRMS Sync) were implemented.
- No scaffolded files (`Models/*` or `Data/KnomeDbContext.cs`) were modified or refactored.
- Every identified issue from recent audits was verified directly against code behavior before intervention.
- All 14 API Controllers and 12 Modules were re-verified via clean builds (`dotnet build`) and full DI resolution checks (`VerifyDiResolvers`).

---

## 1. Issues Verified & Confirmed

During the codebase verification pass, 4 genuine implementation and reliability defects were verified against actual execution behavior:

### Defect 1 (Correctness / Architectural Regression): Unconditional HTTPS Redirection in Development

- **Verification Finding:** `ApplicationBuilderExtensions.UseInfrastructure` called `app.UseHttpsRedirection()` unconditionally, reverting the fix from commit `dc53f14`.
- **Impact:** When running locally on `http://localhost:5095` (the configured development binding in `launchSettings.json`), requests were forced to redirect to HTTPS, causing proxy and connection errors during QA testing and local verification.

### Defect 2 (Correctness / Unreachable Code): Unreachable Suspension Check in `AuthService.LoginAsync`

- **Verification Finding:** `LoginAsync` loaded user credentials via `.Where(u => u.EmployeeId == request.EmployeeId && u.IsActive)`. However, `UserService.SuspendUserAsync` sets `user.IsActive = false` when suspending a user.
- **Impact:** Because suspended users (`IsActive == false`) were filtered out by the EF Core `Where` clause before reaching line 44 (`if (user.IsPermanentlySuspended ...)`), suspended users received `BadRequestException("Invalid Employee ID or password.")` instead of the exact, actionable exception `BadRequestException("This account has been suspended. Please contact HR.")`.

### Defect 3 (Reliability / API Contract Violation): Missing `ForbiddenException` Handler in Global Exception Middleware

- **Verification Finding:** `SuspensionGuard.EnsureNotSuspended(User user)` throws `ForbiddenException("This account has been suspended. Please contact HR.")`. However, `ExceptionHandlingMiddleware.HandleExceptionAsync` did not include a switch pattern match for `ForbiddenException`.
- **Impact:** Whenever `SuspensionGuard` blocked a suspended account across any API workflow, the `ForbiddenException` fell through to the default exception handler, returning HTTP 500 (`Internal Server Error: "An unexpected error occurred on the server."`) instead of the correct HTTP 403 (`Forbidden`).

### Defect 4 (Reliability / API Contract Violation): `InvalidOperationException` on Non-Existent Job Update

- **Verification Finding:** `JobRepository.UpdateAsync(int jobId, UpdateJobDto dto)` checked `if (job == null) throw new InvalidOperationException($"Job {jobId} not found");`.
- **Impact:** When `PUT /api/jobs/{id}` was called for a non-existent job, `InvalidOperationException` was thrown and caught by the global exception middleware as an unhandled exception (HTTP 500) rather than a clean HTTP 404 (`NotFoundException`).

---

## 2. Issues Fixed & Modifications Applied

All 4 confirmed defects were resolved precisely:

| # | Priority Area | Component / File Modified | Resolution Summary |
| --- | --- | --- | --- |
| **D1** | Correctness | `Backend/Knome.API/Extensions/ApplicationBuilderExtensions.cs` | Wrapped `app.UseHttpsRedirection();` inside `if (!app.Environment.IsDevelopment())` to preserve development HTTP routing while enforcing HTTPS redirection in Staging/Production environments. |
| **D2** | Correctness | `Backend/Knome.API/Services/AuthService.cs` | Removed `&& u.IsActive` from the primary login EF query (`LoginAsync`), enabling explicit evaluation of suspended status (`user.IsPermanentlySuspended \|\| user.SuspendedUntil > DateTime.UtcNow`) to return exact suspension errors (`BadRequestException`), followed by an explicit `!user.IsActive` check. |
| **D3** | Reliability | `Backend/Knome.API/Middleware/ExceptionHandlingMiddleware.cs` | Added explicit pattern matching for `ForbiddenException` inside `HandleExceptionAsync` to correctly return `StatusCodes.Status403Forbidden` (HTTP 403) with the domain error message instead of falling through to HTTP 500. |
| **D4** | Reliability | `Backend/Knome.API/Repositories/JobRepository.cs` | Replaced `throw new InvalidOperationException($"Job {jobId} not found")` in `UpdateAsync` with `throw new NotFoundException($"Job ID {jobId} not found.")` (with `using Knome.API.Exceptions;`) so missing job updates return clean HTTP 404 responses. |

---

## 3. Build & Verification Status

### Build Verification (`dotnet build -nologo`)

- **Target:** `Backend/Knome.API/Knome.API.csproj`
- **Result:** `Build succeeded.`
- **Warnings:** `0 Warning(s)`
- **Errors:** `0 Error(s)`

### Runtime DI Verification (`VerifyDiResolvers`)

- **Command:** `dotnet run --project scratch/VerifyDiResolvers/VerifyDiResolvers.csproj --no-build`
- **Verification Output:**

  ```text
  === Verifying Runtime DI Resolution across ALL 14 Controllers and 12 Modules ===
  Services & Repositories resolved successfully.
  All 14 API Controllers constructed cleanly with full DI dependencies.
  100% DI Verification PASS.
  ```

---

## 4. Remaining Issues & Deferred Items (Per Architecture Rules)

1. **In-Memory Search Merge (`SearchRepository.cs`):**
   - *Status:* Investigated and confirmed intentionally preserved.
   - *Note:* `SearchRepository` executes filtered queries against individual type tables (`Users`, `Communities`, `Posts`, `Articles`, etc.) in SQL (`QueryUsers`, `QueryPosts`, etc.) and performs the final multi-type ordering and pagination in memory. While this has scalability trade-offs for very large datasets, it is the established architectural pattern (`FR-SD-01..05`) and is preserved without risky refactoring per constraint rules.
2. **External Enterprise Integrations (HRMS SSO, Email Digests, HRMS Sync Workflows):**
   - *Status:* Deferred per architectural rules (`AGENTS.md`). No dummy implementations or mocks were created. Existing clean abstractions (`IAuthService`, `INotificationService`) remain ready for future drop-in enterprise driver implementations (`HrmsSsoAuthService`).

---

## 5. Production Hardening Pass Defect Resolutions

During the Production Hardening phase (`Backend_Hardening_Implementation_Plan.md`), the following verified defect classifications were systematically resolved across all 14 Controllers and 12 Modules:

| Classification ID | Description | Resolution Applied | Verification Status |
| --- | --- | --- | --- |
| **GBV-001** (`M-001`, `M-002`) | Unvalidated Foreign Key references in DTO requests causing raw SQL Server `500 Internal Server Error` / `DbUpdateException`. | Audited all repositories and services across all 12 modules; added/verified `ExistsAsync` checks before creation/update operations to ensure clean `NotFoundException` (`404`) or `BadRequestException` (`400`) responses. | ✅ Resolved & Verified |
| **ValidationFilter** | Controller actions manually handling `ModelState.IsValid` or missing automatic DTO validation interception. | Implemented and globally registered `ValidationFilter` (`ActionFilterAttribute`) in `AddInfrastructure` / `UseInfrastructure` to automatically catch `ValidationException` / `ModelState` errors and return standardized `ApiResponse` errors (`400 Bad Request`). | ✅ Resolved & Verified |
| **MaximumLength Audit** (`B4-001`) | Unconstrained string properties on creation and update DTOs across multiple modules. | Audited all 28 FluentValidation validators across all 12 modules; verified and enforced `MaximumLength` constraints (`Title <= 200`, `Content/Bio <= 2000/5000`, etc.) ensuring DB schema compliance. | ✅ Resolved & Verified |
| **B7-001** | `PUT /api/communities/{id}` for non-existent community returning `403 Forbidden` instead of `404 Not Found`. | Reordered validation in `CommunityService.UpdateCommunityAsync` and added explicit existence check inside `CheckIsAdminOrSysAdminAsync` (`AnyAsync(c => c.CommunityId == id)`). | ✅ Resolved & Verified |
| **B7-002** | `DELETE /api/communities/{id}` endpoint returning `405 Method Not Allowed` (unimplemented). | Implemented `DeleteCommunityAsync` in `ICommunityService` / `CommunityService` and added `[HttpDelete("{communityId}")]` endpoint in `CommunityController`. | ✅ Resolved & Verified |
| **B6-003 / B8-001** | `POST /api/interactions/reactions` returning `200 OK` for newly created reaction rather than `201 Created`. | Updated `ToggleReactionAsync` to return `(ReactionSummaryDto Summary, bool IsCreated)` tuple and updated `InteractionController` to return `201 Created` for new reactions and `200 OK` for updates/removals. | ✅ Resolved & Verified |
