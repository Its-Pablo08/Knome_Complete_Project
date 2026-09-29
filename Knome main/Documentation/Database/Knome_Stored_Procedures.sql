-- ====================================================================================================
-- KNOME ENTERPRISE PLATFORM - COMPLETE STORED PROCEDURE SUITE
-- ====================================================================================================
-- Database: Knome (MS SQL Server)
-- Purpose: Complete set of stored procedures covering all 16 platform modules and functional areas.
-- Architecture: Database-First, High-Performance, ACID-Compliant Transaction & Error Handling.
-- ====================================================================================================

USE [Knome];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- ####################################################################################################
-- MODULE 1: AUTHENTICATION & SECURITY
-- ####################################################################################################

-- ====================================================================================================
-- 1.1 sp_Auth_GetUserByCredentials
-- Retrieves user record, password hash, and roles by EmployeeId or Email for authentication.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Auth_GetUserByCredentials]
    @Identifier NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.UserId,
        u.EmployeeId,
        u.FullName,
        u.Email,
        u.Designation,
        u.DepartmentId,
        d.Name AS DepartmentName,
        u.Location,
        u.ProfilePhotoUrl,
        u.IsActive,
        u.SuspendedUntil,
        u.IsPermanentlySuspended,
        u.ProfileCompletion,
        u.LastLogin,
        uc.PasswordHash,
        uc.PasswordSalt
    FROM [dbo].[Users] u
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    LEFT JOIN [dbo].[UserCredentials] uc ON u.UserId = uc.UserId
    WHERE u.EmployeeId = @Identifier OR u.Email = @Identifier;

    -- Return assigned roles as secondary result set
    SELECT 
        r.RoleId,
        r.RoleCode,
        r.RoleName
    FROM [dbo].[UserRoles] ur
    INNER JOIN [dbo].[Roles] r ON ur.RoleId = r.RoleId
    INNER JOIN [dbo].[Users] u ON ur.UserId = u.UserId
    WHERE u.EmployeeId = @Identifier OR u.Email = @Identifier;
END;
GO

-- ====================================================================================================
-- 1.2 sp_Auth_UpdateLastLogin
-- Updates the LastLogin UTC timestamp for a user upon successful authentication.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Auth_UpdateLastLogin]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[Users]
    SET [LastLogin] = SYSUTCDATETIME()
    WHERE [UserId] = @UserId;
END;
GO

-- ====================================================================================================
-- 1.3 sp_Auth_ChangePassword
-- Atomically updates a user's password hash and records the update timestamp.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Auth_ChangePassword]
    @UserId INT,
    @NewPasswordHash VARCHAR(255),
    @NewPasswordSalt VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM [dbo].[UserCredentials] WHERE [UserId] = @UserId)
        BEGIN
            UPDATE [dbo].[UserCredentials]
            SET 
                [PasswordHash] = @NewPasswordHash,
                [PasswordSalt] = @NewPasswordSalt,
                [LastUpdated] = SYSUTCDATETIME()
            WHERE [UserId] = @UserId;
        END
        ELSE
        BEGIN
            INSERT INTO [dbo].[UserCredentials] ([UserId], [PasswordHash], [PasswordSalt], [LastUpdated])
            VALUES (@UserId, @NewPasswordHash, @NewPasswordSalt, SYSUTCDATETIME());
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ====================================================================================================
-- 1.4 sp_Auth_CheckUserActive
-- Validates if a user account is active, not permanently suspended, and not temporarily suspended.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Auth_CheckUserActive]
    @UserId INT,
    @IsValid BIT OUTPUT,
    @StatusMessage NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IsActive BIT;
    DECLARE @IsPermanentlySuspended BIT;
    DECLARE @SuspendedUntil DATETIME2(7);

    SELECT 
        @IsActive = [IsActive],
        @IsPermanentlySuspended = [IsPermanentlySuspended],
        @SuspendedUntil = [SuspendedUntil]
    FROM [dbo].[Users]
    WHERE [UserId] = @UserId;

    IF @IsActive IS NULL
    BEGIN
        SET @IsValid = 0;
        SET @StatusMessage = N'User does not exist.';
        RETURN;
    END;

    IF @IsActive = 0
    BEGIN
        SET @IsValid = 0;
        SET @StatusMessage = N'Account is deactivated.';
        RETURN;
    END;

    IF @IsPermanentlySuspended = 1
    BEGIN
        SET @IsValid = 0;
        SET @StatusMessage = N'Account is permanently suspended.';
        RETURN;
    END;

    IF @SuspendedUntil IS NOT NULL AND @SuspendedUntil > SYSUTCDATETIME()
    BEGIN
        SET @IsValid = 0;
        SET @StatusMessage = CONCAT(N'Account is suspended until ', CONVERT(NVARCHAR(30), @SuspendedUntil, 120));
        RETURN;
    END;

    SET @IsValid = 1;
    SET @StatusMessage = N'Account is active and in good standing.';
END;
GO


-- ####################################################################################################
-- MODULE 2: USER PROFILES, SKILLS & DIRECTORY
-- ####################################################################################################

-- ====================================================================================================
-- 2.1 sp_User_GetProfileById
-- Retrieves full profile including stats, department, manager, skills, and interests.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_User_GetProfileById]
    @UserId INT,
    @ViewerUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Base user record with counts and relationships
    SELECT 
        u.UserId,
        u.EmployeeId,
        u.FullName,
        u.Email,
        u.Designation,
        u.DepartmentId,
        d.Name AS DepartmentName,
        d.DepartmentCode,
        u.Location,
        u.ProfilePhotoUrl,
        u.Bio,
        u.BioVisibility,
        u.NetworkVisibility,
        u.PhotosVisibility,
        u.InterestsVisibility,
        u.IsActive,
        u.SuspendedUntil,
        u.IsPermanentlySuspended,
        u.CreatedDate,
        u.MobileNo,
        u.ManagerEmployeeId,
        m.FullName AS ManagerName,
        u.JoiningDate,
        u.ProfileCompletion,
        ISNULL(kb.TotalPoints, 0) AS KarmaPoints,
        ISNULL(kb.BadgeLevel, 'None') AS BadgeLevel,
        (SELECT COUNT(1) FROM [dbo].[Followers] WHERE [FollowingUserId] = u.UserId) AS FollowersCount,
        (SELECT COUNT(1) FROM [dbo].[Followers] WHERE [FollowerUserId] = u.UserId) AS FollowingCount,
        (SELECT COUNT(1) FROM [dbo].[ConnectionRequests] WHERE ([SenderId] = u.UserId OR [ReceiverId] = u.UserId) AND [Status] = 'Accepted') AS ConnectionsCount,
        (SELECT COUNT(1) FROM [dbo].[Posts] WHERE [AuthorUserId] = u.UserId AND [Status] = 'Published') AS PostsCount,
        (SELECT COUNT(1) FROM [dbo].[Articles] WHERE [AuthorUserId] = u.UserId AND [Status] = 'Published') AS ArticlesCount,
        (SELECT COUNT(1) FROM [dbo].[Videos] WHERE [UploaderUserId] = u.UserId) AS VideosCount,
        (SELECT COUNT(1) FROM [dbo].[Podcasts] WHERE [UploaderUserId] = u.UserId) AS PodcastsCount,
        -- Relationship to Viewer
        CASE 
            WHEN @ViewerUserId IS NULL OR @ViewerUserId = u.UserId THEN 'Self'
            WHEN EXISTS (SELECT 1 FROM [dbo].[Followers] WHERE [FollowerUserId] = @ViewerUserId AND [FollowingUserId] = u.UserId) THEN 'Following'
            ELSE 'NotFollowing'
        END AS ViewerFollowStatus,
        CASE 
            WHEN @ViewerUserId IS NULL OR @ViewerUserId = u.UserId THEN 'Self'
            WHEN EXISTS (SELECT 1 FROM [dbo].[ConnectionRequests] WHERE (([SenderId] = @ViewerUserId AND [ReceiverId] = u.UserId) OR ([SenderId] = u.UserId AND [ReceiverId] = @ViewerUserId)) AND [Status] = 'Accepted') THEN 'Connected'
            WHEN EXISTS (SELECT 1 FROM [dbo].[ConnectionRequests] WHERE [SenderId] = @ViewerUserId AND [ReceiverId] = u.UserId AND [Status] = 'Pending') THEN 'RequestSent'
            WHEN EXISTS (SELECT 1 FROM [dbo].[ConnectionRequests] WHERE [SenderId] = u.UserId AND [ReceiverId] = @ViewerUserId AND [Status] = 'Pending') THEN 'RequestReceived'
            ELSE 'NotConnected'
        END AS ViewerConnectionStatus
    FROM [dbo].[Users] u
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    LEFT JOIN [dbo].[Users] m ON u.ManagerEmployeeId = m.EmployeeId
    LEFT JOIN [dbo].[KarmaBalances] kb ON u.UserId = kb.UserId
    WHERE u.UserId = @UserId;

    -- Skills
    SELECT [Skill] FROM [dbo].[UserSkills] WHERE [UserId] = @UserId;

    -- Interests
    SELECT [Interest] FROM [dbo].[UserInterests] WHERE [UserId] = @UserId;

    -- Roles
    SELECT r.RoleId, r.RoleCode, r.RoleName 
    FROM [dbo].[UserRoles] ur
    INNER JOIN [dbo].[Roles] r ON ur.RoleId = r.RoleId
    WHERE ur.UserId = @UserId;
END;
GO

-- ====================================================================================================
-- 2.2 sp_User_GetProfileByEmployeeId
-- Retrieves profile by unique employee code.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_User_GetProfileByEmployeeId]
    @EmployeeId VARCHAR(30),
    @ViewerUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TargetUserId INT;
    SELECT @TargetUserId = [UserId] FROM [dbo].[Users] WHERE [EmployeeId] = @EmployeeId;

    IF @TargetUserId IS NOT NULL
    BEGIN
        EXEC [dbo].[sp_User_GetProfileById] @UserId = @TargetUserId, @ViewerUserId = @ViewerUserId;
    END;
END;
GO

-- ====================================================================================================
-- 2.3 sp_User_UpdateProfile
-- Updates editable user profile attributes and automatically recomputes ProfileCompletion percentage.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_User_UpdateProfile]
    @UserId INT,
    @Bio VARCHAR(1000) = NULL,
    @Location VARCHAR(100) = NULL,
    @MobileNo VARCHAR(20) = NULL,
    @BioVisibility VARCHAR(20) = 'Public',
    @NetworkVisibility VARCHAR(20) = 'Public',
    @PhotosVisibility VARCHAR(20) = 'Public',
    @InterestsVisibility VARCHAR(20) = 'Public',
    @ModifiedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [dbo].[Users]
        SET 
            [Bio] = @Bio,
            [Location] = @Location,
            [MobileNo] = @MobileNo,
            [BioVisibility] = @BioVisibility,
            [NetworkVisibility] = @NetworkVisibility,
            [PhotosVisibility] = @PhotosVisibility,
            [InterestsVisibility] = @InterestsVisibility,
            [ModifiedBy] = ISNULL(@ModifiedBy, @UserId),
            [ModifiedDate] = SYSUTCDATETIME()
        WHERE [UserId] = @UserId;

        -- Recompute ProfileCompletion (out of 100%)
        DECLARE @Score TINYINT = 20; -- Base (Name, Email, EmpId)
        
        SELECT 
            @Score = @Score 
                + CASE WHEN [ProfilePhotoUrl] IS NOT NULL AND LEN([ProfilePhotoUrl]) > 0 THEN 20 ELSE 0 END
                + CASE WHEN [Bio] IS NOT NULL AND LEN([Bio]) > 0 THEN 15 ELSE 0 END
                + CASE WHEN [Location] IS NOT NULL AND LEN([Location]) > 0 THEN 10 ELSE 0 END
                + CASE WHEN [MobileNo] IS NOT NULL AND LEN([MobileNo]) > 0 THEN 10 ELSE 0 END
                + CASE WHEN EXISTS(SELECT 1 FROM [dbo].[UserSkills] WHERE [UserId] = @UserId) THEN 15 ELSE 0 END
                + CASE WHEN EXISTS(SELECT 1 FROM [dbo].[UserInterests] WHERE [UserId] = @UserId) THEN 10 ELSE 0 END
        FROM [dbo].[Users]
        WHERE [UserId] = @UserId;

        IF @Score > 100 SET @Score = 100;

        UPDATE [dbo].[Users]
        SET [ProfileCompletion] = @Score
        WHERE [UserId] = @UserId;

        COMMIT TRANSACTION;

        SELECT @Score AS ProfileCompletion;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ====================================================================================================
