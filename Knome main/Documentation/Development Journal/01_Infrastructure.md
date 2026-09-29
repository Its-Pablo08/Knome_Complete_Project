# Development Journal: Phase 1 — Infrastructure Setup

## Objective
Establish a robust, enterprise-grade infrastructure foundation for the **Knome.API** project, converting the default template into a clean Repository-pattern-based ASP.NET Core 9 Web API ready for subsequent feature implementation. This includes configuring structured logging, generic data repositories, global exception handling, standardized response formatting, validation setups, Swagger, and dependency injection.

Additionally, perform database schema validation to ensure the design supports development-time password-based authentication, applying minimal extension schemas following database-first principles.

---

## NuGet Packages Installed
The following enterprise-grade libraries are configured in [Knome.API.csproj](file:///d:/Knome Final/Backend/Knome.API/Knome.API.csproj):
- **`Serilog.AspNetCore`** & **`Serilog.Sinks.File`**: Advanced structured logging configured for console and daily rolling files.
- **`Swashbuckle.AspNetCore`**: Automatically generates interactive OpenAPI/Swagger developer documentation.
- **`AutoMapper.Extensions.Microsoft.DependencyInjection`**: Maps Domain Entities to/from Data Transfer Objects (DTOs).
- **`FluentValidation.AspNetCore`**: Enables Fluent API validation rules inside the request pipeline.

---

## Folders & Placeholders Kept
As requested, all scaffolded folders were preserved. The empty placeholder directories for Phase 2+ are:
- `DTOs/`
- `Mapping/`
- `Services/`
- `Validators/`
- `Helpers/`

---

## Files Created

| File | Path / Link | Responsibility |
| :--- | :--- | :--- |
| **API Constants** | [ApiConstants.cs](file:///d:/Knome Final/Backend/Knome.API/Constants/ApiConstants.cs) | Static messages and common policy names (e.g. CORS policy). |
| **CORS Settings** | [CorsSettings.cs](file:///d:/Knome Final/Backend/Knome.API/Configuration/CorsSettings.cs) | Strongly-typed configuration class matching the `CorsSettings` appsettings section. |
| **Custom Exceptions** | [NotFoundException.cs](file:///d:/Knome Final/Backend/Knome.API/Exceptions/NotFoundException.cs)<br>[BadRequestException.cs](file:///d:/Knome Final/Backend/Knome.API/Exceptions/BadRequestException.cs)<br>[ConflictException.cs](file:///d:/Knome Final/Backend/Knome.API/Exceptions/ConflictException.cs) | Custom domain-specific exception types mapped to appropriate HTTP Status Codes (404, 400, 409). |
| **Response Wrapper** | [ApiResponse.cs](file:///d:/Knome Final/Backend/Knome.API/Responses/ApiResponse.cs) | Standard envelope for all API responses ensuring a consistent client contract (`Success`, `StatusCode`, `Message`, `Data`, `Errors`). |
| **Global Middleware** | [ExceptionHandlingMiddleware.cs](file:///d:/Knome Final/Backend/Knome.API/Middleware/ExceptionHandlingMiddleware.cs) | Catch-all middleware mapping custom exceptions and Fluent Validation errors to unified JSON responses while logging failures. |
| **Generic Repository** | [IRepository.cs](file:///d:/Knome Final/Backend/Knome.API/Interfaces/IRepository.cs)<br>[Repository.cs](file:///d:/Knome Final/Backend/Knome.API/Repositories/Repository.cs) | Provides basic generic CRUD data operations (`GetByIdAsync`, `GetAllAsync`, `FindAsync`, `AddAsync`, `Update`, `Remove`) without leaking business logic. |
| **DI Extensions** | [ServiceCollectionExtensions.cs](file:///d:/Knome Final/Backend/Knome.API/Extensions/ServiceCollectionExtensions.cs)<br>[ApplicationBuilderExtensions.cs](file:///d:/Knome Final/Backend/Knome.API/Extensions/ApplicationBuilderExtensions.cs) | Separates service registration (AutoMapper, FluentValidation, DBContext, CORS, Swagger) and pipeline configuration for clean architecture. |
| **UserCredential Model** | [UserCredential.cs](file:///d:/Knome Final/Backend/Knome.API/Models/UserCredential.cs) | Model scaffolded automatically to represent the new `UserCredentials` database credentials table. |

---

## Files Modified

| File | Path / Link | Nature of Change |
| :--- | :--- | :--- |
| **AppSettings** | [appsettings.json](file:///d:/Knome Final/Backend/Knome.API/appsettings.json)<br>[appsettings.Development.json](file:///d:/Knome Final/Backend/Knome.API/appsettings.Development.json) | Configured the SQL Server connection string (`LAPTOP-462` database `Knome`) and loaded CORS settings. |
| **Program Start** | [Program.cs](file:///d:/Knome Final/Backend/Knome.API/Program.cs) | Rewritten from scratch to configure Serilog logging, bootstrapping, and register infrastructure components cleanly. |
| **User Entity** | [User.cs](file:///d:/Knome Final/Backend/Knome.API/Models/User.cs) | Regenerated via scaffolding to contain the 1-to-1 virtual reference navigation property for `UserCredential`. |
| **DbContext** | [KnomeDbContext.cs](file:///d:/Knome Final/Backend/Knome.API/Data/KnomeDbContext.cs) | Scaffolded to register `DbSet<UserCredential>` and configure its relations. Modified `OnConfiguring` to wrap design-time configuration and eliminate security warnings. |

---

## Database Authentication Schema Extension

### 1. Schema Validation Findings
* **Users Table**: Contains `EmployeeId` (suitable as login handle) but lacks `PasswordHash`, `PasswordSalt`, or other security credential storage.
* **Credentials Store**: No dedicated authentication or credential table existed in the initial schema.
* **Support Status**: The database schema initially did not support password authentication.

### 2. SQL Schema Changes Applied
To support authentication without changing the existing columns of the `Users` table (preserving generated models clean of security credentials), a separate 1-to-1 extension table named `UserCredentials` was created:

```sql
CREATE TABLE UserCredentials (
    UserId INT NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    PasswordSalt VARCHAR(255) NULL,
    LastUpdated DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_UserCredentials PRIMARY KEY (UserId),
    CONSTRAINT FK_UserCredentials_Users FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);
```

### 3. EF Core Scaffolding Refresh
Following schema updates, the `dotnet ef dbcontext scaffold` command was successfully re-run:
* Generated [UserCredential.cs](file:///d:/Knome Final/Backend/Knome.API/Models/UserCredential.cs).
* Updated [User.cs](file:///d:/Knome Final/Backend/Knome.API/Models/User.cs) with `public virtual UserCredential? UserCredential { get; set; }` 1-to-1 navigation linkage.
* Configured entity mappings in [KnomeDbContext.cs](file:///d:/Knome Final/Backend/Knome.API/Data/KnomeDbContext.cs).
* Removed the hardcoded scaffolding warnings inside [KnomeDbContext.cs](file:///d:/Knome Final/Backend/Knome.API/Data/KnomeDbContext.cs) by enclosing the fallback configuration with `if (!optionsBuilder.IsConfigured)`.

---

## Architectural Decisions

1. **Database-First Models & DbContext Preserved**
   - The scaffolded structures are managed strictly using EF Core design-time scaffolding, preserving their dynamic generation flow.
2. **Dedicated Credentials Store**
   - User profile data is separated from authentication secrets. The 1-to-1 `UserCredentials` relation preserves security encapsulation and prevents scaffolded model pollution.
3. **No Unit of Work Abstraction**
   - Avoided introducing a custom `IUnitOfWork` layer, since EF Core's `DbContext` already encapsulates the Unit of Work pattern (tracking changes and writing atomically via `SaveChangesAsync`).
4. **Structured Serilog Logging**
   - Configured structured console logging and daily-rolling log files (`logs/knome-.log`) to satisfy production audit and debug requirements.
5. **Global Error Mapping**
   - Centralized exception mapping inside a global middleware ensuring the client always receives a clean `ApiResponse` wrapper instead of raw stack traces.

---

## Build Status
- **Build Outcome**: Successful ✅
- **Errors**: 0 ❌
- **Warnings**: 0 ⚠️
- **Command Executed**: `dotnet build` from `d:\Knome Final\Backend\Knome.API`

---

## Known Issues
- None. The project compiles cleanly.

---

## Pending Work
1. **Feature DTOs & Mapping**: Creating specific mapping profiles and models for data transfer (e.g. `UserDTO`, `PostDTO`).
2. **Feature Repositories & Services**: Adding business service layers for Users, Posts, Articles, and Communities.
3. **Controllers**: Exposing REST endpoints mapping to the Service layer.
4. **Request Validation**: Adding validators extending `AbstractValidator<T>` for input sanitization.

---

## Next Recommended Prompt
"Begin Phase 2 (Core Features). Please review the scaffolded models (`User.cs`, `UserCredential.cs`, etc.) and start implementing the User management and Authentication verticals, including `IUserService`, `UserService`, `IAuthService`, `AuthService`, related DTOs, Fluent Validation, and `AuthController` exposing Login/Register endpoints."
