-- =========================================================================================
-- Project: Employee Hub (Central Identity & HRMS Service)
-- Architecture: 6-Layer Enterprise Clean Architecture
-- Database: Microsoft SQL Server (EmployeeHubDb)
-- Purpose: Complete Database Schema, Foreign Keys, Indexes, Audit & SSO Tables, and Seed Data
-- =========================================================================================

-- 1. CREATE DATABASE
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'EmployeeHubDb')
BEGIN
    CREATE DATABASE [EmployeeHubDb];
    PRINT 'Database [EmployeeHubDb] created successfully.';
END
GO

USE [EmployeeHubDb];
GO

-- =========================================================================================
-- 2. SCHEMA DEFINITIONS & TABLES
-- =========================================================================================

-- 2.1 Departments Table
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Departments')
BEGIN
    CREATE TABLE [dbo].[Departments] (
        [DepartmentId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Code] VARCHAR(20) NOT NULL UNIQUE,
        [Name] NVARCHAR(100) NOT NULL,
        [Description] NVARCHAR(255) NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT 'Table [Departments] created.';
END
GO

-- 2.2 Designations Table
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Designations')
BEGIN
    CREATE TABLE [dbo].[Designations] (
        [DesignationId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Title] NVARCHAR(100) NOT NULL UNIQUE,
        [GradeLevel] VARCHAR(20) NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT 'Table [Designations] created.';
END
GO

-- 2.3 Roles Table (RBAC)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Roles')
BEGIN
    CREATE TABLE [dbo].[Roles] (
        [RoleId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [RoleCode] VARCHAR(30) NOT NULL UNIQUE, -- 'EMP', 'CADM', 'HRADM', 'SYSADM'
        [RoleName] NVARCHAR(50) NOT NULL UNIQUE, -- 'Employee', 'Community Admin', 'HR Administrator', 'System Administrator'
        [Description] NVARCHAR(255) NULL,
        [IsSystemRole] BIT NOT NULL DEFAULT 1
    );
    PRINT 'Table [Roles] created.';
END
GO

-- 2.4 Employees Table (Central Employee Profile)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Employees')
BEGIN
    CREATE TABLE [dbo].[Employees] (
        [EmployeeId] VARCHAR(50) NOT NULL PRIMARY KEY, -- e.g. 'MPO101'
        [FullName] NVARCHAR(150) NOT NULL,
        [Email] VARCHAR(150) NOT NULL UNIQUE,
        [PhoneNumber] VARCHAR(20) NULL,
        [DepartmentId] INT NOT NULL,
        [Designation] NVARCHAR(100) NOT NULL,
        [Location] NVARCHAR(100) NOT NULL DEFAULT 'Bhopal HQ',
        [ReportingManagerId] VARCHAR(50) NULL,
        [ProfilePhotoUrl] NVARCHAR(500) NULL,
        [Bio] NVARCHAR(MAX) NULL,
        [Skills] NVARCHAR(MAX) NULL, -- Stored as JSON: ["C#", ".NET Core", "React"]
        [Interests] NVARCHAR(MAX) NULL, -- Stored as JSON: ["Tech", "Leadership"]
        [JoiningDate] DATE NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
        [IsActive] BIT NOT NULL DEFAULT 1,
        [IsPermanentlySuspended] BIT NOT NULL DEFAULT 0,
        [SuspendedUntil] DATETIME2(7) NULL,
        [SuspensionReason] NVARCHAR(500) NULL,
        [CreatedAt] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_Employees_Departments] FOREIGN KEY ([DepartmentId]) REFERENCES [dbo].[Departments]([DepartmentId]),
        CONSTRAINT [FK_Employees_ReportingManager] FOREIGN KEY ([ReportingManagerId]) REFERENCES [dbo].[Employees]([EmployeeId])
    );
    PRINT 'Table [Employees] created.';
END
GO

-- 2.5 User Credentials Table (Authentication)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'UserCredentials')
BEGIN
    CREATE TABLE [dbo].[UserCredentials] (
        [EmployeeId] VARCHAR(50) NOT NULL PRIMARY KEY,
        [PasswordHash] NVARCHAR(500) NOT NULL, -- BCrypt Hash
        [PasswordSalt] NVARCHAR(255) NULL,
        [LastLoginAt] DATETIME2(7) NULL,
        [FailedLoginAttempts] INT NOT NULL DEFAULT 0,
        [IsLocked] BIT NOT NULL DEFAULT 0,
        [LockoutEnd] DATETIME2(7) NULL,
        [MustChangePassword] BIT NOT NULL DEFAULT 0,
        [PasswordChangedAt] DATETIME2(7) NULL,
        [CreatedAt] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_UserCredentials_Employees] FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees]([EmployeeId]) ON DELETE CASCADE
    );
    PRINT 'Table [UserCredentials] created.';