-- 2.4 sp_User_UpdateProfileImages
-- Updates user profile photo url and recalculates completion.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_User_UpdateProfileImages]
    @UserId INT,
    @ProfilePhotoUrl VARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[Users]
    SET 
        [ProfilePhotoUrl] = @ProfilePhotoUrl,
        [ModifiedDate] = SYSUTCDATETIME(),
        [ModifiedBy] = @UserId
    WHERE [UserId] = @UserId;

    -- Re-trigger completion calculation
    EXEC [dbo].[sp_User_UpdateProfile] @UserId = @UserId, @ModifiedBy = @UserId;
END;
GO

-- ====================================================================================================
-- 2.5 sp_User_AddSkill / sp_User_RemoveSkill / sp_User_GetUserSkills
-- Manages employee technical & functional skills.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_User_AddSkill]
    @UserId INT,
    @Skill NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Skill = LTRIM(RTRIM(@Skill));

    IF NOT EXISTS (SELECT 1 FROM [dbo].[UserSkills] WHERE [UserId] = @UserId AND [Skill] = @Skill)
    BEGIN
        INSERT INTO [dbo].[UserSkills] ([UserId], [Skill])
        VALUES (@UserId, @Skill);
    END;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_User_RemoveSkill]
    @UserId INT,
    @Skill NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM [dbo].[UserSkills]
    WHERE [UserId] = @UserId AND [Skill] = LTRIM(RTRIM(@Skill));
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_User_GetUserSkills]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [Skill] FROM [dbo].[UserSkills] WHERE [UserId] = @UserId ORDER BY [Skill] ASC;
END;
GO

-- ====================================================================================================
-- 2.6 sp_User_AddInterest / sp_User_RemoveInterest / sp_User_GetUserInterests
-- Manages employee professional & recreational interests.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_User_AddInterest]
    @UserId INT,
    @Interest NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Interest = LTRIM(RTRIM(@Interest));

    IF NOT EXISTS (SELECT 1 FROM [dbo].[UserInterests] WHERE [UserId] = @UserId AND [Interest] = @Interest)
    BEGIN
        INSERT INTO [dbo].[UserInterests] ([UserId], [Interest])
        VALUES (@UserId, @Interest);
    END;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_User_RemoveInterest]
    @UserId INT,
    @Interest NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM [dbo].[UserInterests]
    WHERE [UserId] = @UserId AND [Interest] = LTRIM(RTRIM(@Interest));
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_User_GetUserInterests]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [Interest] FROM [dbo].[UserInterests] WHERE [UserId] = @UserId ORDER BY [Interest] ASC;
END;
GO

-- ====================================================================================================
-- 2.7 sp_User_GetDirectory
-- Paginated enterprise employee directory search with filtering by department, designation, and skills.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_User_GetDirectory]
    @SearchTerm NVARCHAR(100) = NULL,
    @DepartmentId INT = NULL,
    @Location VARCHAR(100) = NULL,
    @Skill NVARCHAR(100) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH FilteredUsers AS (
        SELECT 
            u.UserId,
            u.EmployeeId,
            u.FullName,
            u.Email,
            u.Designation,
            u.DepartmentId,
            d.Name AS DepartmentName,
            u.Location,
            u.ProfilePhotoUrl,
            u.IsActive,
            kb.TotalPoints AS KarmaPoints,
            kb.BadgeLevel
        FROM [dbo].[Users] u
        LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
        LEFT JOIN [dbo].[KarmaBalances] kb ON u.UserId = kb.UserId
        WHERE u.IsActive = 1
          AND u.IsPermanentlySuspended = 0
          AND (u.SuspendedUntil IS NULL OR u.SuspendedUntil <= SYSUTCDATETIME())
          AND (@DepartmentId IS NULL OR u.DepartmentId = @DepartmentId)
          AND (@Location IS NULL OR u.Location LIKE '%' + @Location + '%')
          AND (@SearchTerm IS NULL OR u.FullName LIKE '%' + @SearchTerm + '%' OR u.Email LIKE '%' + @SearchTerm + '%' OR u.Designation LIKE '%' + @SearchTerm + '%')
          AND (@Skill IS NULL OR EXISTS (SELECT 1 FROM [dbo].[UserSkills] us WHERE us.UserId = u.UserId AND us.Skill LIKE '%' + @Skill + '%'))
    )
    SELECT 
        *,
        (SELECT COUNT(1) FROM FilteredUsers) AS TotalCount
    FROM FilteredUsers
    ORDER BY FullName ASC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO


-- ####################################################################################################
-- MODULE 3: CONNECTIONS & NETWORK GRAPH
-- ####################################################################################################

-- ====================================================================================================
-- 3.1 sp_Connection_SendRequest
-- Sends or re-activates a connection request between two employees.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Connection_SendRequest]
    @SenderId INT,
    @ReceiverId INT,
    @RequestId INT OUTPUT,
    @StatusMessage NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @SenderId = @ReceiverId
    BEGIN
        SET @RequestId = 0;
        SET @StatusMessage = N'Cannot connect with yourself.';
        RETURN;
    END;

    -- Check if reciprocal or duplicate request exists
    DECLARE @ExistingId INT;
    DECLARE @ExistingStatus NVARCHAR(20);

    SELECT @ExistingId = [RequestId], @ExistingStatus = [Status]
    FROM [dbo].[ConnectionRequests]
    WHERE ([SenderId] = @SenderId AND [ReceiverId] = @ReceiverId)
       OR ([SenderId] = @ReceiverId AND [ReceiverId] = @SenderId);

    IF @ExistingId IS NOT NULL
    BEGIN
        IF @ExistingStatus = 'Accepted'
        BEGIN
            SET @RequestId = @ExistingId;
            SET @StatusMessage = N'Already connected.';
            RETURN;
        END;
        IF @ExistingStatus = 'Pending'
        BEGIN
            SET @RequestId = @ExistingId;
            SET @StatusMessage = N'A connection request is already pending.';
            RETURN;
        END;
        
        -- If previously Rejected/Withdrawn, re-open from this sender
        UPDATE [dbo].[ConnectionRequests]
        SET 
            [SenderId] = @SenderId,
            [ReceiverId] = @ReceiverId,
            [Status] = 'Pending',
            [UpdatedDate] = SYSUTCDATETIME()
        WHERE [RequestId] = @ExistingId;

        SET @RequestId = @ExistingId;
        SET @StatusMessage = N'Connection request resent.';
        RETURN;
    END;

    INSERT INTO [dbo].[ConnectionRequests] ([SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate])
    VALUES (@SenderId, @ReceiverId, 'Pending', SYSUTCDATETIME(), SYSUTCDATETIME());

    SET @RequestId = SCOPE_IDENTITY();
    SET @StatusMessage = N'Connection request sent successfully.';
END;
GO

-- ====================================================================================================
-- 3.2 sp_Connection_AcceptRequest
-- Accepts a pending connection request and establishes bilateral connection.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Connection_AcceptRequest]
    @RequestId INT,
    @ReceiverId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[ConnectionRequests]
    SET 
        [Status] = 'Accepted',
        [UpdatedDate] = SYSUTCDATETIME()
    WHERE [RequestId] = @RequestId 
      AND [ReceiverId] = @ReceiverId
      AND [Status] = 'Pending';

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ====================================================================================================
-- 3.3 sp_Connection_RejectRequest
-- Rejects a pending connection request.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Connection_RejectRequest]
    @RequestId INT,
    @ReceiverId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[ConnectionRequests]
    SET 
        [Status] = 'Rejected',
        [UpdatedDate] = SYSUTCDATETIME()
    WHERE [RequestId] = @RequestId 
      AND [ReceiverId] = @ReceiverId
      AND [Status] = 'Pending';

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ====================================================================================================
-- 3.4 sp_Connection_WithdrawRequest
-- Withdraws a sent pending connection request.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Connection_WithdrawRequest]
    @RequestId INT,
    @SenderId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [dbo].[ConnectionRequests]
    WHERE [RequestId] = @RequestId 
      AND [SenderId] = @SenderId
      AND [Status] = 'Pending';

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ====================================================================================================
-- 3.5 sp_Connection_RemoveConnection
-- Disconnects an established relationship between two employees.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Connection_RemoveConnection]
    @UserId1 INT,
    @UserId2 INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [dbo].[ConnectionRequests]
    WHERE (([SenderId] = @UserId1 AND [ReceiverId] = @UserId2) OR ([SenderId] = @UserId2 AND [ReceiverId] = @UserId1))
      AND [Status] = 'Accepted';

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ====================================================================================================
-- 3.6 sp_Connection_GetConnections
-- Retrieves paginated accepted connections for a user.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Connection_GetConnections]
    @UserId INT,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH UserConnections AS (
        SELECT 
            CASE WHEN cr.SenderId = @UserId THEN cr.ReceiverId ELSE cr.SenderId END AS ConnectedUserId,
            cr.UpdatedDate AS ConnectedSince
        FROM [dbo].[ConnectionRequests] cr
        WHERE (cr.SenderId = @UserId OR cr.ReceiverId = @UserId)
          AND cr.Status = 'Accepted'
    )
    SELECT 
        u.UserId,
        u.EmployeeId,
        u.FullName,
        u.Email,
        u.Designation,
        d.Name AS DepartmentName,
        u.Location,
        u.ProfilePhotoUrl,
        c.ConnectedSince,
        (SELECT COUNT(1) FROM UserConnections) AS TotalCount
    FROM UserConnections c
    INNER JOIN [dbo].[Users] u ON c.ConnectedUserId = u.UserId
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    ORDER BY u.FullName ASC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ====================================================================================================
-- 3.7 sp_Connection_GetPendingRequests
-- Retrieves incoming pending connection requests for a user.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Connection_GetPendingRequests]
    @ReceiverId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        cr.RequestId,
        cr.SenderId,
        u.EmployeeId,
        u.FullName,
        u.Email,
        u.Designation,
        d.Name AS DepartmentName,
        u.ProfilePhotoUrl,
        cr.CreatedDate AS RequestedDate
    FROM [dbo].[ConnectionRequests] cr
    INNER JOIN [dbo].[Users] u ON cr.SenderId = u.UserId
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    WHERE cr.ReceiverId = @ReceiverId AND cr.Status = 'Pending'
    ORDER BY cr.CreatedDate DESC;
END;
GO


-- ####################################################################################################
-- MODULE 4: FOLLOWERS & SOCIAL GRAPH
-- ####################################################################################################

-- ====================================================================================================
-- 4.1 sp_Follower_FollowUser
-- Follows a target user.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Follower_FollowUser]
    @FollowerUserId INT,
    @FollowingUserId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @FollowerUserId = @FollowingUserId RETURN;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Followers] WHERE [FollowerUserId] = @FollowerUserId AND [FollowingUserId] = @FollowingUserId)
    BEGIN
        INSERT INTO [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate])
        VALUES (@FollowerUserId, @FollowingUserId, SYSUTCDATETIME());
    END;
END;
GO

