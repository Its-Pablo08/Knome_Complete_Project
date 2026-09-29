# Phase 115: Update User 1076 with Official MPO Employee Hub Profile (Vishendra Sharma)

## Executive Summary
Updated employee record `UserId 1076` with official credentials and organizational metadata from MPO Employee Hub:
- **Employee ID**: `MP0664`
- **Full Name**: `Vishendra Sharma`
- **Work Email**: `vishendra.sharma@mponline.gov.in`
- **Department**: `Higher Education` (`DepartmentId: 1009`)
- **Designation**: `Track Lead`
- **Role**: `Employee` (`EMP`, `RoleId: 4`)
- **Location**: `Bhopal`

To resolve duplicate email unique constraint collisions (`UQ__Users__A9D10534769FA794`), an obsolete development placeholder account (`UserId 1061`, `EmployeeId: VISHENDRA.SHARMA`) had its active connection requests (1 row) and notifications (3 rows) reassigned to `UserId 1076` before being cleaned up from the database.

---

## 1. Database Modifications

### 1.1 SQL Server Migration Script
```sql
BEGIN TRANSACTION;

-- 1. Reassign connection requests & notifications from legacy 1061 to live 1076
UPDATE ConnectionRequests SET ReceiverId = 1076 WHERE ReceiverId = 1061;
UPDATE Notifications SET UserId = 1076 WHERE UserId = 1061;

-- 2. Clean child rows for 1061
DELETE FROM KarmaBalances WHERE UserId = 1061;
DELETE FROM UserRoles WHERE UserId = 1061;
DELETE FROM UserCredentials WHERE UserId = 1061;

-- 3. Delete obsolete test user 1061
DELETE FROM Users WHERE UserId = 1061;

-- 4. Update user 1076 with official Employee Hub profile data
UPDATE Users
SET 
    EmployeeId = 'MP0664',
    FullName = 'Vishendra Sharma',
    Email = 'vishendra.sharma@mponline.gov.in',
    Designation = 'Track Lead',
    DepartmentId = 1009, -- Higher Education
    Location = 'Bhopal',
    ModifiedDate = GETUTCDATE()
WHERE UserId = 1076;

COMMIT TRANSACTION;
```

---

## 2. Codebase & SSO Synchronization

### 2.1 Backend Auth Normalization (`Backend/Knome.API/Services/AuthService.cs`)
- In `LoginAsync`, added automatic alternate employee ID resolution (`altSearchLower`) matching both `MP0` and `MPO` variants (e.g. `MP0664` vs `MPO664`) so employees logging in with either letter 'O' or digit '0' resolve seamlessly.

### 2.2 Frontend Context (`knomeUI/frontend/src/components/contexts/UserContext.jsx`)
- Added `MP0664` / `Vishendra Sharma` to `INITIAL_USERS`.
- Added `MPO664` → `MP0664` employee ID normalization in SSO token ingestion and local login callbacks.

---

## 3. Verification & Deployment

1. **Database Query**:
   ```sql
   SELECT u.UserId, u.EmployeeId, u.FullName, u.Email, u.Designation, d.Name AS Department, r.RoleName
   FROM Users u
   LEFT JOIN Departments d ON u.DepartmentId = d.DepartmentId
   LEFT JOIN UserRoles ur ON u.UserId = ur.UserId
   LEFT JOIN Roles r ON ur.RoleId = r.RoleId
   WHERE u.UserId = 1076;
   ```
   - **Result**: `1076 | MP0664 | Vishendra Sharma | vishendra.sharma@mponline.gov.in | Track Lead | Higher Education | Employee`.

2. **Frontend Build & IIS Deployment**:
   - `npm run build`: Compiled in 2.02s with 0 errors.
   - Mirrored to IIS webroot `C:\inetpub\wwwroot\knome` with 0 failures.