END
GO

-- 2.6 Employee Roles Mapping (Many-to-Many)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'EmployeeRoles')
BEGIN
    CREATE TABLE [dbo].[EmployeeRoles] (
        [EmployeeId] VARCHAR(50) NOT NULL,
        [RoleId] INT NOT NULL,
        [AssignedAt] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [AssignedBy] VARCHAR(50) NULL,
        PRIMARY KEY ([EmployeeId], [RoleId]),
        CONSTRAINT [FK_EmployeeRoles_Employees] FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees]([EmployeeId]) ON DELETE CASCADE,
        CONSTRAINT [FK_EmployeeRoles_Roles] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Roles]([RoleId]) ON DELETE CASCADE
    );
    PRINT 'Table [EmployeeRoles] created.';
END
GO

-- 2.7 Refresh Tokens (JWT Session Management)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RefreshTokens')
BEGIN
    CREATE TABLE [dbo].[RefreshTokens] (
        [TokenId] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [EmployeeId] VARCHAR(50) NOT NULL,
        [Token] NVARCHAR(500) NOT NULL UNIQUE,
        [JwtId] NVARCHAR(100) NOT NULL, -- JTI Claim
        [IsUsed] BIT NOT NULL DEFAULT 0,
        [IsRevoked] BIT NOT NULL DEFAULT 0,
        [ExpiresAt] DATETIME2(7) NOT NULL,
        [CreatedAt] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [CreatedByIp] VARCHAR(50) NULL,
        [RevokedAt] DATETIME2(7) NULL,
        [RevokedByIp] VARCHAR(50) NULL,
        CONSTRAINT [FK_RefreshTokens_Employees] FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees]([EmployeeId]) ON DELETE CASCADE
    );
    PRINT 'Table [RefreshTokens] created.';
END
GO

-- 2.8 Registered SSO Client Applications (e.g. Knome Platform)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SsoClientApps')
BEGIN
    CREATE TABLE [dbo].[SsoClientApps] (
        [ClientId] VARCHAR(50) NOT NULL PRIMARY KEY, -- 'knome-web-portal'
        [ClientName] NVARCHAR(100) NOT NULL, -- 'Knome Knowledge Platform'
        [ClientSecretHash] NVARCHAR(500) NOT NULL,
        [RedirectUri] NVARCHAR(500) NOT NULL, -- 'http://localhost:5173/sso-callback'
        [AllowedOrigins] NVARCHAR(1000) NOT NULL, -- 'http://localhost:5173,http://localhost:3000'
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT 'Table [SsoClientApps] created.';
END
GO

-- 2.9 SSO Authorization Codes / Single-Use Handshake Tickets
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SsoAuthCodes')
BEGIN
    CREATE TABLE [dbo].[SsoAuthCodes] (
        [CodeId] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [AuthCode] NVARCHAR(255) NOT NULL UNIQUE,
        [ClientId] VARCHAR(50) NOT NULL,
        [EmployeeId] VARCHAR(50) NOT NULL,
        [CodeChallenge] NVARCHAR(255) NULL, -- PKCE support
        [CodeChallengeMethod] VARCHAR(10) NULL,
        [RedirectUri] NVARCHAR(500) NOT NULL,
        [Scope] NVARCHAR(200) NOT NULL DEFAULT 'openid profile email roles',
        [IsUsed] BIT NOT NULL DEFAULT 0,
        [ExpiresAt] DATETIME2(7) NOT NULL,
        [CreatedAt] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_SsoAuthCodes_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[SsoClientApps]([ClientId]),
        CONSTRAINT [FK_SsoAuthCodes_Employee] FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees]([EmployeeId])
    );
    PRINT 'Table [SsoAuthCodes] created.';