-- ====================================================================================================
-- 4.2 sp_Follower_UnfollowUser
-- Unfollows a user.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Follower_UnfollowUser]
    @FollowerUserId INT,
    @FollowingUserId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [dbo].[Followers]
    WHERE [FollowerUserId] = @FollowerUserId AND [FollowingUserId] = @FollowingUserId;
END;
GO

-- ====================================================================================================
-- 4.3 sp_Follower_GetFollowers
-- Retrieves paginated list of users following the target user.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Follower_GetFollowers]
    @UserId INT,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH UserFollowers AS (
        SELECT [FollowerUserId], [FollowedDate]
        FROM [dbo].[Followers]
        WHERE [FollowingUserId] = @UserId
    )
    SELECT 
        u.UserId,
        u.EmployeeId,
        u.FullName,
        u.Email,
        u.Designation,
        d.Name AS DepartmentName,
        u.ProfilePhotoUrl,
        f.FollowedDate,
        (SELECT COUNT(1) FROM UserFollowers) AS TotalCount
    FROM UserFollowers f
    INNER JOIN [dbo].[Users] u ON f.FollowerUserId = u.UserId
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    ORDER BY f.FollowedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ====================================================================================================
-- 4.4 sp_Follower_GetFollowing
-- Retrieves paginated list of users the target user is following.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Follower_GetFollowing]
    @UserId INT,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH UserFollowing AS (
        SELECT [FollowingUserId], [FollowedDate]
        FROM [dbo].[Followers]
        WHERE [FollowerUserId] = @UserId
    )
    SELECT 
        u.UserId,
        u.EmployeeId,
        u.FullName,
        u.Email,
        u.Designation,
        d.Name AS DepartmentName,
        u.ProfilePhotoUrl,
        f.FollowedDate,
        (SELECT COUNT(1) FROM UserFollowing) AS TotalCount
    FROM UserFollowing f
    INNER JOIN [dbo].[Users] u ON f.FollowingUserId = u.UserId
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    ORDER BY f.FollowedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO


-- ####################################################################################################
-- MODULE 5: POSTS ENGINE
-- ####################################################################################################

-- ====================================================================================================
-- 5.1 sp_Post_CreatePost
-- Creates a post and returns the generated PostId.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Post_CreatePost]
    @AuthorUserId INT,
    @ContentText NVARCHAR(400),
    @AudienceType VARCHAR(20) = 'Everyone',
    @Status VARCHAR(20) = 'Published',
    @ScheduledDate DATETIME2(7) = NULL,
    @PostId BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PublishedDate DATETIME2(7) = CASE WHEN @Status = 'Published' THEN SYSUTCDATETIME() ELSE NULL END;

    INSERT INTO [dbo].[Posts] (
        [AuthorUserId], [ContentText], [AudienceType], [Status], 
        [ScheduledDate], [PublishedDate], [CreatedDate]
    )
    VALUES (
        @AuthorUserId, @ContentText, @AudienceType, @Status,
        @ScheduledDate, @PublishedDate, SYSUTCDATETIME()
    );

    SET @PostId = SCOPE_IDENTITY();
END;
GO

-- ====================================================================================================
-- 5.2 sp_Post_AddAttachment / sp_Post_DeleteAttachment
-- Manages media/document attachments for a post.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Post_AddAttachment]
    @PostId BIGINT,
    @FileUrl NVARCHAR(400),
    @FileType VARCHAR(20),
    @AttachmentId BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[PostAttachments] ([PostId], [FileUrl], [FileType], [PublishedDate])
    VALUES (@PostId, @FileUrl, @FileType, SYSUTCDATETIME());

    SET @AttachmentId = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Post_DeleteAttachment]
    @AttachmentId BIGINT,
    @PostId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM [dbo].[PostAttachments]
    WHERE [AttachmentId] = @AttachmentId AND [PostId] = @PostId;
END;
GO

-- ====================================================================================================
-- 5.3 sp_Post_UpdatePost
-- Modifies post content and audience.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Post_UpdatePost]
    @PostId BIGINT,
    @AuthorUserId INT,
    @ContentText NVARCHAR(400),
    @AudienceType VARCHAR(20) = 'Everyone'
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[Posts]
    SET 
        [ContentText] = @ContentText,
        [AudienceType] = @AudienceType
    WHERE [PostId] = @PostId AND [AuthorUserId] = @AuthorUserId;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ====================================================================================================
-- 5.4 sp_Post_DeletePost
-- Deletes a post along with associated attachments, interactions, community bindings, and mentions.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Post_DeletePost]
    @PostId BIGINT,
    @AuthorUserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verify ownership or admin permission
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Posts] WHERE [PostId] = @PostId AND ([AuthorUserId] = @AuthorUserId OR @AuthorUserId = 0))
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SELECT 0 AS Success, 'Unauthorized or Post Not Found' AS Message;
            RETURN;
        END;

        -- Cascade child references
        DELETE FROM [dbo].[PostAttachments] WHERE [PostId] = @PostId;
        DELETE FROM [dbo].[PostMentions] WHERE [PostId] = @PostId;
        DELETE FROM [dbo].[PostAudienceCommunities] WHERE [PostId] = @PostId;
        DELETE FROM [dbo].[PostAudienceUsers] WHERE [PostId] = @PostId;
        DELETE FROM [dbo].[CommunityPosts] WHERE [PostId] = @PostId;
        DELETE FROM [dbo].[Comments] WHERE [ContentType] = 'Post' AND [ContentId] = @PostId;
        DELETE FROM [dbo].[Reactions] WHERE [ContentType] = 'Post' AND [ContentId] = @PostId;
        DELETE FROM [dbo].[Bookmarks] WHERE [ContentType] = 'Post' AND [ContentId] = @PostId;
        DELETE FROM [dbo].[Shares] WHERE [ContentType] = 'Post' AND [ContentId] = @PostId;
        DELETE FROM [dbo].[Posts] WHERE [PostId] = @PostId;

        COMMIT TRANSACTION;
        SELECT 1 AS Success, 'Post deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ====================================================================================================
-- 5.5 sp_Post_GetById
-- Retrieves single post with author metadata, reactions summary, and attachments.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Post_GetById]
    @PostId BIGINT,
    @ViewerUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Post core & metrics
    SELECT 
        p.PostId,
        p.AuthorUserId,
        u.FullName AS AuthorName,
        u.EmployeeId AS AuthorEmployeeId,
        u.Designation AS AuthorDesignation,
        d.Name AS AuthorDepartmentName,
        u.ProfilePhotoUrl AS AuthorProfilePhotoUrl,
        p.ContentText,
        p.AudienceType,
        p.Status,
        p.ScheduledDate,
        p.PublishedDate,
        p.CreatedDate,
        (SELECT COUNT(1) FROM [dbo].[Reactions] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId) AS ReactionsCount,
        (SELECT COUNT(1) FROM [dbo].[Comments] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId) AS CommentsCount,
        (SELECT COUNT(1) FROM [dbo].[Shares] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId) AS SharesCount,
        CASE 
            WHEN @ViewerUserId IS NOT NULL THEN (SELECT [ReactionType] FROM [dbo].[Reactions] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId AND [UserId] = @ViewerUserId)
            ELSE NULL
        END AS ViewerReaction,
        CASE 
            WHEN @ViewerUserId IS NOT NULL AND EXISTS(SELECT 1 FROM [dbo].[Bookmarks] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId AND [UserId] = @ViewerUserId) THEN 1
            ELSE 0
        END AS IsBookmarked
    FROM [dbo].[Posts] p
    INNER JOIN [dbo].[Users] u ON p.AuthorUserId = u.UserId
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    WHERE p.PostId = @PostId;

    -- Attachments
    SELECT [AttachmentId], [FileUrl], [FileType], [PublishedDate]
    FROM [dbo].[PostAttachments]
    WHERE [PostId] = @PostId;
END;
GO

-- ====================================================================================================
-- 5.6 sp_Post_GetUserPosts
-- Retrieves paginated list of posts authored by a user.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Post_GetUserPosts]
    @AuthorUserId INT,
    @ViewerUserId INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH UserPosts AS (
        SELECT 
            p.PostId,
            p.AuthorUserId,
            u.FullName AS AuthorName,
            u.EmployeeId AS AuthorEmployeeId,
            u.Designation AS AuthorDesignation,
            d.Name AS AuthorDepartmentName,
            u.ProfilePhotoUrl AS AuthorProfilePhotoUrl,
            p.ContentText,
            p.AudienceType,
            p.Status,
            p.PublishedDate,
            p.CreatedDate,
            (SELECT COUNT(1) FROM [dbo].[Reactions] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId) AS ReactionsCount,
            (SELECT COUNT(1) FROM [dbo].[Comments] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId) AS CommentsCount,
            (SELECT COUNT(1) FROM [dbo].[Shares] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId) AS SharesCount,
            CASE 
                WHEN @ViewerUserId IS NOT NULL THEN (SELECT [ReactionType] FROM [dbo].[Reactions] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId AND [UserId] = @ViewerUserId)
                ELSE NULL
            END AS ViewerReaction,
            CASE 
                WHEN @ViewerUserId IS NOT NULL AND EXISTS(SELECT 1 FROM [dbo].[Bookmarks] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId AND [UserId] = @ViewerUserId) THEN 1
                ELSE 0
            END AS IsBookmarked
        FROM [dbo].[Posts] p
        INNER JOIN [dbo].[Users] u ON p.AuthorUserId = u.UserId
        LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
        WHERE p.AuthorUserId = @AuthorUserId
          AND (p.Status = 'Published' OR p.AuthorUserId = @ViewerUserId)
    )
    SELECT 
        *,
        (SELECT COUNT(1) FROM UserPosts) AS TotalCount
    FROM UserPosts
    ORDER BY CreatedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO


-- ####################################################################################################
-- MODULE 6: ARTICLES ENGINE (LONG-FORM PUBLISHING)
-- ####################################################################################################

-- ====================================================================================================
-- 6.1 sp_Article_CreateArticle
-- Creates draft or published article.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Article_CreateArticle]
    @AuthorUserId INT,
    @Title NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @ContentHtml NVARCHAR(MAX),
    @CategoryId INT,
    @Status VARCHAR(20) = 'Draft',
    @ScheduledDate DATETIME2(7) = NULL,
    @ArticleId BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PublishedDate DATETIME2(7) = CASE WHEN @Status = 'Published' THEN SYSUTCDATETIME() ELSE NULL END;

    INSERT INTO [dbo].[Articles] (
        [AuthorUserId], [Title], [Description], [ContentHtml],
        [CategoryId], [Status], [ScheduledDate], [PublishedDate],
        [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]
    )
    VALUES (
        @AuthorUserId, @Title, @Description, @ContentHtml,
        @CategoryId, @Status, @ScheduledDate, @PublishedDate,
        0, 0, 0, SYSUTCDATETIME()
    );

    SET @ArticleId = SCOPE_IDENTITY();
END;
GO

-- ====================================================================================================
-- 6.2 sp_Article_UpdateArticle
-- Updates article and optionally creates a snapshot version in ArticleVersions.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Article_UpdateArticle]
    @ArticleId BIGINT,
    @AuthorUserId INT,
    @Title NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @ContentHtml NVARCHAR(MAX),
    @CategoryId INT,
    @Status VARCHAR(20) = 'Published',
    @CreateVersionSnapshot BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Create snapshot if requested
        IF @CreateVersionSnapshot = 1
        BEGIN
            INSERT INTO [dbo].[ArticleVersions] ([ArticleId], [ContentHtml], [EditedByUserId], [EditedDate])
            SELECT [ArticleId], [ContentHtml], @AuthorUserId, SYSUTCDATETIME()
            FROM [dbo].[Articles]
            WHERE [ArticleId] = @ArticleId;
        END;

        UPDATE [dbo].[Articles]
        SET 
            [Title] = @Title,
            [Description] = @Description,
            [ContentHtml] = @ContentHtml,
            [CategoryId] = @CategoryId,
            [Status] = @Status,
            [PublishedDate] = CASE WHEN @Status = 'Published' AND [PublishedDate] IS NULL THEN SYSUTCDATETIME() ELSE [PublishedDate] END
        WHERE [ArticleId] = @ArticleId AND [AuthorUserId] = @AuthorUserId;

        COMMIT TRANSACTION;
        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ====================================================================================================
