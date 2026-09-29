using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.DTOs.Karma;

namespace Knome.API.Interfaces;

public interface IKarmaService
{
    Task<KarmaBalanceDto> AwardKarmaAsync(int userId, string activityType, int points, string? contentType = null, long? contentId = null, int? dailyCap = null);
    Task<KarmaBalanceDto> AwardCommunityParticipationAsync(int userId, int communityId);
    Task<KarmaBalanceDto> GetMyBalanceAsync(int currentUserId);
    Task<KarmaBalanceDto> GetUserBalanceAsync(int targetUserId);
    Task<List<LeaderboardEntryDto>> GetLeaderboardAsync(int top = 10);
}