END
GO

-- 2.10 Audit Logs Table
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AuditLogs')
BEGIN
    CREATE TABLE [dbo].[AuditLogs] (
        [LogId] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [EmployeeId] VARCHAR(50) NULL,
        [Action] NVARCHAR(100) NOT NULL, -- 'LOGIN_SUCCESS', 'PASSWORD_RESET', 'ROLE_CHANGED', 'SSO_AUTHORIZED'
        [EntityName] NVARCHAR(100) NULL,
        [EntityId] VARCHAR(100) NULL,
        [Details] NVARCHAR(MAX) NULL,
        [IpAddress] VARCHAR(50) NULL,
        [UserAgent] NVARCHAR(500) NULL,
        [Timestamp] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_AuditLogs_Employees] FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employees]([EmployeeId]) ON DELETE SET NULL
    );
    PRINT 'Table [AuditLogs] created.';
END
GO

-- =========================================================================================
-- 3. PERFORMANCE INDEXES
-- =========================================================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Employees_Email' AND object_id = OBJECT_ID('Employees'))
    CREATE INDEX [IX_Employees_Email] ON [dbo].[Employees] ([Email]);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Employees_DepartmentId' AND object_id = OBJECT_ID('Employees'))
    CREATE INDEX [IX_Employees_DepartmentId] ON [dbo].[Employees] ([DepartmentId]);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Employees_IsActive' AND object_id = OBJECT_ID('Employees'))
    CREATE INDEX [IX_Employees_IsActive] ON [dbo].[Employees] ([IsActive]);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RefreshTokens_Token' AND object_id = OBJECT_ID('RefreshTokens'))
    CREATE INDEX [IX_RefreshTokens_Token] ON [dbo].[RefreshTokens] ([Token]);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RefreshTokens_EmployeeId' AND object_id = OBJECT_ID('RefreshTokens'))
    CREATE INDEX [IX_RefreshTokens_EmployeeId] ON [dbo].[RefreshTokens] ([EmployeeId]);
GO

-- =========================================================================================
-- 4. SEED DATA (Idempotent: Safe to re-run)
-- =========================================================================================

PRINT '=== [1/5] Seeding Departments ===';
IF NOT EXISTS (SELECT 1 FROM [Departments] WHERE [Code] = 'IT_OPS')
    INSERT INTO [Departments] ([Code], [Name], [Description]) VALUES ('IT_OPS', 'IT Operations', 'Information Technology and Infrastructure Support');

IF NOT EXISTS (SELECT 1 FROM [Departments] WHERE [Code] = 'HR')
    INSERT INTO [Departments] ([Code], [Name], [Description]) VALUES ('HR', 'Human Resources', 'Talent Acquisition, People Operations and Welfare');

IF NOT EXISTS (SELECT 1 FROM [Departments] WHERE [Code] = 'ENGG')
    INSERT INTO [Departments] ([Code], [Name], [Description]) VALUES ('ENGG', 'Engineering', 'Core Software Development and Platform Architecture');

IF NOT EXISTS (SELECT 1 FROM [Departments] WHERE [Code] = 'DESIGN')
    INSERT INTO [Departments] ([Code], [Name], [Description]) VALUES ('DESIGN', 'Product Design', 'UI/UX Design, Product Architecture and Research');

IF NOT EXISTS (SELECT 1 FROM [Departments] WHERE [Code] = 'EXP')
    INSERT INTO [Departments] ([Code], [Name], [Description]) VALUES ('EXP', 'Employee Experience', 'Community Engagement, Internal Culture and Knowledge');
GO

PRINT '=== [2/5] Seeding System Roles ===';
IF NOT EXISTS (SELECT 1 FROM [Roles] WHERE [RoleCode] = 'SYSADM')
    INSERT INTO [Roles] ([RoleCode], [RoleName], [Description]) VALUES ('SYSADM', 'System Administrator', 'Full platform governance, security, and audit control');

IF NOT EXISTS (SELECT 1 FROM [Roles] WHERE [RoleCode] = 'HRADM')
    INSERT INTO [Roles] ([RoleCode], [RoleName], [Description]) VALUES ('HRADM', 'HR Administrator', 'Manages departments, roles, employee lifecycle and jobs');