-- 6.3 sp_Article_DeleteArticle
-- Deletes article along with all child attachments, tags, versions, comments, and reactions.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Article_DeleteArticle]
    @ArticleId BIGINT,
    @AuthorUserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM [dbo].[Articles] WHERE [ArticleId] = @ArticleId AND ([AuthorUserId] = @AuthorUserId OR @AuthorUserId = 0))
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SELECT 0 AS Success, 'Unauthorized or Article Not Found' AS Message;
            RETURN;
        END;

        DELETE FROM [dbo].[ArticleAttachments] WHERE [ArticleId] = @ArticleId;
        DELETE FROM [dbo].[ArticleTags] WHERE [ArticleId] = @ArticleId;
        DELETE FROM [dbo].[ArticleVersions] WHERE [ArticleId] = @ArticleId;
        DELETE FROM [dbo].[Comments] WHERE [ContentType] = 'Article' AND [ContentId] = @ArticleId;
        DELETE FROM [dbo].[Reactions] WHERE [ContentType] = 'Article' AND [ContentId] = @ArticleId;
        DELETE FROM [dbo].[Bookmarks] WHERE [ContentType] = 'Article' AND [ContentId] = @ArticleId;
        DELETE FROM [dbo].[Shares] WHERE [ContentType] = 'Article' AND [ContentId] = @ArticleId;
        DELETE FROM [dbo].[Articles] WHERE [ArticleId] = @ArticleId;

        COMMIT TRANSACTION;
        SELECT 1 AS Success, 'Article deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ====================================================================================================
-- 6.4 sp_Article_GetById
-- Retrieves article details, author metadata, tags, attachments, and user engagement metrics.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Article_GetById]
    @ArticleId BIGINT,
    @ViewerUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        a.ArticleId,
        a.AuthorUserId,
        u.FullName AS AuthorName,
        u.EmployeeId AS AuthorEmployeeId,
        u.Designation AS AuthorDesignation,
        d.Name AS AuthorDepartmentName,
        u.ProfilePhotoUrl AS AuthorProfilePhotoUrl,
        a.Title,
        a.Description,
        a.ContentHtml,
        a.CategoryId,
        c.Name AS CategoryName,
        a.Status,
        a.ScheduledDate,
        a.PublishedDate,
        a.ViewCount,
        a.UniqueReadCount,
        a.AvgReadTimeSeconds,
        a.CreatedDate,
        (SELECT COUNT(1) FROM [dbo].[Reactions] WHERE [ContentType] = 'Article' AND [ContentId] = a.ArticleId) AS ReactionsCount,
        (SELECT COUNT(1) FROM [dbo].[Comments] WHERE [ContentType] = 'Article' AND [ContentId] = a.ArticleId) AS CommentsCount,
        (SELECT COUNT(1) FROM [dbo].[Shares] WHERE [ContentType] = 'Article' AND [ContentId] = a.ArticleId) AS SharesCount,
        CASE 
            WHEN @ViewerUserId IS NOT NULL THEN (SELECT [ReactionType] FROM [dbo].[Reactions] WHERE [ContentType] = 'Article' AND [ContentId] = a.ArticleId AND [UserId] = @ViewerUserId)
            ELSE NULL
        END AS ViewerReaction,
        CASE 
            WHEN @ViewerUserId IS NOT NULL AND EXISTS(SELECT 1 FROM [dbo].[Bookmarks] WHERE [ContentType] = 'Article' AND [ContentId] = a.ArticleId AND [UserId] = @ViewerUserId) THEN 1
            ELSE 0
        END AS IsBookmarked
    FROM [dbo].[Articles] a
    INNER JOIN [dbo].[Users] u ON a.AuthorUserId = u.UserId
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    LEFT JOIN [dbo].[Categories] c ON a.CategoryId = c.CategoryId
    WHERE a.ArticleId = @ArticleId;

    -- Tags
    SELECT [Tag] FROM [dbo].[ArticleTags] WHERE [ArticleId] = @ArticleId;

    -- Attachments
    SELECT [AttachmentId], [FileUrl], [FileType], [PublishedDate] 
    FROM [dbo].[ArticleAttachments] 
    WHERE [ArticleId] = @ArticleId;
END;
GO

-- ====================================================================================================
-- 6.5 sp_Article_AddTag / sp_Article_RemoveTag
-- Manages taxonomic tags on articles.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Article_AddTag]
    @ArticleId BIGINT,
    @Tag NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Tag = LTRIM(RTRIM(@Tag));

    IF NOT EXISTS (SELECT 1 FROM [dbo].[ArticleTags] WHERE [ArticleId] = @ArticleId AND [Tag] = @Tag)
    BEGIN
        INSERT INTO [dbo].[ArticleTags] ([ArticleId], [Tag])
        VALUES (@ArticleId, @Tag);
    END;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Article_RemoveTag]
    @ArticleId BIGINT,
    @Tag NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM [dbo].[ArticleTags]
    WHERE [ArticleId] = @ArticleId AND [Tag] = LTRIM(RTRIM(@Tag));
END;
GO

-- ====================================================================================================
-- 6.6 sp_Article_IncrementReadStats
-- Updates view counts, unique reads, and average reading time.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Article_IncrementReadStats]
    @ArticleId BIGINT,
    @IsUniqueRead BIT = 0,
    @ReadDurationSeconds INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[Articles]
    SET 
        [ViewCount] = [ViewCount] + 1,
        [UniqueReadCount] = [UniqueReadCount] + CASE WHEN @IsUniqueRead = 1 THEN 1 ELSE 0 END,
        [AvgReadTimeSeconds] = CASE 
            WHEN [ViewCount] = 0 THEN @ReadDurationSeconds 
            ELSE (([AvgReadTimeSeconds] * [ViewCount]) + @ReadDurationSeconds) / ([ViewCount] + 1) 
        END
    WHERE [ArticleId] = @ArticleId;
END;
GO


-- ####################################################################################################
-- MODULE 7: MEDIA CHANNELS (VIDEOS)
-- ####################################################################################################

-- ====================================================================================================
-- 7.1 sp_Video_CreateVideo
-- Inserts a new video resource.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Video_CreateVideo]
    @UploaderUserId INT,
    @Title NVARCHAR(200),
    @Description NVARCHAR(1000) = NULL,
    @CategoryId INT = NULL,
    @ThumbnailUrl NVARCHAR(400) = NULL,
    @SourceType VARCHAR(20),
    @SourceUrl NVARCHAR(400),
    @FileSizeMb INT = NULL,
    @VideoId BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Videos] (
        [UploaderUserId], [Title], [Description], [CategoryId],
        [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb],
        [ViewCount], [UploadedDate]
    )
    VALUES (
        @UploaderUserId, @Title, @Description, @CategoryId,
        @ThumbnailUrl, @SourceType, @SourceUrl, @FileSizeMb,
        0, SYSUTCDATETIME()
    );

    SET @VideoId = SCOPE_IDENTITY();
END;
GO

-- ====================================================================================================
-- 7.2 sp_Video_GetById
-- Retrieves video details with author info and tags.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Video_GetById]
    @VideoId BIGINT,
    @ViewerUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        v.VideoId,
        v.UploaderUserId,
        u.FullName AS UploaderName,
        u.EmployeeId AS UploaderEmployeeId,
        u.Designation AS UploaderDesignation,
        d.Name AS UploaderDepartmentName,
        u.ProfilePhotoUrl AS UploaderProfilePhotoUrl,
        v.Title,
        v.Description,
        v.CategoryId,
        c.Name AS CategoryName,
        v.ThumbnailUrl,
        v.SourceType,
        v.SourceUrl,
        v.FileSizeMb,
        v.ViewCount,
        v.UploadedDate,
        (SELECT COUNT(1) FROM [dbo].[Reactions] WHERE [ContentType] = 'Video' AND [ContentId] = v.VideoId) AS ReactionsCount,
        (SELECT COUNT(1) FROM [dbo].[Comments] WHERE [ContentType] = 'Video' AND [ContentId] = v.VideoId) AS CommentsCount,
        (SELECT COUNT(1) FROM [dbo].[Shares] WHERE [ContentType] = 'Video' AND [ContentId] = v.VideoId) AS SharesCount,
        CASE 
            WHEN @ViewerUserId IS NOT NULL THEN (SELECT [ReactionType] FROM [dbo].[Reactions] WHERE [ContentType] = 'Video' AND [ContentId] = v.VideoId AND [UserId] = @ViewerUserId)
            ELSE NULL
        END AS ViewerReaction,
        CASE 
            WHEN @ViewerUserId IS NOT NULL AND EXISTS(SELECT 1 FROM [dbo].[Bookmarks] WHERE [ContentType] = 'Video' AND [ContentId] = v.VideoId AND [UserId] = @ViewerUserId) THEN 1
            ELSE 0
        END AS IsBookmarked
    FROM [dbo].[Videos] v
    INNER JOIN [dbo].[Users] u ON v.UploaderUserId = u.UserId
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    LEFT JOIN [dbo].[Categories] c ON v.CategoryId = c.CategoryId
    WHERE v.VideoId = @VideoId;

    -- Tags
    SELECT [Tag] FROM [dbo].[VideoTags] WHERE [VideoId] = @VideoId;
END;
GO

-- ====================================================================================================
-- 7.3 sp_Video_IncrementViews
-- Increments video view counter.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Video_IncrementViews]
    @VideoId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[Videos]
    SET [ViewCount] = [ViewCount] + 1
    WHERE [VideoId] = @VideoId;
END;
GO

-- ====================================================================================================
-- 7.4 sp_Video_DeleteVideo
-- Deletes video, tags, comments, reactions, bookmarks.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Video_DeleteVideo]
    @VideoId BIGINT,
    @UploaderUserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM [dbo].[Videos] WHERE [VideoId] = @VideoId AND ([UploaderUserId] = @UploaderUserId OR @UploaderUserId = 0))
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SELECT 0 AS Success, 'Unauthorized or Video Not Found' AS Message;
            RETURN;
        END;

        DELETE FROM [dbo].[VideoTags] WHERE [VideoId] = @VideoId;
        DELETE FROM [dbo].[Comments] WHERE [ContentType] = 'Video' AND [ContentId] = @VideoId;
        DELETE FROM [dbo].[Reactions] WHERE [ContentType] = 'Video' AND [ContentId] = @VideoId;
        DELETE FROM [dbo].[Bookmarks] WHERE [ContentType] = 'Video' AND [ContentId] = @VideoId;
        DELETE FROM [dbo].[Shares] WHERE [ContentType] = 'Video' AND [ContentId] = @VideoId;
        DELETE FROM [dbo].[Videos] WHERE [VideoId] = @VideoId;

        COMMIT TRANSACTION;
        SELECT 1 AS Success, 'Video deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- ####################################################################################################
-- MODULE 8: MEDIA CHANNELS (PODCASTS & SERIES)
-- ####################################################################################################

-- ====================================================================================================
-- 8.1 sp_Podcast_CreateSeries / sp_Podcast_GetSeriesList
-- Manages podcast show series containers.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Podcast_CreateSeries]
    @Title NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @SeriesId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[PodcastSeries] ([Title], [Description])
    VALUES (@Title, @Description);
    SET @SeriesId = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Podcast_GetSeriesList]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ps.SeriesId,
        ps.Title,
        ps.Description,
        (SELECT COUNT(1) FROM [dbo].[Podcasts] p WHERE p.SeriesId = ps.SeriesId) AS EpisodeCount
    FROM [dbo].[PodcastSeries] ps
    ORDER BY ps.Title ASC;
