# CLAUDE.md

## Project Overview

Project Name: Knome

Knome is an enterprise-grade Knowledge Management Platform being developed for MPOnline Limited.

The platform combines features inspired by LinkedIn, Medium, YouTube and enterprise collaboration systems.

This repository follows a strict Database-First architecture using Entity Framework Core and MS SQL Server.

---

## Technology Stack

### Backend

- ASP.NET Core 10 Web API
- Entity Framework Core
- SQL Server
- Repository Pattern
- Service Pattern
- AutoMapper
- FluentValidation
- Serilog
- JWT Authentication

### Frontend

- React

### Database

- Microsoft SQL Server

---

## Architecture Rules

These rules are mandatory.

- Never manually modify scaffolded Models.
- Never manually modify DbContext.
- Database schema changes must originate from SQL Server.
- Re-scaffold whenever the database changes.
- Preserve Repository + Service Pattern.
- Keep business logic inside Services.
- Keep repositories focused only on data access.
- Keep Controllers thin.
- Follow SOLID pragmatically.
- Prefer readable code over clever code.
- **Always log in through MPO Employee Hub**: [MPO Employee Hub](https://counselling-1.mponline.demo.gov.in:3001/applications).

---

## Documentation Rules

Before implementing any feature:

1. Read Documentation/Project/PROJECT_CONTEXT.md
2. Read Documentation/Project/PROJECT_STATUS.md
3. Read the latest Development Journal
4. Read the relevant FRD section
5. Verify the database schema if required

After completing every phase:

- dotnet restore
- dotnet build
- Verify APIs
- Update Development Journal
- Update API documentation
- Update Documentation/Project/PROJECT_STATUS.md
- Update Documentation/Project/PROJECT_CONTEXT.md

---

## Business Rules

The Functional Requirements Document (FRD) is the primary source of business requirements.

The database schema is the primary source of data structure.

The current codebase is the source of implementation truth.

If any conflict exists between these sources, explain the conflict before implementing.

---

## Coding Standards

Always write:

- Production-ready code
- Human-readable code
- Maintainable code
- Minimal duplication
- Small focused methods
- Proper naming
- No AI-style boilerplate
- No unnecessary abstractions

---

## Verification

Before considering any phase complete:

- Build successfully
- No build errors
- Swagger verification
- Verify authorization
- Verify affected APIs
- Update documentation

Never mark a phase complete until all verification succeeds.