IF NOT EXISTS (SELECT 1 FROM [Roles] WHERE [RoleCode] = 'CADM')
    INSERT INTO [Roles] ([RoleCode], [RoleName], [Description]) VALUES ('CADM', 'Community Admin', 'Oversees communities, moderation and member access');

IF NOT EXISTS (SELECT 1 FROM [Roles] WHERE [RoleCode] = 'EMP')
    INSERT INTO [Roles] ([RoleCode], [RoleName], [Description]) VALUES ('EMP', 'Employee', 'Standard employee self-service and content publishing access');
GO

PRINT '=== [3/5] Seeding Knome SSO Client App ===';
IF NOT EXISTS (SELECT 1 FROM [SsoClientApps] WHERE [ClientId] = 'knome-web-portal')
BEGIN
    INSERT INTO [SsoClientApps] ([ClientId], [ClientName], [ClientSecretHash], [RedirectUri], [AllowedOrigins], [IsActive])
    VALUES (
        'knome-web-portal',
        'Knome Enterprise Knowledge Platform',
        'SECRET_KNOME_2026_HASHED',
        'http://localhost:5173/sso-callback',
        'http://localhost:5173,http://127.0.0.1:5173,http://localhost:3000,http://localhost:5095',
        1
    );
END
GO

PRINT '=== [4/5] Seeding Employees & Credentials (Password: Password@123) ===';
-- BCrypt Hash for 'Password@123' (work factor 11):
DECLARE @BcryptHash NVARCHAR(255) = '$2a$11$CS8Szl.LS4r1zinkLjKb8ucRdww25eHjSGhqc6my/hQXCbb9DW0Nm';
DECLARE @Salt NVARCHAR(255) = 'STATIC_SALT_BCRYPT';

DECLARE @DeptItOps INT = (SELECT TOP 1 [DepartmentId] FROM [Departments] WHERE [Code] = 'IT_OPS');
DECLARE @DeptHr INT = (SELECT TOP 1 [DepartmentId] FROM [Departments] WHERE [Code] = 'HR');
DECLARE @DeptDesign INT = (SELECT TOP 1 [DepartmentId] FROM [Departments] WHERE [Code] = 'DESIGN');
DECLARE @DeptEngg INT = (SELECT TOP 1 [DepartmentId] FROM [Departments] WHERE [Code] = 'ENGG');
DECLARE @DeptExp INT = (SELECT TOP 1 [DepartmentId] FROM [Departments] WHERE [Code] = 'EXP');

-- 4.1 MPO101 - Loveneesh Sharma (System Administrator)
IF NOT EXISTS (SELECT 1 FROM [Employees] WHERE [EmployeeId] = 'MPO101')
    INSERT INTO [Employees] ([EmployeeId], [FullName], [Email], [DepartmentId], [Designation], [Location], [ProfilePhotoUrl], [Bio], [Skills], [Interests])
    VALUES ('MPO101', 'Loveneesh Sharma', 'loveneesh@mponline.gov.in', @DeptItOps, 'IT Operations Manager', 'Bhopal HQ', 'https://randomuser.me/api/portraits/men/40.jpg', 'Managing IT infrastructure and enterprise security.', '["Azure", "Kubernetes", "Cybersecurity"]', '["Tech", "DevOps"]');

IF NOT EXISTS (SELECT 1 FROM [UserCredentials] WHERE [EmployeeId] = 'MPO101')
    INSERT INTO [UserCredentials] ([EmployeeId], [PasswordHash], [PasswordSalt]) VALUES ('MPO101', @BcryptHash, @Salt);

-- 4.2 MPO102 - Vishendra Sharma (Community Admin)
IF NOT EXISTS (SELECT 1 FROM [Employees] WHERE [EmployeeId] = 'MPO102')
    INSERT INTO [Employees] ([EmployeeId], [FullName], [Email], [DepartmentId], [Designation], [Location], [ProfilePhotoUrl], [Bio], [Skills], [Interests])
    VALUES ('MPO102', 'Vishendra Sharma', 'vishendra@mponline.gov.in', @DeptExp, 'Community Experience Specialist', 'Bhopal HQ', 'https://randomuser.me/api/portraits/men/11.jpg', 'Building engaging knowledge sharing communities.', '["Community Management", "Communication"]', '["Culture", "Podcasts"]');