END;
GO

-- ====================================================================================================
-- 8.2 sp_Podcast_CreateEpisode
-- Creates a new podcast audio episode.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Podcast_CreateEpisode]
    @UploaderUserId INT,
    @Title NVARCHAR(200),
    @Description NVARCHAR(1000) = NULL,
    @CoverImageUrl NVARCHAR(400) = NULL,
    @AudioUrl NVARCHAR(MAX),
    @DurationSeconds INT = NULL,
    @CategoryId INT = NULL,
    @SeriesId INT = NULL,
    @FileSizeMb INT = NULL,
    @PodcastId BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Podcasts] (
        [UploaderUserId], [Title], [Description], [CoverImageUrl],
        [AudioUrl], [DurationSeconds], [CategoryId], [SeriesId],
        [FileSizeMb], [UploadedDate]
    )
    VALUES (
        @UploaderUserId, @Title, @Description, @CoverImageUrl,
        @AudioUrl, @DurationSeconds, @CategoryId, @SeriesId,
        @FileSizeMb, SYSUTCDATETIME()
    );

    SET @PodcastId = SCOPE_IDENTITY();
END;
GO

-- ====================================================================================================
-- 8.3 sp_Podcast_GetEpisodeById
-- Retrieves full podcast episode details.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Podcast_GetEpisodeById]
    @PodcastId BIGINT,
    @ViewerUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.PodcastId,
        p.UploaderUserId,
        u.FullName AS UploaderName,
        u.EmployeeId AS UploaderEmployeeId,
        u.Designation AS UploaderDesignation,
        d.Name AS UploaderDepartmentName,
        u.ProfilePhotoUrl AS UploaderProfilePhotoUrl,
        p.Title,
        p.Description,
        p.CoverImageUrl,
        p.AudioUrl,
        p.DurationSeconds,
        p.CategoryId,
        c.Name AS CategoryName,
        p.SeriesId,
        ps.Title AS SeriesTitle,
        p.FileSizeMb,
        p.UploadedDate,
        (SELECT COUNT(1) FROM [dbo].[Reactions] WHERE [ContentType] = 'Podcast' AND [ContentId] = p.PodcastId) AS ReactionsCount,
        (SELECT COUNT(1) FROM [dbo].[Comments] WHERE [ContentType] = 'Podcast' AND [ContentId] = p.PodcastId) AS CommentsCount,
        (SELECT COUNT(1) FROM [dbo].[Shares] WHERE [ContentType] = 'Podcast' AND [ContentId] = p.PodcastId) AS SharesCount,
        CASE 
            WHEN @ViewerUserId IS NOT NULL THEN (SELECT [ReactionType] FROM [dbo].[Reactions] WHERE [ContentType] = 'Podcast' AND [ContentId] = p.PodcastId AND [UserId] = @ViewerUserId)
            ELSE NULL
        END AS ViewerReaction,
        CASE 
            WHEN @ViewerUserId IS NOT NULL AND EXISTS(SELECT 1 FROM [dbo].[Bookmarks] WHERE [ContentType] = 'Podcast' AND [ContentId] = p.PodcastId AND [UserId] = @ViewerUserId) THEN 1
            ELSE 0
        END AS IsBookmarked
    FROM [dbo].[Podcasts] p
    INNER JOIN [dbo].[Users] u ON p.UploaderUserId = u.UserId
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    LEFT JOIN [dbo].[Categories] c ON p.CategoryId = c.CategoryId
    LEFT JOIN [dbo].[PodcastSeries] ps ON p.SeriesId = ps.SeriesId
    WHERE p.PodcastId = @PodcastId;
END;
GO


-- ####################################################################################################
-- MODULE 9: INTERACTIONS ENGINE (REACTIONS, COMMENTS, BOOKMARKS, SHARES)
-- ####################################################################################################

-- ====================================================================================================
-- 9.1 sp_Interaction_ToggleReaction
-- Polymorphic reaction toggling (Like, Celebrate, Support, Insightful, etc.)
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Interaction_ToggleReaction]
    @ContentType VARCHAR(20),
    @ContentId BIGINT,
    @UserId INT,
    @ReactionType VARCHAR(20),
    @ResultAction VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentReaction VARCHAR(20);

    SELECT @CurrentReaction = [ReactionType]
    FROM [dbo].[Reactions]
    WHERE [ContentType] = @ContentType AND [ContentId] = @ContentId AND [UserId] = @UserId;

    IF @CurrentReaction IS NULL
    BEGIN
        INSERT INTO [dbo].[Reactions] ([ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate])
        VALUES (@ContentType, @ContentId, @UserId, @ReactionType, SYSUTCDATETIME());
        SET @ResultAction = 'Added';
    END
    ELSE IF @CurrentReaction = @ReactionType
    BEGIN
        DELETE FROM [dbo].[Reactions]
        WHERE [ContentType] = @ContentType AND [ContentId] = @ContentId AND [UserId] = @UserId;
        SET @ResultAction = 'Removed';
    END
    ELSE
    BEGIN
        UPDATE [dbo].[Reactions]
        SET [ReactionType] = @ReactionType, [CreatedDate] = SYSUTCDATETIME()
        WHERE [ContentType] = @ContentType AND [ContentId] = @ContentId AND [UserId] = @UserId;
        SET @ResultAction = 'Updated';
    END;
END;
GO

-- ====================================================================================================
-- 9.2 sp_Interaction_GetReactionsSummary
-- Returns reaction counts grouped by reaction type for any piece of content.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Interaction_GetReactionsSummary]
    @ContentType VARCHAR(20),
    @ContentId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        [ReactionType],
        COUNT(1) AS [Count]
    FROM [dbo].[Reactions]
    WHERE [ContentType] = @ContentType AND [ContentId] = @ContentId
    GROUP BY [ReactionType]
    ORDER BY [Count] DESC;
END;
GO

-- ====================================================================================================
-- 9.3 sp_Comment_AddComment
-- Inserts a root comment or threaded reply.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Comment_AddComment]
    @ContentType VARCHAR(20),
    @ContentId BIGINT,
    @UserId INT,
    @CommentText NVARCHAR(1000),
    @ParentCommentId BIGINT = NULL,
    @ImageUrl NVARCHAR(400) = NULL,
    @CommentId BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Comments] (
        [ContentType], [ContentId], [UserId], [ParentCommentId],
        [CommentText], [ImageUrl], [CreatedDate]
    )
    VALUES (
        @ContentType, @ContentId, @UserId, @ParentCommentId,
        @CommentText, @ImageUrl, SYSUTCDATETIME()
    );

    SET @CommentId = SCOPE_IDENTITY();
END;
GO

-- ====================================================================================================
-- 9.4 sp_Comment_GetComments
-- Retrieves paginated hierarchical comments for a content item.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Comment_GetComments]
    @ContentType VARCHAR(20),
    @ContentId BIGINT,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH CommentThread AS (
        SELECT 
            c.CommentId,
            c.ContentType,
            c.ContentId,
            c.UserId,
            u.FullName AS AuthorName,
            u.EmployeeId AS AuthorEmployeeId,
            u.ProfilePhotoUrl AS AuthorProfilePhotoUrl,
            u.Designation AS AuthorDesignation,
            c.ParentCommentId,
            c.CommentText,
            c.ImageUrl,
            c.CreatedDate,
            (SELECT COUNT(1) FROM [dbo].[Reactions] WHERE [ContentType] = 'Comment' AND [ContentId] = c.CommentId) AS ReactionsCount,
            (SELECT COUNT(1) FROM [dbo].[Comments] sub WHERE sub.ParentCommentId = c.CommentId) AS ReplyCount
        FROM [dbo].[Comments] c
        INNER JOIN [dbo].[Users] u ON c.UserId = u.UserId
        WHERE c.ContentType = @ContentType AND c.ContentId = @ContentId
    )
    SELECT 
        *,
        (SELECT COUNT(1) FROM CommentThread WHERE ParentCommentId IS NULL) AS TotalRootCount
    FROM CommentThread
    ORDER BY ISNULL(ParentCommentId, CommentId) ASC, CreatedDate ASC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ====================================================================================================
-- 9.5 sp_Comment_DeleteComment
-- Deletes a comment and its child replies.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Comment_DeleteComment]
    @CommentId BIGINT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verify ownership or admin permission
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Comments] WHERE [CommentId] = @CommentId AND ([UserId] = @UserId OR @UserId = 0))
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SELECT 0 AS Success, 'Unauthorized or Comment Not Found' AS Message;
            RETURN;
        END;

        -- Delete replies first
        DELETE FROM [dbo].[Comments] WHERE [ParentCommentId] = @CommentId;
        -- Delete comment itself
        DELETE FROM [dbo].[Comments] WHERE [CommentId] = @CommentId;

        COMMIT TRANSACTION;
        SELECT 1 AS Success, 'Comment deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ====================================================================================================
-- 9.6 sp_Bookmark_ToggleBookmark / sp_Bookmark_GetUserBookmarks
-- Manages saved content bookmarks.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Bookmark_ToggleBookmark]
    @UserId INT,
    @ContentType VARCHAR(20),
    @ContentId BIGINT,
    @IsBookmarked BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM [dbo].[Bookmarks] WHERE [UserId] = @UserId AND [ContentType] = @ContentType AND [ContentId] = @ContentId)
    BEGIN
        DELETE FROM [dbo].[Bookmarks]
        WHERE [UserId] = @UserId AND [ContentType] = @ContentType AND [ContentId] = @ContentId;
        SET @IsBookmarked = 0;
    END
    ELSE
    BEGIN
        INSERT INTO [dbo].[Bookmarks] ([UserId], [ContentType], [ContentId], [SavedDate])
        VALUES (@UserId, @ContentType, @ContentId, SYSUTCDATETIME());
        SET @IsBookmarked = 1;
    END;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Bookmark_GetUserBookmarks]
    @UserId INT,
    @ContentType VARCHAR(20) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH UserBookmarks AS (
        SELECT 
            b.UserId,
            b.ContentType,
            b.ContentId,
            b.SavedDate
        FROM [dbo].[Bookmarks] b
        WHERE b.UserId = @UserId
          AND (@ContentType IS NULL OR b.ContentType = @ContentType)
    )
    SELECT 
        *,
        (SELECT COUNT(1) FROM UserBookmarks) AS TotalCount
    FROM UserBookmarks
    ORDER BY SavedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ====================================================================================================
-- 9.7 sp_Share_RecordShare
-- Records a content reshare.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Share_RecordShare]
    @ContentType VARCHAR(20),
    @ContentId BIGINT,
    @UserId INT,
    @SharedToType VARCHAR(20) = 'Feed',
    @SharedToId BIGINT = NULL,
    @ShareId BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Shares] (
        [ContentType], [ContentId], [UserId],
        [SharedToType], [SharedToId], [CreatedDate]
    )
    VALUES (
        @ContentType, @ContentId, @UserId,
        @SharedToType, @SharedToId, SYSUTCDATETIME()
    );

    SET @ShareId = SCOPE_IDENTITY();
END;
GO


-- ####################################################################################################
-- MODULE 10: COMMUNITIES & GROUPS
-- ####################################################################################################

