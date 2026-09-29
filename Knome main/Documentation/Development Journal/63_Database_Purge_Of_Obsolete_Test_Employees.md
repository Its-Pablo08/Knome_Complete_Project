# Development Journal: 63_Database_Purge_Of_Obsolete_Test_Employees.md

## Overview
Purge of obsolete test and duplicate employee records from the live SQL Server `Knome` database:
1. `UserId 1067` (`EmployeeId: MPO101`, `Loveneesh Sharma` - duplicate test admin entry; permanent primary admin remains `UserId 1`, `EmployeeId: MP0108`)
2. `UserId 1068` (`EmployeeId: NON_EXISTENT_999`, test non-existent user)
3. `UserId 1069` (`EmployeeId: MPO664`, test employee user)
4. `UserId 1071` (`EmployeeId: MPO107`, test employee user)

## Foreign Key Dependency Mapping & Pre-Deletion Resolution
The `Users` table is referenced across 32 foreign key constraints in SQL Server:
- `ModerationReports`: Reassigned `ModeratorUserId` to primary System Administrator (`UserId = 1`).
- `AuditLog`: Reassigned `ActorUserId` to primary System Administrator (`UserId = 1`).
- `Communities`: Reassigned `CreatedByUserId` to primary System Administrator (`UserId = 1`).
- `Notifications`: Deleted dependent notifications targeting these test users (17 rows).
- `UserRoles`: Removed assigned roles for these users (6 rows).
- `UserCredentials`: Removed login credentials for these users (4 rows).
- `KarmaTransactions` & `KarmaBalances`: Removed karma history and ledger balances (5 rows).
- `ConnectionRequests`, `PostMentions`, `Reactions`, `CommunityMembers`, `CommunityAdmins`: Cleaned up active memberships and interactions.

## Execution
```sql
DELETE FROM Users WHERE UserId IN (1067, 1068, 1069, 1071);
```
- Rows affected: 4
- Return status: Success, 0 FK violations.

## Frontend Synchronization
- Removed legacy test record `MPO107` from `INITIAL_USERS` in `knomeUI/frontend/src/components/contexts/UserContext.jsx`.
- Cleaned up obsolete employee ID checks (`MPO101`, `MPO107`) in `knomeUI/frontend/src/pages/Profile.jsx`.
- Clean build: `npm run build` completed cleanly in 1.07s.
- Deployed freshly compiled bundle to IIS `C:\inetpub\wwwroot\knome\`.

## Verification
- Verified via `sqlcmd`: `SELECT UserId, EmployeeId, FullName, Email FROM Users WHERE UserId IN (1067, 1068, 1069, 1071);` returns `(0 rows affected)`.
- Verified backend: `dotnet build -nologo` completed with 0 errors.
- Active admin account intact: `UserId 1`, `EmployeeId MP0108` (`Loveneesh Sharma`).
