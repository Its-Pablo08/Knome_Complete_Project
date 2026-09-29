using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.Models;

namespace Knome.API.Interfaces;

public interface IKarmaRepository
{
    Task<KarmaBalance?> GetBalanceByUserIdAsync(int userId);
    Task<KarmaBalance> GetOrCreateBalanceAsync(int userId);
    Task AddTransactionAsync(KarmaTransaction transaction);
    Task UpdateBalanceAsync(KarmaBalance balance);
    Task<List<KarmaTransaction>> GetRecentTransactionsAsync(int userId, int limit);
    Task<List<KarmaBalance>> GetTopBalancesAsync(int top);
    Task<int> GetTodayPointsByActivityTypeAsync(int userId, string activityType, System.DateTime dateUtc);
    Task<bool> HasEarnedCommunityParticipationTodayAsync(int userId, int communityId, System.DateTime dateUtc);
}
