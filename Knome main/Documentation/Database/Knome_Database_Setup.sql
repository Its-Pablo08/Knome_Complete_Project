-- ============================================================
-- Knome Enterprise Platform
-- Complete Database Setup Script (Schema + Seed Data)
-- Generated: 2026-08-05 15:51:34
-- ============================================================
--
-- SETUP INSTRUCTIONS FOR FRIEND:
-- 1. Install SQL Server Developer/Express edition
-- 2. Open SSMS > File > Open > run this entire .sql file (F5)
-- 3. In appsettings.json (Backend/Knome.API/) set:
--    ConnectionStrings.DefaultConnection =
--    'Server=localhost;Database=Knome;Trusted_Connection=True;TrustServerCertificate=True;'
-- 4. cd Backend/Knome.API && dotnet run
-- 5. cd knomeUI/frontend && npm install && npm run dev
-- Test Login: EMP001 to EMP004, Password: Password@123
-- ============================================================

USE master;
GO
IF DB_ID('Knome') IS NOT NULL
BEGIN
    ALTER DATABASE [Knome] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [Knome];
END
GO
CREATE DATABASE [Knome];
GO
USE [Knome];
GO
SET NOCOUNT ON;
GO

-- ============================================================
-- PART 1: TABLE SCHEMAS
-- ============================================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArticleAttachments](
	[AttachmentId] [bigint] IDENTITY(1,1) NOT NULL,
	[ArticleId] [bigint] NOT NULL,
	[FileUrl] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FileType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PublishedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[ArticleAttachments] ADD  CONSTRAINT [DF_ArticleAttachments_PublishedDate]  DEFAULT (sysutcdatetime()) FOR [PublishedDate]
GO
ALTER TABLE [dbo].[ArticleAttachments]  WITH CHECK ADD FOREIGN KEY([ArticleId])
REFERENCES [dbo].[Articles] ([ArticleId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Articles](
	[ArticleId] [bigint] IDENTITY(1,1) NOT NULL,
	[AuthorUserId] [int] NOT NULL,
	[Title] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ContentHtml] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CategoryId] [int] NOT NULL,
	[Status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ScheduledDate] [datetime2](7) NULL,
	[PublishedDate] [datetime2](7) NULL,
	[ViewCount] [int] NOT NULL,
	[UniqueReadCount] [int] NOT NULL,
	[AvgReadTimeSeconds] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ArticleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[Articles] ADD  DEFAULT ('Published') FOR [Status]
GO
ALTER TABLE [dbo].[Articles] ADD  DEFAULT ((0)) FOR [ViewCount]
GO
ALTER TABLE [dbo].[Articles] ADD  DEFAULT ((0)) FOR [UniqueReadCount]
GO
ALTER TABLE [dbo].[Articles] ADD  DEFAULT ((0)) FOR [AvgReadTimeSeconds]
GO
ALTER TABLE [dbo].[Articles] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Articles]  WITH CHECK ADD FOREIGN KEY([AuthorUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Articles]  WITH CHECK ADD FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([CategoryId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArticleTags](
	[ArticleId] [bigint] NOT NULL,
	[Tag] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ArticleId] ASC,
	[Tag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[ArticleTags]  WITH CHECK ADD FOREIGN KEY([ArticleId])
REFERENCES [dbo].[Articles] ([ArticleId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArticleVersions](
	[VersionId] [bigint] IDENTITY(1,1) NOT NULL,
	[ArticleId] [bigint] NOT NULL,
	[ContentHtml] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EditedByUserId] [int] NOT NULL,
	[EditedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VersionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[ArticleVersions] ADD  DEFAULT (sysutcdatetime()) FOR [EditedDate]
GO
ALTER TABLE [dbo].[ArticleVersions]  WITH CHECK ADD FOREIGN KEY([ArticleId])
REFERENCES [dbo].[Articles] ([ArticleId])
GO
ALTER TABLE [dbo].[ArticleVersions]  WITH CHECK ADD FOREIGN KEY([EditedByUserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditLog](
	[AuditId] [bigint] IDENTITY(1,1) NOT NULL,
	[ActorUserId] [int] NOT NULL,
	[Action] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetType] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetId] [bigint] NOT NULL,
	[Reason] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IPAddress] [varchar](45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Timestamp] [datetime2](7) NOT NULL,
	[OldValue] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NewValue] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[AuditId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_AuditLog_Actor] ON [dbo].[AuditLog]
(
	[ActorUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditLog] ADD  DEFAULT (sysutcdatetime()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[AuditLog]  WITH CHECK ADD FOREIGN KEY([ActorUserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlockedUrls](
	[BlockedUrlId] [int] IDENTITY(1,1) NOT NULL,
	[UrlPattern] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Reason] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[BlockedUrlId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bookmarks](
	[UserId] [int] NOT NULL,
	[ContentType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ContentId] [bigint] NOT NULL,
	[SavedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[ContentType] ASC,
	[ContentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Bookmarks] ADD  DEFAULT (sysutcdatetime()) FOR [SavedDate]
GO
ALTER TABLE [dbo].[Bookmarks]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[CategoryId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AppliesTo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Comments](
	[CommentId] [bigint] IDENTITY(1,1) NOT NULL,
	[ContentType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ContentId] [bigint] NOT NULL,
	[UserId] [int] NOT NULL,
	[ParentCommentId] [bigint] NULL,
	[CommentText] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ImageUrl] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CommentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Comments] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD FOREIGN KEY([ParentCommentId])
REFERENCES [dbo].[Comments] ([CommentId])
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Communities](
	[CommunityId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BannerUrl] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ThumbnailUrl] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CategoryId] [int] NULL,
	[Rules] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Faq] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CommunityType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedByUserId] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CommunityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[Communities] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Communities]  WITH CHECK ADD FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([CategoryId])
GO
ALTER TABLE [dbo].[Communities]  WITH CHECK ADD FOREIGN KEY([CreatedByUserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommunityAdmins](
	[CommunityId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CommunityId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CommunityAdmins]  WITH CHECK ADD FOREIGN KEY([CommunityId])
REFERENCES [dbo].[Communities] ([CommunityId])
GO
ALTER TABLE [dbo].[CommunityAdmins]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommunityMembers](
	[CommunityId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[MemberType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RequestedDate] [datetime2](7) NOT NULL,
	[DecidedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[CommunityId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CommunityMembers] ADD  DEFAULT ('Subscriber') FOR [MemberType]
GO
ALTER TABLE [dbo].[CommunityMembers] ADD  DEFAULT ('Approved') FOR [Status]
GO
ALTER TABLE [dbo].[CommunityMembers] ADD  DEFAULT (sysutcdatetime()) FOR [RequestedDate]
GO
ALTER TABLE [dbo].[CommunityMembers]  WITH CHECK ADD FOREIGN KEY([CommunityId])
REFERENCES [dbo].[Communities] ([CommunityId])
GO
ALTER TABLE [dbo].[CommunityMembers]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommunityPosts](
	[CommunityId] [int] NOT NULL,
	[PostId] [bigint] NOT NULL,
	[IsPinned] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CommunityId] ASC,
	[PostId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CommunityPosts] ADD  DEFAULT ((0)) FOR [IsPinned]
GO
ALTER TABLE [dbo].[CommunityPosts]  WITH CHECK ADD FOREIGN KEY([CommunityId])
REFERENCES [dbo].[Communities] ([CommunityId])
GO
ALTER TABLE [dbo].[CommunityPosts]  WITH CHECK ADD FOREIGN KEY([PostId])
REFERENCES [dbo].[Posts] ([PostId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConnectionRequests](
	[RequestId] [int] IDENTITY(1,1) NOT NULL,
	[SenderId] [int] NOT NULL,
	[ReceiverId] [int] NOT NULL,
	[Status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[UpdatedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ConnectionRequests_Sender_Receiver] ON [dbo].[ConnectionRequests]
(
	[SenderId] ASC,
	[ReceiverId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConnectionRequests] ADD  DEFAULT ('Pending') FOR [Status]
GO
ALTER TABLE [dbo].[ConnectionRequests] ADD  DEFAULT (getutcdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[ConnectionRequests] ADD  DEFAULT (getutcdate()) FOR [UpdatedDate]
GO
ALTER TABLE [dbo].[ConnectionRequests]  WITH CHECK ADD FOREIGN KEY([ReceiverId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[ConnectionRequests]  WITH CHECK ADD FOREIGN KEY([SenderId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departments](
	[DepartmentId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DepartmentCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[DepartmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Followers](
	[FollowerUserId] [int] NOT NULL,
	[FollowingUserId] [int] NOT NULL,
	[FollowedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[FollowerUserId] ASC,
	[FollowingUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_Followers_FollowingUserId] ON [dbo].[Followers]
(
	[FollowingUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Followers] ADD  DEFAULT (sysutcdatetime()) FOR [FollowedDate]
GO
ALTER TABLE [dbo].[Followers]  WITH CHECK ADD FOREIGN KEY([FollowerUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Followers]  WITH CHECK ADD FOREIGN KEY([FollowingUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Followers]  WITH CHECK ADD CHECK  (([FollowerUserId]<>[FollowingUserId]))
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HotPostsScoreCache](
	[ContentType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ContentId] [bigint] NOT NULL,
	[Window] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Score] [decimal](12, 2) NOT NULL,
	[CalculatedAt] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ContentType] ASC,
	[ContentId] ASC,
	[Window] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[HotPostsScoreCache] ADD  DEFAULT (sysutcdatetime()) FOR [CalculatedAt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Jobs](
	[JobId] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DepartmentId] [int] NULL,
	[Description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SkillsRequired] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Location] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClosingDate] [date] NOT NULL,
	[ApplicationLink] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PostedByUserId] [int] NOT NULL,
	[PostedDate] [datetime2](7) NOT NULL,
	[Status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[JobId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[Jobs] ADD  DEFAULT (sysutcdatetime()) FOR [PostedDate]
GO
ALTER TABLE [dbo].[Jobs] ADD  DEFAULT ('Open') FOR [Status]
GO
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[Departments] ([DepartmentId])
GO
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD FOREIGN KEY([PostedByUserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KarmaBalances](
	[UserId] [int] NOT NULL,
	[TotalPoints] [int] NOT NULL,
	[BadgeLevel] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LastUpdated] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[KarmaBalances] ADD  DEFAULT ((0)) FOR [TotalPoints]
GO
ALTER TABLE [dbo].[KarmaBalances] ADD  DEFAULT ('None') FOR [BadgeLevel]
GO
ALTER TABLE [dbo].[KarmaBalances] ADD  DEFAULT (sysutcdatetime()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[KarmaBalances]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KarmaTransactions](
	[TransactionId] [bigint] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ActivityType] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PointsAwarded] [int] NOT NULL,
	[RelatedContentType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RelatedContentId] [bigint] NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[KarmaTransactions] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[KarmaTransactions]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModerationReports](
	[ReportId] [bigint] IDENTITY(1,1) NOT NULL,
	[ReporterUserId] [int] NOT NULL,
	[ContentType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ContentId] [bigint] NOT NULL,
	[ReasonCode] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ModeratorUserId] [int] NULL,
	[ActionTaken] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportedDate] [datetime2](7) NOT NULL,
	[ActionDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[ReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[ModerationReports] ADD  DEFAULT ('Pending') FOR [Status]
GO
ALTER TABLE [dbo].[ModerationReports] ADD  DEFAULT (sysutcdatetime()) FOR [ReportedDate]
GO
ALTER TABLE [dbo].[ModerationReports]  WITH CHECK ADD FOREIGN KEY([ModeratorUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[ModerationReports]  WITH CHECK ADD FOREIGN KEY([ReporterUserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationPreferences](
	[UserId] [int] NOT NULL,
	[EventType] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BellEnabled] [bit] NOT NULL,
	[EmailEnabled] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[EventType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[NotificationPreferences] ADD  DEFAULT ((1)) FOR [BellEnabled]
GO
ALTER TABLE [dbo].[NotificationPreferences] ADD  DEFAULT ((0)) FOR [EmailEnabled]
GO
ALTER TABLE [dbo].[NotificationPreferences]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications](
	[NotificationId] [bigint] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[EventType] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Message] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RelatedContentType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RelatedContentId] [bigint] NULL,
	[IsRead] [bit] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[NotificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Notifications] ADD  DEFAULT ((0)) FOR [IsRead]
GO
ALTER TABLE [dbo].[Notifications] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Podcasts](
	[PodcastId] [bigint] IDENTITY(1,1) NOT NULL,
	[UploaderUserId] [int] NOT NULL,
	[Title] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CoverImageUrl] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DurationSeconds] [int] NULL,
	[CategoryId] [int] NULL,
	[SeriesId] [int] NULL,
	[FileSizeMb] [int] NULL,
	[UploadedDate] [datetime2](7) NOT NULL,
	[AudioUrl] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[PodcastId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[Podcasts] ADD  DEFAULT (sysutcdatetime()) FOR [UploadedDate]
GO
ALTER TABLE [dbo].[Podcasts]  WITH CHECK ADD FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([CategoryId])
GO
ALTER TABLE [dbo].[Podcasts]  WITH CHECK ADD FOREIGN KEY([SeriesId])
REFERENCES [dbo].[PodcastSeries] ([SeriesId])
GO
ALTER TABLE [dbo].[Podcasts]  WITH CHECK ADD FOREIGN KEY([UploaderUserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PodcastSeries](
	[SeriesId] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[SeriesId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostAttachments](
	[AttachmentId] [bigint] IDENTITY(1,1) NOT NULL,
	[PostId] [bigint] NOT NULL,
	[FileUrl] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FileType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PublishedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[PostAttachments] ADD  CONSTRAINT [DF_PostAttachments_PublishedDate]  DEFAULT (sysutcdatetime()) FOR [PublishedDate]
GO
ALTER TABLE [dbo].[PostAttachments]  WITH CHECK ADD FOREIGN KEY([PostId])
REFERENCES [dbo].[Posts] ([PostId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostAudienceCommunities](
	[PostId] [bigint] NOT NULL,
	[CommunityId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PostId] ASC,
	[CommunityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[PostAudienceCommunities]  WITH CHECK ADD FOREIGN KEY([PostId])
REFERENCES [dbo].[Posts] ([PostId])
GO
ALTER TABLE [dbo].[PostAudienceCommunities]  WITH CHECK ADD  CONSTRAINT [FK_PostAudienceCommunities_Community] FOREIGN KEY([CommunityId])
REFERENCES [dbo].[Communities] ([CommunityId])
GO
ALTER TABLE [dbo].[PostAudienceCommunities] CHECK CONSTRAINT [FK_PostAudienceCommunities_Community]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostAudienceUsers](
	[PostId] [bigint] NOT NULL,
	[UserId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PostId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[PostAudienceUsers]  WITH CHECK ADD FOREIGN KEY([PostId])
REFERENCES [dbo].[Posts] ([PostId])
GO
ALTER TABLE [dbo].[PostAudienceUsers]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostMentions](
	[PostId] [bigint] NOT NULL,
	[MentionedUserId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PostId] ASC,
	[MentionedUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[PostMentions]  WITH CHECK ADD FOREIGN KEY([MentionedUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[PostMentions]  WITH CHECK ADD FOREIGN KEY([PostId])
REFERENCES [dbo].[Posts] ([PostId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Posts](
	[PostId] [bigint] IDENTITY(1,1) NOT NULL,
	[AuthorUserId] [int] NOT NULL,
	[ContentText] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AudienceType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ScheduledDate] [datetime2](7) NULL,
	[PublishedDate] [datetime2](7) NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PostId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Posts] ADD  DEFAULT ('Everyone') FOR [AudienceType]
GO
ALTER TABLE [dbo].[Posts] ADD  DEFAULT ('Published') FOR [Status]
GO
ALTER TABLE [dbo].[Posts] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Posts]  WITH CHECK ADD FOREIGN KEY([AuthorUserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reactions](
	[ReactionId] [bigint] IDENTITY(1,1) NOT NULL,
	[ContentType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ContentId] [bigint] NOT NULL,
	[UserId] [int] NOT NULL,
	[ReactionType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Reaction] UNIQUE NONCLUSTERED 
(
	[ContentType] ASC,
	[ContentId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Reactions] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Reactions]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RestrictedKeywords](
	[KeywordId] [int] IDENTITY(1,1) NOT NULL,
	[Keyword] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[KeywordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Keyword] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RoleName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[RoleCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SearchHistory](
	[UserId] [int] NOT NULL,
	[SearchTerm] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SearchedDate] [datetime2](7) NOT NULL
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[SearchHistory] ADD  DEFAULT (sysutcdatetime()) FOR [SearchedDate]
GO
ALTER TABLE [dbo].[SearchHistory]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shares](
	[ShareId] [bigint] IDENTITY(1,1) NOT NULL,
	[ContentType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ContentId] [bigint] NOT NULL,
	[UserId] [int] NOT NULL,
	[SharedToType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SharedToId] [bigint] NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ShareId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Shares] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Shares]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserCredentials](
	[UserId] [int] NOT NULL,
	[PasswordHash] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PasswordSalt] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastUpdated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_UserCredentials] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserCredentials] ADD  DEFAULT (sysutcdatetime()) FOR [LastUpdated]
GO
ALTER TABLE [dbo].[UserCredentials]  WITH CHECK ADD  CONSTRAINT [FK_UserCredentials_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserCredentials] CHECK CONSTRAINT [FK_UserCredentials_Users]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserInterests](
	[UserId] [int] NOT NULL,
	[Interest] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[Interest] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserInterests]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoles](
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([RoleId])
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeId] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FullName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Email] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Designation] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DepartmentId] [int] NULL,
	[Location] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProfilePhotoUrl] [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Bio] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BioVisibility] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NetworkVisibility] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PhotosVisibility] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[InterestsVisibility] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[SuspendedUntil] [datetime2](7) NULL,
	[IsPermanentlySuspended] [bit] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[LastSyncedFromHrmsDate] [datetime2](7) NULL,
	[MobileNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ManagerEmployeeId] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[JoiningDate] [date] NULL,
	[LastLogin] [datetime2](7) NULL,
	[ProfileCompletion] [tinyint] NOT NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_Users_Department] ON [dbo].[Users]
(
	[DepartmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_Users_Email] ON [dbo].[Users]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ('Public') FOR [BioVisibility]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ('Public') FOR [NetworkVisibility]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ('Public') FOR [PhotosVisibility]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ('Public') FOR [InterestsVisibility]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [IsPermanentlySuspended]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_ProfileCompletion]  DEFAULT ((0)) FOR [ProfileCompletion]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[Departments] ([DepartmentId])
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Manager] FOREIGN KEY([ManagerEmployeeId])
REFERENCES [dbo].[Users] ([EmployeeId])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Manager]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [CK_Users_BioVisibility] CHECK  (([BioVisibility]='Private' OR [BioVisibility]='Connections' OR [BioVisibility]='Public'))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [CK_Users_BioVisibility]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [CK_Users_InterestsVisibility] CHECK  (([InterestsVisibility]='Private' OR [InterestsVisibility]='Connections' OR [InterestsVisibility]='Public'))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [CK_Users_InterestsVisibility]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [CK_Users_NetworkVisibility] CHECK  (([NetworkVisibility]='Private' OR [NetworkVisibility]='Connections' OR [NetworkVisibility]='Public'))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [CK_Users_NetworkVisibility]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [CK_Users_PhotosVisibility] CHECK  (([PhotosVisibility]='Private' OR [PhotosVisibility]='Connections' OR [PhotosVisibility]='Public'))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [CK_Users_PhotosVisibility]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSkills](
	[UserId] [int] NOT NULL,
	[Skill] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[Skill] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[UserSkills]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Videos](
	[VideoId] [bigint] IDENTITY(1,1) NOT NULL,
	[UploaderUserId] [int] NOT NULL,
	[Title] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CategoryId] [int] NULL,
	[ThumbnailUrl] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SourceUrl] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FileSizeMb] [int] NULL,
	[ViewCount] [int] NOT NULL,
	[UploadedDate] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VideoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Videos] ADD  DEFAULT ((0)) FOR [ViewCount]
GO
ALTER TABLE [dbo].[Videos] ADD  DEFAULT (sysutcdatetime()) FOR [UploadedDate]
GO
ALTER TABLE [dbo].[Videos]  WITH CHECK ADD FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([CategoryId])
GO
ALTER TABLE [dbo].[Videos]  WITH CHECK ADD FOREIGN KEY([UploaderUserId])
REFERENCES [dbo].[Users] ([UserId])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VideoTags](
	[VideoId] [bigint] NOT NULL,
	[Tag] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VideoId] ASC,
	[Tag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[VideoTags]  WITH CHECK ADD FOREIGN KEY([VideoId])
REFERENCES [dbo].[Videos] ([VideoId])
GO


-- ============================================================
-- PART 2: FOREIGN KEY CONSTRAINTS
-- ============================================================

ALTER TABLE [dbo].[ArticleAttachments]  WITH CHECK ADD FOREIGN KEY([ArticleId])
REFERENCES [dbo].[Articles] ([ArticleId])
GO
ALTER TABLE [dbo].[Articles]  WITH CHECK ADD FOREIGN KEY([AuthorUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Articles]  WITH CHECK ADD FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([CategoryId])
GO
ALTER TABLE [dbo].[ArticleTags]  WITH CHECK ADD FOREIGN KEY([ArticleId])
REFERENCES [dbo].[Articles] ([ArticleId])
GO
ALTER TABLE [dbo].[ArticleVersions]  WITH CHECK ADD FOREIGN KEY([ArticleId])
REFERENCES [dbo].[Articles] ([ArticleId])
GO
ALTER TABLE [dbo].[ArticleVersions]  WITH CHECK ADD FOREIGN KEY([EditedByUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[AuditLog]  WITH CHECK ADD FOREIGN KEY([ActorUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Bookmarks]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD FOREIGN KEY([ParentCommentId])
REFERENCES [dbo].[Comments] ([CommentId])
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Communities]  WITH CHECK ADD FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([CategoryId])
GO
ALTER TABLE [dbo].[Communities]  WITH CHECK ADD FOREIGN KEY([CreatedByUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[CommunityAdmins]  WITH CHECK ADD FOREIGN KEY([CommunityId])
REFERENCES [dbo].[Communities] ([CommunityId])
GO
ALTER TABLE [dbo].[CommunityAdmins]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[CommunityMembers]  WITH CHECK ADD FOREIGN KEY([CommunityId])
REFERENCES [dbo].[Communities] ([CommunityId])
GO
ALTER TABLE [dbo].[CommunityMembers]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[CommunityPosts]  WITH CHECK ADD FOREIGN KEY([CommunityId])
REFERENCES [dbo].[Communities] ([CommunityId])
GO
ALTER TABLE [dbo].[CommunityPosts]  WITH CHECK ADD FOREIGN KEY([PostId])
REFERENCES [dbo].[Posts] ([PostId])
GO
ALTER TABLE [dbo].[ConnectionRequests]  WITH CHECK ADD FOREIGN KEY([ReceiverId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[ConnectionRequests]  WITH CHECK ADD FOREIGN KEY([SenderId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Followers]  WITH CHECK ADD FOREIGN KEY([FollowerUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Followers]  WITH CHECK ADD FOREIGN KEY([FollowingUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[Departments] ([DepartmentId])
GO
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD FOREIGN KEY([PostedByUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[KarmaBalances]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[KarmaTransactions]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[ModerationReports]  WITH CHECK ADD FOREIGN KEY([ModeratorUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[ModerationReports]  WITH CHECK ADD FOREIGN KEY([ReporterUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[NotificationPreferences]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Podcasts]  WITH CHECK ADD FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([CategoryId])
GO
ALTER TABLE [dbo].[Podcasts]  WITH CHECK ADD FOREIGN KEY([SeriesId])
REFERENCES [dbo].[PodcastSeries] ([SeriesId])
GO
ALTER TABLE [dbo].[Podcasts]  WITH CHECK ADD FOREIGN KEY([UploaderUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[PostAttachments]  WITH CHECK ADD FOREIGN KEY([PostId])
REFERENCES [dbo].[Posts] ([PostId])
GO
ALTER TABLE [dbo].[PostAudienceCommunities]  WITH CHECK ADD FOREIGN KEY([PostId])
REFERENCES [dbo].[Posts] ([PostId])
GO
ALTER TABLE [dbo].[PostAudienceCommunities]  WITH CHECK ADD  CONSTRAINT [FK_PostAudienceCommunities_Community] FOREIGN KEY([CommunityId])
REFERENCES [dbo].[Communities] ([CommunityId])
GO
ALTER TABLE [dbo].[PostAudienceCommunities] CHECK CONSTRAINT [FK_PostAudienceCommunities_Community]
GO
ALTER TABLE [dbo].[PostAudienceUsers]  WITH CHECK ADD FOREIGN KEY([PostId])
REFERENCES [dbo].[Posts] ([PostId])
GO
ALTER TABLE [dbo].[PostAudienceUsers]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[PostMentions]  WITH CHECK ADD FOREIGN KEY([MentionedUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[PostMentions]  WITH CHECK ADD FOREIGN KEY([PostId])
REFERENCES [dbo].[Posts] ([PostId])
GO
ALTER TABLE [dbo].[Posts]  WITH CHECK ADD FOREIGN KEY([AuthorUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Reactions]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[SearchHistory]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Shares]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserCredentials]  WITH CHECK ADD  CONSTRAINT [FK_UserCredentials_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserCredentials] CHECK CONSTRAINT [FK_UserCredentials_Users]
GO
ALTER TABLE [dbo].[UserInterests]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([RoleId])
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[Departments] ([DepartmentId])
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Manager] FOREIGN KEY([ManagerEmployeeId])
REFERENCES [dbo].[Users] ([EmployeeId])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Manager]
GO
ALTER TABLE [dbo].[UserSkills]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Videos]  WITH CHECK ADD FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([CategoryId])
GO
ALTER TABLE [dbo].[Videos]  WITH CHECK ADD FOREIGN KEY([UploaderUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[VideoTags]  WITH CHECK ADD FOREIGN KEY([VideoId])
REFERENCES [dbo].[Videos] ([VideoId])
GO

-- ============================================================
-- PART 3: SEED DATA (INSERT Statements)
-- ============================================================

-- Departments
SET IDENTITY_INSERT [dbo].[Departments] ON;
SET IDENTITY_INSERT [dbo].[Departments] ON 

INSERT [dbo].[Departments] ([DepartmentId], [Name], [DepartmentCode]) VALUES (1, N'HR', NULL)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [DepartmentCode]) VALUES (2, N'Finance', NULL)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [DepartmentCode]) VALUES (3, N'Technology', NULL)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [DepartmentCode]) VALUES (4, N'CTO', NULL)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [DepartmentCode]) VALUES (5, N'Marketing', NULL)
INSERT [dbo].[Departments] ([DepartmentId], [Name], [DepartmentCode]) VALUES (6, N'Information Technology', N'IT')
INSERT [dbo].[Departments] ([DepartmentId], [Name], [DepartmentCode]) VALUES (7, N'Human Resources', N'HR')
SET IDENTITY_INSERT [dbo].[Departments] OFF
SET IDENTITY_INSERT [dbo].[Departments] OFF;
GO

-- Roles
SET IDENTITY_INSERT [dbo].[Roles] ON;
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([RoleId], [RoleCode], [RoleName], [Description]) VALUES (1, N'EMP', N'Employee', NULL)
INSERT [dbo].[Roles] ([RoleId], [RoleCode], [RoleName], [Description]) VALUES (2, N'CADM', N'Community Admin', NULL)
INSERT [dbo].[Roles] ([RoleId], [RoleCode], [RoleName], [Description]) VALUES (3, N'HRADM', N'HR Administrator', NULL)
INSERT [dbo].[Roles] ([RoleId], [RoleCode], [RoleName], [Description]) VALUES (4, N'SYSADM', N'System Administrator', NULL)
SET IDENTITY_INSERT [dbo].[Roles] OFF
SET IDENTITY_INSERT [dbo].[Roles] OFF;
GO

-- Categories
SET IDENTITY_INSERT [dbo].[Categories] ON;
SET IDENTITY_INSERT [dbo].[Categories] ON 

INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (1, N'Technology', N'Article')
INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (2, N'Hobbies', N'Community')
INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (7, N'Engineering', N'Article')
INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (8, N'Design', N'Article')
INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (9, N'Product Management', N'Article')
INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (10, N'Company Culture', N'Article')
INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (11, N'Tech Talks', N'Video')
INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (12, N'Leadership', N'Podcast')
INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (13, N'Training & Tutorials', N'Video')
INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (14, N'Townhalls', N'Video')
INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (15, N'Engineering Tech Talks', N'Video')
INSERT [dbo].[Categories] ([CategoryId], [Name], [AppliesTo]) VALUES (16, N'Leadership Updates', N'Video')
SET IDENTITY_INSERT [dbo].[Categories] OFF
SET IDENTITY_INSERT [dbo].[Categories] OFF;
GO

-- Users
SET IDENTITY_INSERT [dbo].[Users] ON;
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([UserId], [EmployeeId], [FullName], [Email], [Designation], [DepartmentId], [Location], [ProfilePhotoUrl], [Bio], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [SuspendedUntil], [IsPermanentlySuspended], [CreatedDate], [LastSyncedFromHrmsDate], [MobileNo], [ManagerEmployeeId], [JoiningDate], [LastLogin], [ProfileCompletion], [CreatedBy], [ModifiedBy], [ModifiedDate]) VALUES (1, N'MPO101', N'Loveneesh Sharma', N'loveneesh.sharma@example.com', N'System Administrator', NULL, N'Bhopal', N'/uploads/profiles/user_1_3971b95d8b644059b8d83e9b880812be.jpg', N'I am a dedicated professional working at Knome, focused on bridging the gap between innovative technology. I spend my days strategizing and collaborating with cross-functional teams to deliver excellence.', N'Public', N'Public', N'Public', N'Public', 1, NULL, 0, CAST(N'2026-07-13T06:10:21.6466330' AS DateTime2), CAST(N'2026-07-17T12:28:02.6902763' AS DateTime2), N'', NULL, NULL, CAST(N'2026-07-17T12:28:02.6902765' AS DateTime2), 75, NULL, NULL, CAST(N'2026-08-04T10:25:47.4777817' AS DateTime2))
INSERT [dbo].[Users] ([UserId], [EmployeeId], [FullName], [Email], [Designation], [DepartmentId], [Location], [ProfilePhotoUrl], [Bio], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [SuspendedUntil], [IsPermanentlySuspended], [CreatedDate], [LastSyncedFromHrmsDate], [MobileNo], [ManagerEmployeeId], [JoiningDate], [LastLogin], [ProfileCompletion], [CreatedBy], [ModifiedBy], [ModifiedDate]) VALUES (2, N'MPO102', N'Vishendra Sharma', N'vishendra.sharma@example.com', N'Community Administrator', NULL, N'Bhopal', N'/uploads/profiles/user_2_d1062e5e4ee349c29ba9efc275ffec95.png', N'I am a dedicated professional working at Knome, focused on bridging the gap between innovative technology and user needs. I spend my days strategizing and collaborating with cross-functional teams to deliver excellence.', N'Public', N'Public', N'Public', N'Public', 1, NULL, 0, CAST(N'2026-07-13T06:10:21.6486579' AS DateTime2), CAST(N'2026-07-17T10:58:17.2764258' AS DateTime2), N'', NULL, NULL, CAST(N'2026-07-17T10:58:17.2764262' AS DateTime2), 75, NULL, NULL, CAST(N'2026-08-04T10:32:21.2421488' AS DateTime2))
INSERT [dbo].[Users] ([UserId], [EmployeeId], [FullName], [Email], [Designation], [DepartmentId], [Location], [ProfilePhotoUrl], [Bio], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [SuspendedUntil], [IsPermanentlySuspended], [CreatedDate], [LastSyncedFromHrmsDate], [MobileNo], [ManagerEmployeeId], [JoiningDate], [LastLogin], [ProfileCompletion], [CreatedBy], [ModifiedBy], [ModifiedDate]) VALUES (3, N'MPO103', N'Sourabh Sahu', N'sourabh.sahu@example.com', N'HR Administrator', 7, N'Bhopal', N'/uploads/profiles/user_3_976bd073c81c46da83b59cea5578dae6.jpg', N'', N'Public', N'Public', N'Public', N'Public', 1, NULL, 0, CAST(N'2026-07-13T06:10:21.6486579' AS DateTime2), CAST(N'2026-07-17T12:59:30.6103372' AS DateTime2), N'', NULL, NULL, CAST(N'2026-07-17T12:59:30.6103377' AS DateTime2), 85, NULL, NULL, CAST(N'2026-08-04T12:19:42.9236602' AS DateTime2))
INSERT [dbo].[Users] ([UserId], [EmployeeId], [FullName], [Email], [Designation], [DepartmentId], [Location], [ProfilePhotoUrl], [Bio], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [SuspendedUntil], [IsPermanentlySuspended], [CreatedDate], [LastSyncedFromHrmsDate], [MobileNo], [ManagerEmployeeId], [JoiningDate], [LastLogin], [ProfileCompletion], [CreatedBy], [ModifiedBy], [ModifiedDate]) VALUES (4, N'MPO104', N'Rishikesh Ugle', N'rishikesh.ugle@example.com', N'Software Engineer', NULL, N'Bhopal', N'/uploads/profiles/user_4_e17dcbd3cbe14b6fbf00cc1009dd045d.jpg', N'', N'Public', N'Public', N'Public', N'Public', 1, NULL, 0, CAST(N'2026-07-13T06:10:21.6506789' AS DateTime2), CAST(N'2026-07-17T12:48:35.8199640' AS DateTime2), N'', NULL, NULL, CAST(N'2026-07-17T12:48:35.8199646' AS DateTime2), 75, NULL, NULL, CAST(N'2026-08-04T11:53:24.6190036' AS DateTime2))
INSERT [dbo].[Users] ([UserId], [EmployeeId], [FullName], [Email], [Designation], [DepartmentId], [Location], [ProfilePhotoUrl], [Bio], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [SuspendedUntil], [IsPermanentlySuspended], [CreatedDate], [LastSyncedFromHrmsDate], [MobileNo], [ManagerEmployeeId], [JoiningDate], [LastLogin], [ProfileCompletion], [CreatedBy], [ModifiedBy], [ModifiedDate]) VALUES (5, N'MPO105', N'Meghna Tiwari', N'meghna.tiwari@example.com', N'Business Analyst', NULL, N'Bhopal', NULL, NULL, N'Public', N'Public', N'Public', N'Public', 1, NULL, 0, CAST(N'2026-07-13T06:10:21.6506789' AS DateTime2), CAST(N'2026-07-17T09:13:31.8660427' AS DateTime2), N'9999999999', NULL, NULL, CAST(N'2026-07-17T09:13:31.8660436' AS DateTime2), 75, NULL, NULL, CAST(N'2026-08-04T12:01:20.6522614' AS DateTime2))
INSERT [dbo].[Users] ([UserId], [EmployeeId], [FullName], [Email], [Designation], [DepartmentId], [Location], [ProfilePhotoUrl], [Bio], [BioVisibility], [NetworkVisibility], [PhotosVisibility], [InterestsVisibility], [IsActive], [SuspendedUntil], [IsPermanentlySuspended], [CreatedDate], [LastSyncedFromHrmsDate], [MobileNo], [ManagerEmployeeId], [JoiningDate], [LastLogin], [ProfileCompletion], [CreatedBy], [ModifiedBy], [ModifiedDate]) VALUES (6, N'MPO106', N'Mayur Verma', N'mayur.verma@example.com', N'UI Designer', NULL, N'Bhopal', N'/uploads/profiles/user_6_ee5c7a03cba741adb09ff0e0dae01947.jpg', N'', N'Public', N'Public', N'Public', N'Public', 1, NULL, 0, CAST(N'2026-07-13T06:10:21.6506789' AS DateTime2), CAST(N'2026-07-17T09:13:37.2840914' AS DateTime2), N'', NULL, NULL, CAST(N'2026-07-17T09:13:37.2840924' AS DateTime2), 75, NULL, NULL, CAST(N'2026-08-04T12:59:30.7613401' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Users] OFF
SET IDENTITY_INSERT [dbo].[Users] OFF;
GO

-- UserCredentials
INSERT [dbo].[UserCredentials] ([UserId], [PasswordHash], [PasswordSalt], [LastUpdated]) VALUES (1, N'$2a$11$CS8Szl.LS4r1zinkLjKb8ucRdww25eHjSGhqc6my/hQXCbb9DW0Nm', N'STATIC_SALT_FOR_BCRYPT', CAST(N'2026-07-20T04:58:24.4096464' AS DateTime2))
INSERT [dbo].[UserCredentials] ([UserId], [PasswordHash], [PasswordSalt], [LastUpdated]) VALUES (2, N'$2a$11$CS8Szl.LS4r1zinkLjKb8ucRdww25eHjSGhqc6my/hQXCbb9DW0Nm', N'STATIC_SALT_FOR_BCRYPT', CAST(N'2026-07-20T04:58:24.4096464' AS DateTime2))
INSERT [dbo].[UserCredentials] ([UserId], [PasswordHash], [PasswordSalt], [LastUpdated]) VALUES (3, N'$2a$11$CS8Szl.LS4r1zinkLjKb8ucRdww25eHjSGhqc6my/hQXCbb9DW0Nm', N'STATIC_SALT_FOR_BCRYPT', CAST(N'2026-07-20T04:58:24.4096464' AS DateTime2))
INSERT [dbo].[UserCredentials] ([UserId], [PasswordHash], [PasswordSalt], [LastUpdated]) VALUES (4, N'$2a$11$CS8Szl.LS4r1zinkLjKb8ucRdww25eHjSGhqc6my/hQXCbb9DW0Nm', N'STATIC_SALT_FOR_BCRYPT', CAST(N'2026-07-20T04:58:24.4096464' AS DateTime2))
INSERT [dbo].[UserCredentials] ([UserId], [PasswordHash], [PasswordSalt], [LastUpdated]) VALUES (5, N'$2a$11$CS8Szl.LS4r1zinkLjKb8ucRdww25eHjSGhqc6my/hQXCbb9DW0Nm', N'STATIC_SALT_FOR_BCRYPT', CAST(N'2026-07-20T04:58:24.4096464' AS DateTime2))
INSERT [dbo].[UserCredentials] ([UserId], [PasswordHash], [PasswordSalt], [LastUpdated]) VALUES (6, N'$2a$11$CS8Szl.LS4r1zinkLjKb8ucRdww25eHjSGhqc6my/hQXCbb9DW0Nm', N'STATIC_SALT_FOR_BCRYPT', CAST(N'2026-07-20T04:58:24.4096464' AS DateTime2))
GO

-- UserRoles
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (1, 4)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (2, 2)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (3, 3)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (4, 1)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (5, 1)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (6, 2)
GO

-- UserSkills
INSERT [dbo].[UserSkills] ([UserId], [Skill]) VALUES (1, N'C#')
INSERT [dbo].[UserSkills] ([UserId], [Skill]) VALUES (2, N'Community Management')
INSERT [dbo].[UserSkills] ([UserId], [Skill]) VALUES (3, N'HR Management')
GO

-- UserInterests
INSERT [dbo].[UserInterests] ([UserId], [Interest]) VALUES (1, N'Technology')
INSERT [dbo].[UserInterests] ([UserId], [Interest]) VALUES (2, N'Communities')
INSERT [dbo].[UserInterests] ([UserId], [Interest]) VALUES (3, N'Recruitment')
GO

-- Followers
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (1, 2, CAST(N'2026-07-30T13:19:53.3918193' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (1, 3, CAST(N'2026-07-30T13:22:56.4262096' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (1, 4, CAST(N'2026-07-23T12:47:50.6648167' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (1, 5, CAST(N'2026-07-24T09:08:00.4175661' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (1, 6, CAST(N'2026-07-30T13:25:24.9349445' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (2, 1, CAST(N'2026-07-27T07:11:18.1146943' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (2, 3, CAST(N'2026-07-31T04:32:22.1934765' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (2, 4, CAST(N'2026-07-24T06:29:03.4913597' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (2, 5, CAST(N'2026-07-27T05:31:08.2155427' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (2, 6, CAST(N'2026-07-28T11:26:48.0666496' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (3, 1, CAST(N'2026-07-30T13:22:56.4262096' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (3, 2, CAST(N'2026-07-31T04:32:22.1934765' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (3, 5, CAST(N'2026-07-24T10:25:33.0083996' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (3, 6, CAST(N'2026-07-23T12:37:57.5040579' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (4, 1, CAST(N'2026-07-13T06:10:21.8257217' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (4, 2, CAST(N'2026-07-24T06:29:03.4913597' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (4, 3, CAST(N'2026-08-03T12:20:11.0292442' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (4, 5, CAST(N'2026-07-28T11:24:10.5766847' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (4, 6, CAST(N'2026-07-23T12:29:39.6458718' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (5, 1, CAST(N'2026-07-24T09:08:00.4175661' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (5, 2, CAST(N'2026-07-27T05:31:08.2155427' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (5, 3, CAST(N'2026-07-24T10:25:33.0083996' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (5, 4, CAST(N'2026-07-28T11:24:10.5766847' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (5, 6, CAST(N'2026-07-27T09:45:18.2733047' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (6, 1, CAST(N'2026-07-30T13:25:24.9349445' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (6, 2, CAST(N'2026-07-28T11:26:48.0666496' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (6, 3, CAST(N'2026-07-23T12:37:57.5040579' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (6, 4, CAST(N'2026-07-23T12:29:39.6458718' AS DateTime2))
INSERT [dbo].[Followers] ([FollowerUserId], [FollowingUserId], [FollowedDate]) VALUES (6, 5, CAST(N'2026-07-30T07:05:37.2223381' AS DateTime2))
GO

-- ConnectionRequests
SET IDENTITY_INSERT [dbo].[ConnectionRequests] ON;
SET IDENTITY_INSERT [dbo].[ConnectionRequests] ON 

INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (1, 4, 5, N'Connected', CAST(N'2026-07-23T11:36:21.4000000' AS DateTime2), CAST(N'2026-07-28T11:24:10.2016136' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (2, 2, 4, N'Connected', CAST(N'2026-07-23T12:24:47.4033333' AS DateTime2), CAST(N'2026-07-24T06:29:03.0630619' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (3, 2, 5, N'Connected', CAST(N'2026-07-23T12:28:41.4733333' AS DateTime2), CAST(N'2026-07-27T05:31:08.0548213' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (4, 4, 6, N'Connected', CAST(N'2026-07-23T12:29:22.3366667' AS DateTime2), CAST(N'2026-07-23T12:29:39.0047968' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (5, 6, 5, N'Connected', CAST(N'2026-07-23T12:32:48.6200000' AS DateTime2), CAST(N'2026-07-30T10:45:11.3373513' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (6, 3, 6, N'Connected', CAST(N'2026-07-23T12:37:38.9300000' AS DateTime2), CAST(N'2026-07-23T12:37:57.4067376' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (7, 1, 4, N'Connected', CAST(N'2026-07-23T12:47:26.1700000' AS DateTime2), CAST(N'2026-07-23T12:47:50.5612178' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (8, 1, 5, N'Connected', CAST(N'2026-07-24T09:07:29.8400000' AS DateTime2), CAST(N'2026-07-24T09:08:00.1530798' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (9, 5, 3, N'Connected', CAST(N'2026-07-24T10:25:14.0700000' AS DateTime2), CAST(N'2026-07-24T10:25:32.8412602' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (10, 1, 2, N'Connected', CAST(N'2026-07-27T07:11:02.3333333' AS DateTime2), CAST(N'2026-07-30T13:19:53.2183049' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (11, 4, 3, N'Connected', CAST(N'2026-07-27T13:02:39.2666667' AS DateTime2), CAST(N'2026-08-03T12:20:10.9133411' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (12, 2, 6, N'Connected', CAST(N'2026-07-28T11:26:26.6766667' AS DateTime2), CAST(N'2026-07-28T11:26:47.9522964' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (13, 2, 3, N'Connected', CAST(N'2026-07-30T13:19:45.0800000' AS DateTime2), CAST(N'2026-07-31T04:32:22.0392724' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (14, 3, 1, N'Connected', CAST(N'2026-07-30T13:22:29.7133333' AS DateTime2), CAST(N'2026-07-30T13:22:56.2452535' AS DateTime2))
INSERT [dbo].[ConnectionRequests] ([RequestId], [SenderId], [ReceiverId], [Status], [CreatedDate], [UpdatedDate]) VALUES (15, 1, 6, N'Connected', CAST(N'2026-07-30T13:25:00.4566667' AS DateTime2), CAST(N'2026-07-30T13:25:24.8520430' AS DateTime2))
SET IDENTITY_INSERT [dbo].[ConnectionRequests] OFF
SET IDENTITY_INSERT [dbo].[ConnectionRequests] OFF;
GO

-- Communities
SET IDENTITY_INSERT [dbo].[Communities] ON;
SET IDENTITY_INSERT [dbo].[Communities] ON 

INSERT [dbo].[Communities] ([CommunityId], [Name], [Description], [BannerUrl], [ThumbnailUrl], [CategoryId], [Rules], [Faq], [CommunityType], [CreatedByUserId], [CreatedDate]) VALUES (1, N'Tech Hub', N'Technology Discussions', NULL, NULL, 1, NULL, NULL, N'Public', 2, CAST(N'2026-07-13T06:10:21.9846716' AS DateTime2))
INSERT [dbo].[Communities] ([CommunityId], [Name], [Description], [BannerUrl], [ThumbnailUrl], [CategoryId], [Rules], [Faq], [CommunityType], [CreatedByUserId], [CreatedDate]) VALUES (2, N'DotNet Developers Community', N'The DotNet Developers Community is a place for developers, students, software engineers, architects, and technology enthusiasts who are passionate about Microsoft .NET technologies. Our mission is to help members learn, build, collaborate, and grow together by sharing practical knowledge, real-world experiences, and industry best practices.', N'', N'oklch(0.58 0.16 234)', 1, N'Be respectful and professional.
Help others whenever possible.
Share accurate technical information.
No spam, promotions, or self-advertising without permission.
Keep discussions related to software development and technology.
Use descriptive titles when asking questions.
Share code snippets using proper formatting.
Encourage learning and collaboration.', N'1. What is the .NET Developers Community?

The .NET Developers Community is a platform where developers, students, and technology enthusiasts can learn, collaborate, share knowledge, and stay updated with the latest Microsoft .NET technologies.

2. Who can join this community?

Anyone interested in .NET development can join, including:

Students
Beginners
Software Developers
Full Stack Developers
Backend Developers
Architects
DevOps Engineers
Tech Enthusiasts
3. Is the community free to join?

Yes. Membership is completely free.

4. What technologies are covered?

Our community focuses on:

C#
.NET
ASP.NET Core
Web API
Entity Framework Core
SQL Server
Blazor
.NET MAUI
Azure
Docker
Kubernetes
Microservices
Clean Architecture
Design Patterns
Git & GitHub
5. Can beginners join?

Absolutely! Beginners are welcome, and members are encouraged to ask questions and learn from the community.

6. Can I ask coding questions?

Yes. You can ask technical questions, share code snippets, and seek guidance from experienced developers.

7. Can I share my projects?

Yes. Members are encouraged to showcase personal, academic, and open-source projects to receive constructive feedback.

8. Are job opportunities shared?

Yes. We share relevant job openings, internships, freelance opportunities, and hiring updates whenever available.

9. Do you organize events?

Yes. We organize:

Live coding sessions
Technical workshops
Webinars
Q&A sessions
Community discussions
Project showcases
10. How can I contribute?

You can contribute by:

Answering questions
Writing technical articles
Sharing useful resources
Contributing to open-source projects
Mentoring beginners
Speaking at community events
11. What are the community rules?
Be respectful to all members.
No spam or irrelevant promotions.
Keep discussions professional and technology-focused.
Use respectful language.
Share accurate and helpful information.
Respect intellectual property and licensing.
12. How do I stay updated?

Stay active in the community, enable notifications, and participate in discussions and events to receive the latest updates.

13. Can I invite my friends or colleagues?

Yes. Everyone interested in .NET development is welcome to join and contribute.

14. How do I become a community moderator?

Active contributors who consistently help others, maintain professionalism, and positively support the community may be invited to become moderators.

15. How can I contact the community administrators?

You can reach out to the administrators through the community platform''s direct messaging feature or the designated contact channel provided by the community.', N'Public', 3, CAST(N'2026-07-13T11:41:14.7874840' AS DateTime2))
INSERT [dbo].[Communities] ([CommunityId], [Name], [Description], [BannerUrl], [ThumbnailUrl], [CategoryId], [Rules], [Faq], [CommunityType], [CreatedByUserId], [CreatedDate]) VALUES (3, N'Higher', NULL, NULL, NULL, 7, NULL, NULL, N'Public', 1, CAST(N'2026-07-27T05:53:02.3112183' AS DateTime2))
INSERT [dbo].[Communities] ([CommunityId], [Name], [Description], [BannerUrl], [ThumbnailUrl], [CategoryId], [Rules], [Faq], [CommunityType], [CreatedByUserId], [CreatedDate]) VALUES (4, N'Cloud & DevOps Excellence', N'Enterprise hub for cloud architecture, Kubernetes, CI/CD pipelines, and DevOps best practices at MPOnline.', NULL, NULL, NULL, N'1. Be respectful
2. Share technical insights
3. No spam', N'Q: Who can join?
A: Any MPOnline employee!', N'Public', 1, CAST(N'2026-07-30T05:47:13.0776156' AS DateTime2))
INSERT [dbo].[Communities] ([CommunityId], [Name], [Description], [BannerUrl], [ThumbnailUrl], [CategoryId], [Rules], [Faq], [CommunityType], [CreatedByUserId], [CreatedDate]) VALUES (5, N'DevOps & AI Innovation Hub', N'Enterprise community for DevOps engineers, ML pipelines, and Cloud Infrastructure at MPOnline.', NULL, NULL, NULL, N'1. Respect everyone
2. Share technical knowledge
3. No self-promotion', N'Q: Who can join?
A: Open to all employees!', N'Public', 2, CAST(N'2026-07-30T05:47:33.4648535' AS DateTime2))
INSERT [dbo].[Communities] ([CommunityId], [Name], [Description], [BannerUrl], [ThumbnailUrl], [CategoryId], [Rules], [Faq], [CommunityType], [CreatedByUserId], [CreatedDate]) VALUES (6, N'DevOps & AI Innovation Hub', N'Enterprise community for DevOps engineers, ML pipelines, and Cloud Infrastructure at MPOnline.', NULL, NULL, NULL, N'1. Respect everyone
2. Share technical knowledge
3. No self-promotion', N'Q: Who can join?
A: Open to all employees!', N'Public', 2, CAST(N'2026-07-30T05:59:11.6411137' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Communities] OFF
SET IDENTITY_INSERT [dbo].[Communities] OFF;
GO

-- CommunityMembers
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (1, 1, N'Subscriber', N'Approved', CAST(N'2026-07-13T06:10:22.0005503' AS DateTime2), NULL)
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (1, 2, N'Admin', N'Approved', CAST(N'2026-07-13T06:10:22.0005503' AS DateTime2), NULL)
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (1, 3, N'Subscriber', N'Approved', CAST(N'2026-07-13T06:10:22.0005503' AS DateTime2), NULL)
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (1, 4, N'Subscriber', N'Approved', CAST(N'2026-07-13T06:10:22.0005503' AS DateTime2), NULL)
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (1, 5, N'Subscriber', N'Approved', CAST(N'2026-07-13T06:10:22.0005503' AS DateTime2), NULL)
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (1, 6, N'Subscriber', N'Approved', CAST(N'2026-07-13T06:10:22.0005503' AS DateTime2), NULL)
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (2, 2, N'Subscriber', N'Approved', CAST(N'2026-08-03T12:38:42.3731592' AS DateTime2), CAST(N'2026-08-03T12:38:42.3731593' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (2, 3, N'Member', N'Approved', CAST(N'2026-07-13T11:41:14.8271752' AS DateTime2), CAST(N'2026-07-13T11:41:14.8272088' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (2, 6, N'Subscriber', N'Approved', CAST(N'2026-08-03T12:38:00.3617248' AS DateTime2), CAST(N'2026-08-03T12:38:00.3618381' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (3, 1, N'Moderator', N'Approved', CAST(N'2026-07-27T05:53:02.5983102' AS DateTime2), CAST(N'2026-07-27T05:53:02.5984381' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (4, 1, N'Moderator', N'Approved', CAST(N'2026-07-30T05:47:13.2395886' AS DateTime2), CAST(N'2026-07-30T05:47:13.2396642' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (4, 2, N'Subscriber', N'Approved', CAST(N'2026-07-30T05:47:13.7889610' AS DateTime2), CAST(N'2026-07-30T05:47:13.7889612' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (5, 2, N'Moderator', N'Approved', CAST(N'2026-07-30T05:47:33.4795117' AS DateTime2), CAST(N'2026-07-30T05:47:33.4795118' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (5, 4, N'Subscriber', N'Approved', CAST(N'2026-07-30T05:47:33.7829197' AS DateTime2), CAST(N'2026-07-30T05:47:33.7829199' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (6, 1, N'Subscriber', N'Approved', CAST(N'2026-07-30T06:07:10.7768930' AS DateTime2), CAST(N'2026-07-30T06:07:10.7768931' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (6, 2, N'Moderator', N'Approved', CAST(N'2026-07-30T05:59:11.6813620' AS DateTime2), CAST(N'2026-07-30T05:59:11.6813621' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (6, 3, N'Subscriber', N'Approved', CAST(N'2026-07-30T06:08:50.4690241' AS DateTime2), CAST(N'2026-07-30T06:08:50.4690244' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (6, 4, N'Subscriber', N'Approved', CAST(N'2026-07-30T05:59:11.9809582' AS DateTime2), CAST(N'2026-07-30T05:59:11.9809583' AS DateTime2))
INSERT [dbo].[CommunityMembers] ([CommunityId], [UserId], [MemberType], [Status], [RequestedDate], [DecidedDate]) VALUES (6, 6, N'Subscriber', N'Approved', CAST(N'2026-07-30T07:23:09.0412828' AS DateTime2), CAST(N'2026-07-30T07:23:09.0413268' AS DateTime2))
GO

-- Posts
SET IDENTITY_INSERT [dbo].[Posts] ON;
SET IDENTITY_INSERT [dbo].[Posts] ON 

INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (1, 5, N'Welcome to Tech Hub!', N'Everyone', N'Published', NULL, NULL, CAST(N'2026-07-13T06:10:22.1285003' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (3, 3, N'Dependency Injection (DI) is one of the most important concepts in modern ASP.NET Core development. It helps you build applications that are clean, maintainable, and easy to test.', N'Everyone', N'Published', NULL, CAST(N'2026-07-15T07:14:05.1405240' AS DateTime2), CAST(N'2026-07-15T07:14:05.1404819' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (14, 2, N'🚀 .NET Developers: Small Improvements Create Big Results!
Every great .NET developer starts with writing clean, maintainable, and scalable code—not just code that works.', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T06:30:37.1718807' AS DateTime2), CAST(N'2026-07-17T06:30:37.1717877' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (15, 2, N'🚀 .NET Developers: Small Improvements Create Big Results!
Every great .NET developer starts with writing clean, maintainable, and scalable code—not just code that works.', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T06:37:36.2820365' AS DateTime2), CAST(N'2026-07-17T06:37:36.2820355' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (16, 2, N'🚀 .NET Developers: Small Improvements Create Big Results!
Every great .NET developer starts with writing clean, maintainable, and scalable code—not just code that works.', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T06:38:40.0674703' AS DateTime2), CAST(N'2026-07-17T06:38:40.0674693' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (17, 2, N'I used sql server.', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T06:47:24.5010885' AS DateTime2), CAST(N'2026-07-17T06:47:24.5009836' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (18, 2, N'@Sourabh Sahu, I Learn sql.', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T06:53:50.6990241' AS DateTime2), CAST(N'2026-07-17T06:53:50.6990236' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (19, 2, N'i worked on dot net.', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T08:40:36.6607812' AS DateTime2), CAST(N'2026-07-17T08:40:36.6607804' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (20, 3, N'I learned .net.
', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T08:45:54.7632671' AS DateTime2), CAST(N'2026-07-17T08:45:54.7632664' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (23, 4, N'my first post.', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T09:44:27.2370217' AS DateTime2), CAST(N'2026-07-17T09:44:27.2370201' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (24, 3, N'Strong leadership is built through continuous learning, collaboration, and shared experiences. Welcome to Leadership Circle, a private community where leaders come together to exchange ideas, discuss challenges, and inspire one another to achieve excellence.', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T10:43:14.7871376' AS DateTime2), CAST(N'2026-07-17T10:43:14.7870345' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (25, 4, N'Engineering Is More Than Writing Code
Engineering isn''t just about building software—it''s about solving real-world problems with logic, creativity, and collaboration.', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T10:51:09.0082780' AS DateTime2), CAST(N'2026-07-17T10:51:09.0082777' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (26, 3, N'I am created one dotnet project.', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T12:35:38.9187433' AS DateTime2), CAST(N'2026-07-17T12:35:38.9186463' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (27, 4, N'I learn sql.', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T12:45:06.1245798' AS DateTime2), CAST(N'2026-07-17T12:45:06.1244802' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (28, 3, N'⚙️ The Engineer''s Mindset
Great engineers don''t just build software—they build trust, reliability, and innovation.
Every line of code, every system design, and every technical decision contributes to creating products that solve real-world problems.
#Engineering #SoftwareEngineering #Developer #Programming #Tech #Coding#SoftwareDevelopment #Innovation', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T12:48:26.2626434' AS DateTime2), CAST(N'2026-07-17T12:48:26.2626429' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (29, 4, N'Technology evolves rapidly, but one platform continues to power everything from enterprise applications to cloud-native services: .NET.
Whether you''re building REST APIs, web applications, desktop software, mobile apps, or microservices, .NET provides the performance, security, and flexibility needed to deliver reliable solutions.
#DotNet #DotNet8 #DotNet9 #CSharp #ASPNETCore ', N'Everyone', N'Published', NULL, CAST(N'2026-07-17T12:59:24.4109988' AS DateTime2), CAST(N'2026-07-17T12:59:24.4109966' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (30, 5, N'Welcome to Tech Hub!', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (32, 3, N'Dependency Injection (DI) is one of the most important concepts in modern ASP.NET Core development. It helps you build applications that are clean, maintainable, and easy to test.', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (33, 4, N'ðŸš€ .NET Developers: Small Improvements Create Big Results!
Every great .NET developer starts with writing clean, maintainable, and scalable codeâ€”not just code that works.', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (34, 4, N'ðŸš€ .NET Developers: Small Improvements Create Big Results!
Every great .NET developer starts with writing clean, maintainable, and scalable codeâ€”not just code that works.', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (35, 4, N'ðŸš€ .NET Developers: Small Improvements Create Big Results!
Every great .NET developer starts with writing clean, maintainable, and scalable codeâ€”not just code that works.', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (36, 6, N'I used sql server.', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (37, 2, N'@Sourabh Sahu, I Learn sql.', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (38, 5, N'i worked on dot net.', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (40, 6, N'Shared a post from @Sourabh Sahu:

"I learned .net."', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (42, 2, N'Strong leadership is built through continuous learning, collaboration, and shared experiences. Welcome to Leadership Circle, a private community where leaders come together to exchange ideas, discuss challenges, and inspire one another to achieve excellence.', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (43, 3, N'Engineering Is More Than Writing Code
Engineering isn''t just about building softwareâ€”it''s about solving real-world problems with logic, creativity, and collaboration.', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (45, 4, N'I learn sql.', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2), CAST(N'2026-07-20T05:05:30.0700000' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (49, 3, N'My first Post.', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:26:32.7965235' AS DateTime2), CAST(N'2026-07-20T05:26:32.7965255' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (50, 3, N'?? Building modern applications with .NET 8!
From Minimal APIs and Entity Framework Core to Dependency Injection and Clean Architecture, .NET empowers developers to build secure, scalable, and high-performance applications.
Every line of clean code is an investment in the future.
#DotNet #ASPNETCore #CSharp #EntityFrameworkCore #WebAPI #SoftwareDevelopment', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T05:39:37.5130725' AS DateTime2), CAST(N'2026-07-20T05:39:37.5131096' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (55, 4, N'New Technology is Changing the World—Faster Than Ever
We are living in an era where innovation is no longer optional—it''s shaping the future every single day.
Technologies transforming our world:
Artificial Intelligence (AI) & Generative AI
Cloud Computing
Cybersecurity
Internet of Things (IoT)
Machine Learning
#Technology #Innovation #ArtificialIntelligence #GenerativeAI', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T06:34:01.3916150' AS DateTime2), CAST(N'2026-07-20T06:34:01.3916969' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (56, 3, N'.NET 8 Web API: Building Modern, Scalable Enterprise Applications
 Why .NET 8 is becoming the preferred choice for enterprise development?
Modern businesses need applications that are fast, secure, scalable, and cloud-ready. With ASP.NET Core 8, developers can build high-performance APIs and enterprise solutions with advanced features.
#DotNet #NET8 #CSharp #ASPNetCore', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T06:54:47.5277834' AS DateTime2), CAST(N'2026-07-20T06:54:47.5279868' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (61, 3, N'tech world', N'Everyone', N'Published', NULL, CAST(N'2026-07-20T09:21:16.1696015' AS DateTime2), CAST(N'2026-07-20T09:21:16.1696023' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10055, 6, N'Hello Knome community! This is post number 1 by Mayur Verma. Sharing my thoughts today!', N'Everyone', N'Published', NULL, CAST(N'2026-07-22T06:14:34.9313971' AS DateTime2), CAST(N'2026-07-22T06:14:34.9314136' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10056, 6, N'Hello Knome community! This is post number 2 by Mayur Verma. Sharing my thoughts today!', N'Everyone', N'Published', NULL, CAST(N'2026-07-22T06:14:35.2719527' AS DateTime2), CAST(N'2026-07-22T06:14:35.2719530' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10057, 6, N'Hello Knome community! This is post number 3 by Mayur Verma. Sharing my thoughts today!', N'Everyone', N'Published', NULL, CAST(N'2026-07-22T06:14:35.3252844' AS DateTime2), CAST(N'2026-07-22T06:14:35.3252847' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10058, 6, N'Hello Knome community! This is post number 4 by Mayur Verma. Sharing my thoughts today!', N'Everyone', N'Published', NULL, CAST(N'2026-07-22T06:14:35.3873589' AS DateTime2), CAST(N'2026-07-22T06:14:35.3873592' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10059, 6, N'Hello Knome community! This is post number 5 by Mayur Verma. Sharing my thoughts today!', N'Everyone', N'Published', NULL, CAST(N'2026-07-22T06:14:35.4482973' AS DateTime2), CAST(N'2026-07-22T06:14:35.4482977' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10065, 2, N'My name.', N'Everyone', N'Published', NULL, CAST(N'2026-07-22T11:36:57.5937487' AS DateTime2), CAST(N'2026-07-22T11:36:57.5939886' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10066, 2, N'hey.', N'Everyone', N'Published', NULL, CAST(N'2026-07-22T11:39:29.2146393' AS DateTime2), CAST(N'2026-07-22T11:39:29.2146405' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10067, 2, N'TESTING', N'Everyone', N'Published', NULL, CAST(N'2026-07-22T11:46:48.1777136' AS DateTime2), CAST(N'2026-07-22T11:46:48.1777160' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10069, 3, N'I have one video.', N'Everyone', N'Published', NULL, CAST(N'2026-07-22T12:03:43.7940987' AS DateTime2), CAST(N'2026-07-22T12:03:43.7940998' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10074, 4, N'first post', N'Everyone', N'Published', NULL, CAST(N'2026-07-27T13:06:37.4873370' AS DateTime2), CAST(N'2026-07-27T13:06:37.4873385' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10076, 4, N'Excited to join DevOps & AI Innovation Hub! Here is our latest Docker & Kubernetes setup guide for MPOnline microservices. #devops #kubernetes', N'Community', N'Published', NULL, CAST(N'2026-07-30T05:47:33.8602491' AS DateTime2), CAST(N'2026-07-30T05:47:33.8603181' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10077, 4, N'Excited to join DevOps & AI Innovation Hub! Here is our latest Docker & Kubernetes setup guide for MPOnline microservices. #devops #kubernetes', N'Community', N'Published', NULL, CAST(N'2026-07-30T05:59:12.0568081' AS DateTime2), CAST(N'2026-07-30T05:59:12.0568084' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10078, 4, N'my great achievement today. ', N'Everyone', N'Published', NULL, CAST(N'2026-07-30T13:12:31.7493501' AS DateTime2), CAST(N'2026-07-30T13:12:31.7496215' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10079, 2, N'react is best for creating frontend.', N'Everyone', N'Published', NULL, CAST(N'2026-07-30T13:21:56.7548024' AS DateTime2), CAST(N'2026-07-30T13:21:56.7548028' AS DateTime2))
INSERT [dbo].[Posts] ([PostId], [AuthorUserId], [ContentText], [AudienceType], [Status], [ScheduledDate], [PublishedDate], [CreatedDate]) VALUES (10081, 2, N'JSX is a powerful syntax extension in React that makes writing and managing UI components easier and more readable.
It lets developers write HTML-like code directly inside JavaScript.
JSX improves code clarity by combining structure and logic in one place.
It is compiled into regular JavaScript before running in the browser.', N'Everyone', N'Published', NULL, CAST(N'2026-08-03T10:48:10.0940112' AS DateTime2), CAST(N'2026-08-03T10:48:10.0942720' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Posts] OFF
SET IDENTITY_INSERT [dbo].[Posts] OFF;
GO

-- PostAttachments
SET IDENTITY_INSERT [dbo].[PostAttachments] ON;
SET IDENTITY_INSERT [dbo].[PostAttachments] ON 

INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (4, 14, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (5, 15, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (6, 16, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (7, 17, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (8, 19, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (9, 20, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Document', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (11, 23, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Video', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (12, 24, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (13, 24, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Document', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (14, 24, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Video', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (15, 25, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (16, 27, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (17, 27, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Document', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (18, 28, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (19, 29, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (24, 55, N'/uploads/media/media_bc61b4763d104924abb50176be180e3d.png', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (25, 56, N'/uploads/media/media_c51c4f22dfa44e3ba771220d2f17ff9c.png', N'Image', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (26, 56, N'/uploads/media/media_750f03fa397140c99a52ac1b3e8c7727.docx', N'Document', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (33, 61, N'/uploads/media/media_5f3e5c1c491f457e9d8e586bd39fa5d0.mp4', N'Video', CAST(N'2026-07-27T06:30:13.6595298' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (10031, 10078, N'/uploads/media/media_70b0df7632474dc6bfcff0891882f6ed.png', N'Image', CAST(N'2026-07-30T13:12:32.8421281' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (10032, 10079, N'/uploads/media/media_2bf1a4b46ab648e6a97c5b11d0ba17b3.jpg', N'Image', CAST(N'2026-07-30T13:21:56.7665341' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (10033, 10081, N'/uploads/media/media_23d2e6c2410645ec93ceac00a753db02.png', N'Image', CAST(N'2026-08-03T10:48:10.1779711' AS DateTime2))
INSERT [dbo].[PostAttachments] ([AttachmentId], [PostId], [FileUrl], [FileType], [PublishedDate]) VALUES (10034, 10081, N'/uploads/media/media_76ef205419d64a79bf4b79b2746278c6.pdf', N'Document', CAST(N'2026-08-03T10:48:10.1905174' AS DateTime2))
SET IDENTITY_INSERT [dbo].[PostAttachments] OFF
SET IDENTITY_INSERT [dbo].[PostAttachments] OFF;
GO

-- PostAudienceCommunities: (empty)
-- PostAudienceUsers: (empty)
-- CommunityPosts
INSERT [dbo].[CommunityPosts] ([CommunityId], [PostId], [IsPinned]) VALUES (1, 1, 1)
GO

-- CommunityAdmins
INSERT [dbo].[CommunityAdmins] ([CommunityId], [UserId]) VALUES (1, 2)
INSERT [dbo].[CommunityAdmins] ([CommunityId], [UserId]) VALUES (2, 3)
INSERT [dbo].[CommunityAdmins] ([CommunityId], [UserId]) VALUES (3, 1)
INSERT [dbo].[CommunityAdmins] ([CommunityId], [UserId]) VALUES (4, 1)
INSERT [dbo].[CommunityAdmins] ([CommunityId], [UserId]) VALUES (5, 2)
INSERT [dbo].[CommunityAdmins] ([CommunityId], [UserId]) VALUES (6, 2)
GO

-- Articles
SET IDENTITY_INSERT [dbo].[Articles] ON;
SET IDENTITY_INSERT [dbo].[Articles] ON 

INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (1, 1, N'Getting Started with .NET', N'Basics', N'<p>Introduction to .NET and C# for Knome users.</p>', 1, N'Published', NULL, NULL, 0, 0, 0, CAST(N'2026-07-13T06:10:22.0005503' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (2, 4, N'A comprehensive guide on hybrid search indexing and retrieval', N'This is a comprehensive guide to hybrid search indexing and retrieval techniques. We combine dense vector embeddings with classical BM25 keyword matching to achieve high precision ...', N'This is a comprehensive guide to hybrid search indexing and retrieval techniques. We combine dense vector embeddings with classical BM25 keyword matching to achieve high precision and recall on complex queries. Our evaluation harness shows a significant jump in recall, making internal help documentation search highly effective.', 2, N'Published', NULL, CAST(N'2026-07-13T09:55:41.8174313' AS DateTime2), 2, 0, 0, CAST(N'2026-07-13T09:55:41.8173790' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (12, 2, N'10 ASP.NET Core Best Practices Every .NET Developer Should Follow in 2026', N'Modern software development is about building applications that are secure, easy to extend. ...', N'Modern software development is about building applications that are secure, easy to extend. ', 1, N'Published', NULL, CAST(N'2026-07-13T10:13:55.1964194' AS DateTime2), 2, 0, 0, CAST(N'2026-07-13T10:13:55.1964188' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (14, 3, N'ASP.NET Core 8 in 2026: Why It Remains the Best Choice for Enterprise Web API Development', N'ASP.NET Core 8 continues to be one of the strongest frameworks for enterprise backend development in 2026. Its combination of performance, security, scalability, and cloud readines...', N'ASP.NET Core 8 continues to be one of the strongest frameworks for enterprise backend development in 2026. Its combination of performance, security, scalability, and cloud readiness makes it suitable for applications ranging from simple APIs to large-scale distributed systems.', 1, N'Published', NULL, CAST(N'2026-07-13T11:31:17.3373232' AS DateTime2), 4, 0, 0, CAST(N'2026-07-13T11:31:17.3373228' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (15, 3, N'.NET: A Complete Guide for Modern Application Development', N'The .NET platform, developed by Microsoft, is one of the most powerful and widely used frameworks for building modern applications. Whether you are creating web applications, RESTf...', N'The .NET platform, developed by Microsoft, is one of the most powerful and widely used frameworks for building modern applications. Whether you are creating web applications, RESTful APIs, desktop software, cloud-native services, mobile applications, or enterprise systems, .NET provides a robust, secure, and high-performance ecosystem.', 1, N'Published', NULL, CAST(N'2026-07-13T12:46:16.2383848' AS DateTime2), 1, 0, 0, CAST(N'2026-07-13T12:46:16.2382498' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (16, 3, N'.NET: A Complete Guide for Modern Application Development', N'The .NET platform, developed by Microsoft, is one of the most powerful and widely used frameworks for building modern applications....', N'The .NET platform, developed by Microsoft, is one of the most powerful and widely used frameworks for building modern applications.', 1, N'Published', NULL, CAST(N'2026-07-13T12:48:17.9796759' AS DateTime2), 1, 0, 0, CAST(N'2026-07-13T12:48:17.9796753' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (17, 3, N'.NET: A Complete Guide for Modern Application Development', N'The .NET platform, developed by Microsoft, is one of the most powerful and widely used frameworks for building modern applications....', N'The .NET platform, developed by Microsoft, is one of the most powerful and widely used frameworks for building modern applications.', 1, N'Published', NULL, CAST(N'2026-07-13T12:51:17.7437945' AS DateTime2), 2, 0, 0, CAST(N'2026-07-13T12:51:17.7436972' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (18, 3, N'Getting Started with ASP.NET Core 8: A Modern Framework for Web Development', N'No summary provided', N'ASP.NET Core 8 is Microsoft''s latest cross-platform framework for building high-performance web applications, REST APIs, cloud-native solutions, and microservices. It is open-source, lightweight, and designed to run seamlessly on Windows, Linux, and macOS.

Whether you''re a beginner or an experienced .NET developer, ASP.NET Core 8 offers powerful tools to create scalable and secure applications with minimal effort.', 1, N'Published', NULL, CAST(N'2026-07-17T06:53:01.0737881' AS DateTime2), 1, 0, 0, CAST(N'2026-07-17T06:53:01.0737179' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (19, 5, N'Mastering Dependency Injection in ASP.NET Core', N'No summary provided', N'Start writiDependency Injection (DI) is one of the most important design patterns in modern software development. ASP.NET Core has built-in support for Dependency Injection, making it easier to create loosely coupled, maintainable, and testable applications.

Instead of creating object instances manually, DI allows the framework to provide the required dependencies automatically. This reduces code complexity and improves application architecture.ng your long-form article here...', 1, N'Published', NULL, CAST(N'2026-07-17T06:57:35.9092759' AS DateTime2), 1, 0, 0, CAST(N'2026-07-17T06:57:35.9092751' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (20, 5, N'Mastering Dependency Injection in ASP.NET Core', N'No summary provided', N'Dependency Injection (DI) is one of the most important design patterns in modern software development. ASP.NET Core has built-in support for Dependency Injection, making it easier to create loosely coupled, maintainable, and testable applications.', 7, N'Published', NULL, CAST(N'2026-07-17T07:11:36.0834506' AS DateTime2), 1, 0, 0, CAST(N'2026-07-17T07:11:36.0834500' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (21, 5, N'Design Patterns in .NET: Building Scalable and Maintainable Applications', N'No summary provided', N'As software projects grow in size and complexity, writing clean and maintainable code becomes increasingly important. Design patterns provide proven solutions to recurring software design problems, helping developers create applications that are easier to understand, extend, and test..', 8, N'Published', NULL, CAST(N'2026-07-17T07:13:21.5949206' AS DateTime2), 1, 0, 0, CAST(N'2026-07-17T07:13:21.5949201' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (22, 5, N'Product Management: Turning Ideas into Successful Products', N'No summary provided', N'In today''s fast-paced digital world, building a successful product requires much more than writing code. It demands a clear vision, a deep understanding of customer needs, strategic planning, and continuous collaboration across teams. This is where Product Management plays a vital role.', 9, N'Published', NULL, CAST(N'2026-07-17T07:15:08.8491721' AS DateTime2), 1, 0, 0, CAST(N'2026-07-17T07:15:08.8491717' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (23, 5, N'Computer Science & Software Engineering', N'No summary provided', N'<p class="isSelectedEnd">Focuses on developing software applications, cloud platforms, artificial intelligence, cybersecurity, and distributed systems.</p><p class="isSelectedEnd">Key Areas:</p><ul data-spread="false"><li>Software Development</li><li>Artificial Intelligence</li><li>Machine Learning</li><li>Cloud Computing</li><li>Cybersecurity</li><li>Data Engineering</li><li>Mobile Application Development.</li></ul>', 7, N'Published', NULL, CAST(N'2026-07-17T07:24:29.2936060' AS DateTime2), 1, 0, 0, CAST(N'2026-07-17T07:24:29.2936052' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (24, 3, N'Building a Strong Company Culture Through Knowledge Sharing', N'No summary provided', N'<p data-start="281" data-end="565" class="PDq2pG_selectionAnchorContainer">A successful organization is built on more than products and services—it is built on people. When employees openly share knowledge, collaborate across teams, and continuously learn from one another, they create a workplace culture that drives innovation, trust, and long-term success.<span aria-hidden="true" class="PDq2pG_selectionAnchor"></span></p><p data-start="567" data-end="683">Knowledge sharing empowers every team member to contribute their expertise while helping others grow professionally.</p><hr data-start="685" data-end="688"><h2 data-start="690" data-end="722">Why Knowledge Sharing Matters</h2><p data-start="724" data-end="762">Knowledge sharing helps organizations:</p><ul data-start="764" data-end="1016">
<li data-start="764" data-end="807">
Improve collaboration across departments.
</li>
<li data-start="808" data-end="854">
Reduce duplicate work and repeated mistakes.
</li>
<li data-start="855" data-end="897">
Accelerate onboarding for new employees.
</li>
<li data-start="898" data-end="930">
Encourage continuous learning.
</li>
<li data-start="931" data-end="976">
Preserve valuable organizational knowledge.
</li>
<li data-start="977" data-end="1016">
Increase productivity and efficiency.
</li>
</ul><p data-start="1018" data-end="1093">When employees freely exchange ideas and best practices, everyone benefits.</p><hr data-start="1095" data-end="1098"><h2 data-start="1100" data-end="1142">Core Values of a Strong Company Culture</h2><p data-start="1144" data-end="1198">A healthy workplace culture is built on shared values.</p><h3 data-start="1200" data-end="1220">🤝 Collaboration</h3><p data-start="1221" data-end="1287">Work together, support teammates, and solve problems collectively.</p><h3 data-start="1289" data-end="1315">📚 Continuous Learning</h3><p data-start="1316" data-end="1390">Encourage employees to learn new technologies, tools, and industry trends.</p><h3 data-start="1392" data-end="1409">💡 Innovation</h3><p data-start="1410" data-end="1494">Promote creative thinking and welcome new ideas that improve processes and products.</p><h3 data-start="1496" data-end="1510">🌟 Respect</h3><p data-start="1511" data-end="1577">Treat every colleague with professionalism, empathy, and fairness.</p><h3 data-start="1579" data-end="1600">🎯 Accountability</h3><p data-start="1601" data-end="1661">Take ownership of responsibilities and deliver quality work.</p><h3 data-start="1663" data-end="1692">🔄 Continuous Improvement</h3><p class="opacity-50">




















</p><p data-start="1693" data-end="1764">Seek feedback, reflect on experiences, and strive to improve every day.</p>', 10, N'Published', NULL, CAST(N'2026-07-17T10:01:50.0964965' AS DateTime2), 1, 0, 0, CAST(N'2026-07-17T10:01:50.0964958' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (25, 4, N'The Evolution of Modern Leadership in .NET Architecture', N'No summary provided', N'<p data-path-to-node="1"><i data-path-to-node="1" data-index-in-node="0">Building autonomous systems by empowering technical teams.</i></p><p data-path-to-node="2" id="p-rc_79d589fb585f5cc0-36"><span data-path-to-node="2,0">In the world of software engineering, traditional top-down command structures are rapidly becoming legacy tech. Just as modern .NET environments rely on distributed, scalable, and asynchronous microservices rather than rigid monolithic structures, contemporary engineering leadership requires a major architectural pivot</span><span data-path-to-node="2,1"><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><source-footnote _nghost-ng-c3698509682="" class="ng-star-inserted"><sup _ngcontent-ng-c3698509682="" class="superscript"><!----></sup></source-footnote><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----></span><span data-path-to-node="2,2">: <b data-path-to-node="2,2" data-index-in-node="2">moving away from centralized command and toward distributed team autonomy.</b></span></p>', 7, N'Published', NULL, CAST(N'2026-07-20T07:22:33.1552111' AS DateTime2), 0, 0, 53, CAST(N'2026-07-20T07:22:33.1553944' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (26, 2, N'Changing the World with AI: How Intelligent Machines are Rewriting the Human Story', NULL, N'<p class="opacity-50">We are no longer just imagining the future of artificial intelligence; we are actively living in it. AI has officially transitioned from a specialized tech tool to the primary engine driving global change. From reshaping how we treat diseases to fund changing the nature of work, the AI revolution isn''t just coming—it is already altering the fabric of our daily lives.</p><p class="opacity-50">We are no longer just imagining the future of artificial intelligence; we are actively living in it. AI has officially transitioned from a specialized tech tool to the primary engine driving global change. From reshaping how we treat diseases to fund changing the nature of work, the AI revolution isn''t just coming—it is already altering the fabric of our daily lives.</p>', 7, N'Published', NULL, CAST(N'2026-07-20T10:15:39.8751672' AS DateTime2), 0, 0, 39, CAST(N'2026-07-20T10:15:39.8753022' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (27, 2, N'Changing the World with AI: How Intelligent Machines are Rewriting the Human Story', NULL, N'<p class="opacity-50">We are no longer just imagining the future of artificial intelligence; we are actively living in it. AI has officially transitioned from a specialized tech tool to the primary engine driving global change. From reshaping how we treat diseases to fund changing the nature of work, the AI revolution isn''t just coming—it is already altering the fabric of our daily lives.</p><p class="opacity-50">We are no longer just imagining the future of artificial intelligence; we are actively living in it. AI has officially transitioned from a specialized tech tool to the primary engine driving global change.</p>', 7, N'Published', NULL, CAST(N'2026-07-20T10:16:00.1451205' AS DateTime2), 0, 0, 31, CAST(N'2026-07-20T10:16:00.1451211' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (28, 2, N'First Article', NULL, N'<p class="opacity-50">My First Article.</p>', 7, N'Published', NULL, CAST(N'2026-07-20T10:36:43.5846187' AS DateTime2), 0, 0, 2, CAST(N'2026-07-20T10:36:43.5847247' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (29, 3, N'The New Architecture of Belonging: Reimagining Company Culture for the Modern Era', NULL, N'<p data-path-to-node="1">Culture isn’t what is written on a plaque in the office lobby; it’s what happens when no one is looking. It is the sum total of how a team communicates, makes decisions, handles failure, and celebrates success.</p><p data-path-to-node="2">As the&nbsp; of the traditional workplace have permanently blurred, building a vibrant, resilient company culture has shifted from a human resources initiative to a core business strategy. The organizations thriving today are those that treat culture not as a static set of rules, but as a living, breathing ecosystem.</p><p data-path-to-node="3">Here is how forward-thinking companies are architecting cultures that attract top talent and drive sustainable growth.</p>', 7, N'Published', NULL, CAST(N'2026-07-20T10:42:11.9959232' AS DateTime2), 0, 0, 34, CAST(N'2026-07-20T10:42:11.9959241' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (10025, 6, N'The Future of Software Development: Why AI-Assisted Coding Is Becoming an Essential Skill', NULL, N'<h1></h1><h2>Introduction</h2><p class="isSelectedEnd">Software development has evolved dramatically over the past decade. From manual coding to cloud-native applications, developers have continuously adapted to new tools and methodologies. Today, Artificial Intelligence (AI) is driving the next major transformation. AI-assisted coding is no longer a futuristic concept—it is becoming a standard part of modern software development.</p><p>Rather than replacing developers, AI acts as an intelligent assistant that helps write code, detect bugs, generate documentation, and automate repetitive tasks. Developers who learn to work effectively with AI will be more productive and better prepared for the future of the industry.</p>', 7, N'Published', NULL, CAST(N'2026-07-22T06:22:38.7816774' AS DateTime2), 0, 0, 32, CAST(N'2026-07-22T06:22:38.7817988' AS DateTime2))
INSERT [dbo].[Articles] ([ArticleId], [AuthorUserId], [Title], [Description], [ContentHtml], [CategoryId], [Status], [ScheduledDate], [PublishedDate], [ViewCount], [UniqueReadCount], [AvgReadTimeSeconds], [CreatedDate]) VALUES (10028, 2, N'Testing', NULL, N'<p class="opacity-50">Start writing your long-form article here...</p>', 8, N'Published', NULL, CAST(N'2026-07-27T06:24:56.4114749' AS DateTime2), 0, 0, 3, CAST(N'2026-07-27T06:24:56.4114755' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Articles] OFF
SET IDENTITY_INSERT [dbo].[Articles] OFF;
GO

-- ArticleAttachments
SET IDENTITY_INSERT [dbo].[ArticleAttachments] ON;
SET IDENTITY_INSERT [dbo].[ArticleAttachments] ON 

INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (11, 15, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (12, 17, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Image', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (13, 18, N'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&q=80&w=1200&h=400', N'image', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (14, 19, N'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&q=80&w=1200&h=400', N'image', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (15, 20, N'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&q=80&w=1200&h=400', N'image', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (16, 21, N'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&q=80&w=1200&h=400', N'image', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (17, 22, N'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&q=80&w=1200&h=400', N'image', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (18, 23, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'image', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (19, 24, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'image', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (20, 25, N'/uploads/media/media_10884f41025c440293f2dcb83978c614.png', N'File', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (23, 28, N'/uploads/media/media_6870f65a396749af904d1a4a8e576c90.png', N'File', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (24, 29, N'/uploads/media/media_873dbb7d0c7d480cb81698128fc11d90.png', N'File', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (25, 29, N'/uploads/media/media_cd65682b3fb4408d936c72421a9c9938.pdf', N'File', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (10020, 10025, N'/uploads/media/media_7b49d1e8ed884dec9437644983c21fc9.png', N'File', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
INSERT [dbo].[ArticleAttachments] ([AttachmentId], [ArticleId], [FileUrl], [FileType], [PublishedDate]) VALUES (10023, 10028, N'/uploads/media/media_a9d04aaf5faa449687e673db01d6143e.mp4', N'File', CAST(N'2026-07-27T06:30:13.6127603' AS DateTime2))
SET IDENTITY_INSERT [dbo].[ArticleAttachments] OFF
SET IDENTITY_INSERT [dbo].[ArticleAttachments] OFF;
GO

-- ArticleTags
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (2, N'evaluation')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (2, N'hybrid')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (2, N'search')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (12, N'.NET 8')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (12, N'ASP.NET Core')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (12, N'C# and EF Core.')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (14, N'#Dotnet')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (15, N'.net')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (15, N'asp.net core')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (15, N'backend development')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (15, N'c#')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (15, N'cloud computing')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (15, N'dotnet 8')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (15, N'entity framework core')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (15, N'software engineering')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (15, N'sql server')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (15, N'web api')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (16, N'.net')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (16, N'asp.net core')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (16, N'backend development')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (16, N'c#')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (16, N'cloud computing')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (16, N'dotnet 8')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (16, N'entity framework core')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (16, N'software engineering')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (16, N'sql server')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (16, N'web api')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (17, N'.net')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (17, N'asp.net core')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (17, N'backend development')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (17, N'c#')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (17, N'cloud computing')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (17, N'dotnet 8')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (17, N'entity framework core')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (17, N'software engineering')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (17, N'sql server')
INSERT [dbo].[ArticleTags] ([ArticleId], [Tag]) VALUES (17, N'web api')
GO

-- Videos
SET IDENTITY_INSERT [dbo].[Videos] ON;
SET IDENTITY_INSERT [dbo].[Videos] ON 

INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (2, 3, N'Complete ASP.NET Core 8 & .NET Full Course for Beginners | Learn C#, Web API & EF Core', N'🚀 Learn ASP.NET Core 8 and .NET from beginner to advanced in this comprehensive course.

In this video, you''ll learn:

✅ Introduction to .NET & .NET 8
✅ C# Programming Basics
✅ ASP.NET Core Architecture
✅ Creating Web APIs
✅ HTTP Methods (GET, POST, PUT, DELETE)
✅ Entity Framework Core
✅ SQL Server Integration
✅ Dependency Injection
✅ Repository Pattern
✅ Authentication & JWT
✅ Swagger API Testing
✅ CRUD Operations
✅ Error Handling
✅ Logging
✅ File Upload
✅ Best Practices
✅ Real-world Project Structure

This course is perfect for:
• Beginners
• Students
• Software Developers
• Interview Preparation
• Anyone who wants to become an ASP.NET Core Developer

🔗 Source Video:
https://www.youtube.com/watch?v=8JsP5ZHpp5o

#dotnet #aspnetcore #csharp #webapi #entityframework #sqlserver #programming #backend #developer #softwareengineering', 1, N'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&q=80&w=800', N'Embedded', N'https://www.youtube.com/watch?v=8JsP5ZHpp5o', NULL, 1, CAST(N'2026-07-13T12:33:18.9986871' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (5, 2, N'Inside the Future: AI Supercomputer & Quantum Data Center in 8K | Sci-Fi Technology Animation', N'Experience a breathtaking journey through a futuristic AI-powered data center where quantum computing, artificial intelligence, and next-generation digital infrastructure come together.', 13, N'/uploads/media/media_a50e8df78abb42c18f4119c3245053e1.png', N'LocalUpload', N'/uploads/media/media_d843342f47b54770b66dc511813c8b3c.mp4', 11, 0, CAST(N'2026-07-21T06:39:54.8000932' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (6, 3, N'nature', N'Nature beauty', 14, NULL, N'LocalUpload', N'/uploads/media/media_bfb9fb0f6b1d46369516491d6b2e84e1.mp4', 31, 0, CAST(N'2026-07-21T06:55:56.2827434' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (7, 5, N'Learning Software Engineering During the Era of AI', N'What happens when the future of your profession is challenged by the very technology it helped create? In this eye-opening TEDxCSTU talk, veteran technologist and entrepreneur Raymond Fu explores a provocative question: If AI can write code, is it still worth learning software engineering?

Drawing from decades of experience leading innovation in the tech industry, and reflecting on his role as both a professor and the father of a future engineer, Raymond offers a bold new perspective on what it means to be a software engineer in the AI era. With real-world examples, personal insights, and a touch of humor, he explores how AI is reshaping the profession, and why human engineers are more essential than ever.', 15, NULL, N'Stream', N'https://www.youtube.com/watch?v=w4rG5GY9IlA', NULL, 0, CAST(N'2026-07-21T07:03:30.9391462' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (8, 1, N'Effective Leadership & Team Building', N'A great session on how to lead teams effectively in modern organizations.', 16, N'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&q=80&w=800&h=450', N'OneDrive', N'https://www.youtube.com/watch?v=u4ZoJKF_VuA', 0, 150, CAST(N'2026-07-21T12:51:53.3533333' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (9, 5, N'abc', N'afgagagh', 13, NULL, N'Stream', N'https://www.youtube.com/watch?v=ebtBVb0Vrcs&list=RDebtBVb0Vrcs&start_radio=1', NULL, 0, CAST(N'2026-07-21T10:07:22.4090574' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10003, 4, N'tech', N'This is technical world.', 13, NULL, N'LocalUpload', N'/uploads/media/media_3899824177b1406187e0aafcd21d01b7.mp4', 9, 0, CAST(N'2026-07-22T06:58:33.2148756' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10004, 5, N'Changing tech', N'Tech is regularly change.', 13, N'/uploads/media/media_381986d165ba4bf3b0ef1077f6e11ca1.png', N'LocalUpload', N'/uploads/media/media_25a9c9e890e04528b3e22df2caee9f44.mp4', 11, 0, CAST(N'2026-07-24T09:12:39.2442223' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10005, 5, N'VideoCheck', N'Just to check.', 15, NULL, N'LocalUpload', N'/uploads/media/media_a542ba8f52a445278813a52b99bad4fd.mp4', 9, 0, CAST(N'2026-07-27T09:50:31.4198637' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10006, 1, N'Quantum core', N'', 13, N'/uploads/media/media_29fdfe51c46c4e41966f6a9a0114fc2f.jpg', N'LocalUpload', N'/uploads/media/media_2e45d467c3c14c7d90c37d3a52d7b41d.mp4', 5, 0, CAST(N'2026-07-31T10:01:44.4440936' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10007, 3, N'Qunt', N'THis is tech.', 13, N'/uploads/media/media_87f06ac3e4f640029f4707167f102a50.jpg', N'LocalUpload', N'/uploads/media/media_2a87ce92a1814fa3acd7ca15ef81ad8b.mp4', 5, 0, CAST(N'2026-08-03T10:23:59.8109782' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10008, 1, N'this', N'This is tech', 13, N'/uploads/media/media_0d7ab2ef60f4457cb8607f2c1faaf94f.jpg', N'LocalUpload', N'/uploads/media/media_2e97633e4e9d49a5b681b0dd577af4dd.mp4', 5, 0, CAST(N'2026-08-03T10:25:28.0980527' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10009, 1, N'AI', N'Changing the world using AI.', 13, N'/uploads/media/media_65811c7d759b4de08bc384244f8b750f.jpg', N'LocalUpload', N'/uploads/media/media_f51868af11e44d9b9d772dabc1dd758f.mp4', 2, 0, CAST(N'2026-08-04T11:03:46.2891725' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10010, 1, N'Human Brain', N'Neural networks are computational models inspired by the human brain that learn patterns from data without programming.', 13, N'/uploads/media/media_d76cc1219df74b0babe759067abef37d.jpg', N'LocalUpload', N'/uploads/media/media_754906945be04301b250cd6d656b8b35.mp4', 10, 0, CAST(N'2026-08-04T11:08:29.2490007' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10011, 1, N'Machine learning', N'', 13, N'/uploads/media/media_c8f349517ea5400d86813152b087b66e.jpg', N'LocalUpload', N'/uploads/media/media_0248ce033d6040d3946204e941b385ec.mp4', 2, 0, CAST(N'2026-08-04T11:19:34.6616218' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10014, 3, N'robot', N'robot video', 13, N'/uploads/media/media_848d199fffec47b09e154ea13b16474c.jpg', N'LocalUpload', N'/uploads/media/media_aeface44d71f493888dd824ba048f2ea.mp4', 7, 0, CAST(N'2026-08-04T12:22:45.9608323' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10015, 3, N'Abhishek tech related', N'', 13, NULL, N'Stream', N'https://www.youtube.com/watch?v=yXhncpJTzyI', NULL, 0, CAST(N'2026-08-04T12:25:35.5126836' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10016, 3, N'sales force', N'sales froce', 13, NULL, N'Stream', N'https://www.youtube.com/watch?v=F8UE0OCyiFM', NULL, 0, CAST(N'2026-08-04T12:30:30.8094414' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10017, 3, N'Salesforce Full Stack Developer Roadmap 2026', N'Salesforce Full Stack Developer Roadmap 2026

Uploaded via Enterprise Video Portal. Channel: Coding Tuition', 13, N'https://i.ytimg.com/vi/F8UE0OCyiFM/hqdefault.jpg', N'Stream', N'https://www.youtube.com/watch?v=F8UE0OCyiFM', NULL, 0, CAST(N'2026-08-04T12:37:52.0667973' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10018, 3, N'The ml', N'', 13, N'/uploads/media/media_0662317746c24046bf54557584a54648.jpg', N'LocalUpload', N'/uploads/media/media_c816aa280f854df2b49de73c7552daf3.mp4', 10, 0, CAST(N'2026-08-04T12:57:02.5692076' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10019, 1, N'THE AI', N'', 13, N'/uploads/media/media_41905c9879774e77997c6503c8db2554.jpg', N'LocalUpload', N'/uploads/media/media_6c07008435fd4d04a3155a557a8b0cba.mp4', 2, 0, CAST(N'2026-08-04T13:01:05.5445845' AS DateTime2))
INSERT [dbo].[Videos] ([VideoId], [UploaderUserId], [Title], [Description], [CategoryId], [ThumbnailUrl], [SourceType], [SourceUrl], [FileSizeMb], [ViewCount], [UploadedDate]) VALUES (10020, 1, N'JavaScript Full Course | JavaScript - Learn Everything | Sheryians Coding School', N'JavaScript Full Course | JavaScript - Learn Everything | Sheryians Coding School

Uploaded via Enterprise Video Portal. Channel: Sheryians Coding School', 13, N'https://i.ytimg.com/vi/a-wVHL0lpb0/hqdefault.jpg', N'Stream', N'https://www.youtube.com/watch?v=a-wVHL0lpb0&list=PLbtI3_MArDOnNvk8CCCSR01CQ8B8iNh-A', NULL, 0, CAST(N'2026-08-05T05:47:56.5175979' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Videos] OFF
SET IDENTITY_INSERT [dbo].[Videos] OFF;
GO

-- VideoTags
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'.net tutorial')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'asp.net core')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'asp.net core 8')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'backend development')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'beginner tutorial')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'c#')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'crud')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'csharp')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'dependency injection')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'dotnet')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'ef core')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'entity framework core')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'jwt authentication')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'programming')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'repository pattern')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'rest api')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'software engineering')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'sql server')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'swagger')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (2, N'web api')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#8K')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#AI')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Animation')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Artificial')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Center')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Cloud')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Computer')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Computing')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Cyberpunk')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Data')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Deep')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Digital')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Fiction')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Future')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Futuristic')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Generation')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#High')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Infrastructure')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Innovation')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Intelligence')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Learning')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Machine')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Network')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Neural')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Next')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Processing')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Quantum')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Room')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Science')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Sci-Fi')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Server')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Supercomputer')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Tech')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Technology')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Virtual')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#Visualization')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (5, N'#World')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (6, N'#Nature')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (7, N'#Innovation')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (7, N'#PersonalGrowth')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (7, N'#TEDxTalks')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (9, N'#youtube')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (10003, N'#tech')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (10004, N'#Tech')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (10011, N'#ML')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (10015, N'#tcs')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (10016, N'#tcs')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (10017, N'#salesforce')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (10018, N'#ML')
INSERT [dbo].[VideoTags] ([VideoId], [Tag]) VALUES (10020, N'#JS')
GO

-- PodcastSeries
SET IDENTITY_INSERT [dbo].[PodcastSeries] ON;
SET IDENTITY_INSERT [dbo].[PodcastSeries] ON 

INSERT [dbo].[PodcastSeries] ([SeriesId], [Title], [Description]) VALUES (1, N'Tech Talks', N'Latest technology')
INSERT [dbo].[PodcastSeries] ([SeriesId], [Title], [Description]) VALUES (2, N'Leadership Insights', N'Leadership')
SET IDENTITY_INSERT [dbo].[PodcastSeries] OFF
SET IDENTITY_INSERT [dbo].[PodcastSeries] OFF;
GO

-- Podcasts
SET IDENTITY_INSERT [dbo].[Podcasts] ON;
SET IDENTITY_INSERT [dbo].[Podcasts] ON 

INSERT [dbo].[Podcasts] ([PodcastId], [UploaderUserId], [Title], [Description], [CoverImageUrl], [DurationSeconds], [CategoryId], [SeriesId], [FileSizeMb], [UploadedDate], [AudioUrl]) VALUES (1, 6, N'Tech Talk Episode 1', N'Introduction Podcast', NULL, NULL, NULL, 1, NULL, CAST(N'2026-07-13T06:10:22.0005503' AS DateTime2), N'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3')
INSERT [dbo].[Podcasts] ([PodcastId], [UploaderUserId], [Title], [Description], [CoverImageUrl], [DurationSeconds], [CategoryId], [SeriesId], [FileSizeMb], [UploadedDate], [AudioUrl]) VALUES (2, 3, N'The Mountain ', N'Welcome to The Mountain Podcast ?????

Escape the noise and discover the beauty of the mountains through inspiring conversations, breathtaking landscapes, and stories that fuel adventure. Whether you''re a hiker, traveler, nature lover, or someone seeking peace and motivation, this podcast brings you closer to the wild.', NULL, 150, NULL, NULL, NULL, CAST(N'2026-07-21T09:26:35.0503227' AS DateTime2), N'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3')
INSERT [dbo].[Podcasts] ([PodcastId], [UploaderUserId], [Title], [Description], [CoverImageUrl], [DurationSeconds], [CategoryId], [SeriesId], [FileSizeMb], [UploadedDate], [AudioUrl]) VALUES (3, 2, N'the_mountain', N'Welcome to The Mountain Podcast ?????

Escape the noise and discover the beauty of the mountains through inspiring conversations, breathtaking landscapes, and stories that fuel adventure. Whether you''re a hiker, traveler, nature lover, or someone seeking peace and motivation, this podcast brings you closer to the wild.', NULL, 150, NULL, NULL, NULL, CAST(N'2026-07-21T09:34:33.9179787' AS DateTime2), N'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3')
INSERT [dbo].[Podcasts] ([PodcastId], [UploaderUserId], [Title], [Description], [CoverImageUrl], [DurationSeconds], [CategoryId], [SeriesId], [FileSizeMb], [UploadedDate], [AudioUrl]) VALUES (10002, 5, N'AI based', N'AI is a future of tech.', N'/uploads/media/media_06db4e227b8e440185963342300223c4.png', 152, NULL, NULL, NULL, CAST(N'2026-07-24T09:15:34.9562234' AS DateTime2), N'/uploads/media/media_c6fd193038fc4997bb0f40c816ba995f.mp3')
INSERT [dbo].[Podcasts] ([PodcastId], [UploaderUserId], [Title], [Description], [CoverImageUrl], [DurationSeconds], [CategoryId], [SeriesId], [FileSizeMb], [UploadedDate], [AudioUrl]) VALUES (10003, 5, N'Tech', N'Tech is everything.', NULL, 152, NULL, NULL, NULL, CAST(N'2026-07-24T09:16:53.2855802' AS DateTime2), N'/uploads/media/media_5a30bfaf5b0e4aa2903e4b326de811eb.mp3')
INSERT [dbo].[Podcasts] ([PodcastId], [UploaderUserId], [Title], [Description], [CoverImageUrl], [DurationSeconds], [CategoryId], [SeriesId], [FileSizeMb], [UploadedDate], [AudioUrl]) VALUES (10004, 6, N'tech related prodcast', N'tech related prodcast', NULL, 152, NULL, NULL, NULL, CAST(N'2026-07-28T11:38:18.0267198' AS DateTime2), N'/uploads/media/media_fed9d6bd901a4c218e559e18ff120b54.mp3')
INSERT [dbo].[Podcasts] ([PodcastId], [UploaderUserId], [Title], [Description], [CoverImageUrl], [DurationSeconds], [CategoryId], [SeriesId], [FileSizeMb], [UploadedDate], [AudioUrl]) VALUES (10005, 1, N'The tech', N'Tech is everything.', N'/uploads/media/media_2e15fd2d902543c09cba8a8cc43bb3e7.png', 202, NULL, NULL, NULL, CAST(N'2026-07-31T10:10:14.9734002' AS DateTime2), N'/uploads/media/media_bf4857bf501344c0b46f494ae30206cb.mp3')
SET IDENTITY_INSERT [dbo].[Podcasts] OFF
SET IDENTITY_INSERT [dbo].[Podcasts] OFF;
GO

-- Jobs
SET IDENTITY_INSERT [dbo].[Jobs] ON;
SET IDENTITY_INSERT [dbo].[Jobs] ON 

INSERT [dbo].[Jobs] ([JobId], [Title], [DepartmentId], [Description], [SkillsRequired], [Location], [ClosingDate], [ApplicationLink], [PostedByUserId], [PostedDate], [Status]) VALUES (1, N'Software Engineer', 6, N'Hiring .NET Developer', N'C#, SQL Server', N'Bhopal', CAST(N'2026-12-31' AS Date), N'https://company.example/apply', 3, CAST(N'2026-07-13T06:10:22.0005503' AS DateTime2), N'Open')
SET IDENTITY_INSERT [dbo].[Jobs] OFF
SET IDENTITY_INSERT [dbo].[Jobs] OFF;
GO

-- Reactions
SET IDENTITY_INSERT [dbo].[Reactions] ON;
SET IDENTITY_INSERT [dbo].[Reactions] ON 

INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (2, N'Article', 14, 3, N'Like', CAST(N'2026-07-13T12:51:38.0258062' AS DateTime2))
INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (7, N'Post', 10059, 4, N'Like', CAST(N'2026-07-22T06:44:39.9093339' AS DateTime2))
INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (12, N'Post', 10067, 3, N'Like', CAST(N'2026-07-22T11:55:59.2559723' AS DateTime2))
INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (14, N'Post', 10069, 2, N'Like', CAST(N'2026-07-23T05:18:51.6872097' AS DateTime2))
INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (15, N'Post', 10069, 3, N'Like', CAST(N'2026-07-23T11:29:33.6808625' AS DateTime2))
INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (16, N'Post', 10069, 4, N'Like', CAST(N'2026-07-23T11:29:44.4985962' AS DateTime2))
INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (17, N'Post', 10069, 6, N'Like', CAST(N'2026-07-23T12:36:55.3917516' AS DateTime2))
INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (23, N'Post', 10005, 2, N'Like', CAST(N'2026-07-31T12:41:19.0210067' AS DateTime2))
INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (24, N'Post', 10081, 5, N'Like', CAST(N'2026-08-04T10:57:58.2338227' AS DateTime2))
INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (26, N'Post', 10081, 1, N'Like', CAST(N'2026-08-05T09:47:20.9923036' AS DateTime2))
INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (27, N'Post', 10079, 1, N'Like', CAST(N'2026-08-05T09:47:33.7738474' AS DateTime2))
INSERT [dbo].[Reactions] ([ReactionId], [ContentType], [ContentId], [UserId], [ReactionType], [CreatedDate]) VALUES (28, N'Post', 10077, 1, N'Like', CAST(N'2026-08-05T09:52:25.9172939' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Reactions] OFF
SET IDENTITY_INSERT [dbo].[Reactions] OFF;
GO

-- Comments
SET IDENTITY_INSERT [dbo].[Comments] ON;
SET IDENTITY_INSERT [dbo].[Comments] ON 

INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (1, N'Post', 1, 2, NULL, N'Great post!', NULL, CAST(N'2026-07-13T06:10:22.1470586' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (2, N'Post', 10059, 4, NULL, N'nice post', NULL, CAST(N'2026-07-22T06:45:17.2505044' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (3, N'Post', 10059, 4, NULL, N'nice post', NULL, CAST(N'2026-07-22T06:45:20.1089928' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (4, N'Post', 10059, 4, NULL, N'nice post', NULL, CAST(N'2026-07-22T06:45:46.7495142' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (28, N'Post', 10059, 4, NULL, N'hello', NULL, CAST(N'2026-07-22T06:56:57.0803743' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (29, N'Post', 61, 4, NULL, N'hello', NULL, CAST(N'2026-07-22T06:57:09.7408569' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (30, N'Post', 61, 4, NULL, N'hello', NULL, CAST(N'2026-07-22T06:57:09.9210685' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (31, N'Post', 61, 4, NULL, N'hello', NULL, CAST(N'2026-07-22T06:57:10.1475651' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (32, N'Post', 61, 4, NULL, N'hello', NULL, CAST(N'2026-07-22T06:57:11.0788342' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (54, N'Post', 10069, 2, NULL, N'hello
', NULL, CAST(N'2026-07-23T05:19:30.1408246' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (55, N'Post', 10069, 2, NULL, N'nice post', NULL, CAST(N'2026-07-23T05:21:53.8803904' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (56, N'Article', 10028, 1, NULL, N'hello', NULL, CAST(N'2026-07-29T09:25:24.6534995' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (57, N'Article', 10028, 6, NULL, N'nice explain this', NULL, CAST(N'2026-07-30T13:26:15.6980421' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (60, N'Post', 10005, 1, NULL, N'hello', NULL, CAST(N'2026-08-03T10:21:28.0726692' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (61, N'Post', 10005, 1, 60, N'hey', NULL, CAST(N'2026-08-03T10:21:36.2051253' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (62, N'Post', 10005, 1, 60, N'hey', NULL, CAST(N'2026-08-03T10:21:36.2052866' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (63, N'Post', 10005, 1, NULL, N'hey', NULL, CAST(N'2026-08-03T10:22:17.6300314' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (64, N'Post', 10005, 1, 60, N'hello', NULL, CAST(N'2026-08-03T10:22:50.4016436' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (65, N'Article', 10028, 1, 56, N'hello', NULL, CAST(N'2026-08-03T10:29:37.6375439' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (66, N'Post', 10008, 1, NULL, N'nice content bro
', NULL, CAST(N'2026-08-03T10:36:20.3979637' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (67, N'Post', 10008, 6, 66, N'this is best content', NULL, CAST(N'2026-08-03T10:42:15.3861287' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (68, N'Post', 10008, 6, 67, N'hhhj', NULL, CAST(N'2026-08-03T10:42:21.4208838' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (69, N'Post', 10008, 4, 67, N'what are you doing', NULL, CAST(N'2026-08-03T10:42:57.0372027' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (70, N'Post', 10081, 1, NULL, N'hello', NULL, CAST(N'2026-08-04T13:01:55.3374993' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (71, N'Post', 10081, 1, 70, N'hello', NULL, CAST(N'2026-08-04T13:02:06.0853135' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (72, N'Post', 10081, 3, 71, N'heloo', NULL, CAST(N'2026-08-04T13:03:33.9959079' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (73, N'Post', 10079, 1, NULL, N'hello', NULL, CAST(N'2026-08-05T09:47:40.3693822' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (74, N'Post', 10077, 1, NULL, N'hello
', NULL, CAST(N'2026-08-05T09:52:35.6340162' AS DateTime2))
INSERT [dbo].[Comments] ([CommentId], [ContentType], [ContentId], [UserId], [ParentCommentId], [CommentText], [ImageUrl], [CreatedDate]) VALUES (75, N'Post', 10081, 3, NULL, N'nice post', NULL, CAST(N'2026-08-05T09:59:30.8910215' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Comments] OFF
SET IDENTITY_INSERT [dbo].[Comments] OFF;
GO

-- Shares
SET IDENTITY_INSERT [dbo].[Shares] ON;
SET IDENTITY_INSERT [dbo].[Shares] ON 

INSERT [dbo].[Shares] ([ShareId], [ContentType], [ContentId], [UserId], [SharedToType], [SharedToId], [CreatedDate]) VALUES (1, N'Post', 1, 1, N'Timeline', NULL, CAST(N'2026-07-13T06:10:22.1470586' AS DateTime2))
INSERT [dbo].[Shares] ([ShareId], [ContentType], [ContentId], [UserId], [SharedToType], [SharedToId], [CreatedDate]) VALUES (6, N'Post', 10005, 1, N'Timeline', NULL, CAST(N'2026-07-27T10:41:05.4407700' AS DateTime2))
INSERT [dbo].[Shares] ([ShareId], [ContentType], [ContentId], [UserId], [SharedToType], [SharedToId], [CreatedDate]) VALUES (12, N'Post', 10069, 5, N'User', 4, CAST(N'2026-07-27T10:57:47.3654603' AS DateTime2))
INSERT [dbo].[Shares] ([ShareId], [ContentType], [ContentId], [UserId], [SharedToType], [SharedToId], [CreatedDate]) VALUES (17, N'Post', 10077, 6, N'User', 4, CAST(N'2026-07-30T07:20:35.0416300' AS DateTime2))
INSERT [dbo].[Shares] ([ShareId], [ContentType], [ContentId], [UserId], [SharedToType], [SharedToId], [CreatedDate]) VALUES (18, N'Post', 10076, 1, N'User', 4, CAST(N'2026-07-30T12:47:40.8895837' AS DateTime2))
INSERT [dbo].[Shares] ([ShareId], [ContentType], [ContentId], [UserId], [SharedToType], [SharedToId], [CreatedDate]) VALUES (21, N'Profile', 1, 1, N'User', 3, CAST(N'2026-08-03T12:16:35.3442181' AS DateTime2))
INSERT [dbo].[Shares] ([ShareId], [ContentType], [ContentId], [UserId], [SharedToType], [SharedToId], [CreatedDate]) VALUES (22, N'Post', 10081, 3, N'User', 4, CAST(N'2026-08-04T13:03:56.6607584' AS DateTime2))
INSERT [dbo].[Shares] ([ShareId], [ContentType], [ContentId], [UserId], [SharedToType], [SharedToId], [CreatedDate]) VALUES (23, N'Post', 10079, 1, N'User', 5, CAST(N'2026-08-05T09:47:47.2566672' AS DateTime2))
INSERT [dbo].[Shares] ([ShareId], [ContentType], [ContentId], [UserId], [SharedToType], [SharedToId], [CreatedDate]) VALUES (24, N'Post', 10081, 3, N'User', 2, CAST(N'2026-08-05T09:59:46.1375629' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Shares] OFF
SET IDENTITY_INSERT [dbo].[Shares] OFF;
GO

-- Bookmarks
INSERT [dbo].[Bookmarks] ([UserId], [ContentType], [ContentId], [SavedDate]) VALUES (1, N'Post', 1, CAST(N'2026-07-13T06:10:22.1470586' AS DateTime2))
INSERT [dbo].[Bookmarks] ([UserId], [ContentType], [ContentId], [SavedDate]) VALUES (2, N'Post', 10069, CAST(N'2026-07-24T06:06:53.8349887' AS DateTime2))
INSERT [dbo].[Bookmarks] ([UserId], [ContentType], [ContentId], [SavedDate]) VALUES (4, N'Post', 10077, CAST(N'2026-07-30T09:42:57.4588905' AS DateTime2))
INSERT [dbo].[Bookmarks] ([UserId], [ContentType], [ContentId], [SavedDate]) VALUES (4, N'Video', 10018, CAST(N'2026-08-05T09:41:21.4770744' AS DateTime2))
INSERT [dbo].[Bookmarks] ([UserId], [ContentType], [ContentId], [SavedDate]) VALUES (5, N'Post', 10069, CAST(N'2026-07-24T10:24:53.9512289' AS DateTime2))
GO

-- Notifications
SET IDENTITY_INSERT [dbo].[Notifications] ON;
SET IDENTITY_INSERT [dbo].[Notifications] ON 

INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (1, 5, N'Like', N'Loveneesh Sharma liked your post.', N'Post', 1, 0, CAST(N'2026-07-13T06:10:22.1470586' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (3, 3, N'Badge', N'Congratulations! You''ve earned the Bronze badge.', N'Badge', NULL, 0, CAST(N'2026-07-20T05:26:33.0072537' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (4, 4, N'Badge', N'Congratulations! You''ve earned the Bronze badge.', N'Badge', NULL, 0, CAST(N'2026-07-20T05:48:54.2616323' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (5, 3, N'Badge', N'Congratulations! You''ve earned the Silver badge.', N'Badge', NULL, 0, CAST(N'2026-07-20T07:14:22.6258354' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (6, 2, N'Badge', N'Congratulations! You''ve earned the Bronze badge.', N'Badge', NULL, 0, CAST(N'2026-07-20T10:36:44.0659584' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (7, 5, N'Badge', N'Congratulations! You''ve earned the Bronze badge.', N'Badge', NULL, 0, CAST(N'2026-07-21T07:03:31.4390364' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10005, 6, N'Badge', N'Congratulations! You''ve earned the Bronze badge.', N'Badge', NULL, 0, CAST(N'2026-07-22T06:14:35.1517465' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10006, 6, N'Reaction', N'Your Post received a new reaction.', N'Post', 10060, 0, CAST(N'2026-07-22T06:30:27.0188153' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10007, 6, N'Reaction', N'Your Post received a new reaction.', N'Post', 10060, 0, CAST(N'2026-07-22T06:36:15.8961554' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10008, 6, N'Reaction', N'Your Post received a new reaction.', N'Post', 10059, 0, CAST(N'2026-07-22T06:44:40.0689789' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10009, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10059, 0, CAST(N'2026-07-22T06:45:17.4401390' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10010, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10059, 0, CAST(N'2026-07-22T06:45:20.2135085' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10011, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10059, 0, CAST(N'2026-07-22T06:45:46.9063793' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10012, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:47:00.1068045' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10013, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:54:37.5273394' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10014, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:54:40.1576571' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10015, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:54:41.7519690' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10016, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:54:41.9161751' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10017, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:54:42.1295607' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10018, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:54:44.8543106' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10019, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:54:45.0765259' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10020, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:54:45.2873117' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10021, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:54:46.1409551' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10022, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:54:46.3458580' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10023, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:54:47.7864895' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10024, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:55:30.9231036' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10025, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:55:33.5253661' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10026, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:55:33.7088881' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10027, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:55:33.9587946' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10028, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:55:34.5420684' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10029, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:55:34.7897562' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10030, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:55:35.5594900' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10031, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:56:30.8691515' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10032, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:56:48.7411646' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10033, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:56:49.7414528' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10034, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T06:56:49.9044144' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10035, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10059, 0, CAST(N'2026-07-22T06:56:57.1556480' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10036, 3, N'Comment', N'Your Post received a new comment.', N'Post', 61, 0, CAST(N'2026-07-22T06:57:09.8548185' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10037, 3, N'Comment', N'Your Post received a new comment.', N'Post', 61, 0, CAST(N'2026-07-22T06:57:10.0489226' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10038, 3, N'Comment', N'Your Post received a new comment.', N'Post', 61, 0, CAST(N'2026-07-22T06:57:10.3800251' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10039, 3, N'Comment', N'Your Post received a new comment.', N'Post', 61, 0, CAST(N'2026-07-22T06:57:11.1921816' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10040, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T07:09:22.3626799' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10041, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T07:10:07.0929747' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10042, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T07:10:09.0003377' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10043, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T07:12:44.8320287' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10044, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T07:13:02.0786723' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10045, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T07:13:02.5233172' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10046, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 1, CAST(N'2026-07-22T07:13:02.7428663' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10047, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T07:13:02.9843985' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10048, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T07:13:05.5589309' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10049, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T07:15:38.7367138' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10050, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 0, CAST(N'2026-07-22T07:15:39.9884650' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10051, 6, N'Badge', N'Congratulations! You''ve earned the Silver badge.', N'Badge', NULL, 1, CAST(N'2026-07-22T07:15:40.2020219' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10052, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10060, 1, CAST(N'2026-07-22T07:15:40.2746687' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10053, 3, N'Comment', N'Your Post received a new comment.', N'Post', 10064, 0, CAST(N'2026-07-22T11:05:57.4037426' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10054, 3, N'Comment', N'Your Post received a new comment.', N'Post', 10064, 0, CAST(N'2026-07-22T11:15:11.7774707' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10055, 3, N'Comment', N'Your Post received a new comment.', N'Post', 10064, 0, CAST(N'2026-07-22T11:15:12.9702142' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10056, 3, N'Comment', N'Your Post received a new comment.', N'Post', 10064, 0, CAST(N'2026-07-22T11:15:13.8484978' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10057, 3, N'Comment', N'Your Post received a new comment.', N'Post', 10064, 0, CAST(N'2026-07-22T11:15:14.0281236' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10058, 3, N'Comment', N'Your Post received a new comment.', N'Post', 10064, 0, CAST(N'2026-07-22T11:15:17.8719418' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10059, 3, N'Comment', N'Your Post received a new comment.', N'Post', 10064, 0, CAST(N'2026-07-22T11:16:20.8591441' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10060, 2, N'Reaction', N'Your Post received a new reaction.', N'Post', 10068, 1, CAST(N'2026-07-22T11:55:55.9565145' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10061, 2, N'Reaction', N'Your Post received a new reaction.', N'Post', 10068, 0, CAST(N'2026-07-22T11:55:57.7319763' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10062, 2, N'Reaction', N'Your Post received a new reaction.', N'Post', 10067, 1, CAST(N'2026-07-22T11:55:59.4944847' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10063, 3, N'Reaction', N'Your Post received a new reaction.', N'Post', 10069, 0, CAST(N'2026-07-23T04:55:57.7743271' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10064, 3, N'Reaction', N'Your Post received a new reaction.', N'Post', 10069, 0, CAST(N'2026-07-23T05:18:52.1965818' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10065, 3, N'Comment', N'Your Post received a new comment.', N'Post', 10069, 0, CAST(N'2026-07-23T05:19:30.2987664' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10066, 3, N'Comment', N'Your Post received a new comment.', N'Post', 10069, 0, CAST(N'2026-07-23T05:21:54.1237242' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10068, 5, N'ConnectionRequest', N'Rishikesh Ugle sent you a connection request.', N'User', 4, 1, CAST(N'2026-07-23T11:36:21.4608726' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10069, 4, N'ConnectionRequest', N'Vishendra Sharma sent you a connection request.', N'User', 2, 1, CAST(N'2026-07-23T12:24:47.7113691' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10070, 5, N'ConnectionRequest', N'Vishendra Sharma sent you a connection request.', N'User', 2, 1, CAST(N'2026-07-23T12:28:41.6645776' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10071, 6, N'ConnectionRequest', N'Rishikesh Ugle sent you a connection request.', N'User', 4, 1, CAST(N'2026-07-23T12:29:22.4214693' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10072, 4, N'ConnectionRequest', N'Mayur Verma accepted your connection request.', N'User', 6, 0, CAST(N'2026-07-23T12:29:39.7422408' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10073, 5, N'ConnectionRequest', N'Mayur Verma sent you a connection request.', N'User', 6, 1, CAST(N'2026-07-23T12:32:48.7020493' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10074, 3, N'Reaction', N'Your Post received a new reaction.', N'Post', 10069, 0, CAST(N'2026-07-23T12:36:55.7533781' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10075, 6, N'ConnectionRequest', N'Sourabh Sahu sent you a connection request.', N'User', 3, 1, CAST(N'2026-07-23T12:37:38.9933244' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10076, 3, N'ConnectionRequest', N'Mayur Verma accepted your connection request.', N'User', 6, 0, CAST(N'2026-07-23T12:37:57.5488180' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10077, 4, N'ConnectionRequest', N'Loveneesh Sharma sent you a connection request.', N'User', 1, 1, CAST(N'2026-07-23T12:47:26.2536155' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10079, 2, N'ConnectionRequest', N'Rishikesh Ugle accepted your connection request.', N'User', 4, 0, CAST(N'2026-07-24T06:29:03.7191103' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10080, 5, N'ConnectionRequest', N'Loveneesh Sharma sent you a connection request.', N'User', 1, 1, CAST(N'2026-07-24T09:07:30.0254780' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10081, 1, N'ConnectionRequest', N'Meghna Tiwari accepted your connection request.', N'User', 5, 1, CAST(N'2026-07-24T09:08:00.5018056' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10082, 3, N'ConnectionRequest', N'Meghna Tiwari sent you a connection request.', N'User', 5, 1, CAST(N'2026-07-24T10:25:14.1451486' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10083, 5, N'ConnectionRequest', N'Sourabh Sahu accepted your connection request.', N'User', 3, 0, CAST(N'2026-07-24T10:25:33.1342657' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10084, 2, N'ConnectionRequest', N'Meghna Tiwari accepted your connection request.', N'User', 5, 0, CAST(N'2026-07-27T05:31:08.3169618' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10085, 5, N'CommunityInvite', N'Loveneesh Sharma invited you to join the community "Higher".', N'Community', 3, 0, CAST(N'2026-07-27T05:53:02.8824272' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10086, 4, N'CommunityInvite', N'Loveneesh Sharma invited you to join the community "Higher".', N'Community', 3, 0, CAST(N'2026-07-27T05:53:02.9443007' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10087, 3, N'CommunityInvite', N'Loveneesh Sharma invited you to join the community "Higher".', N'Community', 3, 0, CAST(N'2026-07-27T05:53:02.9580108' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10088, 5, N'CommunityInvite', N'Loveneesh Sharma invited you to join the community "Higher".', N'Community', 3, 1, CAST(N'2026-07-27T05:53:03.2787478' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10089, 4, N'CommunityInvite', N'Loveneesh Sharma invited you to join the community "Higher".', N'Community', 3, 1, CAST(N'2026-07-27T05:53:03.2889177' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10090, 3, N'CommunityInvite', N'Loveneesh Sharma invited you to join the community "Higher".', N'Community', 3, 1, CAST(N'2026-07-27T05:53:03.3013562' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10091, 2, N'Badge', N'Congratulations! You''ve earned the Silver badge.', N'Badge', NULL, 0, CAST(N'2026-07-27T06:24:56.6126825' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10092, 2, N'ConnectionRequest', N'Loveneesh Sharma sent you a connection request.', N'User', 1, 1, CAST(N'2026-07-27T07:11:02.4963726' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10093, 1, N'Follower', N'Vishendra Sharma started following you.', N'User', 2, 1, CAST(N'2026-07-27T07:11:18.1322632' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10094, 6, N'Follower', N'Meghna Tiwari started following you.', N'User', 5, 0, CAST(N'2026-07-27T09:45:18.2916122' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10095, 5, N'Badge', N'Congratulations! You''ve earned the Silver badge.', N'Badge', NULL, 0, CAST(N'2026-07-27T09:50:31.9788998' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10096, 5, N'Share', N'Someone shared a post with you.', N'Post', 10072, 1, CAST(N'2026-07-27T10:44:32.0789225' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10097, 4, N'Share', N'Someone shared a post with you.', N'Post', 10070, 1, CAST(N'2026-07-27T10:45:22.3963531' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10098, 3, N'Share', N'Rishikesh Ugle shared a post with you.', N'Post', 10072, 1, CAST(N'2026-07-27T10:51:04.3058320' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10099, 3, N'Share', N'Rishikesh Ugle shared a post with you.', N'Post', 10072, 1, CAST(N'2026-07-27T10:51:04.3058890' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10100, 5, N'Share', N'Sourabh Sahu shared a post with you.', N'Post', 10070, 1, CAST(N'2026-07-27T10:54:30.5766174' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10101, 4, N'Share', N'Meghna Tiwari shared a post with you.', N'Post', 10069, 1, CAST(N'2026-07-27T10:57:47.5607717' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10102, 5, N'Share', N'Rishikesh Ugle shared a post with you.', N'Post', 10072, 1, CAST(N'2026-07-27T11:03:35.8655244' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10103, 4, N'Share', N'Sourabh Sahu shared a post with you.', N'Post', 10064, 1, CAST(N'2026-07-27T12:34:35.8542929' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10104, 5, N'Share', N'Loveneesh Sharma shared a post with you.', N'Post', 10072, 1, CAST(N'2026-07-27T12:59:26.8668119' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10105, 3, N'ConnectionRequest', N'Rishikesh Ugle sent you a connection request.', N'User', 4, 0, CAST(N'2026-07-27T13:02:39.3354802' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10106, 4, N'ConnectionRequest', N'Meghna Tiwari accepted your connection request.', N'User', 5, 0, CAST(N'2026-07-28T11:24:10.8767375' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10107, 6, N'ConnectionRequest', N'Vishendra Sharma sent you a connection request.', N'User', 2, 1, CAST(N'2026-07-28T11:26:26.7994965' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10108, 2, N'ConnectionRequest', N'Mayur Verma accepted your connection request.', N'User', 6, 0, CAST(N'2026-07-28T11:26:48.1708227' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10109, 2, N'Comment', N'Your Article received a new comment.', N'Article', 10028, 0, CAST(N'2026-07-29T09:25:25.0571466' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10110, 5, N'Follower', N'Mayur Verma started following you.', N'User', 6, 0, CAST(N'2026-07-30T07:05:37.2814169' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10111, 4, N'Share', N'Mayur Verma shared a post with you.', N'Post', 10077, 0, CAST(N'2026-07-30T07:20:35.3339570' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10112, 6, N'ConnectionRequest', N'Meghna Tiwari accepted your connection request.', N'User', 5, 0, CAST(N'2026-07-30T10:45:11.6060133' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10113, 4, N'Badge', N'Congratulations! You''ve earned the Silver badge.', N'Badge', NULL, 0, CAST(N'2026-07-30T12:47:41.7531101' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10114, 4, N'Share', N'Loveneesh Sharma shared a post with you.', N'Post', 10076, 1, CAST(N'2026-07-30T12:47:42.0769910' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10115, 3, N'ConnectionRequest', N'Vishendra Sharma sent you a connection request.', N'User', 2, 1, CAST(N'2026-07-30T13:19:45.2160412' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10116, 1, N'ConnectionRequest', N'Vishendra Sharma accepted your connection request.', N'User', 2, 1, CAST(N'2026-07-30T13:19:53.4190171' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10117, 1, N'ConnectionRequest', N'Sourabh Sahu sent you a connection request.', N'User', 3, 1, CAST(N'2026-07-30T13:22:29.7375938' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10118, 3, N'ConnectionRequest', N'Loveneesh Sharma accepted your connection request.', N'User', 1, 0, CAST(N'2026-07-30T13:22:56.5653362' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10119, 6, N'ConnectionRequest', N'Loveneesh Sharma sent you a connection request.', N'User', 1, 1, CAST(N'2026-07-30T13:25:00.5316176' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10120, 1, N'ConnectionRequest', N'Mayur Verma accepted your connection request.', N'User', 6, 1, CAST(N'2026-07-30T13:25:24.9485430' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10121, 2, N'Comment', N'Your Article received a new comment.', N'Article', 10028, 0, CAST(N'2026-07-30T13:26:15.8801098' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10122, 2, N'ConnectionRequest', N'Sourabh Sahu accepted your connection request.', N'User', 3, 0, CAST(N'2026-07-31T04:32:22.2995790' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10123, 4, N'Share', N'Mayur Verma shared a post with you.', N'Post', 10080, 0, CAST(N'2026-07-31T05:05:52.9345095' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10124, 5, N'Share', N'Rishikesh Ugle shared a post with you.', N'Post', 10080, 0, CAST(N'2026-07-31T05:06:30.2623159' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10125, 6, N'Comment', N'Your Post received a new comment.', N'Post', 10080, 0, CAST(N'2026-07-31T06:41:46.5764203' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10126, 2, N'Comment', N'Your Article received a new comment.', N'Article', 10028, 0, CAST(N'2026-08-03T10:29:37.8281409' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10127, 1, N'Comment', N'Someone replied to your comment on a Post.', N'Post', 10008, 1, CAST(N'2026-08-03T10:42:15.5365740' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10128, 6, N'Comment', N'Someone replied to your comment on a Post.', N'Post', 10008, 0, CAST(N'2026-08-03T10:42:57.1625452' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10129, 3, N'Share', N'Loveneesh Sharma shared a profile with you.', N'Profile', 1, 0, CAST(N'2026-08-03T12:16:37.8190851' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10130, 3, N'Share', N'Loveneesh Sharma shared Loveneesh Sharma''s profile with you!', N'Profile', 1, 0, CAST(N'2026-08-03T12:16:38.2344454' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10131, 4, N'ConnectionRequest', N'Sourabh Sahu accepted your connection request.', N'User', 3, 0, CAST(N'2026-08-03T12:20:11.0909224' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10132, 3, N'ConnectionRequest', N'You are now connected with Rishikesh Ugle.', N'User', 4, 0, CAST(N'2026-08-03T12:20:11.1369275' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10133, 4, N'Follower', N'Sourabh Sahu started following you.', N'User', 3, 0, CAST(N'2026-08-03T12:32:07.3137593' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10134, 4, N'Follower', N'Sourabh Sahu started following you.', N'User', 3, 0, CAST(N'2026-08-03T12:33:53.9037020' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10135, 4, N'Follower', N'Sourabh Sahu started following you.', N'User', 3, 0, CAST(N'2026-08-03T12:33:56.8612873' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10136, 2, N'Reaction', N'Your Post received a new reaction.', N'Post', 10081, 0, CAST(N'2026-08-04T10:57:58.7453887' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10137, 2, N'Comment', N'Your Post received a new comment.', N'Post', 10081, 0, CAST(N'2026-08-04T13:01:55.5747787' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10138, 1, N'Badge', N'Congratulations! You''ve earned the Bronze badge.', N'Badge', NULL, 0, CAST(N'2026-08-04T13:02:06.1972752' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10139, 2, N'Comment', N'Your Post received a new comment.', N'Post', 10081, 0, CAST(N'2026-08-04T13:02:06.3172981' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10140, 2, N'Comment', N'Your Post received a new comment.', N'Post', 10081, 0, CAST(N'2026-08-04T13:03:34.2510919' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10141, 1, N'Comment', N'Someone replied to your comment on a Post.', N'Post', 10081, 0, CAST(N'2026-08-04T13:03:34.3688613' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10142, 4, N'Share', N'Sourabh Sahu shared a post with you.', N'Post', 10081, 0, CAST(N'2026-08-04T13:03:57.1903553' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10143, 2, N'Reaction', N'Your Post received a new reaction.', N'Post', 10081, 0, CAST(N'2026-08-05T09:47:19.7159835' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10144, 2, N'Reaction', N'Your Post received a new reaction.', N'Post', 10081, 0, CAST(N'2026-08-05T09:47:21.1214540' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10145, 2, N'Reaction', N'Your Post received a new reaction.', N'Post', 10079, 0, CAST(N'2026-08-05T09:47:33.8939489' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10146, 2, N'Comment', N'Your Post received a new comment.', N'Post', 10079, 0, CAST(N'2026-08-05T09:47:40.5641161' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10147, 5, N'Share', N'Loveneesh Sharma shared a post with you.', N'Post', 10079, 0, CAST(N'2026-08-05T09:47:47.4979693' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10148, 4, N'Reaction', N'Your Post received a new reaction.', N'Post', 10077, 0, CAST(N'2026-08-05T09:52:26.1028272' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10149, 4, N'Comment', N'Your Post received a new comment.', N'Post', 10077, 0, CAST(N'2026-08-05T09:52:35.7804973' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10150, 2, N'Comment', N'Your Post received a new comment.', N'Post', 10081, 0, CAST(N'2026-08-05T09:59:31.0874319' AS DateTime2))
INSERT [dbo].[Notifications] ([NotificationId], [UserId], [EventType], [Message], [RelatedContentType], [RelatedContentId], [IsRead], [CreatedDate]) VALUES (10151, 2, N'Share', N'Sourabh Sahu shared a post with you.', N'Post', 10081, 0, CAST(N'2026-08-05T09:59:46.2745918' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Notifications] OFF
SET IDENTITY_INSERT [dbo].[Notifications] OFF;
GO

-- NotificationPreferences
INSERT [dbo].[NotificationPreferences] ([UserId], [EventType], [BellEnabled], [EmailEnabled]) VALUES (1, N'NewPost', 1, 1)
INSERT [dbo].[NotificationPreferences] ([UserId], [EventType], [BellEnabled], [EmailEnabled]) VALUES (2, N'NewPost', 1, 1)
INSERT [dbo].[NotificationPreferences] ([UserId], [EventType], [BellEnabled], [EmailEnabled]) VALUES (3, N'NewPost', 1, 1)
INSERT [dbo].[NotificationPreferences] ([UserId], [EventType], [BellEnabled], [EmailEnabled]) VALUES (4, N'NewPost', 1, 1)
INSERT [dbo].[NotificationPreferences] ([UserId], [EventType], [BellEnabled], [EmailEnabled]) VALUES (5, N'NewPost', 1, 1)
INSERT [dbo].[NotificationPreferences] ([UserId], [EventType], [BellEnabled], [EmailEnabled]) VALUES (6, N'NewPost', 1, 1)
GO

-- KarmaBalances
INSERT [dbo].[KarmaBalances] ([UserId], [TotalPoints], [BadgeLevel], [LastUpdated]) VALUES (1, 129, N'Bronze', CAST(N'2026-08-05T09:52:35.6784531' AS DateTime2))
INSERT [dbo].[KarmaBalances] ([UserId], [TotalPoints], [BadgeLevel], [LastUpdated]) VALUES (2, 175, N'Bronze', CAST(N'2026-08-05T09:59:46.2234782' AS DateTime2))
INSERT [dbo].[KarmaBalances] ([UserId], [TotalPoints], [BadgeLevel], [LastUpdated]) VALUES (3, 268, N'Bronze', CAST(N'2026-08-05T09:59:46.1676696' AS DateTime2))
INSERT [dbo].[KarmaBalances] ([UserId], [TotalPoints], [BadgeLevel], [LastUpdated]) VALUES (4, 118, N'Bronze', CAST(N'2026-08-05T09:52:35.7493155' AS DateTime2))
INSERT [dbo].[KarmaBalances] ([UserId], [TotalPoints], [BadgeLevel], [LastUpdated]) VALUES (5, 119, N'Bronze', CAST(N'2026-08-04T10:57:58.3255243' AS DateTime2))
INSERT [dbo].[KarmaBalances] ([UserId], [TotalPoints], [BadgeLevel], [LastUpdated]) VALUES (6, 129, N'Bronze', CAST(N'2026-08-03T10:42:21.4529557' AS DateTime2))
GO

-- KarmaTransactions
SET IDENTITY_INSERT [dbo].[KarmaTransactions] ON;
SET IDENTITY_INSERT [dbo].[KarmaTransactions] ON 

INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (1, 5, N'PostCreated', 10, N'Post', 1, CAST(N'2026-07-13T06:10:22.1470586' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (3, 4, N'PublishArticle', 10, N'Article', 2, CAST(N'2026-07-13T09:55:41.9943622' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (4, 2, N'PublishArticle', 10, N'Article', 12, CAST(N'2026-07-13T10:13:55.2483601' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (5, 3, N'PublishArticle', 10, N'Article', 14, CAST(N'2026-07-13T11:31:17.3751943' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (6, 3, N'UploadVideo', 8, N'Video', 2, CAST(N'2026-07-13T12:33:19.3653383' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (7, 3, N'PublishArticle', 10, N'Article', 15, CAST(N'2026-07-13T12:46:16.3556752' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (8, 3, N'PublishArticle', 10, N'Article', 16, CAST(N'2026-07-13T12:48:18.0127294' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (9, 3, N'CreatePost', 2, N'Post', 3, CAST(N'2026-07-15T07:14:05.3257954' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (14, 4, N'CreatePost', 2, N'Post', 11, CAST(N'2026-07-17T05:32:12.8951628' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (15, 2, N'CreatePost', 2, N'Post', 12, CAST(N'2026-07-17T06:14:58.9035464' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (16, 2, N'CreatePost', 2, N'Post', 13, CAST(N'2026-07-17T06:23:16.6900669' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (17, 2, N'CreatePost', 2, N'Post', 14, CAST(N'2026-07-17T06:30:37.5750767' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (18, 2, N'CreatePost', 2, N'Post', 15, CAST(N'2026-07-17T06:37:36.3236795' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (19, 2, N'CreatePost', 2, N'Post', 16, CAST(N'2026-07-17T06:38:40.1063244' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (20, 3, N'PublishArticle', 10, N'Article', 18, CAST(N'2026-07-17T06:53:01.1669659' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (21, 5, N'PublishArticle', 10, N'Article', 19, CAST(N'2026-07-17T06:57:35.9407222' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (22, 5, N'PublishArticle', 10, N'Article', 20, CAST(N'2026-07-17T07:11:36.1122696' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (23, 5, N'PublishArticle', 10, N'Article', 21, CAST(N'2026-07-17T07:13:21.6033133' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (24, 3, N'CreatePost', 2, N'Post', 20, CAST(N'2026-07-17T08:45:54.7945123' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (26, 3, N'CreatePost', 2, N'Post', 22, CAST(N'2026-07-17T08:58:47.0621287' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (27, 4, N'CreatePost', 2, N'Post', 23, CAST(N'2026-07-17T09:44:27.2816027' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (28, 3, N'PublishArticle', 10, N'Article', 24, CAST(N'2026-07-17T10:01:50.1412938' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (29, 3, N'CreatePost', 2, N'Post', 24, CAST(N'2026-07-17T10:43:15.1250730' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (30, 4, N'CreatePost', 2, N'Post', 25, CAST(N'2026-07-17T10:51:09.0289393' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (31, 3, N'CreatePost', 2, N'Post', 26, CAST(N'2026-07-17T12:35:39.0870781' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (32, 4, N'CreatePost', 2, N'Post', 27, CAST(N'2026-07-17T12:45:06.4251839' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (33, 3, N'CreatePost', 2, N'Post', 28, CAST(N'2026-07-17T12:48:26.3011693' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (34, 4, N'CreatePost', 2, N'Post', 29, CAST(N'2026-07-17T12:59:24.4647337' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (36, 3, N'CreatePost', 5, N'Post', 49, CAST(N'2026-07-20T05:26:32.8939643' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (37, 3, N'CreatePost', 5, N'Post', 50, CAST(N'2026-07-20T05:39:37.7637308' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (39, 3, N'CreatePost', 5, N'Post', 52, CAST(N'2026-07-20T05:59:53.0158516' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (40, 4, N'CreatePost', 5, N'Post', 54, CAST(N'2026-07-20T06:10:53.8061429' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (41, 4, N'CreatePost', 5, N'Post', 53, CAST(N'2026-07-20T06:10:53.8061235' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (42, 4, N'CreatePost', 5, N'Post', 55, CAST(N'2026-07-20T06:34:01.9193481' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (43, 3, N'CreatePost', 5, N'Post', 56, CAST(N'2026-07-20T06:54:48.8491883' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (44, 3, N'CreatePost', 5, N'Post', 57, CAST(N'2026-07-20T06:54:50.0235146' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (45, 3, N'CreatePost', 5, N'Post', 58, CAST(N'2026-07-20T07:14:22.1786952' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (46, 4, N'CreateArticle', 15, N'Article', 25, CAST(N'2026-07-20T07:22:34.6452082' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (47, 4, N'CreatePost', 5, N'Post', 60, CAST(N'2026-07-20T08:56:48.3173509' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (48, 4, N'CreatePost', 5, N'Post', 59, CAST(N'2026-07-20T08:56:48.3188613' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (49, 3, N'CreatePost', 5, N'Post', 61, CAST(N'2026-07-20T09:21:16.2915541' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (50, 2, N'CreateArticle', 15, N'Article', 28, CAST(N'2026-07-20T10:36:43.8629162' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (51, 3, N'CreateArticle', 15, N'Article', 29, CAST(N'2026-07-20T10:42:12.0959544' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (52, 2, N'CreateVideo', 10, N'Video', 5, CAST(N'2026-07-21T06:39:55.0857692' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (53, 3, N'CreateVideo', 10, N'Video', 6, CAST(N'2026-07-21T06:55:57.7368853' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (54, 5, N'CreateVideo', 10, N'Video', 7, CAST(N'2026-07-21T07:03:31.0764491' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (55, 3, N'CreatePodcast', 10, N'Podcast', 2, CAST(N'2026-07-21T09:26:35.8452389' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (56, 2, N'CreatePodcast', 10, N'Podcast', 3, CAST(N'2026-07-21T09:34:33.9765775' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (57, 5, N'CreateVideo', 10, N'Video', 9, CAST(N'2026-07-21T10:07:23.6484799' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10042, 6, N'CreatePost', 2, N'Post', 10055, CAST(N'2026-07-22T06:14:35.0830979' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10043, 6, N'CreatePost', 2, N'Post', 10056, CAST(N'2026-07-22T06:14:35.2820624' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10044, 6, N'CreatePost', 2, N'Post', 10057, CAST(N'2026-07-22T06:14:35.3364505' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10045, 6, N'CreatePost', 2, N'Post', 10058, CAST(N'2026-07-22T06:14:35.3999239' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10046, 6, N'CreatePost', 2, N'Post', 10059, CAST(N'2026-07-22T06:14:35.4581739' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10047, 6, N'CreateArticle', 10, N'Article', 10025, CAST(N'2026-07-22T06:22:39.2220600' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10050, 6, N'ReceiveLike', 1, N'Post', 10059, CAST(N'2026-07-22T06:44:39.9323797' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10051, 6, N'ReceiveComment', 2, N'Post', 10059, CAST(N'2026-07-22T06:45:17.3671595' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10052, 6, N'ReceiveComment', 2, N'Post', 10059, CAST(N'2026-07-22T06:45:20.1320948' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10053, 6, N'ReceiveComment', 2, N'Post', 10059, CAST(N'2026-07-22T06:45:46.7899490' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10077, 6, N'ReceiveComment', 2, N'Post', 10059, CAST(N'2026-07-22T06:56:57.0999488' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10078, 3, N'ReceiveComment', 2, N'Post', 61, CAST(N'2026-07-22T06:57:09.7659230' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10079, 3, N'ReceiveComment', 2, N'Post', 61, CAST(N'2026-07-22T06:57:09.9446683' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10080, 3, N'ReceiveComment', 2, N'Post', 61, CAST(N'2026-07-22T06:57:10.1812167' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10081, 3, N'ReceiveComment', 2, N'Post', 61, CAST(N'2026-07-22T06:57:11.1031578' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10082, 4, N'CreateVideo', 8, N'Video', 10003, CAST(N'2026-07-22T06:58:33.4902948' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10119, 2, N'CreatePost', 2, N'Post', 10065, CAST(N'2026-07-22T11:36:58.0734704' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10120, 2, N'CreatePost', 2, N'Post', 10066, CAST(N'2026-07-22T11:39:29.3657385' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10121, 2, N'CreatePost', 2, N'Post', 10067, CAST(N'2026-07-22T11:46:48.3184140' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10127, 3, N'AddLike', 1, N'Post', 10067, CAST(N'2026-07-22T11:55:59.2862008' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10128, 2, N'ReceiveLike', 1, N'Post', 10067, CAST(N'2026-07-22T11:55:59.3963873' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10129, 3, N'CreatePost', 2, N'Post', 10069, CAST(N'2026-07-22T12:03:43.9318230' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10130, 1, N'AddLike', 1, N'Post', 10069, CAST(N'2026-07-23T04:55:57.4796536' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10131, 3, N'ReceiveLike', 1, N'Post', 10069, CAST(N'2026-07-23T04:55:57.7019591' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10132, 2, N'AddLike', 1, N'Post', 10069, CAST(N'2026-07-23T05:18:51.8270847' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10133, 3, N'ReceiveLike', 1, N'Post', 10069, CAST(N'2026-07-23T05:18:51.9905922' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10134, 2, N'AddComment', 2, N'Post', 10069, CAST(N'2026-07-23T05:19:30.2031164' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10135, 3, N'ReceiveComment', 2, N'Post', 10069, CAST(N'2026-07-23T05:19:30.2577501' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10136, 2, N'AddComment', 2, N'Post', 10069, CAST(N'2026-07-23T05:21:53.9053617' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10137, 3, N'ReceiveComment', 2, N'Post', 10069, CAST(N'2026-07-23T05:21:54.0273194' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10138, 3, N'AddLike', 1, N'Post', 10069, CAST(N'2026-07-23T11:29:33.8195484' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10139, 4, N'AddLike', 1, N'Post', 10069, CAST(N'2026-07-23T11:29:44.5140431' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10140, 3, N'ReceiveLike', 1, N'Post', 10069, CAST(N'2026-07-23T11:29:44.5575523' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10141, 6, N'AddLike', 1, N'Post', 10069, CAST(N'2026-07-23T12:36:55.4129922' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10142, 3, N'ReceiveLike', 1, N'Post', 10069, CAST(N'2026-07-23T12:36:55.6201680' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10145, 5, N'CreateVideo', 8, N'Video', 10004, CAST(N'2026-07-24T09:12:39.5927652' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10146, 5, N'CreatePodcast', 8, N'Podcast', 10002, CAST(N'2026-07-24T09:15:35.1435075' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10147, 5, N'CreatePodcast', 8, N'Podcast', 10003, CAST(N'2026-07-24T09:16:53.3582534' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10151, 1, N'CommunityParticipation', 5, N'Community', 1, CAST(N'2026-07-27T05:51:46.0002863' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10152, 1, N'CommunityParticipation', 5, N'Community', 3, CAST(N'2026-07-27T05:53:02.9941655' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10154, 2, N'CreateArticle', 10, N'Article', 10028, CAST(N'2026-07-27T06:24:56.5304953' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10155, 5, N'CreateVideo', 8, N'Video', 10005, CAST(N'2026-07-27T09:50:31.8368183' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10156, 1, N'AddShare', 2, N'Post', 10005, CAST(N'2026-07-27T10:41:06.4472463' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10166, 5, N'AddShare', 2, N'Post', 10069, CAST(N'2026-07-27T10:57:47.3949524' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10167, 3, N'ReceiveShare', 3, N'Post', 10069, CAST(N'2026-07-27T10:57:47.4892180' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10171, 3, N'AddLike', 1, N'Post', 10028, CAST(N'2026-07-27T11:17:35.2955732' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10172, 3, N'AddLike', 1, N'Post', 10028, CAST(N'2026-07-27T11:17:51.4441877' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10173, 3, N'AddLike', 1, N'Post', 10028, CAST(N'2026-07-27T11:24:00.3354424' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10177, 1, N'AddLike', 1, N'Post', 10005, CAST(N'2026-07-27T12:40:34.1775253' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10178, 3, N'CommunityParticipation', 5, N'Community', 2, CAST(N'2026-07-27T12:54:01.9954333' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10179, 3, N'CommunityParticipation', 5, N'Community', 1, CAST(N'2026-07-27T12:54:23.8183452' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10182, 4, N'CreatePost', 2, N'Post', 10074, CAST(N'2026-07-27T13:06:37.5764372' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10184, 6, N'CreatePodcast', 8, N'Podcast', 10004, CAST(N'2026-07-28T11:38:18.4843123' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10185, 1, N'AddComment', 2, N'Article', 10028, CAST(N'2026-07-29T09:25:24.7147039' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10186, 2, N'ReceiveComment', 2, N'Article', 10028, CAST(N'2026-07-29T09:25:24.9184570' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10187, 1, N'CommunityParticipation', 5, N'Community', 4, CAST(N'2026-07-30T05:47:13.3648855' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10188, 2, N'CommunityParticipation', 5, N'Community', 5, CAST(N'2026-07-30T05:47:33.5020697' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10189, 4, N'CreatePost', 2, N'Post', 10076, CAST(N'2026-07-30T05:47:33.9965586' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10190, 4, N'CommunityParticipation', 5, N'Community', 5, CAST(N'2026-07-30T05:54:37.0047660' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10191, 2, N'CommunityParticipation', 5, N'Community', 6, CAST(N'2026-07-30T05:59:11.7487150' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10192, 4, N'CreatePost', 2, N'Post', 10077, CAST(N'2026-07-30T05:59:12.1022652' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10193, 4, N'CommunityParticipation', 5, N'Community', 6, CAST(N'2026-07-30T06:00:13.1913690' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10194, 1, N'CommunityParticipation', 5, N'Community', 6, CAST(N'2026-07-30T06:07:34.9857814' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10195, 3, N'CommunityParticipation', 5, N'Community', 6, CAST(N'2026-07-30T06:40:37.2429592' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10196, 6, N'AddShare', 2, N'Post', 10077, CAST(N'2026-07-30T07:20:35.1024406' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10197, 4, N'ReceiveShare', 3, N'Post', 10077, CAST(N'2026-07-30T07:20:35.2093536' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10198, 2, N'CommunityParticipation', 5, N'Community', 1, CAST(N'2026-07-30T09:16:22.6934443' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10199, 1, N'CommunityParticipation', 5, N'Community', 1, CAST(N'2026-07-30T12:44:07.2171179' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10200, 1, N'AddShare', 2, N'Post', 10076, CAST(N'2026-07-30T12:47:41.0592747' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10201, 4, N'ReceiveShare', 3, N'Post', 10076, CAST(N'2026-07-30T12:47:41.4439427' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10202, 4, N'CreatePost', 2, N'Post', 10078, CAST(N'2026-07-30T13:12:33.3788966' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10203, 2, N'CreatePost', 2, N'Post', 10079, CAST(N'2026-07-30T13:21:56.8216922' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10204, 6, N'AddComment', 2, N'Article', 10028, CAST(N'2026-07-30T13:26:15.7708959' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10205, 2, N'ReceiveComment', 2, N'Article', 10028, CAST(N'2026-07-30T13:26:15.8456503' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10213, 1, N'CreateVideo', 8, N'Video', 10006, CAST(N'2026-07-31T10:01:44.5722314' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10214, 1, N'CreatePodcast', 8, N'Podcast', 10005, CAST(N'2026-07-31T10:10:15.0743022' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10215, 2, N'AddLike', 1, N'Post', 10005, CAST(N'2026-07-31T12:41:19.0826825' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10216, 1, N'AddComment', 2, N'Post', 10005, CAST(N'2026-08-03T10:21:28.6440980' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10217, 1, N'AddComment', 2, N'Post', 10005, CAST(N'2026-08-03T10:21:36.2354562' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10218, 1, N'AddComment', 2, N'Post', 10005, CAST(N'2026-08-03T10:21:36.2353906' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10219, 1, N'AddComment', 2, N'Post', 10005, CAST(N'2026-08-03T10:22:17.6588872' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10220, 1, N'AddComment', 2, N'Post', 10005, CAST(N'2026-08-03T10:22:50.4244829' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10221, 3, N'CreateVideo', 8, N'Video', 10007, CAST(N'2026-08-03T10:24:00.2407160' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10222, 1, N'CreateVideo', 8, N'Video', 10008, CAST(N'2026-08-03T10:25:28.1655896' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10223, 1, N'AddComment', 2, N'Article', 10028, CAST(N'2026-08-03T10:29:37.6607318' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10224, 2, N'ReceiveComment', 2, N'Article', 10028, CAST(N'2026-08-03T10:29:37.7485200' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10225, 1, N'AddComment', 2, N'Post', 10008, CAST(N'2026-08-03T10:36:21.0856507' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10226, 6, N'AddComment', 2, N'Post', 10008, CAST(N'2026-08-03T10:42:15.4198076' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10227, 6, N'AddComment', 2, N'Post', 10008, CAST(N'2026-08-03T10:42:21.4382478' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10228, 4, N'AddComment', 2, N'Post', 10008, CAST(N'2026-08-03T10:42:57.0520786' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10229, 2, N'CreatePost', 2, N'Post', 10081, CAST(N'2026-08-03T10:48:10.4555580' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10230, 4, N'CommunityParticipation', 5, N'Community', 1, CAST(N'2026-08-03T11:22:49.8509505' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10231, 1, N'AddShare', 2, N'Profile', 1, CAST(N'2026-08-03T12:16:35.8674106' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10232, 3, N'CommunityParticipation', 5, N'Community', 6, CAST(N'2026-08-03T12:36:54.6448140' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10233, 3, N'CommunityParticipation', 5, N'Community', 2, CAST(N'2026-08-03T12:37:02.9077681' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10234, 5, N'AddLike', 1, N'Post', 10081, CAST(N'2026-08-04T10:57:58.2650384' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10235, 2, N'ReceiveLike', 1, N'Post', 10081, CAST(N'2026-08-04T10:57:58.5982824' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10236, 1, N'CreateVideo', 8, N'Video', 10009, CAST(N'2026-08-04T11:03:46.4898660' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10237, 1, N'CreateVideo', 8, N'Video', 10010, CAST(N'2026-08-04T11:08:29.3686514' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10238, 1, N'CreateVideo', 8, N'Video', 10011, CAST(N'2026-08-04T11:19:34.7726297' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10239, 3, N'CreateVideo', 8, N'Video', 10014, CAST(N'2026-08-04T12:22:46.0106027' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10240, 3, N'CreateVideo', 8, N'Video', 10015, CAST(N'2026-08-04T12:25:35.5992328' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10241, 3, N'CreateVideo', 8, N'Video', 10016, CAST(N'2026-08-04T12:30:30.9273153' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10242, 1, N'AddComment', 2, N'Post', 10081, CAST(N'2026-08-04T13:01:55.3743068' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10243, 2, N'ReceiveComment', 2, N'Post', 10081, CAST(N'2026-08-04T13:01:55.4761679' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10244, 1, N'AddComment', 2, N'Post', 10081, CAST(N'2026-08-04T13:02:06.1087214' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10245, 2, N'ReceiveComment', 2, N'Post', 10081, CAST(N'2026-08-04T13:02:06.2595874' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10246, 3, N'AddComment', 2, N'Post', 10081, CAST(N'2026-08-04T13:03:34.0220921' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10247, 2, N'ReceiveComment', 2, N'Post', 10081, CAST(N'2026-08-04T13:03:34.1488440' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10248, 3, N'AddShare', 2, N'Post', 10081, CAST(N'2026-08-04T13:03:56.7202171' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10249, 2, N'ReceiveShare', 3, N'Post', 10081, CAST(N'2026-08-04T13:03:56.9014353' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10250, 1, N'CreateVideo', 8, N'Video', 10020, CAST(N'2026-08-05T05:47:56.9924698' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10251, 1, N'CommunityParticipation', 5, N'Community', 1, CAST(N'2026-08-05T08:50:43.2055884' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10252, 1, N'CommunityParticipation', 5, N'Community', 6, CAST(N'2026-08-05T08:53:59.4233398' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10253, 2, N'CommunityParticipation', 5, N'Community', 1, CAST(N'2026-08-05T09:02:49.0308850' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10254, 1, N'AddLike', 1, N'Post', 10081, CAST(N'2026-08-05T09:47:19.4431943' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10255, 2, N'ReceiveLike', 1, N'Post', 10081, CAST(N'2026-08-05T09:47:19.5791235' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10256, 1, N'AddLike', 1, N'Post', 10081, CAST(N'2026-08-05T09:47:21.0032719' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10257, 2, N'ReceiveLike', 1, N'Post', 10081, CAST(N'2026-08-05T09:47:21.0600406' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10258, 1, N'AddLike', 1, N'Post', 10079, CAST(N'2026-08-05T09:47:33.7822636' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10259, 2, N'ReceiveLike', 1, N'Post', 10079, CAST(N'2026-08-05T09:47:33.8359954' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10260, 1, N'AddComment', 2, N'Post', 10079, CAST(N'2026-08-05T09:47:40.4236397' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10261, 2, N'ReceiveComment', 2, N'Post', 10079, CAST(N'2026-08-05T09:47:40.4965429' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10262, 1, N'AddShare', 2, N'Post', 10079, CAST(N'2026-08-05T09:47:47.3162653' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10263, 2, N'ReceiveShare', 3, N'Post', 10079, CAST(N'2026-08-05T09:47:47.3953696' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10264, 1, N'AddLike', 1, N'Post', 10077, CAST(N'2026-08-05T09:52:25.9456813' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10265, 4, N'ReceiveLike', 1, N'Post', 10077, CAST(N'2026-08-05T09:52:26.0442188' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10266, 1, N'AddComment', 2, N'Post', 10077, CAST(N'2026-08-05T09:52:35.6506228' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10267, 4, N'ReceiveComment', 2, N'Post', 10077, CAST(N'2026-08-05T09:52:35.7240146' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10268, 3, N'AddComment', 2, N'Post', 10081, CAST(N'2026-08-05T09:59:30.9277230' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10269, 2, N'ReceiveComment', 2, N'Post', 10081, CAST(N'2026-08-05T09:59:31.0116876' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10270, 3, N'AddShare', 2, N'Post', 10081, CAST(N'2026-08-05T09:59:46.1505184' AS DateTime2))
INSERT [dbo].[KarmaTransactions] ([TransactionId], [UserId], [ActivityType], [PointsAwarded], [RelatedContentType], [RelatedContentId], [CreatedDate]) VALUES (10271, 2, N'ReceiveShare', 3, N'Post', 10081, CAST(N'2026-08-05T09:59:46.2011572' AS DateTime2))
SET IDENTITY_INSERT [dbo].[KarmaTransactions] OFF
SET IDENTITY_INSERT [dbo].[KarmaTransactions] OFF;
GO

-- BlockedUrls: (empty)
-- RestrictedKeywords
SET IDENTITY_INSERT [dbo].[RestrictedKeywords] ON;
SET IDENTITY_INSERT [dbo].[RestrictedKeywords] ON 

INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (57, N'aadhaar')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (1, N'abuse')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (2, N'abusive')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (43, N'access token')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (40, N'api key')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (41, N'apikey')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (63, N'bank account')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (70, N'betting')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (19, N'bomb')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (14, N'bullying')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (64, N'buy now')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (69, N'casino')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (36, N'cheat')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (53, N'classified')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (65, N'click here')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (48, N'client secret')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (51, N'confidential')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (47, N'connection string')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (37, N'crack')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (60, N'credit card')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (61, N'cvv')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (8, N'damn')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (49, N'database password')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (67, N'earn money')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (25, N'explicit')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (7, N'fool')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (35, N'fraud')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (66, N'free money')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (71, N'gambling')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (27, N'hack')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (28, N'hacker')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (29, N'hacking')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (13, N'harassment')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (10, N'hate')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (9, N'hell')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (3, N'idiot')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (54, N'internal only')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (45, N'jwt token')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (16, N'kill')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (6, N'loser')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (68, N'lottery')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (30, N'malware')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (5, N'moron')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (17, N'murder')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (52, N'nda')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (26, N'nude')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (15, N'offensive')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (62, N'otp')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (58, N'pan card')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (59, N'passport')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (39, N'password')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (33, N'phishing')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (38, N'piracy')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (22, N'porn')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (23, N'pornography')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (46, N'private key')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (56, N'proprietary')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (11, N'racist')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (32, N'ransomware')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (44, N'refresh token')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (55, N'restricted')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (50, N'salary')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (34, N'scam')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (42, N'secret key')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (12, N'sexist')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (24, N'sexual')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (4, N'stupid')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (18, N'terrorist')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (20, N'violence')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (31, N'virus')
INSERT [dbo].[RestrictedKeywords] ([KeywordId], [Keyword]) VALUES (21, N'weapon')
SET IDENTITY_INSERT [dbo].[RestrictedKeywords] OFF
SET IDENTITY_INSERT [dbo].[RestrictedKeywords] OFF;
GO


-- ============================================================
-- SETUP COMPLETE
-- Knome database is ready. Enjoy!
-- ============================================================
