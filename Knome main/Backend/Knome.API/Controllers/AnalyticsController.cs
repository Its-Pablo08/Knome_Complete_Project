using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Knome.API.Constants;
using Knome.API.Data;
using Knome.API.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Knome.API.Controllers;

/// <summary>
/// HR Analytics &amp; Reporting controller for platform metrics and insights.
/// Synchronized directly with live SQL Server database.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AnalyticsController : KnomeControllerBase
{
    private readonly KnomeDbContext _context;

    public AnalyticsController(KnomeDbContext context)
    {
        _context = context;
    }

    /// <summary>
    /// User engagement metrics (active users, total karma, karma distribution).
    /// </summary>
    [HttpGet("engagement")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetEngagementMetrics()
    {
        var totalUsers = await _context.Users.CountAsync();
        var activeUsers = await _context.Users.CountAsync(u => u.IsActive && !u.IsPermanentlySuspended);
        var suspendedUsers = await _context.Users.CountAsync(u => !u.IsActive || u.IsPermanentlySuspended);
        
        var karmaStats = await _context.KarmaBalances
            .Select(k => k.TotalPoints)
            .ToListAsync();

        var metrics = new
        {
            TotalUsers = totalUsers,
            ActiveUsers = activeUsers,
            SuspendedUsers = suspendedUsers,
            TotalKarmaDistributed = karmaStats.Sum(),
            AverageKarmaPerUser = karmaStats.Count > 0 ? (int)karmaStats.Average() : 0,
            KarmaTiers = new
            {
                Bronze = karmaStats.Count(k => k <= 250),
                Silver = karmaStats.Count(k => k > 250 && k <= 1000),
                Gold = karmaStats.Count(k => k > 1000 && k <= 5000),
                Platinum = karmaStats.Count(k => k > 5000)
            }
        };

        return Ok(ApiResponse<object>.SuccessResponse(200, "Engagement metrics retrieved successfully.", metrics));
    }

    /// <summary>
    /// Community health metrics (member counts, community activity).
    /// Filters by active communities and approved memberships.
    /// </summary>
    [HttpGet("community-health")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetCommunityHealthMetrics()
    {
        var totalCommunities = await _context.Communities.CountAsync(c => c.IsActive);
        var totalMemberships = await _context.CommunityMembers.CountAsync(cm => (cm.Status == "Approved" || cm.Status == "Active") && cm.Community.IsActive);

        var communitiesSummary = await _context.Communities
            .Where(c => c.IsActive)
            .Select(c => new
            {
                c.CommunityId,
                c.Name,
                AccessType = c.CommunityType,
                MembersCount = c.CommunityMembers.Count(m => (m.Status == "Approved" || m.Status == "Active")),
                PostsCount = c.Posts.Count
            })
            .OrderByDescending(c => c.MembersCount)
            .Take(10)
            .ToListAsync();

        var metrics = new
        {
            TotalCommunities = totalCommunities,
            TotalMemberships = totalMemberships,
            AverageMembersPerCommunity = totalCommunities > 0 ? (int)Math.Round((double)totalMemberships / totalCommunities) : 0,
            TopCommunities = communitiesSummary
        };

        return Ok(ApiResponse<object>.SuccessResponse(200, "Community health metrics retrieved successfully.", metrics));
    }

    /// <summary>
    /// Content performance metrics (posts, articles, videos, podcasts, reactions count).
    /// </summary>
    [HttpGet("content-performance")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetContentPerformanceMetrics()
    {
        var postsCount = await _context.Posts.CountAsync();
        var articlesCount = await _context.Articles.CountAsync();
        var videosCount = await _context.Videos.CountAsync();
        var podcastsCount = await _context.Podcasts.CountAsync(p => p.IsActive);
        var reactionsCount = await _context.Reactions.CountAsync();
        var commentsCount = await _context.Comments.CountAsync();

        var metrics = new
        {
            TotalPosts = postsCount,
            TotalArticles = articlesCount,
            TotalVideos = videosCount,
            TotalPodcasts = podcastsCount,
            TotalReactions = reactionsCount,
            TotalComments = commentsCount,
            TotalContentCount = postsCount + articlesCount + videosCount + podcastsCount
        };

        return Ok(ApiResponse<object>.SuccessResponse(200, "Content performance metrics retrieved successfully.", metrics));
    }

    /// <summary>
    /// Trending content and top contributors from live database.
    /// </summary>
    [HttpGet("trending")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetTrendingMetrics()
    {
        var topContributors = await _context.KarmaBalances
            .Include(k => k.User)
            .OrderByDescending(k => k.TotalPoints)
            .Take(10)
            .Select(k => new
            {
                UserId = k.UserId,
                FullName = k.User.FullName,
                Designation = k.User.Designation ?? "Employee",
                Department = k.User.Department != null ? k.User.Department.Name : "MPOnline",
                TotalPoints = k.TotalPoints
            })
            .ToListAsync();

        var topCommunities = await _context.Communities
            .Where(c => c.IsActive)
            .Select(c => new
            {
                c.CommunityId,
                c.Name,
                AccessType = c.CommunityType,
                MembersCount = c.CommunityMembers.Count(m => m.Status == "Approved" || m.Status == "Active"),
                PostsCount = c.Posts.Count
            })
            .OrderByDescending(c => c.MembersCount)
            .Take(10)
            .ToListAsync();

        var metrics = new
        {
            TopContributors = topContributors,
            TopCommunities = topCommunities
        };

        return Ok(ApiResponse<object>.SuccessResponse(200, "Trending metrics retrieved successfully.", metrics));
    }

    /// <summary>
    /// Moderation and audit metrics for the analytics portal.
    /// </summary>
    [HttpGet("moderation")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetModerationMetrics()
    {
        var pendingReportsCount = await _context.ModerationReports.CountAsync(r => r.Status == "Pending");
        var resolvedReportsCount = await _context.ModerationReports.CountAsync(r => r.Status == "Resolved");
        var dismissedReportsCount = await _context.ModerationReports.CountAsync(r => r.Status == "Dismissed");
        var suspendedUsersCount = await _context.Users.CountAsync(u => !u.IsActive || u.IsPermanentlySuspended);
        var totalAuditLogsCount = await _context.AuditLogs.CountAsync();

        var recentAuditLogs = await _context.AuditLogs
            .OrderByDescending(l => l.Timestamp)
            .Take(25)
            .Select(l => new
            {
                LogId = l.AuditId,
                Timestamp = l.Timestamp,
                ActorFullName = l.ActorUser != null ? l.ActorUser.FullName : "System Administrator",
                Action = l.Action,
                TargetType = l.TargetType,
                Details = l.Reason ?? (l.TargetType + " #" + l.TargetId)
            })
            .ToListAsync();

        var pendingReports = await _context.ModerationReports
            .Where(r => r.Status == "Pending")
            .OrderByDescending(r => r.ReportedDate)
            .Take(25)
            .Select(r => new
            {
                r.ReportId,
                r.ReporterUserId,
                ReporterFullName = r.ReporterUser != null ? r.ReporterUser.FullName : ("User #" + r.ReporterUserId),
                r.ContentType,
                r.ContentId,
                r.ReasonCode,
                r.Status,
                r.ReportedDate
            })
            .ToListAsync();

        var metrics = new
        {
            PendingReportsCount = pendingReportsCount,
            ResolvedReportsCount = resolvedReportsCount,
            DismissedReportsCount = dismissedReportsCount,
            SuspendedUsersCount = suspendedUsersCount,
            TotalAuditLogsCount = totalAuditLogsCount,
            AuditLogs = recentAuditLogs,
            PendingReports = pendingReports
        };

        return Ok(ApiResponse<object>.SuccessResponse(200, "Moderation metrics retrieved successfully.", metrics));
    }
}
