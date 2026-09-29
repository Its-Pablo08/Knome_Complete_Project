-- =========================================================================
-- KNOME ENTERPRISE PLATFORM: DATA ARCHIVAL DATABASE & STORED PROCEDURES
-- Client: MPOnline Limited
-- Target: Knome_Archive Database (Cold/Historical Storage)
-- =========================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Knome_Archive')
BEGIN
    CREATE DATABASE Knome_Archive;
END
GO

USE Knome_Archive;
GO

-- 1. AuditLog Archive Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditLogs_Archive')
BEGIN
    CREATE TABLE dbo.AuditLogs_Archive (
        AuditId BIGINT NOT NULL,
        ActorUserId INT NOT NULL,
        Action VARCHAR(100) NOT NULL,
        TargetType VARCHAR(100) NOT NULL,
        TargetId BIGINT NOT NULL,
        Reason VARCHAR(MAX) NULL,
        IPAddress VARCHAR(50) NULL,
        Timestamp DATETIME2 NOT NULL,
        OldValue VARCHAR(MAX) NULL,
        NewValue VARCHAR(MAX) NULL,
        ArchivedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_AuditLogs_Archive PRIMARY KEY (AuditId)
    );
    CREATE NONCLUSTERED INDEX IX_AuditLogs_Archive_Timestamp ON dbo.AuditLogs_Archive(Timestamp);
    CREATE NONCLUSTERED INDEX IX_AuditLogs_Archive_Actor ON dbo.AuditLogs_Archive(ActorUserId);
END
GO

-- 2. Notifications Archive Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Notifications_Archive')
BEGIN
    CREATE TABLE dbo.Notifications_Archive (
        NotificationId BIGINT NOT NULL,
        UserId INT NOT NULL,
        EventType NVARCHAR(100) NOT NULL,
        Message NVARCHAR(MAX) NOT NULL,
        RelatedContentType NVARCHAR(100) NULL,
        RelatedContentId BIGINT NULL,
        IsRead BIT NOT NULL,
        CreatedDate DATETIME2 NOT NULL,
        ArchivedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Notifications_Archive PRIMARY KEY (NotificationId)
    );
    CREATE NONCLUSTERED INDEX IX_Notifications_Archive_UserDate ON dbo.Notifications_Archive(UserId, CreatedDate);
END
GO

-- 3. SearchHistory Archive Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SearchHistory_Archive')
BEGIN
    CREATE TABLE dbo.SearchHistory_Archive (
        SearchHistoryId BIGINT IDENTITY(1,1) NOT NULL,
        UserId INT NOT NULL,
        SearchTerm NVARCHAR(500) NOT NULL,
        SearchedDate DATETIME2 NOT NULL,
        ArchivedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_SearchHistory_Archive PRIMARY KEY (SearchHistoryId)
    );
    CREATE NONCLUSTERED INDEX IX_SearchHistory_Archive_Date ON dbo.SearchHistory_Archive(SearchedDate);
END
GO

-- 4. KarmaTransactions Archive Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'KarmaTransactions_Archive')
BEGIN
    CREATE TABLE dbo.KarmaTransactions_Archive (
        TransactionId BIGINT NOT NULL,
        UserId INT NOT NULL,
        ActivityType NVARCHAR(100) NOT NULL,
        PointsAwarded INT NOT NULL,
        RelatedContentType NVARCHAR(100) NULL,
        RelatedContentId BIGINT NULL,
        CreatedDate DATETIME2 NOT NULL,
        ArchivedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_KarmaTransactions_Archive PRIMARY KEY (TransactionId)
    );
    CREATE NONCLUSTERED INDEX IX_KarmaTransactions_Archive_UserDate ON dbo.KarmaTransactions_Archive(UserId, CreatedDate);
END
GO

-- 5. Posts Archive Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Posts_Archive')
BEGIN
    CREATE TABLE dbo.Posts_Archive (
        PostId BIGINT NOT NULL,
        AuthorUserId INT NOT NULL,
        ContentText NVARCHAR(MAX) NOT NULL,
        AudienceType NVARCHAR(50) NOT NULL,
        Status NVARCHAR(50) NOT NULL,
        ScheduledDate DATETIME2 NULL,
        PublishedDate DATETIME2 NULL,
        CreatedDate DATETIME2 NOT NULL,
        ArchivedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Posts_Archive PRIMARY KEY (PostId)
    );
    CREATE NONCLUSTERED INDEX IX_Posts_Archive_AuthorDate ON dbo.Posts_Archive(AuthorUserId, CreatedDate);
END
GO

-- =========================================================================
-- CREATE OR ALTER STORED PROCEDURE IN PRIMARY DB (Knome)
-- =========================================================================
USE Knome;
GO

