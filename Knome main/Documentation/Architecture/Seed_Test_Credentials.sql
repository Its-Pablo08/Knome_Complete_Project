-- =========================================================================================
-- Knome EEP Portal — Safe Seed & Reset Script for API Testing Credentials
-- Database: Knome (Microsoft SQL Server)
-- Purpose: Ensures required roles, departments, categories, and test user accounts exist
--          with known passwords for manual verification via Swagger UI (localhost:5095/swagger).
-- Note: This script is idempotent (safe to run multiple times without duplicate errors).
-- =========================================================================================

USE [Knome];
GO

PRINT '=== [1/6] Verifying Base Authorization Roles ===';
IF NOT EXISTS (SELECT 1 FROM [Roles] WHERE [RoleName] = 'Employee')
    INSERT INTO [Roles] ([RoleName], [Description]) VALUES ('Employee', 'Standard EEP employee access');

IF NOT EXISTS (SELECT 1 FROM [Roles] WHERE [RoleName] = 'Community Admin')
    INSERT INTO [Roles] ([RoleName], [Description]) VALUES ('Community Admin', 'Can manage communities, join requests, and pinned posts');

IF NOT EXISTS (SELECT 1 FROM [Roles] WHERE [RoleName] = 'HR Administrator')
    INSERT INTO [Roles] ([RoleName], [Description]) VALUES ('HR Administrator', 'Can manage employee profiles, departments, roles, jobs, and broadcasts');

IF NOT EXISTS (SELECT 1 FROM [Roles] WHERE [RoleName] = 'System Administrator')
    INSERT INTO [Roles] ([RoleName], [Description]) VALUES ('System Administrator', 'Full system access, audit logs, jobs, broadcasts, and governance');
GO

PRINT '=== [2/6] Verifying Default Department ===';
IF NOT EXISTS (SELECT 1 FROM [Departments] WHERE [Name] = 'Technology')
    INSERT INTO [Departments] ([Name], [DepartmentCode]) VALUES ('Technology', 'TECH');

IF NOT EXISTS (SELECT 1 FROM [Departments] WHERE [Name] = 'Human Resources')
    INSERT INTO [Departments] ([Name], [DepartmentCode]) VALUES ('Human Resources', 'HR');
GO

PRINT '=== [3/6] Verifying Default Content Categories ===';
IF NOT EXISTS (SELECT 1 FROM [Categories] WHERE [Name] = 'Engineering' AND [AppliesTo] = 'Article')
    INSERT INTO [Categories] ([Name], [AppliesTo]) VALUES ('Engineering', 'Article');

IF NOT EXISTS (SELECT 1 FROM [Categories] WHERE [Name] = 'Tech Talks' AND [AppliesTo] = 'Video')
    INSERT INTO [Categories] ([Name], [AppliesTo]) VALUES ('Tech Talks', 'Video');

IF NOT EXISTS (SELECT 1 FROM [Categories] WHERE [Name] = 'Leadership' AND [AppliesTo] = 'Podcast')
    INSERT INTO [Categories] ([Name], [AppliesTo]) VALUES ('Leadership', 'Podcast');
GO

PRINT '=== [4/6] Seeding & Resetting Test User Accounts (Password: Password@123) ===';
DECLARE @TechDeptId INT = (SELECT TOP 1 [DepartmentId] FROM [Departments] WHERE [Name] = 'Technology');
DECLARE @HrDeptId INT = (SELECT TOP 1 [DepartmentId] FROM [Departments] WHERE [Name] = 'Human Resources');
IF @TechDeptId IS NULL SET @TechDeptId = 1;
IF @HrDeptId IS NULL SET @HrDeptId = 2;

DECLARE @Hash NVARCHAR(255) = '$2a$11$CS8Szl.LS4r1zinkLjKb8ucRdww25eHjSGhqc6my/hQXCbb9DW0Nm';
DECLARE @Salt NVARCHAR(255) = 'STATIC_SALT_FOR_BCRYPT';

-- 4.1 MPO101: Loveneesh Sharma (System Administrator)
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [EmployeeId] = 'MPO101')
    INSERT INTO [Users] ([EmployeeId], [Email], [FullName], [Designation], [DepartmentId], [Location], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [IsPermanentlySuspended], [CreatedDate])
    VALUES ('MPO101', 'mpo101@knome.local', 'Loveneesh Sharma', 'System Administrator', @TechDeptId, 'Bhopal HQ', 'Public', 'Public', 'Public', 'Public', 1, 0, GETUTCDATE());
ELSE UPDATE [Users] SET [IsActive] = 1, [IsPermanentlySuspended] = 0 WHERE [EmployeeId] = 'MPO101';

-- 4.2 MPO102: Vishendra Sharma (Community Admin)
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [EmployeeId] = 'MPO102')
    INSERT INTO [Users] ([EmployeeId], [Email], [FullName], [Designation], [DepartmentId], [Location], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [IsPermanentlySuspended], [CreatedDate])
    VALUES ('MPO102', 'mpo102@knome.local', 'Vishendra Sharma', 'Community Manager', @TechDeptId, 'Bhopal HQ', 'Public', 'Public', 'Public', 'Public', 1, 0, GETUTCDATE());
