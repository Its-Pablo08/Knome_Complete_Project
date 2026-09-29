# Backend Hardening Implementation Plan

**Project**: Knome Enterprise Knowledge Management Platform  
**Phase**: Production Hardening (Post-Verification)  
**Target**: Antigravity Agent (Implementation)

---

## 1. Objective

This document provides the implementation roadmap for the Production Hardening phase following the completed Backend API Verification. The hardening phase addresses three global issue classes and five endpoint-specific issues identified during verification, while preserving the existing architecture, business behaviour, and API contracts.

**Goals**:

- Resolve GBV-001 (FK existence validation) across 8 endpoints in 6 modules
- Normalize M-001 (FluentValidation response format) to `ApiResponse<T>` envelope
- Add M-002 (MaximumLength) validation to 18 DTO string properties
- Fix 5 endpoint-specific behavioural issues without altering business logic
- Maintain zero regressions across all 14 verified modules

---

## 2. Implementation Principles

- **Preserve Existing Architecture**: No changes to scaffolded Models, DbContext, Repository Pattern, Service Pattern, DI wiring, AutoMapper profiles, or FluentValidation registration
- **Preserve Business Behaviour**: No logic modifications; only validation gaps and response format inconsistencies addressed
- **Minimal Code Changes**: Modify only validators, exception middleware, and controller endpoints with behavioural issues
- **No Unnecessary Refactoring**: Do not restructure services, repositories, or DTOs
- **Reuse Existing Services**: Leverage existing `IRepository<T>.ExistsAsync` methods for FK checks
- **Reuse Existing Repositories**: Do not create new repository methods unless absolutely required
- **Keep API Contracts Stable**: Request/response DTOs unchanged; only validation and error envelope affected
- **Database-First Immutable**: Scaffolded Models and DbContext remain untouched; no migrations generated

---

## 3. Architectural Constraints

| Constraint | Enforcement |
| --- | --- |
| **Never modify scaffolded Models** | `Backend/Knome.API/Models/` — read-only |
| **Never modify DbContext** | `Backend/Knome.API/Data/KnomeDbContext.cs` — read-only |
| **Preserve Repository Pattern** | All data access via `IRepository<T>` and specialized repositories |
| **Preserve Service Pattern** | All business logic in `Services/`; controllers remain thin |
| **Preserve Dependency Injection** | Registration in `ServiceCollectionExtensions.cs` unchanged |
| **Preserve AutoMapper** | Profiles in `Mapping/` unchanged; assembly scanning preserved |
| **Preserve FluentValidation** | Validators in `Validators/` modified only for added rules |
| **Preserve `ApiResponse<T>`** | All endpoints must return this envelope; normalization already complete |

---

## 4. Scope Freeze

**This phase MUST ONLY resolve verified implementation defects.**

**Explicitly excluded from this phase**:

- New features
- UI changes
- Database redesign
- Architecture redesign
- Technology migration
- Performance optimization (beyond verified issues)
- Refactoring without technical justification
- New API endpoints (except B7-002 Community DELETE)
- New business logic or workflows
- Security penetration testing
- Cloud deployment preparation
- Load testing or scaling optimizations

---

## 5. Assumptions & Deferred Scope

The following items are **intentionally deferred** and outside the scope of the current hardening phase:

| Deferred Item | Reason |
| --- | --- |
| **HRMS SSO Integration** (`/api/auth/sso-login`) | Endpoint exists; integration pending external IDP provisioning |
| **HRMS Synchronization Workflows** | Architecture ready; pending external HRMS REST/OData endpoints |
| **Email Digest Engine** (`FR-NT-02`) | Engine ready; pending corporate SMTP server provisioning |
| **External Notification Providers** | Core engine complete; provider integrations deferred |
| Cloud deployment / containerization | Infrastructure concern; not backend hardening |
| Security penetration testing | Separate security phase |
| Performance optimization beyond verified issues | Not required for functional correctness |
| Database scaling / read replicas | Infrastructure concern |
| New API endpoints beyond B7-002 fix | Feature scope; not hardening |

---

## 6. Implementation Roadmap

### Pass 1: Global Business Validation Hardening (GBV-001)

**Objective**: Eliminate HTTP 500 responses for invalid foreign keys by adding database existence checks before persistence.

**Scope**: 8 endpoints across 6 modules

- Articles: `CategoryId` (POST/PUT)
- Videos: `CategoryId` (POST/PUT)
- Podcasts: `CategoryId`, `SeriesId` (POST/PUT)
- Communities: `CategoryId` (POST/PUT)
- Jobs: `DepartmentId` (POST/PUT)

**Modules Affected**: Validators and Services for each module

**Engineering Objective**:

- Add database existence validation for each foreign key field before persistence
- Validators already reference constants for enum validation; extend with FK existence checks
- Services already perform some FK checks (e.g., PodcastService validates SeriesId); standardize pattern
- Use existing `IRepository<T>.ExistsAsync` methods where available

**Verification Required**:

- Each endpoint returns 400 `ApiResponse` for invalid FK (not 500)
- Valid FK requests continue to succeed
- Existing unit of work boundaries preserved

**Regression Risks**:

