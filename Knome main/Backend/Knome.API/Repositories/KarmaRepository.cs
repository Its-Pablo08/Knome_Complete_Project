using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Knome.API.Constants;
using Knome.API.Data;
using Knome.API.Interfaces;
using Knome.API.Models;
using Microsoft.EntityFrameworkCore;

namespace Knome.API.Repositories;

public class KarmaRepository : IKarmaRepository
{
    private readonly KnomeDbContext _db;

    public KarmaRepository(KnomeDbContext db)
    {
        _db = db;
    }

    public async Task<KarmaBalance?> GetBalanceByUserIdAsync(int userId)
    {
        return await _db.KarmaBalances
            .Include(k => k.User)
            .FirstOrDefaultAsync(k => k.UserId == userId);
    }

    public async Task<KarmaBalance> GetOrCreateBalanceAsync(int userId)
    {
        var balance = await _db.KarmaBalances
            .Include(k => k.User)
            .FirstOrDefaultAsync(k => k.UserId == userId);

        if (balance == null)
        {
            balance = new KarmaBalance
            {
                UserId = userId,
                TotalPoints = 0,
                BadgeLevel = BadgeLevels.Bronze,
                LastUpdated = Knome.API.Common.KnomeTime.Now
            };
            _db.KarmaBalances.Add(balance);
            await _db.SaveChangesAsync();

            // Reload to ensure User navigation property is loaded if available
            balance = await _db.KarmaBalances
                .Include(k => k.User)
                .FirstOrDefaultAsync(k => k.UserId == userId) ?? balance;
        }

        return balance;
    }

    public async Task AddTransactionAsync(KarmaTransaction transaction)
    {
        _db.KarmaTransactions.Add(transaction);
        await _db.SaveChangesAsync();
    }

    public async Task UpdateBalanceAsync(KarmaBalance balance)
    {
        _db.KarmaBalances.Update(balance);
        await _db.SaveChangesAsync();
    }

    public async Task<List<KarmaTransaction>> GetRecentTransactionsAsync(int userId, int limit)
    {
        return await _db.KarmaTransactions
            .Where(t => t.UserId == userId)
            .OrderByDescending(t => t.CreatedDate)
            .Take(limit)
            .ToListAsync();
    }

    public async Task<List<KarmaBalance>> GetTopBalancesAsync(int top)
    {
        return await _db.KarmaBalances
            .Include(k => k.User)
            .OrderByDescending(k => k.TotalPoints)
            .Take(top)
            .ToListAsync();
    }

    public async Task<int> GetTodayPointsByActivityTypeAsync(int userId, string activityType, DateTime dateUtc)
    {
        var startDate = dateUtc.Date;
        var endDate = startDate.AddDays(1);
        return await _db.KarmaTransactions
            .Where(t => t.UserId == userId && t.ActivityType == activityType && t.CreatedDate >= startDate && t.CreatedDate < endDate)
            .SumAsync(t => (int?)t.PointsAwarded) ?? 0;
    }

    public async Task<bool> HasEarnedCommunityParticipationTodayAsync(int userId, int communityId, DateTime dateUtc)
    {
        var startDate = dateUtc.Date;
        var endDate = startDate.AddDays(1);
        return await _db.KarmaTransactions
            .AnyAsync(t => t.UserId == userId &&
                           t.ActivityType == KarmaActivityTypes.CommunityParticipation &&
                           t.RelatedContentType == ContentTypes.Community &&
                           t.RelatedContentId == communityId &&
                           t.CreatedDate >= startDate &&
                           t.CreatedDate < endDate);
    }
}