ELSE UPDATE [Users] SET [IsActive] = 1, [IsPermanentlySuspended] = 0 WHERE [EmployeeId] = 'MPO102';

-- 4.3 MPO103: Sourabh Sahu (HR Administrator)
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [EmployeeId] = 'MPO103')
    INSERT INTO [Users] ([EmployeeId], [Email], [FullName], [Designation], [DepartmentId], [Location], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [IsPermanentlySuspended], [CreatedDate])
    VALUES ('MPO103', 'mpo103@knome.local', 'Sourabh Sahu', 'HR Lead Specialist', @HrDeptId, 'Bhopal HQ', 'Public', 'Public', 'Public', 'Public', 1, 0, GETUTCDATE());
ELSE UPDATE [Users] SET [IsActive] = 1, [IsPermanentlySuspended] = 0 WHERE [EmployeeId] = 'MPO103';

-- 4.4 MPO104: Rishikesh Ugle (Employee)
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [EmployeeId] = 'MPO104')
    INSERT INTO [Users] ([EmployeeId], [Email], [FullName], [Designation], [DepartmentId], [Location], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [IsPermanentlySuspended], [CreatedDate])
    VALUES ('MPO104', 'mpo104@knome.local', 'Rishikesh Ugle', 'Software Engineer', @TechDeptId, 'Bhopal HQ', 'Public', 'Public', 'Public', 'Public', 1, 0, GETUTCDATE());
ELSE UPDATE [Users] SET [IsActive] = 1, [IsPermanentlySuspended] = 0 WHERE [EmployeeId] = 'MPO104';

-- 4.5 MPO105: Meghna Tiwari (Employee)
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [EmployeeId] = 'MPO105')
    INSERT INTO [Users] ([EmployeeId], [Email], [FullName], [Designation], [DepartmentId], [Location], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [IsPermanentlySuspended], [CreatedDate])
    VALUES ('MPO105', 'mpo105@knome.local', 'Meghna Tiwari', 'Software Engineer', @TechDeptId, 'Bhopal HQ', 'Public', 'Public', 'Public', 'Public', 1, 0, GETUTCDATE());
ELSE UPDATE [Users] SET [IsActive] = 1, [IsPermanentlySuspended] = 0 WHERE [EmployeeId] = 'MPO105';

-- 4.6 MPO106: Mayur Verma (Employee)
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [EmployeeId] = 'MPO106')
    INSERT INTO [Users] ([EmployeeId], [Email], [FullName], [Designation], [DepartmentId], [Location], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [IsPermanentlySuspended], [CreatedDate])
    VALUES ('MPO106', 'mpo106@knome.local', 'Mayur Verma', 'Software Engineer', @TechDeptId, 'Bhopal HQ', 'Public', 'Public', 'Public', 'Public', 1, 0, GETUTCDATE());
ELSE UPDATE [Users] SET [IsActive] = 1, [IsPermanentlySuspended] = 0 WHERE [EmployeeId] = 'MPO106';

-- 4.7 MPO107: Vilash Deshmukh (System Administrator)
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [EmployeeId] = 'MPO107')
    INSERT INTO [Users] ([EmployeeId], [Email], [FullName], [Designation], [DepartmentId], [Location], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [IsPermanentlySuspended], [CreatedDate])
    VALUES ('MPO107', 'vilash.deshmukh@mponline.gov.in', 'Vilash Deshmukh', 'TL', @TechDeptId, 'Bhopal HQ', 'Public', 'Public', 'Public', 'Public', 1, 0, GETUTCDATE());
ELSE UPDATE [Users] SET [IsActive] = 1, [IsPermanentlySuspended] = 0 WHERE [EmployeeId] = 'MPO107';

-- 4.8 MPO112: Rajesh Kumar (Community Admin - Approved)
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [EmployeeId] = 'MPO112')
    INSERT INTO [Users] ([EmployeeId], [Email], [FullName], [Designation], [DepartmentId], [Location], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [IsPermanentlySuspended], [CreatedDate])
    VALUES ('MPO112', 'rajesh.kumar@mponline.gov.in', 'Rajesh Kumar', 'Senior Software Engineer', @TechDeptId, 'Bhopal HQ', 'Public', 'Public', 'Public', 'Public', 1, 0, GETUTCDATE());
ELSE UPDATE [Users] SET [IsActive] = 1, [IsPermanentlySuspended] = 0 WHERE [EmployeeId] = 'MPO112';

-- 4.9 MPO108: Pooja Sharma (Pending Role Assignment)
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [EmployeeId] = 'MPO108')
    INSERT INTO [Users] ([EmployeeId], [Email], [FullName], [Designation], [DepartmentId], [Location], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [IsPermanentlySuspended], [CreatedDate])
    VALUES ('MPO108', 'pooja.sharma@mponline.gov.in', 'Pooja Sharma', 'Frontend Engineer', @TechDeptId, 'Bhopal HQ', 'Public', 'Public', 'Public', 'Public', 1, 0, GETUTCDATE());
ELSE UPDATE [Users] SET [IsActive] = 1, [IsPermanentlySuspended] = 0 WHERE [EmployeeId] = 'MPO108';

