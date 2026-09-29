-- =========================================================================
-- KNOME ENTERPRISE PLATFORM: MIGRATION SCRIPT
-- Migrate Database Date and Time Constraints & Historical Records to IST (UTC+05:30)
-- =========================================================================

USE [Knome];
GO

PRINT '=============================================================';
PRINT 'STEP 1: UPDATING DEFAULT CONSTRAINTS TO SYSDATETIME() / GETDATE()';
PRINT '=============================================================';

DECLARE @table NVARCHAR(128), @col NVARCHAR(128), @con NVARCHAR(128);
DECLARE @sql NVARCHAR(MAX);

DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT t.name, c.name, d.name
    FROM sys.default_constraints d
    JOIN sys.tables t ON d.parent_object_id = t.object_id
    JOIN sys.columns c ON d.parent_object_id = c.object_id AND d.parent_column_id = c.column_id
    WHERE d.definition LIKE '%utc%';

OPEN cur;
FETCH NEXT FROM cur INTO @table, @col, @con;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'ALTER TABLE [' + @table + N'] DROP CONSTRAINT [' + @con + N'];' + CHAR(13) + CHAR(10) +
               N'ALTER TABLE [' + @table + N'] ADD CONSTRAINT [' + @con + N'] DEFAULT (sysdatetime()) FOR [' + @col + N'];';
    EXEC sp_executesql @sql;
    PRINT 'Updated constraint ' + @con + ' on ' + @table + '.' + @col + ' to sysdatetime()';
    FETCH NEXT FROM cur INTO @table, @col, @con;
END
CLOSE cur;
DEALLOCATE cur;
GO

PRINT '=============================================================';
PRINT 'STEP 2: ADJUSTING HISTORICAL TIMESTAMPS BY +330 MINUTES (IST)';
PRINT '=============================================================';

BEGIN TRANSACTION;

-- Comments
UPDATE [dbo].[Comments] SET [CreatedDate] = DATEADD(minute, 330, [CreatedDate]) WHERE [CreatedDate] IS NOT NULL;
PRINT 'Adjusted Comments';

-- Posts
UPDATE [dbo].[Posts] SET 
    [CreatedDate] = DATEADD(minute, 330, [CreatedDate]),
    [PublishedDate] = CASE WHEN [PublishedDate] IS NOT NULL THEN DATEADD(minute, 330, [PublishedDate]) ELSE NULL END,
    [ScheduledDate] = CASE WHEN [ScheduledDate] IS NOT NULL THEN DATEADD(minute, 330, [ScheduledDate]) ELSE NULL END;
PRINT 'Adjusted Posts';

-- PostAttachments
UPDATE [dbo].[PostAttachments] SET [PublishedDate] = DATEADD(minute, 330, [PublishedDate]) WHERE [PublishedDate] IS NOT NULL;
PRINT 'Adjusted PostAttachments';

-- Articles
UPDATE [dbo].[Articles] SET 
    [CreatedDate] = DATEADD(minute, 330, [CreatedDate]),
    [PublishedDate] = CASE WHEN [PublishedDate] IS NOT NULL THEN DATEADD(minute, 330, [PublishedDate]) ELSE NULL END,
    [ScheduledDate] = CASE WHEN [ScheduledDate] IS NOT NULL THEN DATEADD(minute, 330, [ScheduledDate]) ELSE NULL END;
PRINT 'Adjusted Articles';

-- ArticleAttachments
UPDATE [dbo].[ArticleAttachments] SET [PublishedDate] = DATEADD(minute, 330, [PublishedDate]) WHERE [PublishedDate] IS NOT NULL;
PRINT 'Adjusted ArticleAttachments';

-- ArticleVersions
UPDATE [dbo].[ArticleVersions] SET [EditedDate] = DATEADD(minute, 330, [EditedDate]) WHERE [EditedDate] IS NOT NULL;
PRINT 'Adjusted ArticleVersions';

-- Videos
UPDATE [dbo].[Videos] SET [UploadedDate] = DATEADD(minute, 330, [UploadedDate]) WHERE [UploadedDate] IS NOT NULL;
PRINT 'Adjusted Videos';

-- Podcasts
UPDATE [dbo].[Podcasts] SET [UploadedDate] = DATEADD(minute, 330, [UploadedDate]) WHERE [UploadedDate] IS NOT NULL;
PRINT 'Adjusted Podcasts';

-- Communities
UPDATE [dbo].[Communities] SET [CreatedDate] = DATEADD(minute, 330, [CreatedDate]) WHERE [CreatedDate] IS NOT NULL;
PRINT 'Adjusted Communities';