- Validator async rules may require repository resolution
- Ensure validators remain stateless and thread-safe
- Verify no circular dependencies introduced in DI

---

### Pass 2: API Response Consistency Hardening (M-001)

**Objective**: Unify all validation error responses to `ApiResponse` envelope instead of ProblemDetails.

**Scope**: All 28 FluentValidation validators across 14 controllers

**Engineering Objective**:

- Disable automatic model validation integration with ASP.NET Core pipeline
- Configure FluentValidation to signal validation failure via exception rather than model state integration
- `ExceptionHandlingMiddleware` already catches `ValidationException` and returns `ApiResponse.FailureResponse(400, message, errors)`
- Ensure `ValidationException.Errors` maps to `List<string>` format expected by `ApiResponse`

**Verification Required**:

- All validation failures (empty fields, length violations, enum mismatches) return `ApiResponse` with `success: false, statusCode: 400, errors: [...]`
- Business logic errors (wrong password, not found, forbidden) continue returning `ApiResponse`
- Swagger shows consistent error response schema

**Regression Risks**:

- Disabling auto-validation changes model binding pipeline; verify controllers still receive validated DTOs
- Ensure endpoint-specific validators still execute
- Confirm `ApiController` attribute behaviour unchanged for non-FluentValidation scenarios

---

### Pass 3: DTO Validation Hardening (M-002)

**Objective**: Add `MaximumLength` constraints to all string DTO properties lacking length limits.

**Scope**: 18 properties across 10 DTOs in 6 modules

**Modules Affected**: Auth, Articles, Videos, Podcasts, Communities, Jobs, Notifications

**Engineering Objective**:

- Add length constraints in existing validators for each property
- Length values derived from database column sizes or business requirements
- No DTO class modifications; validators only

**Verification Required**:

- Oversized strings rejected at validation layer (400) not service/DB layer
- Valid strings within limits continue to process
- No truncation or silent data loss

**Regression Risks**: None expected; additive validation rules only

---

### Pass 4: Endpoint-Specific Fixes

**Objective**: Resolve 5 endpoint behavioural issues without changing business logic.

| Issue | Resolution Objective |
| --- | --- |
| **B4-001** Article `POST/PUT` invalid CategoryId → 400 | Covered by Pass 1 |
| **B6-001/002** Podcast invalid CategoryId/SeriesId → 400 | Covered by Pass 1 |
| **B7-001** Community `PUT` non-existent returns 403 not 404 | Move existence check before authorization in service |
| **B7-002** Community `DELETE` not implemented (405) | Add `DELETE` endpoint in controller calling service method |
| **B8-001** Reaction toggle returns 200 for new reaction | Service returns creation indicator; controller maps to 201 |
| **B13-001** Jobs invalid DepartmentId → 400 | Covered by Pass 1 |

**Verification Required**:

- Each fixed endpoint returns expected status code
- Business behaviour unchanged (ownership, permissions, notifications)
- Swagger reflects correct status codes

---

### Pass 5: Regression Verification

**Objective**: Confirm zero regressions across all 14 modules after hardening.

**Verification Steps**:

1. **Build**: `dotnet build -nologo` — zero warnings, zero errors
2. **DI Verification**: `dotnet run --project Backend/Knome.API/scratch/VerifyDiResolvers/VerifyDiResolvers.csproj` — 100% PASS
3. **Scratch Verification**: Run all phase-specific scratch projects (VerifyPhase1 through VerifyPhase12)
4. **Swagger Verification**: All 14 controllers visible, correct schemas, status codes documented
5. **Database Verification**: Spot-check FK validation, FK existence, cascade behaviours
6. **API Regression**: Re-run critical path tests from verification (auth, create/read/update/delete, authz)

**Gate**: No pass proceeds to next until all regression checks pass.

---

### Pass 6: Documentation Synchronization

**Objective**: Update project documentation to reflect hardened state.

**Documents to Update** (only after all implementation passes complete):

| Document | Update |
| --- | --- |
| `PROJECT_STATUS.md` | Mark hardening complete; update module statuses |
| `PROJECT_CONTEXT.md` | Reflect resolved issues; note architectural decisions |
| `Development Journal` | Add hardening entry with date, scope, verification results |
| `RTM` | Trace GBV-001, M-001, M-002 to FRD requirements |
| `API Documentation` | Update error response schemas, status codes |
| `AGENTS.md` | Add hardening phase reference if needed |
| `CLAUDE.md` | No changes expected unless architecture altered |

---

### Pass 7: Backend Freeze Checklist

**Objective**: Final verification before frontend integration.

**Checklist**:

- [ ] All 7 implementation passes complete
- [ ] `dotnet build` — zero warnings, zero errors
- [ ] `VerifyDiResolvers` — 100% PASS
- [ ] All phase scratch verifications — PASS
- [ ] Swagger loads without errors for all 14 controllers
- [ ] All 140+ endpoints return `ApiResponse<T>` envelope
- [ ] All 8 GBV-001 endpoints return 400 for invalid FK
- [ ] All 28 validators return `ApiResponse` error format
- [ ] All 18 `MaximumLength` validations active
- [ ] 5 endpoint-specific fixes verified
- [ ] Documentation synchronized
- [ ] No TODOs, FIXMEs, or placeholder code introduced

