# Dev Journal 34: Article Category Role-Based Access Control (System Administrator Only)

## Overview
Implemented role-based access control (RBAC) enabling **System Administrators exclusively** to create and manage custom Article categories directly within the Article creation experience (`Articles.jsx` and `CreateArticleModal.jsx`), backed by secure, enterprise-grade ASP.NET Core API endpoints and SQL Server persistence.

## Architectural Decision & Constraints
- **Zero Model Modification**: Leveraged existing `Categories` table (`CategoryId`, `Name`, `AppliesTo = 'Article'`) in SQL Server without modifying `Models/` or `KnomeDbContext.cs` manually.
- **Strict Role-Based Authorization**:
  - `GET /api/articles/categories` is accessible by all authenticated users to populate article category dropdowns dynamically.
  - `POST /api/articles/categories` is strictly guarded by `[Authorize(Roles = Roles.SystemAdmin)]`, rejecting non-admin attempts with HTTP 403 Forbidden.
- **Data Integrity**: Duplicate category names under the Article domain are strictly prevented (case-insensitive check returning HTTP 409 Conflict). Name trimmed and constrained to maximum 100 characters.
- **Safe Fallback**: Frontend maintains default fallback categories (`Engineering`, `Product`, `Design`, `Culture`, `Tutorial`, `Company News`, `Leadership`) in case of network unavailability.

## Key Changes

### 1. Backend API (`Backend/Knome.API`)
- **DTOs (`DTOs/Categories/CategoryDto.cs`)**:
  - `CategoryDto`: Exposes `CategoryId`, `Name`, and `AppliesTo`.
  - `CreateCategoryDto`: Validates input `Name` (required, max 100 chars).
- **Service Layer (`Interfaces/IArticleService.cs` & `Services/ArticleService.cs`)**:
  - `GetArticleCategoriesAsync()`: Queries `_db.Categories` where `AppliesTo == "Article"`, sorted alphabetically.
  - `CreateArticleCategoryAsync()`: Validates name, enforces duplicate check against existing categories, inserts new row with `AppliesTo = "Article"`, saves, and returns the created DTO.
- **Controller Layer (`Controllers/ArticleController.cs`)**:
  - `GET /api/articles/categories`: Returns dynamic list in standard `ApiResponse<List<CategoryDto>>`.
  - `POST /api/articles/categories`: Decorated with `[Authorize(Roles = Roles.SystemAdmin)]`. Handles conflict handling (409) and validation errors (400).

### 2. Frontend Integration (`knomeUI/frontend`)
- **API Client (`src/utils/articleService.js`)**:
  - Added `getArticleCategories()` and `createArticleCategory(name)`.
- **Article Authoring View (`src/pages/Articles.jsx`)**:
  - Checks if active user has `Roles.SystemAdmin` (`user.roles?.includes('System Administrator')` or `user.role === 'SYSADM'`).
  - Added `+ Add Category` button beside Category label, displayed only for System Administrators.
  - Interactive inline category creator with input box, Save, and Cancel buttons.
  - Automatically selects the newly added category upon creation and displays a toast notification.
  - Dynamic categories also update the filter tabs in the article explore listing.
- **Modal Component (`src/components/modals/CreateArticleModal.jsx`)**:
  - Mirrored identical RBAC-guarded `+ Add Category` UI, inline input, dynamic state synchronization, and instant auto-selection.

## Verification & Testing
- **Compilation**:
  - Backend: `dotnet build -nologo` succeeded with `0 Error(s)`.
  - Frontend: `npm run build` completed cleanly in 1.31s with zero errors.
- **Live RBAC Verification (`scratch/verify_category_rbac.ps1`)**:
  - Verified System Administrator (`MPO107` / Vilash Deshmukh) authentication: Successful.
  - Category retrieval (`GET /api/articles/categories`): Returned dynamic list.
  - Category creation (`POST /api/articles/categories`): Successfully created new category (ID 1013, Name: "Cloud Architecture 281").
  - Duplicate conflict prevention: Attempting to recreate the same category correctly returned `HTTP 409 Conflict`.
  - RBAC security enforcement: Attempting to create category as standard Employee (`EMP001`) correctly returned `HTTP 403 Forbidden`.