-- ====================================================================================================
-- 10.1 sp_Community_CreateCommunity
-- Creates a community and automatically grants creator Admin membership.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Community_CreateCommunity]
    @Name NVARCHAR(150),
    @Description NVARCHAR(1000) = NULL,
    @BannerUrl NVARCHAR(400) = NULL,
    @ThumbnailUrl NVARCHAR(400) = NULL,
    @CategoryId INT = NULL,
    @Rules NVARCHAR(MAX) = NULL,
    @Faq NVARCHAR(MAX) = NULL,
    @CommunityType VARCHAR(20) = 'Public',
    @CreatedByUserId INT,
    @CommunityId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[Communities] (
            [Name], [Description], [BannerUrl], [ThumbnailUrl],
            [CategoryId], [Rules], [Faq], [CommunityType],
            [CreatedByUserId], [CreatedDate]
        )
        VALUES (
            @Name, @Description, @BannerUrl, @ThumbnailUrl,
            @CategoryId, @Rules, @Faq, @CommunityType,
            @CreatedByUserId, SYSUTCDATETIME()
        );

        SET @CommunityId = SCOPE_IDENTITY();

        -- Creator is automatically Admin
        INSERT INTO [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate])
        VALUES (@CommunityId, @CreatedByUserId, 'Admin', 'Approved', SYSUTCDATETIME(), SYSUTCDATETIME());

        INSERT INTO [dbo].[CommunityAdmins] ([CommunityId], [UserId])
        VALUES (@CommunityId, @CreatedByUserId);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ====================================================================================================
-- 10.2 sp_Community_GetById
-- Retrieves community details, category, member counts, and viewer membership status.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Community_GetById]
    @CommunityId INT,
    @ViewerUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.CommunityId,
        c.Name,
        c.Description,
        c.BannerUrl,
        c.ThumbnailUrl,
        c.CategoryId,
        cat.Name AS CategoryName,
        c.Rules,
        c.Faq,
        c.CommunityType,
        c.CreatedByUserId,
        u.FullName AS CreatorName,
        c.CreatedDate,
        (SELECT COUNT(1) FROM [dbo].[CommunityMembers] WHERE [CommunityId] = c.CommunityId AND [Status] = 'Approved') AS MembersCount,
        (SELECT COUNT(1) FROM [dbo].[CommunityPosts] WHERE [CommunityId] = c.CommunityId) AS PostsCount,
        CASE 
            WHEN @ViewerUserId IS NOT NULL THEN (
                SELECT [Status] FROM [dbo].[CommunityMembers] WHERE [CommunityId] = c.CommunityId AND [UserId] = @ViewerUserId
            )
            ELSE NULL
        END AS ViewerMembershipStatus,
        CASE 
            WHEN @ViewerUserId IS NOT NULL THEN (
                SELECT [MemberType] FROM [dbo].[CommunityMembers] WHERE [CommunityId] = c.CommunityId AND [UserId] = @ViewerUserId
            )
            ELSE NULL
        END AS ViewerMemberType
    FROM [dbo].[Communities] c
    INNER JOIN [dbo].[Users] u ON c.CreatedByUserId = u.UserId
    LEFT JOIN [dbo].[Categories] cat ON c.CategoryId = cat.CategoryId
    WHERE c.CommunityId = @CommunityId;
END;
GO

-- ====================================================================================================
-- 10.3 sp_Community_Join / sp_Community_Leave
-- Handles user joining (instant if Public, Pending if Private) and leaving community.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Community_Join]
    @CommunityId INT,
    @UserId INT,
    @StatusMessage NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CommunityType VARCHAR(20);
    SELECT @CommunityType = [CommunityType] FROM [dbo].[Communities] WHERE [CommunityId] = @CommunityId;

    IF @CommunityType IS NULL
    BEGIN
        SET @StatusMessage = N'Community does not exist.';
        RETURN;
    END;

    DECLARE @InitialStatus VARCHAR(20) = CASE WHEN @CommunityType = 'Public' THEN 'Approved' ELSE 'Pending' END;
    DECLARE @DecidedDate DATETIME2(7) = CASE WHEN @CommunityType = 'Public' THEN SYSUTCDATETIME() ELSE NULL END;

    IF EXISTS (SELECT 1 FROM [dbo].[CommunityMembers] WHERE [CommunityId] = @CommunityId AND [UserId] = @UserId)
    BEGIN
        UPDATE [dbo].[CommunityMembers]
        SET [Status] = @InitialStatus, [RequestedDate] = SYSUTCDATETIME(), [DecidedDate] = @DecidedDate
        WHERE [CommunityId] = @CommunityId AND [UserId] = @UserId;
    END
    ELSE
    BEGIN
        INSERT INTO [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate])
        VALUES (@CommunityId, @UserId, 'Subscriber', @InitialStatus, SYSUTCDATETIME(), @DecidedDate);
    END;

    SET @StatusMessage = CASE WHEN @CommunityType = 'Public' THEN N'Joined community successfully.' ELSE N'Membership request submitted for approval.' END;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Community_Leave]
    @CommunityId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM [dbo].[CommunityAdmins] WHERE [CommunityId] = @CommunityId AND [UserId] = @UserId;
        DELETE FROM [dbo].[CommunityMembers] WHERE [CommunityId] = @CommunityId AND [UserId] = @UserId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ====================================================================================================
-- 10.4 sp_Community_ApproveMember / sp_Community_RejectMember
-- Approves or rejects pending membership requests by community admins.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Community_ApproveMember]
    @CommunityId INT,
    @UserId INT,
    @AdminUserId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CommunityAdmins] WHERE [CommunityId] = @CommunityId AND [UserId] = @AdminUserId)
    BEGIN
        SELECT 0 AS Success, 'Only community admins can approve members' AS Message;
        RETURN;
    END;

    UPDATE [dbo].[CommunityMembers]
    SET [Status] = 'Approved', [DecidedDate] = SYSUTCDATETIME()
    WHERE [CommunityId] = @CommunityId AND [UserId] = @UserId;

    SELECT 1 AS Success, 'Member approved' AS Message;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Community_RejectMember]
    @CommunityId INT,
    @UserId INT,
    @AdminUserId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CommunityAdmins] WHERE [CommunityId] = @CommunityId AND [UserId] = @AdminUserId)
    BEGIN
        SELECT 0 AS Success, 'Only community admins can reject members' AS Message;
        RETURN;
    END;

    UPDATE [dbo].[CommunityMembers]
    SET [Status] = 'Rejected', [DecidedDate] = SYSUTCDATETIME()
    WHERE [CommunityId] = @CommunityId AND [UserId] = @UserId;

    SELECT 1 AS Success, 'Member rejected' AS Message;
END;
GO

-- ====================================================================================================
-- 10.5 sp_Community_AddPost / sp_Community_GetFeed
-- Links post to a community and queries community feed.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Community_AddPost]
    @CommunityId INT,
    @PostId BIGINT,
    @IsPinned BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[CommunityPosts] WHERE [CommunityId] = @CommunityId AND [PostId] = @PostId)
    BEGIN
        INSERT INTO [dbo].[CommunityPosts] ([CommunityId], [PostId], [IsPinned])
        VALUES (@CommunityId, @PostId, @IsPinned);
    END;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Community_GetFeed]
    @CommunityId INT,
    @ViewerUserId INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH CommPosts AS (
        SELECT 
            cp.IsPinned,
            p.PostId,
            p.AuthorUserId,
            u.FullName AS AuthorName,
            u.EmployeeId AS AuthorEmployeeId,
            u.Designation AS AuthorDesignation,
            u.ProfilePhotoUrl AS AuthorProfilePhotoUrl,
            p.ContentText,
            p.PublishedDate,
            p.CreatedDate,
            (SELECT COUNT(1) FROM [dbo].[Reactions] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId) AS ReactionsCount,
            (SELECT COUNT(1) FROM [dbo].[Comments] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId) AS CommentsCount,
            (SELECT COUNT(1) FROM [dbo].[Shares] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId) AS SharesCount,
            CASE 
                WHEN @ViewerUserId IS NOT NULL THEN (SELECT [ReactionType] FROM [dbo].[Reactions] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId AND [UserId] = @ViewerUserId)
                ELSE NULL
            END AS ViewerReaction
        FROM [dbo].[CommunityPosts] cp
        INNER JOIN [dbo].[Posts] p ON cp.PostId = p.PostId
        INNER JOIN [dbo].[Users] u ON p.AuthorUserId = u.UserId
        WHERE cp.CommunityId = @CommunityId AND p.Status = 'Published'
    )
    SELECT 
        *,
        (SELECT COUNT(1) FROM CommPosts) AS TotalCount
    FROM CommPosts
    ORDER BY IsPinned DESC, CreatedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO


-- ####################################################################################################
-- MODULE 11: FEED & GAMIFICATION ENGINE (KARMA)
-- ####################################################################################################

-- ====================================================================================================
-- 11.1 sp_Feed_GetPersonalizedFeed
-- Aggregates personalized feed blending followed users, connections, joined communities, and public content.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Feed_GetPersonalizedFeed]
    @UserId INT,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH FeedItems AS (
        -- Posts from Followed Users, Connections, Joined Communities, or Public
        SELECT 
            'Post' AS ContentType,
            p.PostId AS ContentId,
            p.AuthorUserId AS AuthorId,
            u.FullName AS AuthorName,
            u.Designation AS AuthorDesignation,
            u.ProfilePhotoUrl AS AuthorProfilePhotoUrl,
            p.ContentText AS TitleOrContent,
            NULL AS Description,
            p.PublishedDate AS PublishedDate,
            (SELECT COUNT(1) FROM [dbo].[Reactions] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId) AS ReactionsCount,
            (SELECT COUNT(1) FROM [dbo].[Comments] WHERE [ContentType] = 'Post' AND [ContentId] = p.PostId) AS CommentsCount,
            CASE 
                WHEN p.AuthorUserId = @UserId THEN 100
                WHEN EXISTS (SELECT 1 FROM [dbo].[Followers] WHERE [FollowerUserId] = @UserId AND [FollowingUserId] = p.AuthorUserId) THEN 80
                WHEN EXISTS (SELECT 1 FROM [dbo].[ConnectionRequests] WHERE (([SenderId] = @UserId AND [ReceiverId] = p.AuthorUserId) OR ([SenderId] = p.AuthorUserId AND [ReceiverId] = @UserId)) AND [Status] = 'Accepted') THEN 70
                WHEN EXISTS (SELECT 1 FROM [dbo].[CommunityPosts] cp INNER JOIN [dbo].[CommunityMembers] cm ON cp.CommunityId = cm.CommunityId WHERE cp.PostId = p.PostId AND cm.UserId = @UserId AND cm.Status = 'Approved') THEN 60
                ELSE 10
            END AS AffinityScore
        FROM [dbo].[Posts] p
        INNER JOIN [dbo].[Users] u ON p.AuthorUserId = u.UserId
        WHERE p.Status = 'Published'

        UNION ALL

        -- Articles
        SELECT 
            'Article' AS ContentType,
            a.ArticleId AS ContentId,
            a.AuthorUserId AS AuthorId,
            u.FullName AS AuthorName,
            u.Designation AS AuthorDesignation,
            u.ProfilePhotoUrl AS AuthorProfilePhotoUrl,
            a.Title AS TitleOrContent,
            a.Description AS Description,
            a.PublishedDate AS PublishedDate,
            (SELECT COUNT(1) FROM [dbo].[Reactions] WHERE [ContentType] = 'Article' AND [ContentId] = a.ArticleId) AS ReactionsCount,
            (SELECT COUNT(1) FROM [dbo].[Comments] WHERE [ContentType] = 'Article' AND [ContentId] = a.ArticleId) AS CommentsCount,
            CASE 
                WHEN a.AuthorUserId = @UserId THEN 100
                WHEN EXISTS (SELECT 1 FROM [dbo].[Followers] WHERE [FollowerUserId] = @UserId AND [FollowingUserId] = a.AuthorUserId) THEN 80
                WHEN EXISTS (SELECT 1 FROM [dbo].[ConnectionRequests] WHERE (([SenderId] = @UserId AND [ReceiverId] = a.AuthorUserId) OR ([SenderId] = a.AuthorUserId AND [ReceiverId] = @UserId)) AND [Status] = 'Accepted') THEN 70
                ELSE 10
            END AS AffinityScore
        FROM [dbo].[Articles] a
        INNER JOIN [dbo].[Users] u ON a.AuthorUserId = u.UserId
        WHERE a.Status = 'Published'
    )
    SELECT 
        *,
        (SELECT COUNT(1) FROM FeedItems) AS TotalCount
    FROM FeedItems
    ORDER BY AffinityScore DESC, PublishedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ====================================================================================================
