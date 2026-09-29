# Development Journal: Phase 2 — Authentication Foundation

## Objective
Implement a secure, production-ready, development-time authentication system using **Employee ID + BCrypt Password** and **JSON Web Tokens (JWT)** for stateless authentication and role-based authorization.

The architecture strictly maintains clean separation of concerns and adheres to the **Repository + Service Pattern**. The design ensures that when **HRMS SSO** is integrated in the future, the authentication provider can be seamlessly swapped by replacing `AuthService` with an SSO implementation of `IAuthService` without changing `AuthController`, authorization attributes (`[Authorize]`), or frontend API contracts.

---

## NuGet Packages Installed
The following authentication and cryptographic libraries were added to [Knome.API.csproj](file:///d:/Knome Final/Backend/Knome.API/Knome.API.csproj):
- **`BCrypt.Net-Next (4.0.3)`**: Industry-standard secure password hashing and verification with configurable work factors.
- **`Microsoft.AspNetCore.Authentication.JwtBearer (9.0.6)`**: ASP.NET Core 9 middleware for validating Bearer tokens and populating `ClaimsPrincipal`.
- **`System.IdentityModel.Tokens.Jwt (8.9.0)`**: Token generation and JWT formatting utilities.

---

## Files Created

| File | Path / Link | Responsibility |
| :--- | :--- | :--- |
| **JWT Settings POCO** | [JwtSettings.cs](file:///d:/Knome Final/Backend/Knome.API/Configuration/JwtSettings.cs) | Strongly-typed configuration model bound to the `JwtSettings` section in `appsettings.json`. |
| **Role Constants** | [Roles.cs](file:///d:/Knome Final/Backend/Knome.API/Constants/Roles.cs) | Static role strings (`Employee`, `Community Admin`, `HR Administrator`, `System Administrator`) matching DB `RoleName` exactly. |
| **Login Request DTO** | [LoginRequestDto.cs](file:///d:/Knome Final/Backend/Knome.API/DTOs/Auth/LoginRequestDto.cs) | Encapsulates client login payloads (`EmployeeId` + `Password`). |
| **Login Response DTO** | [LoginResponseDto.cs](file:///d:/Knome Final/Backend/Knome.API/DTOs/Auth/LoginResponseDto.cs) | Returns the signed JWT `Token`, expiry timestamp `ExpiresAt`, and basic `CurrentUserDto` profile. |
| **Current User DTO** | [CurrentUserDto.cs](file:///d:/Knome Final/Backend/Knome.API/DTOs/Auth/CurrentUserDto.cs) | Safe user profile representation stripped of sensitive fields (`UserId`, `EmployeeId`, `FullName`, `Email`, `Designation`, `Department`, and `Roles`). |
| **Login Request Validator** | [LoginRequestValidator.cs](file:///d:/Knome Final/Backend/Knome.API/Validators/Auth/LoginRequestValidator.cs) | FluentValidation rules verifying `EmployeeId` and `Password` presence and minimum requirements. |
| **Auth Service Contract** | [IAuthService.cs](file:///d:/Knome Final/Backend/Knome.API/Interfaces/IAuthService.cs) | Interface defining `LoginAsync` and `GetCurrentUserAsync`. Abstraction layer designed for future HRMS SSO provider replacement. |
| **Auth Service** | [AuthService.cs](file:///d:/Knome Final/Backend/Knome.API/Services/AuthService.cs) | Implements single-query user/credential/department/role fetching via EF Core `Include()`, BCrypt password verification, suspension checks, and JWT claim generation (`Sub`, `Jti`, `employeeId`, `fullName`, and `Role` claims). |
| **Auth Controller** | [AuthController.cs](file:///d:/Knome Final/Backend/Knome.API/Controllers/AuthController.cs) | Thin API controller exposing `/api/auth/login` (POST), `/api/auth/logout` (POST), and `/api/auth/me` (GET). Wrapped in `ApiResponse<T>` envelopes. |

---

## Files Modified

| File | Path / Link | Nature of Change |
| :--- | :--- | :--- |
| **AppSettings** | [appsettings.json](file:///d:/Knome Final/Backend/Knome.API/appsettings.json)<br>[appsettings.Development.json](file:///d:/Knome Final/Backend/Knome.API/appsettings.Development.json) | Added `JwtSettings` configuration block containing `SecretKey`, `Issuer`, `Audience`, and `ExpiryMinutes`. |
| **Service Collection Extensions** | [ServiceCollectionExtensions.cs](file:///d:/Knome Final/Backend/Knome.API/Extensions/ServiceCollectionExtensions.cs) | Registered `JwtBearerDefaults.AuthenticationScheme`, configured `TokenValidationParameters`, registered `IAuthService` (`Scoped`), added policy registrations for all four roles, and added Swagger `Bearer` security scheme + requirement so tokens can be tested directly from Swagger UI. Organized into private helper methods (`AddCorsPolicy`, `AddDatabase`, `AddAuthentication`, `AddAuthorization`, `AddApplicationServices`, `AddSwagger`) for readability. |
| **Application Builder Extensions** | [ApplicationBuilderExtensions.cs](file:///d:/Knome Final/Backend/Knome.API/Extensions/ApplicationBuilderExtensions.cs) | Added `app.UseAuthentication()` immediately before `app.UseAuthorization()` in the HTTP request pipeline. |

---

## Architectural Decisions

1. **Provider-Swap SSO Readiness (`IAuthService`)**
   - The system uses `IAuthService` as a strict abstraction layer between `AuthController` and the underlying authentication mechanism.
   - When HRMS SSO is ready, creating an `HrmsSsoAuthService` implementing `IAuthService` and changing one DI line in `ServiceCollectionExtensions.cs` (`services.AddScoped<IAuthService, HrmsSsoAuthService>()`) will switch the entire application to SSO without altering Controllers, authorization attributes (`[Authorize(Roles = ...)]`), or frontend code.

2. **No Registration, Reset, or Refresh Token Flow**
   - Per explicit requirements, no user registration, self-service password reset, email verification, or refresh tokens were implemented.
   - Employee identities and initial credentials (`UserCredentials`) are provisioned administratively/via HR sync, mirroring enterprise HRMS behavior.

3. **Single-Query Authentication with Eager Loading**
   - In `LoginAsync`, a single EF Core query using `.Include(u => u.UserCredential).Include(u => u.Department).Include(u => u.Roles)` retrieves all required authentication, credential, department, and role data atomically, preventing N+1 queries during login.

4. **BCrypt Work Factor & Verification**
   - Password hashes stored in `UserCredentials.PasswordHash` are verified using `BCrypt.Net.BCrypt.Verify(request.Password, user.UserCredential.PasswordHash)`. A work factor of 11 is used for generated hashes.

5. **Role Mapping via `RoleName`**
   - The database contains `Roles` with both `RoleCode` (`EMP`, `CADM`, `HRADM`, `SYSADM`) and `RoleName` (`Employee`, `Community Admin`, `HR Administrator`, `System Administrator`).
   - JWT `ClaimTypes.Role` claims and `CurrentUserDto.Roles` are mapped to `RoleName` to provide descriptive, standard names inside `[Authorize(Roles = "Employee")]` policy checks.

6. **Stateless Logout**
   - `POST /api/auth/logout` returns success immediately without server-side token blacklisting, requiring the frontend client to discard the JWT. Once HRMS SSO is integrated, this endpoint will initiate the SSO logout redirect flow.

---

## Verification & Live Testing Results

### 1. Build Status
- **Build Outcome**: Successful ✅
- **Errors**: 0 ❌
- **Warnings**: 0 ⚠️
- **Command Executed**: `dotnet build`

### 2. Live Database Verification (`VerifyAuth`)
An end-to-end test app (`scratch/VerifyAuth`) was executed against the live SQL Server (`Server=LAPTOP-462;Database=Knome;...`):
- **Seeding & Hash Fix**: Seeded test user `EMP001` (`John Doe`, `Technology` department, `Employee` role) with a valid BCrypt hash (`$2a$11$q0xQPEZDVgMSUk9qie3U4.6fABcb8mYU7Aknj7LFm2FhMYyV0Brz6` for password `Test@1234`).
- **`LoginAsync` Test**: Executed with `EMP001` + `Test@1234`. Successfully verified the password and generated a signed JWT token (`HS256`) containing all user claims and the `Employee` role.
- **`GetCurrentUserAsync` Test**: Executed with `UserId = 1`. Successfully returned the clean profile DTO (`John Doe`, `john.doe@knome.local`, `Senior Software Engineer`, `Technology`).
- **Invalid Password Test**: Executed `LoginAsync` with `WrongPassword123`. Correctly rejected the request and threw `BadRequestException("Invalid Employee ID or password.")`.

---

## Known Issues
- None. The project compiles cleanly and passes all end-to-end authentication flows against the database.

## Future Considerations (FRD Alignment)
Per **Rule 6** of the mandatory Project Context guidelines, the following business rules and integration specifications described in the **Functional Requirements Document (FRD v1.0)** are documented here as future requirements governing downstream phases:

1. **Active Directory / SSO Integration (`INT-02` & `NFR-SEC-02`)**:
   - *FRD Requirement*: `NFR-SEC-02` mandates "Authentication via SSO only; no local password. 100% of logins via AD/SSO; no local auth fallback."
   - *Current Implementation vs. Future Plan*: Phase 2 uses local `UserCredentials` (`PasswordHash`) strictly as a development-time scaffolding/bridge while HRMS/SSO infrastructure (`INT-02`) is under setup.
   - *Architectural Safeguard*: Because `AuthController` interacts solely with `IAuthService`, replacing `AuthService` with an `HrmsSsoAuthService` implementing SAML 2.0 / OAuth 2.0 / AD claims in a future phase will satisfy `NFR-SEC-02` with **zero refactoring** required in `AuthController`, the `[Authorize]` pipeline, or client contracts.

2. **HRMS Master Data Synchronization (`INT-01` & `FR-UP-01`)**:
   - *FRD Requirement*: `FR-UP-01` requires auto-populating employee master data (`Name`, `Designation`, `Department`, `Location`, `EmployeeId`) from HRMS.
   - *Future Plan*: A scheduled sync job or webhook handler (`IEmployeeSyncService`) will ingest and update records in the scaffolded `Users` and `Departments` tables without requiring user self-registration or password reset flows.

3. **Digital Personal Data Protection (DPDP) Act Compliance (Section 12.2 Constraints)**:
   - *FRD Requirement*: Compliance with Indian data privacy legislation (`DPDP Act 2023`).
   - *Future Plan*: Profile visibility settings (`FR-UP-04`: `Public`, `Connections Only`, `Private`) stored in `Users.BioVisibility`, `NetworkVisibility`, `PhotosVisibility`, and `InterestsVisibility` will be strictly enforced at the `UserService` query layer during Phase 3 (User Profile Management) before serializing payloads to API consumers.

---

## Pending Work (Next Phases)
1. **User Profile & Management API (`IUserService` - Phase 3)**: Implementing endpoints supporting `FR-UP-01` through `FR-UP-06` (Bio/Skills/Interests updates, photo upload resizing, and visibility filtering) and HR Admin management (`FR-SM-04` suspension handling).
2. **Community & Post Verticals (Phase 4+)**: Implementing core platform modules (Communities `FR-CM-01..09`, Posts `FR-PC-01..07`, Articles `FR-AB-01..07`) using the established Repository + Service pattern and protected by our newly verified JWT `[Authorize]` policies.

---

## Next Recommended Prompt
"Begin Phase 3 (User Profile & Management). Please review FRD Section 5.2 (`FR-UP-01` to `FR-UP-06`) along with existing `User`, `Department`, `Role`, `UserSkill`, and `UserInterest` models. Implement `IUserService` and `UserController` adhering to the FRD requirements, DPDP visibility constraints, and our established Repository + Service architecture."