IF NOT EXISTS (SELECT 1 FROM [UserCredentials] WHERE [EmployeeId] = 'MPO102')
    INSERT INTO [UserCredentials] ([EmployeeId], [PasswordHash], [PasswordSalt]) VALUES ('MPO102', @BcryptHash, @Salt);

-- 4.3 MPO103 - Sourabh Sahu (HR Administrator)
IF NOT EXISTS (SELECT 1 FROM [Employees] WHERE [EmployeeId] = 'MPO103')
    INSERT INTO [Employees] ([EmployeeId], [FullName], [Email], [DepartmentId], [Designation], [Location], [ProfilePhotoUrl], [Bio], [Skills], [Interests])
    VALUES ('MPO103', 'Sourabh Sahu', 'sourabh.sahu@mponline.gov.in', @DeptHr, 'Talent Acquisition Manager', 'Bhopal HQ', 'https://randomuser.me/api/portraits/men/22.jpg', 'Leading people operations, recruitment, and organizational development.', '["Talent Sourcing", "HR Strategy", "Employee Relations"]', '["Leadership", "Management"]');

IF NOT EXISTS (SELECT 1 FROM [UserCredentials] WHERE [EmployeeId] = 'MPO103')
    INSERT INTO [UserCredentials] ([EmployeeId], [PasswordHash], [PasswordSalt]) VALUES ('MPO103', @BcryptHash, @Salt);

-- 4.4 MPO104 - Rishikesh Ugle (Employee)
IF NOT EXISTS (SELECT 1 FROM [Employees] WHERE [EmployeeId] = 'MPO104')
    INSERT INTO [Employees] ([EmployeeId], [FullName], [Email], [DepartmentId], [Designation], [Location], [ProfilePhotoUrl], [Bio], [Skills], [Interests])
    VALUES ('MPO104', 'Rishikesh Ugle', 'rishikesh@mponline.gov.in', @DeptDesign, 'Software Engineer', 'Bhopal HQ', 'https://randomuser.me/api/portraits/men/33.jpg', 'Full-stack developer focused on microservices and UI architecture.', '["C#", "React", "SQL Server"]', '["Coding", "AI"]');

IF NOT EXISTS (SELECT 1 FROM [UserCredentials] WHERE [EmployeeId] = 'MPO104')
    INSERT INTO [UserCredentials] ([EmployeeId], [PasswordHash], [PasswordSalt]) VALUES ('MPO104', @BcryptHash, @Salt);

-- 4.5 MPO105 - Meghna Tiwari (Employee)
IF NOT EXISTS (SELECT 1 FROM [Employees] WHERE [EmployeeId] = 'MPO105')
    INSERT INTO [Employees] ([EmployeeId], [FullName], [Email], [DepartmentId], [Designation], [Location], [ProfilePhotoUrl], [Bio], [Skills], [Interests])
    VALUES ('MPO105', 'Meghna Tiwari', 'meghna@mponline.gov.in', @DeptDesign, 'Business Analyst', 'Bhopal HQ', 'https://randomuser.me/api/portraits/women/44.jpg', 'Bridging business requirements with high-performance software solutions.', '["Business Analysis", "Agile", "Product Management"]', '["Reading", "Design"]');

IF NOT EXISTS (SELECT 1 FROM [UserCredentials] WHERE [EmployeeId] = 'MPO105')
    INSERT INTO [UserCredentials] ([EmployeeId], [PasswordHash], [PasswordSalt]) VALUES ('MPO105', @BcryptHash, @Salt);

-- 4.6 MPO106 - Mayur Verma (Employee)
IF NOT EXISTS (SELECT 1 FROM [Employees] WHERE [EmployeeId] = 'MPO106')
    INSERT INTO [Employees] ([EmployeeId], [FullName], [Email], [DepartmentId], [Designation], [Location], [ProfilePhotoUrl], [Bio], [Skills], [Interests])
    VALUES ('MPO106', 'Mayur Verma', 'mayur@mponline.gov.in', @DeptEngg, 'UI Designer', 'Bhopal HQ', 'https://randomuser.me/api/portraits/men/55.jpg', 'Crafting pixel-perfect user interfaces and design systems.', '["Figma", "Tailwind CSS", "Design Systems"]', '["Art", "Music"]');

