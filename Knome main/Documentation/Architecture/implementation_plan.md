# Phase 1 — Infrastructure Setup (Revised)

## Current State

| Item | Status |
|------|--------|
| **Project** | ASP.NET Core 10 Web API (`net10.0`) |
| **DbContext** | `Data/KnomeDbContext.cs` — 35 entities, scaffolded ✅ |
| **Models** | 35 files in `Models/` — scaffolded, **will NOT be modified** ✅ |
| **NuGet Packages** | AutoMapper, FluentValidation, Swashbuckle, Serilog already added to `.csproj` ✅ |
| **Folder Structure** | Created but **all empty** — needs code files |
| **Program.cs** | Still default weatherforecast template — **needs replacement** |
| **appsettings.json** | No connection string configured — **needs update** |

---

## Architectural Decisions

### What we're building and why

| Decision | Rationale |
|----------|-----------|
| **Generic Repository (CRUD only)** | Provides a reusable data access layer. Contains only `GetByIdAsync`, `GetAllAsync`, `FindAsync`, `AddAsync`, `Update`, `Remove`. No business logic. |
| **No Unit of Work** | Single DbContext project. EF Core's `DbContext` already acts as a UoW. Adding a separate `IUnitOfWork` wrapper is unnecessary abstraction with no clear value here. Services call `SaveChangesAsync()` on the context directly when needed. |
| **No .gitkeep files** | Empty folders with placeholder files add noise. Folders that need code in Phase 2+ will be created when that code is written. For now, only create folders that will contain Phase 1 files. |
| **Custom exceptions without a base class** | Three focused exception types (`NotFoundException`, `BadRequestException`, `ConflictException`). No abstract `ApiException` base — the middleware switches on concrete types. Simpler, easier to read. |
| **Serilog over default logging** | Structured logging with console + file sinks. Already added to `.csproj`. |
| **No `Helpers/` folder in Phase 1** | No helper classes needed yet. Will be created in a later phase if required. |

### What we're NOT building (and why)

| Skipped | Reason |
|---------|--------|
| Feature repositories | Phase 2 — no features exist yet |
| Feature services | Phase 2 |
| Controllers | Phase 2 |
| DTOs, Validators, Mapping profiles | Phase 2 — no feature to map yet |
| Authentication/Authorization | Future phase |

---

## Proposed Changes

### Files to Create

#### Exceptions/

| File | Purpose |
|------|---------|
| `NotFoundException.cs` | Thrown when a requested entity doesn't exist. Maps to **404**. |
| `BadRequestException.cs` | Thrown for invalid input that isn't a validation error. Maps to **400**. |
| `ConflictException.cs` | Thrown for duplicate/conflict scenarios. Maps to **409**. |

Each exception is a simple class inheriting `Exception` with a constructor taking a `string message`.

---

#### Responses/

| File | Purpose |
|------|---------|
| `ApiResponse.cs` | Standard response envelope. Contains `ApiResponse` (non-generic, for errors) and `ApiResponse<T>` (for data). Properties: `bool Success`, `int StatusCode`, `string Message`, `T? Data`, `List<string>? Errors`. Static factory methods: `Ok`, `Created`, `Fail`, `NotFound`. |

---

#### Middleware/

| File | Purpose |
|------|---------|
| `ExceptionHandlingMiddleware.cs` | Catches unhandled exceptions. Maps `NotFoundException` → 404, `BadRequestException` → 400, `ConflictException` → 409, anything else → 500. Logs the error. Returns `ApiResponse` JSON. |

---

#### Interfaces/

| File | Purpose |
|------|---------|
| `IRepository.cs` | Generic repository contract. **CRUD operations only**: `GetByIdAsync(int id)`, `GetAllAsync()`, `FindAsync(Expression<Func<T, bool>>)`, `AddAsync(T entity)`, `Update(T entity)`, `Remove(T entity)`. No business logic. |

---

#### Repositories/

| File | Purpose |
|------|---------|
| `Repository.cs` | Generic EF Core implementation of `IRepository<T>`. Operates on `KnomeDbContext`. Short, clean methods. |

---

#### Extensions/

| File | Purpose |
|------|---------|
| `ServiceCollectionExtensions.cs` | Single extension method `AddInfrastructure(this IServiceCollection, IConfiguration)` that registers: DbContext, generic repository, AutoMapper, FluentValidation, Swagger, CORS. |
| `ApplicationBuilderExtensions.cs` | Single extension method `UseInfrastructure(this WebApplication)` that configures: exception middleware, Swagger (dev), CORS, HTTPS redirection. |

---

#### Constants/

| File | Purpose |
|------|---------|
| `ApiConstants.cs` | Static class with string constants: default messages (`"Resource not found"`, `"Request completed successfully"`, etc.), CORS policy name. |

---

#### Configuration/

| File | Purpose |
|------|---------|
| `CorsSettings.cs` | POCO for binding `CorsSettings` section from `appsettings.json`. Properties: `string[] AllowedOrigins`. |

---

### Files to Modify

| File | Change |
|------|--------|
| `Program.cs` | Full rewrite. Remove weatherforecast. Configure Serilog, call `AddInfrastructure()`, `UseInfrastructure()`, map controllers. |
| `appsettings.json` | Add `ConnectionStrings.DefaultConnection` (placeholder), `CorsSettings` section. Keep existing `Logging` and `AllowedHosts`. |
| `appsettings.Development.json` | Add development connection string. |
| `Knome.API.csproj` | No changes — packages already added. |

---

### Folders to Remove (empty, unused in Phase 1)

| Folder | Reason |
|--------|--------|
| `DTOs/` | No DTOs until Phase 2. Will recreate when needed. |
| `Mapping/` | No mapping profiles until Phase 2. |
| `Services/` | No services until Phase 2. |
| `Validators/` | No validators until Phase 2. |
| `Helpers/` | No helpers needed yet. |

> [!NOTE]
> These are currently empty folders. Removing them keeps the project clean. They'll be created in Phase 2 when actual code goes into them.

---

### Files NOT Modified

| File/Folder | Reason |
|-------------|--------|
| `Models/` (35 files) | Scaffolded — never modified manually |
| `Data/KnomeDbContext.cs` | Scaffolded — never modified manually |
| `Properties/launchSettings.json` | No changes needed |

---

## Verification Plan

After implementation, run sequentially:

```bash
dotnet restore
dotnet build
```

**Pass criteria**: 0 errors, 0 warnings. If any build error occurs, fix it before stopping.

---

## Documentation

After successful build, create:

```
Documentation/Development Journal/01_Infrastructure.md
```

With sections: Objective, Files Created, Files Modified, Packages Installed, Architectural Decisions, Build Status, Known Issues, Pending Work, Next Recommended Prompt.

---

## Open Questions

> [!IMPORTANT]
> **Connection String**: The `appsettings.Development.json` needs your actual SQL Server connection string. I'll put a placeholder (`Server=.;Database=KnomeDb;Trusted_Connection=true;TrustServerCertificate=true;`) — adjust as needed.

> [!IMPORTANT]
> **Empty folder cleanup**: Shall I delete the 5 empty folders (DTOs, Mapping, Services, Validators, Helpers) to keep the project clean, or leave them as placeholders for Phase 2?