CREATE OR ALTER PROCEDURE dbo.sp_ArchiveKnomeData
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Cutoff3Months DATETIME2 = DATEADD(MONTH, -3, SYSUTCDATETIME());
    DECLARE @BatchSize INT = 500;
    DECLARE @RowsAffected INT = 1;

    PRINT 'Starting Knome Data Archival Job at ' + CONVERT(NVARCHAR, SYSUTCDATETIME(), 120);

    -- ---------------------------------------------------------------------
    -- 1. ARCHIVE AUDIT LOG (> 3 Months)
    -- ---------------------------------------------------------------------
    SET @RowsAffected = 1;
    WHILE @RowsAffected > 0
    BEGIN
        BEGIN TRANSACTION;

        INSERT INTO Knome_Archive.dbo.AuditLogs_Archive (
            AuditId, ActorUserId, Action, TargetType, TargetId, Reason, IPAddress, Timestamp, OldValue, NewValue, ArchivedDate
        )
        SELECT TOP (@BatchSize) 
            AuditId, ActorUserId, Action, TargetType, TargetId, Reason, IPAddress, Timestamp, OldValue, NewValue, SYSUTCDATETIME()
        FROM Knome.dbo.AuditLog WITH (NOLOCK)
        WHERE Timestamp < @Cutoff3Months;

        SET @RowsAffected = @@ROWCOUNT;

        IF @RowsAffected > 0
        BEGIN
            DELETE FROM Knome.dbo.AuditLog
            WHERE AuditId IN (
                SELECT TOP (@BatchSize) AuditId 
                FROM Knome.dbo.AuditLog 
                WHERE Timestamp < @Cutoff3Months
            );
        END

        COMMIT TRANSACTION;
        WAITFOR DELAY '00:00:00.050';
    END;

    -- ---------------------------------------------------------------------
    -- 2. ARCHIVE NOTIFICATIONS (> 3 Months)
    -- ---------------------------------------------------------------------
    SET @RowsAffected = 1;
    WHILE @RowsAffected > 0
    BEGIN
        BEGIN TRANSACTION;

        INSERT INTO Knome_Archive.dbo.Notifications_Archive (
            NotificationId, UserId, EventType, Message, RelatedContentType, RelatedContentId, IsRead, CreatedDate, ArchivedDate
        )
        SELECT TOP (@BatchSize) 
            NotificationId, UserId, EventType, Message, RelatedContentType, RelatedContentId, IsRead, CreatedDate, SYSUTCDATETIME()
        FROM Knome.dbo.Notifications WITH (NOLOCK)
        WHERE CreatedDate < @Cutoff3Months;

        SET @RowsAffected = @@ROWCOUNT;

        IF @RowsAffected > 0
        BEGIN
            DELETE FROM Knome.dbo.Notifications
            WHERE NotificationId IN (
                SELECT TOP (@BatchSize) NotificationId 
                FROM Knome.dbo.Notifications 
                WHERE CreatedDate < @Cutoff3Months
            );
        END

        COMMIT TRANSACTION;
        WAITFOR DELAY '00:00:00.050';
    END;

    -- ---------------------------------------------------------------------
    -- 3. ARCHIVE KARMA TRANSACTIONS (> 3 Months)
    -- ---------------------------------------------------------------------
    SET @RowsAffected = 1;
    WHILE @RowsAffected > 0
    BEGIN
        BEGIN TRANSACTION;

        INSERT INTO Knome_Archive.dbo.KarmaTransactions_Archive (
            TransactionId, UserId, ActivityType, PointsAwarded, RelatedContentType, RelatedContentId, CreatedDate, ArchivedDate
        )
        SELECT TOP (@BatchSize) 
            TransactionId, UserId, ActivityType, PointsAwarded, RelatedContentType, RelatedContentId, CreatedDate, SYSUTCDATETIME()
        FROM Knome.dbo.KarmaTransactions WITH (NOLOCK)
        WHERE CreatedDate < @Cutoff3Months;

        SET @RowsAffected = @@ROWCOUNT;

        IF @RowsAffected > 0
        BEGIN
            DELETE FROM Knome.dbo.KarmaTransactions
            WHERE TransactionId IN (
                SELECT TOP (@BatchSize) TransactionId 
                FROM Knome.dbo.KarmaTransactions 
                WHERE CreatedDate < @Cutoff3Months
            );
        END

        COMMIT TRANSACTION;
        WAITFOR DELAY '00:00:00.050';
    END;

    -- ---------------------------------------------------------------------
    -- 4. ARCHIVE SEARCH HISTORY (> 3 Months)
    -- ---------------------------------------------------------------------
    SET @RowsAffected = 1;
    WHILE @RowsAffected > 0
    BEGIN
        BEGIN TRANSACTION;

        INSERT INTO Knome_Archive.dbo.SearchHistory_Archive (
            UserId, SearchTerm, SearchedDate, ArchivedDate
        )
        SELECT TOP (@BatchSize) 
            UserId, SearchTerm, SearchedDate, SYSUTCDATETIME()
        FROM Knome.dbo.SearchHistory WITH (NOLOCK)
        WHERE SearchedDate < @Cutoff3Months;

        SET @RowsAffected = @@ROWCOUNT;

        IF @RowsAffected > 0
        BEGIN
            DELETE TOP (@BatchSize) FROM Knome.dbo.SearchHistory
            WHERE SearchedDate < @Cutoff3Months;
        END

        COMMIT TRANSACTION;
        WAITFOR DELAY '00:00:00.050';
    END;

    PRINT 'Knome Data Archival Job Finished Successfully at ' + CONVERT(NVARCHAR, SYSUTCDATETIME(), 120);
END
GO