-- 11.2 sp_Karma_AwardKarma
-- Awards karma points to a user, appends audit transaction, and updates BadgeLevel.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Karma_AwardKarma]
    @UserId INT,
    @ActivityType VARCHAR(40),
    @PointsAwarded INT,
    @RelatedContentType VARCHAR(20) = NULL,
    @RelatedContentId BIGINT = NULL,
    @NewBalance INT OUTPUT,
    @BadgeLevel VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Record transaction
        INSERT INTO [dbo].[KarmaTransactions] (
            [UserId], [ActivityType], [PointsAwarded],
            [RelatedContentType], [RelatedContentId], [CreatedDate]
        )
        VALUES (
            @UserId, @ActivityType, @PointsAwarded,
            @RelatedContentType, @RelatedContentId, SYSUTCDATETIME()
        );

        -- Upsert balance
        IF EXISTS (SELECT 1 FROM [dbo].[KarmaBalances] WHERE [UserId] = @UserId)
        BEGIN
            UPDATE [dbo].[KarmaBalances]
            SET 
                [TotalPoints] = [TotalPoints] + @PointsAwarded,
                [LastUpdated] = SYSUTCDATETIME()
            WHERE [UserId] = @UserId;
        END
        ELSE
        BEGIN
            INSERT INTO [dbo].[KarmaBalances] ([UserId], [TotalPoints], [BadgeLevel], [LastUpdated])
            VALUES (@UserId, @PointsAwarded, 'None', SYSUTCDATETIME());
        END;

        -- Calculate badge level
        SELECT @NewBalance = [TotalPoints] FROM [dbo].[KarmaBalances] WHERE [UserId] = @UserId;

        SET @BadgeLevel = CASE 
            WHEN @NewBalance >= 5000 THEN 'Diamond'
            WHEN @NewBalance >= 2000 THEN 'Platinum'
            WHEN @NewBalance >= 1000 THEN 'Gold'
            WHEN @NewBalance >= 500 THEN 'Silver'
            WHEN @NewBalance >= 100 THEN 'Bronze'
            ELSE 'None'
        END;

        UPDATE [dbo].[KarmaBalances]
        SET [BadgeLevel] = @BadgeLevel
        WHERE [UserId] = @UserId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ====================================================================================================
-- 11.3 sp_Karma_GetLeaderboard
-- Returns the top karma leaderboard rankings.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Karma_GetLeaderboard]
    @TopCount INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopCount)
        ROW_NUMBER() OVER (ORDER BY kb.TotalPoints DESC) AS [Rank],
        kb.UserId,
        u.EmployeeId,
        u.FullName,
        u.Designation,
        d.Name AS DepartmentName,
        u.ProfilePhotoUrl,
        kb.TotalPoints,
        kb.BadgeLevel
    FROM [dbo].[KarmaBalances] kb
    INNER JOIN [dbo].[Users] u ON kb.UserId = u.UserId
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    WHERE u.IsActive = 1 AND u.IsPermanentlySuspended = 0
    ORDER BY kb.TotalPoints DESC;
END;
GO


-- ####################################################################################################
-- MODULE 12: GLOBAL SEARCH & DISCOVERY
-- ####################################################################################################

-- ====================================================================================================
-- 12.1 sp_Search_GlobalSearch
-- Executes multi-entity search across Users, Posts, Articles, Videos, Podcasts, and Communities.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Search_GlobalSearch]
    @SearchTerm NVARCHAR(200),
    @UserId INT = NULL,
    @EntityLimit INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Log search if user specified
    IF @UserId IS NOT NULL AND LEN(LTRIM(RTRIM(@SearchTerm))) > 0
    BEGIN
        INSERT INTO [dbo].[SearchHistory] ([UserId], [SearchTerm], [SearchedDate])
        VALUES (@UserId, LTRIM(RTRIM(@SearchTerm)), SYSUTCDATETIME());
    END;

    -- Result 1: Users
    SELECT TOP (@EntityLimit)
        u.UserId,
        u.EmployeeId,
        u.FullName,
        u.Designation,
        d.Name AS DepartmentName,
        u.ProfilePhotoUrl
    FROM [dbo].[Users] u
    LEFT JOIN [dbo].[Departments] d ON u.DepartmentId = d.DepartmentId
    WHERE u.IsActive = 1
      AND (u.FullName LIKE '%' + @SearchTerm + '%' OR u.Designation LIKE '%' + @SearchTerm + '%' OR u.Email LIKE '%' + @SearchTerm + '%');

    -- Result 2: Articles
    SELECT TOP (@EntityLimit)
        a.ArticleId,
        a.Title,
        a.Description,
        a.PublishedDate,
        u.FullName AS AuthorName
    FROM [dbo].[Articles] a
    INNER JOIN [dbo].[Users] u ON a.AuthorUserId = u.UserId
    WHERE a.Status = 'Published'
      AND (a.Title LIKE '%' + @SearchTerm + '%' OR a.Description LIKE '%' + @SearchTerm + '%');

    -- Result 3: Posts
    SELECT TOP (@EntityLimit)
        p.PostId,
        p.ContentText,
        p.PublishedDate,
        u.FullName AS AuthorName
    FROM [dbo].[Posts] p
    INNER JOIN [dbo].[Users] u ON p.AuthorUserId = u.UserId
    WHERE p.Status = 'Published'
      AND p.ContentText LIKE '%' + @SearchTerm + '%';

    -- Result 4: Communities
    SELECT TOP (@EntityLimit)
        c.CommunityId,
        c.Name,
        c.Description,
        c.ThumbnailUrl,
        (SELECT COUNT(1) FROM [dbo].[CommunityMembers] WHERE [CommunityId] = c.CommunityId AND [Status] = 'Approved') AS MembersCount
    FROM [dbo].[Communities] c
    WHERE c.Name LIKE '%' + @SearchTerm + '%' OR c.Description LIKE '%' + @SearchTerm + '%';

    -- Result 5: Videos
    SELECT TOP (@EntityLimit)
        v.VideoId,
        v.Title,
        v.ThumbnailUrl,
        v.ViewCount
    FROM [dbo].[Videos] v
    WHERE v.Title LIKE '%' + @SearchTerm + '%' OR v.Description LIKE '%' + @SearchTerm + '%';

    -- Result 6: Podcasts
    SELECT TOP (@EntityLimit)
        pod.PodcastId,
        pod.Title,
        pod.CoverImageUrl,
        pod.DurationSeconds
    FROM [dbo].[Podcasts] pod
    WHERE pod.Title LIKE '%' + @SearchTerm + '%' OR pod.Description LIKE '%' + @SearchTerm + '%';
END;
GO

-- ====================================================================================================
-- 12.2 sp_Search_GetRecentSearches / sp_Search_ClearHistory
-- Retrieves recent user searches and clears history.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Search_GetRecentSearches]
    @UserId INT,
    @TopCount INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopCount)
        [SearchTerm],
        MAX([SearchedDate]) AS LastSearchedDate
    FROM [dbo].[SearchHistory]
    WHERE [UserId] = @UserId
    GROUP BY [SearchTerm]
    ORDER BY LastSearchedDate DESC;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Search_ClearHistory]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM [dbo].[SearchHistory] WHERE [UserId] = @UserId;
END;
GO


-- ####################################################################################################
-- MODULE 13: JOBS BOARD
-- ####################################################################################################

-- ====================================================================================================
-- 13.1 sp_Job_CreateJob
-- Creates a job requisition.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Job_CreateJob]
    @Title NVARCHAR(200),
    @DepartmentId INT = NULL,
    @Description NVARCHAR(MAX),
    @SkillsRequired NVARCHAR(500) = NULL,
    @Location NVARCHAR(150) = NULL,
    @ClosingDate DATE,
    @ApplicationLink NVARCHAR(400),
    @PostedByUserId INT,
    @JobId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Jobs] (
        [Title], [DepartmentId], [Description], [SkillsRequired],
        [Location], [ClosingDate], [ApplicationLink], [PostedByUserId],
        [PostedDate], [Status]
    )
    VALUES (
        @Title, @DepartmentId, @Description, @SkillsRequired,
        @Location, @ClosingDate, @ApplicationLink, @PostedByUserId,
        SYSUTCDATETIME(), 'Open'
    );

    SET @JobId = SCOPE_IDENTITY();
END;
GO

-- ====================================================================================================
-- 13.2 sp_Job_GetPagedJobs
-- Paginated job postings with dynamic search & department filters.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Job_GetPagedJobs]
    @DepartmentId INT = NULL,
    @Location NVARCHAR(150) = NULL,
    @SearchTerm NVARCHAR(100) = NULL,
    @Status VARCHAR(20) = 'Open',
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH FilteredJobs AS (
        SELECT 
            j.JobId,
            j.Title,
            j.DepartmentId,
            d.Name AS DepartmentName,
            j.Description,
            j.SkillsRequired,
            j.Location,
            j.ClosingDate,
            j.ApplicationLink,
            j.PostedByUserId,
            u.FullName AS PostedByName,
            j.PostedDate,
            j.Status
        FROM [dbo].[Jobs] j
        LEFT JOIN [dbo].[Departments] d ON j.DepartmentId = d.DepartmentId
        LEFT JOIN [dbo].[Users] u ON j.PostedByUserId = u.UserId
        WHERE (@Status IS NULL OR j.Status = @Status)
          AND (@DepartmentId IS NULL OR j.DepartmentId = @DepartmentId)
          AND (@Location IS NULL OR j.Location LIKE '%' + @Location + '%')
          AND (@SearchTerm IS NULL OR j.Title LIKE '%' + @SearchTerm + '%' OR j.SkillsRequired LIKE '%' + @SearchTerm + '%')
    )
    SELECT 
        *,
        (SELECT COUNT(1) FROM FilteredJobs) AS TotalCount
    FROM FilteredJobs
    ORDER BY PostedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ====================================================================================================
-- 13.3 sp_Job_ExpireOverdueJobs
-- Background worker procedure to close expired jobs where ClosingDate < today.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Job_ExpireOverdueJobs]
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[Jobs]
    SET [Status] = 'Closed'
    WHERE [Status] = 'Open' AND [ClosingDate] < CAST(SYSUTCDATETIME() AS DATE);

    SELECT @@ROWCOUNT AS ExpiredJobsCount;
END;
GO


-- ####################################################################################################
-- MODULE 14: NOTIFICATIONS ENGINE
-- ####################################################################################################

-- ====================================================================================================
-- 14.1 sp_Notification_CreateNotification
-- Creates in-app notification if user has enabled preferences for event type.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Notification_CreateNotification]
    @UserId INT,
    @EventType VARCHAR(40),
    @Message NVARCHAR(400),
    @RelatedContentType VARCHAR(20) = NULL,
    @RelatedContentId BIGINT = NULL,
    @NotificationId BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if user disabled in-app bell notifications for this event
    IF EXISTS (SELECT 1 FROM [dbo].[NotificationPreferences] WHERE [UserId] = @UserId AND [EventType] = @EventType AND [BellEnabled] = 0)
    BEGIN
        SET @NotificationId = 0;
        RETURN;
    END;

    INSERT INTO [dbo].[Notifications] (
        [UserId], [EventType], [Message],
        [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]
    )
    VALUES (
        @UserId, @EventType, @Message,
        @RelatedContentType, @RelatedContentId, 0, SYSUTCDATETIME()
    );

    SET @NotificationId = SCOPE_IDENTITY();
END;
GO