IF NOT EXISTS (SELECT 1 FROM [UserCredentials] WHERE [EmployeeId] = 'MPO106')
    INSERT INTO [UserCredentials] ([EmployeeId], [PasswordHash], [PasswordSalt]) VALUES ('MPO106', @BcryptHash, @Salt);
GO

PRINT '=== [5/5] Assigning Employee Roles ===';
DECLARE @RoleSysAdminId INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleCode] = 'SYSADM');
DECLARE @RoleHrAdminId INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleCode] = 'HRADM');
DECLARE @RoleCommAdminId INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleCode] = 'CADM');
DECLARE @RoleEmpId INT = (SELECT [RoleId] FROM [Roles] WHERE [RoleCode] = 'EMP');

-- All employees get standard 'EMP' role
IF NOT EXISTS (SELECT 1 FROM [EmployeeRoles] WHERE [EmployeeId] = 'MPO101' AND [RoleId] = @RoleEmpId) INSERT INTO [EmployeeRoles] ([EmployeeId], [RoleId]) VALUES ('MPO101', @RoleEmpId);
IF NOT EXISTS (SELECT 1 FROM [EmployeeRoles] WHERE [EmployeeId] = 'MPO102' AND [RoleId] = @RoleEmpId) INSERT INTO [EmployeeRoles] ([EmployeeId], [RoleId]) VALUES ('MPO102', @RoleEmpId);
IF NOT EXISTS (SELECT 1 FROM [EmployeeRoles] WHERE [EmployeeId] = 'MPO103' AND [RoleId] = @RoleEmpId) INSERT INTO [EmployeeRoles] ([EmployeeId], [RoleId]) VALUES ('MPO103', @RoleEmpId);
IF NOT EXISTS (SELECT 1 FROM [EmployeeRoles] WHERE [EmployeeId] = 'MPO104' AND [RoleId] = @RoleEmpId) INSERT INTO [EmployeeRoles] ([EmployeeId], [RoleId]) VALUES ('MPO104', @RoleEmpId);
IF NOT EXISTS (SELECT 1 FROM [EmployeeRoles] WHERE [EmployeeId] = 'MPO105' AND [RoleId] = @RoleEmpId) INSERT INTO [EmployeeRoles] ([EmployeeId], [RoleId]) VALUES ('MPO105', @RoleEmpId);
IF NOT EXISTS (SELECT 1 FROM [EmployeeRoles] WHERE [EmployeeId] = 'MPO106' AND [RoleId] = @RoleEmpId) INSERT INTO [EmployeeRoles] ([EmployeeId], [RoleId]) VALUES ('MPO106', @RoleEmpId);

-- Specific Elevated Roles
IF NOT EXISTS (SELECT 1 FROM [EmployeeRoles] WHERE [EmployeeId] = 'MPO101' AND [RoleId] = @RoleSysAdminId) INSERT INTO [EmployeeRoles] ([EmployeeId], [RoleId]) VALUES ('MPO101', @RoleSysAdminId);
IF NOT EXISTS (SELECT 1 FROM [EmployeeRoles] WHERE [EmployeeId] = 'MPO102' AND [RoleId] = @RoleCommAdminId) INSERT INTO [EmployeeRoles] ([EmployeeId], [RoleId]) VALUES ('MPO102', @RoleCommAdminId);
IF NOT EXISTS (SELECT 1 FROM [EmployeeRoles] WHERE [EmployeeId] = 'MPO103' AND [RoleId] = @RoleHrAdminId) INSERT INTO [EmployeeRoles] ([EmployeeId], [RoleId]) VALUES ('MPO103', @RoleHrAdminId);
GO

PRINT '=========================================================================================';
PRINT '  [SUCCESS] EmployeeHubDb Database, Schema & Seed Records Initialized Successfully!     ';
PRINT '  Credentials (All accounts):                                                           ';
PRINT '    Password: Password@123                                                              ';
PRINT '    Accounts: MPO101 (SysAdmin), MPO102 (CommAdmin), MPO103 (HRAdmin), MPO104-106 (Emp) ';
PRINT '=========================================================================================';
GO
