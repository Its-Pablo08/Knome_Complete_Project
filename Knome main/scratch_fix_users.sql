USE [Knome];

-- Delete EMP001 - EMP004
DELETE FROM [Users] WHERE [EmployeeId] IN ('EMP001', 'EMP002', 'EMP003', 'EMP004');

-- Ensure MPO users have credentials
DECLARE @Hash VARCHAR(255) = '$2a$11$CS8Szl.LS4r1zinkLjKb8ucRdww25eHjSGhqc6my/hQXCbb9DW0Nm';
DECLARE @Salt VARCHAR(255) = 'STATIC_SALT_FOR_BCRYPT';

INSERT INTO [UserCredentials] ([UserId], [PasswordHash], [PasswordSalt])
SELECT [UserId], @Hash, @Salt
FROM [Users]
WHERE [EmployeeId] LIKE 'MPO%'
  AND NOT EXISTS (SELECT 1 FROM [UserCredentials] WHERE [UserId] = [Users].[UserId]);

-- Assign roles based on the requested list
DECLARE @RoleEmp INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleName] = 'Employee');
DECLARE @RoleSysAdmin INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleName] = 'System Administrator');
DECLARE @RoleCommAdmin INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleName] = 'Community Administrator' OR [RoleName] = 'Community Admin');
DECLARE @RoleHrAdmin INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleName] = 'HR Administrator');

-- Add Employee role to all
INSERT INTO [UserRoles] ([UserId], [RoleId])
SELECT [UserId], @RoleEmp
FROM [Users] WHERE [EmployeeId] LIKE 'MPO%'
  AND NOT EXISTS (SELECT 1 FROM [UserRoles] ur WHERE ur.[UserId] = [Users].[UserId] AND ur.[RoleId] = @RoleEmp);

-- Add System Admin to MPO101
INSERT INTO [UserRoles] ([UserId], [RoleId])
SELECT [UserId], @RoleSysAdmin
FROM [Users] WHERE [EmployeeId] = 'MPO101'
  AND NOT EXISTS (SELECT 1 FROM [UserRoles] ur WHERE ur.[UserId] = [Users].[UserId] AND ur.[RoleId] = @RoleSysAdmin);

-- Add Community Admin to MPO102
INSERT INTO [UserRoles] ([UserId], [RoleId])
SELECT [UserId], @RoleCommAdmin
FROM [Users] WHERE [EmployeeId] = 'MPO102'
  AND NOT EXISTS (SELECT 1 FROM [UserRoles] ur WHERE ur.[UserId] = [Users].[UserId] AND ur.[RoleId] = @RoleCommAdmin);

-- Add HR Admin to MPO103
INSERT INTO [UserRoles] ([UserId], [RoleId])
SELECT [UserId], @RoleHrAdmin
FROM [Users] WHERE [EmployeeId] = 'MPO103'
  AND NOT EXISTS (SELECT 1 FROM [UserRoles] ur WHERE ur.[UserId] = [Users].[UserId] AND ur.[RoleId] = @RoleHrAdmin);