-- CommunityMembers
UPDATE [dbo].[CommunityMembers] SET 
    [RequestedDate] = DATEADD(minute, 330, [RequestedDate]),
    [DecidedDate] = CASE WHEN [DecidedDate] IS NOT NULL THEN DATEADD(minute, 330, [DecidedDate]) ELSE NULL END;
PRINT 'Adjusted CommunityMembers';

-- ConnectionRequests
UPDATE [dbo].[ConnectionRequests] SET 
    [CreatedDate] = DATEADD(minute, 330, [CreatedDate]),
    [UpdatedDate] = CASE WHEN [UpdatedDate] IS NOT NULL THEN DATEADD(minute, 330, [UpdatedDate]) ELSE NULL END;
PRINT 'Adjusted ConnectionRequests';

-- Followers
UPDATE [dbo].[Followers] SET [FollowedDate] = DATEADD(minute, 330, [FollowedDate]) WHERE [FollowedDate] IS NOT NULL;
PRINT 'Adjusted Followers';

-- Reactions
UPDATE [dbo].[Reactions] SET [CreatedDate] = DATEADD(minute, 330, [CreatedDate]) WHERE [CreatedDate] IS NOT NULL;
PRINT 'Adjusted Reactions';

-- Shares
UPDATE [dbo].[Shares] SET [CreatedDate] = DATEADD(minute, 330, [CreatedDate]) WHERE [CreatedDate] IS NOT NULL;
PRINT 'Adjusted Shares';

-- Bookmarks
UPDATE [dbo].[Bookmarks] SET [SavedDate] = DATEADD(minute, 330, [SavedDate]) WHERE [SavedDate] IS NOT NULL;
PRINT 'Adjusted Bookmarks';

-- Notifications
UPDATE [dbo].[Notifications] SET [CreatedDate] = DATEADD(minute, 330, [CreatedDate]) WHERE [CreatedDate] IS NOT NULL;
PRINT 'Adjusted Notifications';

-- ModerationReports
UPDATE [dbo].[ModerationReports] SET 
    [ReportedDate] = DATEADD(minute, 330, [ReportedDate]),
    [ActionDate] = CASE WHEN [ActionDate] IS NOT NULL THEN DATEADD(minute, 330, [ActionDate]) ELSE NULL END;
PRINT 'Adjusted ModerationReports';

-- KarmaTransactions & Balances
UPDATE [dbo].[KarmaTransactions] SET [CreatedDate] = DATEADD(minute, 330, [CreatedDate]) WHERE [CreatedDate] IS NOT NULL;
UPDATE [dbo].[KarmaBalances] SET [LastUpdated] = DATEADD(minute, 330, [LastUpdated]) WHERE [LastUpdated] IS NOT NULL;
PRINT 'Adjusted Karma';

-- AuditLog
UPDATE [dbo].[AuditLog] SET [Timestamp] = DATEADD(minute, 330, [Timestamp]) WHERE [Timestamp] IS NOT NULL;
PRINT 'Adjusted AuditLog';

-- SearchHistory
UPDATE [dbo].[SearchHistory] SET [SearchedDate] = DATEADD(minute, 330, [SearchedDate]) WHERE [SearchedDate] IS NOT NULL;
PRINT 'Adjusted SearchHistory';

-- RoleRequests
UPDATE [dbo].[RoleRequests] SET 
    [CreatedAt] = DATEADD(minute, 330, [CreatedAt]),
    [ProcessedAt] = CASE WHEN [ProcessedAt] IS NOT NULL THEN DATEADD(minute, 330, [ProcessedAt]) ELSE NULL END;
PRINT 'Adjusted RoleRequests';

-- Users & Credentials
UPDATE [dbo].[Users] SET 
    [CreatedDate] = DATEADD(minute, 330, [CreatedDate]),
    [ModifiedDate] = CASE WHEN [ModifiedDate] IS NOT NULL THEN DATEADD(minute, 330, [ModifiedDate]) ELSE NULL END,
    [LastLogin] = CASE WHEN [LastLogin] IS NOT NULL THEN DATEADD(minute, 330, [LastLogin]) ELSE NULL END;
UPDATE [dbo].[UserCredentials] SET [LastUpdated] = DATEADD(minute, 330, [LastUpdated]) WHERE [LastUpdated] IS NOT NULL;
PRINT 'Adjusted Users';

COMMIT TRANSACTION;
GO

PRINT '=============================================================';
PRINT 'MIGRATION TO IST COMPLETED SUCCESSFULLY';
PRINT '=============================================================';