-- ====================================================================================================
-- 14.2 sp_Notification_BroadcastNotification
-- Broadcasts notification to all active users or members of a department.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Notification_BroadcastNotification]
    @EventType VARCHAR(40),
    @Message NVARCHAR(400),
    @DepartmentId INT = NULL,
    @RelatedContentType VARCHAR(20) = NULL,
    @RelatedContentId BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Notifications] (
        [UserId], [EventType], [Message],
        [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]
    )
    SELECT 
        u.UserId,
        @EventType,
        @Message,
        @RelatedContentType,
        @RelatedContentId,
        0,
        SYSUTCDATETIME()
    FROM [dbo].[Users] u
    WHERE u.IsActive = 1
      AND u.IsPermanentlySuspended = 0
      AND (@DepartmentId IS NULL OR u.DepartmentId = @DepartmentId)
      AND NOT EXISTS (SELECT 1 FROM [dbo].[NotificationPreferences] np WHERE np.UserId = u.UserId AND np.EventType = @EventType AND np.BellEnabled = 0);
END;
GO

-- ====================================================================================================
-- 14.3 sp_Notification_GetUserNotifications / sp_Notification_MarkAsRead / sp_Notification_MarkAllAsRead
-- Retrieves and manages user notification center state.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Notification_GetUserNotifications]
    @UserId INT,
    @UnreadOnly BIT = 0,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH UserNotifs AS (
        SELECT 
            n.NotificationId,
            n.UserId,
            n.EventType,
            n.Message,
            n.RelatedContentType,
            n.RelatedContentId,
            n.IsRead,
            n.CreatedDate
        FROM [dbo].[Notifications] n
        WHERE n.UserId = @UserId
          AND (@UnreadOnly = 0 OR n.IsRead = 0)
    )
    SELECT 
        *,
        (SELECT COUNT(1) FROM UserNotifs) AS TotalCount,
        (SELECT COUNT(1) FROM [dbo].[Notifications] WHERE [UserId] = @UserId AND [IsRead] = 0) AS TotalUnreadCount
    FROM UserNotifs
    ORDER BY CreatedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Notification_MarkAsRead]
    @NotificationId BIGINT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[Notifications]
    SET [IsRead] = 1
    WHERE [NotificationId] = @NotificationId AND [UserId] = @UserId;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Notification_MarkAllAsRead]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[Notifications]
    SET [IsRead] = 1
    WHERE [UserId] = @UserId AND [IsRead] = 0;
END;
GO


-- ####################################################################################################
-- MODULE 15: AUDIT TRAIL, MODERATION & GOVERNANCE
-- ####################################################################################################

-- ====================================================================================================
-- 15.1 sp_Audit_LogAction
-- Inserts immutable audit trail entry.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Audit_LogAction]
    @ActorUserId INT,
    @Action VARCHAR(100),
    @TargetType VARCHAR(30),
    @TargetId BIGINT,
    @Reason VARCHAR(500) = NULL,
    @IPAddress VARCHAR(45) = NULL,
    @OldValue VARCHAR(MAX) = NULL,
    @NewValue VARCHAR(MAX) = NULL,
    @AuditId BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[AuditLog] (
        [ActorUserId], [Action], [TargetType], [TargetId],
        [Reason], [IPAddress], [Timestamp], [OldValue], [NewValue]
    )
    VALUES (
        @ActorUserId, @Action, @TargetType, @TargetId,
        @Reason, @IPAddress, SYSUTCDATETIME(), @OldValue, @NewValue
    );

    SET @AuditId = SCOPE_IDENTITY();
END;
GO

-- ====================================================================================================
-- 15.2 sp_Audit_GetLogsPaged
-- Paginated audit log retrieval with advanced filtering.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Audit_GetLogsPaged]
    @ActorUserId INT = NULL,
    @Action VARCHAR(100) = NULL,
    @TargetType VARCHAR(30) = NULL,
    @FromDate DATETIME2(7) = NULL,
    @ToDate DATETIME2(7) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH Logs AS (
        SELECT 
            al.AuditId,
            al.ActorUserId,
            u.FullName AS ActorFullName,
            u.EmployeeId AS ActorEmployeeId,
            al.Action,
            al.TargetType,
            al.TargetId,
            al.Reason,
            al.IPAddress,
            al.Timestamp,
            al.OldValue,
            al.NewValue
        FROM [dbo].[AuditLog] al
        INNER JOIN [dbo].[Users] u ON al.ActorUserId = u.UserId
        WHERE (@ActorUserId IS NULL OR al.ActorUserId = @ActorUserId)
          AND (@Action IS NULL OR al.Action = @Action)
          AND (@TargetType IS NULL OR al.TargetType = @TargetType)
          AND (@FromDate IS NULL OR al.Timestamp >= @FromDate)
          AND (@ToDate IS NULL OR al.Timestamp <= @ToDate)
    )
    SELECT 
        *,
        (SELECT COUNT(1) FROM Logs) AS TotalCount
    FROM Logs
    ORDER BY Timestamp DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ====================================================================================================
-- 15.3 sp_Admin_SetUserStatus
-- Updates active or suspended status of an employee account and logs audit entry.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Admin_SetUserStatus]
    @TargetUserId INT,
    @ActorAdminId INT,
    @IsActive BIT,
    @IsPermanentlySuspended BIT,
    @SuspendedUntil DATETIME2(7) = NULL,
    @Reason VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [dbo].[Users]
        SET 
            [IsActive] = @IsActive,
            [IsPermanentlySuspended] = @IsPermanentlySuspended,
            [SuspendedUntil] = @SuspendedUntil,
            [ModifiedBy] = @ActorAdminId,
            [ModifiedDate] = SYSUTCDATETIME()
        WHERE [UserId] = @TargetUserId;

        -- Record Audit
        EXEC [dbo].[sp_Audit_LogAction]
            @ActorUserId = @ActorAdminId,
            @Action = 'USER_STATUS_CHANGED',
            @TargetType = 'User',
            @TargetId = @TargetUserId,
            @Reason = @Reason,
            @AuditId = NULL;

        COMMIT TRANSACTION;
        SELECT 1 AS Success, 'User status updated successfully' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ====================================================================================================
-- 15.4 sp_Moderation_SubmitReport / sp_Moderation_ResolveReport
-- Content moderation workflows.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Moderation_SubmitReport]
    @ReporterUserId INT,
    @ContentType VARCHAR(20),
    @ContentId BIGINT,
    @ReasonCode VARCHAR(40),
    @ReportId BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[ModerationReports] (
        [ReporterUserId], [ContentType], [ContentId],
        [ReasonCode], [Status], [ReportedDate]
    )
    VALUES (
        @ReporterUserId, @ContentType, @ContentId,
        @ReasonCode, 'Pending', SYSUTCDATETIME()
    );

    SET @ReportId = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Moderation_ResolveReport]
    @ReportId BIGINT,
    @ModeratorUserId INT,
    @Status VARCHAR(20), -- 'Resolved', 'Dismissed'
    @ActionTaken VARCHAR(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[ModerationReports]
    SET 
        [Status] = @Status,
        [ModeratorUserId] = @ModeratorUserId,
        [ActionTaken] = @ActionTaken,
        [ActionDate] = SYSUTCDATETIME()
    WHERE [ReportId] = @ReportId;
END;
GO


-- ####################################################################################################
-- MODULE 16: ANALYTICS & DASHBOARD METRICS
-- ####################################################################################################

-- ====================================================================================================
-- 16.1 sp_Analytics_GetOverviewMetrics
-- Executive overview metrics for executive and HR dashboards.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Analytics_GetOverviewMetrics]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        (SELECT COUNT(1) FROM [dbo].[Users] WHERE [IsActive] = 1) AS TotalActiveUsers,
        (SELECT COUNT(1) FROM [dbo].[Users] WHERE [LastLogin] >= DATEADD(DAY, -1, SYSUTCDATETIME())) AS ActiveUsersLast24Hours,
        (SELECT COUNT(1) FROM [dbo].[Posts] WHERE [Status] = 'Published') AS TotalPosts,
        (SELECT COUNT(1) FROM [dbo].[Articles] WHERE [Status] = 'Published') AS TotalArticles,
        (SELECT COUNT(1) FROM [dbo].[Videos]) AS TotalVideos,
        (SELECT COUNT(1) FROM [dbo].[Podcasts]) AS TotalPodcasts,
        (SELECT COUNT(1) FROM [dbo].[Communities]) AS TotalCommunities,
        (SELECT COUNT(1) FROM [dbo].[Jobs] WHERE [Status] = 'Open') AS TotalOpenJobs,
        (SELECT COUNT(1) FROM [dbo].[Reactions]) AS TotalReactions,
        (SELECT COUNT(1) FROM [dbo].[Comments]) AS TotalComments,
        (SELECT COUNT(1) FROM [dbo].[Shares]) AS TotalShares;
END;
GO

-- ====================================================================================================
-- 16.2 sp_Analytics_GetCommunityMetrics
-- Engagement statistics for communities.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Analytics_GetCommunityMetrics]
    @CommunityId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.CommunityId,
        c.Name,
        (SELECT COUNT(1) FROM [dbo].[CommunityMembers] WHERE [CommunityId] = c.CommunityId AND [Status] = 'Approved') AS TotalMembers,
        (SELECT COUNT(1) FROM [dbo].[CommunityMembers] WHERE [CommunityId] = c.CommunityId AND [Status] = 'Pending') AS PendingJoinRequests,
        (SELECT COUNT(1) FROM [dbo].[CommunityPosts] WHERE [CommunityId] = c.CommunityId) AS TotalPostsShared,
        (SELECT COUNT(1) FROM [dbo].[CommunityPosts] cp INNER JOIN [dbo].[Posts] p ON cp.PostId = p.PostId WHERE cp.CommunityId = c.CommunityId AND p.CreatedDate >= DATEADD(DAY, -7, SYSUTCDATETIME())) AS PostsLast7Days
    FROM [dbo].[Communities] c
    WHERE c.CommunityId = @CommunityId;
END;
GO

-- ====================================================================================================
-- 16.3 sp_Analytics_GetContentAnalytics
-- Metrics breakdown for articles and videos.
-- ====================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_Analytics_GetContentAnalytics]
    @ContentType VARCHAR(20),
    @TopCount INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @ContentType = 'Article'
    BEGIN
        SELECT TOP (@TopCount)
            a.ArticleId AS ContentId,
            a.Title,
            u.FullName AS AuthorName,
            a.ViewCount,
            a.UniqueReadCount,
            a.AvgReadTimeSeconds,
            (SELECT COUNT(1) FROM [dbo].[Reactions] WHERE [ContentType] = 'Article' AND [ContentId] = a.ArticleId) AS ReactionsCount,
            (SELECT COUNT(1) FROM [dbo].[Comments] WHERE [ContentType] = 'Article' AND [ContentId] = a.ArticleId) AS CommentsCount
        FROM [dbo].[Articles] a
        INNER JOIN [dbo].[Users] u ON a.AuthorUserId = u.UserId
        WHERE a.Status = 'Published'
        ORDER BY a.ViewCount DESC;
    END
    ELSE IF @ContentType = 'Video'
    BEGIN
        SELECT TOP (@TopCount)
            v.VideoId AS ContentId,
            v.Title,
            u.FullName AS AuthorName,
            v.ViewCount,
            (SELECT COUNT(1) FROM [dbo].[Reactions] WHERE [ContentType] = 'Video' AND [ContentId] = v.VideoId) AS ReactionsCount,
            (SELECT COUNT(1) FROM [dbo].[Comments] WHERE [ContentType] = 'Video' AND [ContentId] = v.VideoId) AS CommentsCount
        FROM [dbo].[Videos] v
        INNER JOIN [dbo].[Users] u ON v.UploaderUserId = u.UserId
        ORDER BY v.ViewCount DESC;
    END;
END;
GO