-- Insert / Update UserCredentials for all users
INSERT INTO [UserCredentials] ([UserId], [PasswordHash], [PasswordSalt])
SELECT u.[UserId], @Hash, @Salt
FROM [Users] u
WHERE NOT EXISTS (SELECT 1 FROM [UserCredentials] uc WHERE uc.[UserId] = u.[UserId]);

UPDATE [UserCredentials] SET [PasswordHash] = @Hash, [PasswordSalt] = @Salt;

PRINT '=== [5/6] Assigning Roles to Test Users ===';
DECLARE @RoleEmp INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleName] = 'Employee');
DECLARE @RoleCommAdmin INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleName] = 'Community Admin');
DECLARE @RoleHrAdmin INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleName] = 'HR Administrator');
DECLARE @RoleSysAdmin INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleName] = 'System Administrator');

DECLARE @U1 INT = (SELECT [UserId] FROM [Users] WHERE [EmployeeId] = 'MPO101');
DECLARE @U2 INT = (SELECT [UserId] FROM [Users] WHERE [EmployeeId] = 'MPO102');
DECLARE @U3 INT = (SELECT [UserId] FROM [Users] WHERE [EmployeeId] = 'MPO103');
DECLARE @U4 INT = (SELECT [UserId] FROM [Users] WHERE [EmployeeId] = 'MPO104');
DECLARE @U5 INT = (SELECT [UserId] FROM [Users] WHERE [EmployeeId] = 'MPO105');
DECLARE @U6 INT = (SELECT [UserId] FROM [Users] WHERE [EmployeeId] = 'MPO106');
DECLARE @U7 INT = (SELECT [UserId] FROM [Users] WHERE [EmployeeId] = 'MPO107');
DECLARE @U12 INT = (SELECT [UserId] FROM [Users] WHERE [EmployeeId] = 'MPO112');

-- Clear old roles for fresh assignment
DELETE FROM [UserRoles] WHERE [UserId] IN (@U1, @U2, @U3, @U4, @U5, @U6, @U7, @U12);
-- Ensure pending users have no roles
DELETE ur FROM [UserRoles] ur INNER JOIN [Users] u ON ur.UserId = u.UserId WHERE u.EmployeeId IN ('MPO108');

-- Assign Specific Roles
IF @U1 IS NOT NULL INSERT INTO [UserRoles] ([UserId], [RoleId]) VALUES (@U1, @RoleSysAdmin), (@U1, @RoleEmp);
IF @U2 IS NOT NULL INSERT INTO [UserRoles] ([UserId], [RoleId]) VALUES (@U2, @RoleCommAdmin), (@U2, @RoleEmp);
IF @U3 IS NOT NULL INSERT INTO [UserRoles] ([UserId], [RoleId]) VALUES (@U3, @RoleHrAdmin), (@U3, @RoleEmp);
IF @U4 IS NOT NULL INSERT INTO [UserRoles] ([UserId], [RoleId]) VALUES (@U4, @RoleEmp);
IF @U5 IS NOT NULL INSERT INTO [UserRoles] ([UserId], [RoleId]) VALUES (@U5, @RoleEmp);
IF @U6 IS NOT NULL INSERT INTO [UserRoles] ([UserId], [RoleId]) VALUES (@U6, @RoleEmp);
IF @U7 IS NOT NULL INSERT INTO [UserRoles] ([UserId], [RoleId]) VALUES (@U7, @RoleSysAdmin), (@U7, @RoleEmp);
IF @U12 IS NOT NULL INSERT INTO [UserRoles] ([UserId], [RoleId]) VALUES (@U12, @RoleCommAdmin), (@U12, @RoleEmp);

PRINT '=== [6/6] Ensuring Karma Balance Rows for All Users ===';
INSERT INTO [KarmaBalances] ([UserId], [TotalPoints], [BadgeLevel], [LastUpdated])
SELECT u.[UserId], 150, 'Bronze', GETUTCDATE()
FROM [Users] u
WHERE NOT EXISTS (SELECT 1 FROM [KarmaBalances] kb WHERE kb.[UserId] = u.[UserId]);
GO

PRINT '=== Seed Verification Complete! ===';
PRINT 'Test Credentials Available (Password: Password@123):';
PRINT '  Approved Users:';
PRINT '    MPO101 -> System Administrator, Employee (Loveneesh Sharma)';
PRINT '    MPO102 -> Community Admin, Employee (Vishendra Sharma)';
PRINT '    MPO103 -> HR Administrator, Employee (Sourabh Sahu)';
PRINT '    MPO104 -> Employee (Rishikesh Ugle)';
PRINT '    MPO105 -> Employee (Meghna Tiwari)';
PRINT '    MPO106 -> Employee (Mayur Verma)';
PRINT '    MPO107 -> System Administrator, Employee (Vilash Deshmukh)';
PRINT '    MPO112 -> Community Admin, Employee (Rajesh Kumar)';
PRINT '  Pending Role Users (Awaiting System Admin Assignment):';
PRINT '    MPO108 -> Pending (Pooja Sharma)';
GO
