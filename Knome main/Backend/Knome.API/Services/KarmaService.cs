using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using AutoMapper;
using Knome.API.Constants;
using Knome.API.DTOs.Karma;
using Knome.API.Exceptions;
using Knome.API.Interfaces;
using Knome.API.Models;

namespace Knome.API.Services;

public class KarmaService : IKarmaService
{
    private readonly IKarmaRepository _repo;
    private readonly IMapper _mapper;
    private readonly INotificationService _notificationService;

    public KarmaService(IKarmaRepository repo, IMapper mapper, INotificationService notificationService)
    {
        _repo = repo;
        _mapper = mapper;
        _notificationService = notificationService;
    }

    public async Task<KarmaBalanceDto> AwardKarmaAsync(int userId, string activityType, int points, string? contentType = null, long? contentId = null, int? dailyCap = null)
    {
        if (userId <= 0 || points <= 0)
            throw new BadRequestException("Invalid user ID or points amount for karma transaction.");

        int pointsToAward = points;

        if (dailyCap.HasValue && dailyCap.Value > 0)
        {
            var alreadyEarnedToday = await _repo.GetTodayPointsByActivityTypeAsync(userId, activityType, Knome.API.Common.KnomeTime.Now.Date);
            if (alreadyEarnedToday >= dailyCap.Value)
            {
                return await GetMyBalanceAsync(userId);
            }
            pointsToAward = Math.Min(points, dailyCap.Value - alreadyEarnedToday);
        }

        if (pointsToAward <= 0)
        {
            return await GetMyBalanceAsync(userId);
        }

        var tx = new KarmaTransaction
        {
            UserId = userId,
            ActivityType = activityType,
            PointsAwarded = pointsToAward,
            RelatedContentType = contentType,
            RelatedContentId = contentId,
            CreatedDate = Knome.API.Common.KnomeTime.Now
        };
        await _repo.AddTransactionAsync(tx);

        var balance = await _repo.GetOrCreateBalanceAsync(userId);
        var previousBadge = balance.BadgeLevel;
        balance.TotalPoints += pointsToAward;
        if (balance.TotalPoints < 0) balance.TotalPoints = 0; // Prevent negative balance

        balance.BadgeLevel = BadgeLevels.ComputeBadge(balance.TotalPoints);
        balance.LastUpdated = Knome.API.Common.KnomeTime.Now;

        await _repo.UpdateBalanceAsync(balance);

        // FR-NT-01: notify on badge-level increase (producer -> generic engine)
        if (!string.IsNullOrEmpty(balance.BadgeLevel) &&
            balance.BadgeLevel != previousBadge &&
            BadgeLevels.Rank(balance.BadgeLevel) > BadgeLevels.Rank(previousBadge))
        {
            await _notificationService.PublishAsync(
                userId,
                NotificationTypes.Badge,
                $"Congratulations! You've earned the {balance.BadgeLevel} badge.",
                relatedContentType: NotificationContentTypes.Badge,
                relatedContentId: null);
        }

        return await GetMyBalanceAsync(userId);
    }

    public async Task<KarmaBalanceDto> AwardCommunityParticipationAsync(int userId, int communityId)
    {
        if (userId <= 0 || communityId <= 0)
            return await GetMyBalanceAsync(userId > 0 ? userId : 1);

        var hasEarnedToday = await _repo.HasEarnedCommunityParticipationTodayAsync(userId, communityId, Knome.API.Common.KnomeTime.Now.Date);
        if (hasEarnedToday)
        {
            return await GetMyBalanceAsync(userId);
        }

        return await AwardKarmaAsync(
            userId,
            KarmaActivityTypes.CommunityParticipation,
            KarmaPoints.CommunityParticipationPoints,
            ContentTypes.Community,
            communityId);
    }

    public async Task<KarmaBalanceDto> GetMyBalanceAsync(int currentUserId)
    {
        var balance = await _repo.GetOrCreateBalanceAsync(currentUserId);
        var dto = _mapper.Map<KarmaBalanceDto>(balance);

        var recentTxs = await _repo.GetRecentTransactionsAsync(currentUserId, 100);
        dto.RecentTransactions = _mapper.Map<List<KarmaTransactionDto>>(recentTxs);

        return dto;
    }

    public async Task<KarmaBalanceDto> GetUserBalanceAsync(int targetUserId)
    {
        var balance = await _repo.GetBalanceByUserIdAsync(targetUserId);
        if (balance == null)
            throw new NotFoundException($"Karma balance for user ID {targetUserId} not found.");

        var dto = _mapper.Map<KarmaBalanceDto>(balance);
        var recentTxs = await _repo.GetRecentTransactionsAsync(targetUserId, 100);
        dto.RecentTransactions = _mapper.Map<List<KarmaTransactionDto>>(recentTxs);

        return dto;
    }

    public async Task<List<LeaderboardEntryDto>> GetLeaderboardAsync(int top = 10)
    {
        if (top <= 0 || top > 100) top = 10;
        var balances = await _repo.GetTopBalancesAsync(top);

        var dtos = new List<LeaderboardEntryDto>();
        int rank = 1;
        foreach (var b in balances)
        {
            var entry = _mapper.Map<LeaderboardEntryDto>(b);
            entry.Rank = rank++;
            dtos.Add(entry);
        }

        return dtos;
    }
}