**Sign-off**: Backend frozen for frontend integration upon checklist completion.

---

## 7. Expected File Groups

| Pass | File Group | Reason |
| --- | --- | --- |
| **Pass 1 (GBV-001)** | `Validators/Articles/*.cs`, `Validators/Videos/*.cs`, `Validators/Podcasts/*.cs`, `Validators/Communities/*.cs`, `Validators/Jobs/*.cs` | Add FK existence validation rules |
| | `Services/ArticleService.cs`, `Services/VideoService.cs`, `Services/PodcastService.cs`, `Services/CommunityService.cs`, `Services/JobService.cs` | May add defensive pre-checks before persistence |
| **Pass 2 (M-001)** | `Extensions/ServiceCollectionExtensions.cs` | Disable auto-validation; configure exception-throwing mode |
| | `Middleware/ExceptionHandlingMiddleware.cs` | Verify `ValidationException` handling maps to `ApiResponse` errors list |
| **Pass 3 (M-002)** | `Validators/Auth/*.cs`, `Validators/Articles/*.cs`, `Validators/Videos/*.cs`, `Validators/Podcasts/*.cs`, `Validators/Communities/*.cs`, `Validators/Jobs/*.cs`, `Validators/Notifications/*.cs` | Add `MaximumLength` rules |
| **Pass 4 (Endpoint Fixes)** | `Services/CommunityService.cs` | Move existence check before auth in `UpdateCommunityAsync` |
| | `Controllers/CommunityController.cs` | Add `HttpDelete("{communityId}")` endpoint |
| | `Services/ContentInteractionService.cs` | Return creation status from `ToggleReactionAsync` |
| | `Controllers/InteractionController.cs` | Map reaction creation to 201 status code |
| **Pass 5-7** | `PROJECT_STATUS.md`, `PROJECT_CONTEXT.md`, `Documentation/Development Journal/*.md`, `Documentation/API_Testing_Guide.md`, `AGENTS.md` | Post-implementation sync |

---

## 8. Regression Strategy

**Philosophy**: Verify before proceeding; prevent regressions rather than fix afterwards.

**Per-Pass Gates** (each pass must pass all before next begins):

1. **Build Gate**: `dotnet build` — zero warnings/errors
2. **DI Gate**: `VerifyDiResolvers` — 100% resolution
3. **Targeted Test Gate**: Run verification tests specific to modified endpoints
4. **Scope Gate**: Run adjacent module scratch verifications to detect cross-module impact
5. **Full Regression Gate** (after Pass 4): Complete 14-batch regression suite

**Automation**: Use existing scratch projects (`VerifyDiResolvers`, `VerifyPhase1` through `VerifyPhase12`) as regression suite. No new test infrastructure needed.

**Rollback**: If any gate fails, revert pass changes, investigate, re-apply. Do not accumulate failing changes.

---

## 9. Acceptance Criteria

### Per-Pass Completion Criteria

A pass is **complete only if all** criteria met:

| Criterion | Verification |
| --- | --- |
| **Build Succeeds** | `dotnet build -nologo` — zero warnings, zero errors |
| **No New Diagnostics** | Analyzer, compiler, and IDE diagnostics clean |
| **Existing Functionality Unchanged** | All pre-existing tests pass; no behavioural modifications |
| **Pass-Specific Verification** | Targeted tests for modified endpoints pass |
| **Regression Checks Pass** | Adjacent module scratch verifications pass |

### Overall Hardening Completion

Hardening phase complete only if **all 7 passes** meet above criteria AND **Backend Freeze Checklist** (Pass 7) fully checked.

---

## 10. Final Implementation Instructions

**For the Implementation Agent (Antigravity Agent)**:

1. **Complete one pass at a time** — Do not start Pass N+1 until Pass N meets all acceptance criteria
2. **Build after every pass** — `dotnet build -nologo` must be clean
3. **Verify after every pass** — Run `VerifyDiResolvers` and affected phase scratch projects
4. **Minimize file modifications** — Touch only files in Expected File Groups; avoid collateral changes
5. **Avoid duplicate logic** — Reuse existing `ExistsAsync` repository methods; do not create new validation infrastructure
6. **Preserve existing architecture** — No new patterns, no restructuring, no new abstractions
7. **Preserve existing API contracts** — Request/response DTOs unchanged; only validation behaviour and error envelope modified
8. **Stop after each completed pass for review** — Do not chain passes without verification
9. **Document decisions** — Note any architectural decisions in Development Journal during implementation

**Order of Execution**: Pass 1 → Pass 2 → Pass 3 → Pass 4 → Pass 5 → Pass 6 → Pass 7

**Emergency Brake**: If any pass introduces regressions that cannot be resolved within the pass, halt, revert, and escalate architectural decision before proceeding.

---

*Plan Generated: 15 July 2026*  
*Source: Backend_Verification_Findings.md + AGENTS.md + CLAUDE.md + PROJECT_CONTEXT.md*  
*Target Agent: Antigravity Agent (Implementation)*
