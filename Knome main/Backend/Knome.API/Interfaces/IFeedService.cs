using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.DTOs.Feed;

namespace Knome.API.Interfaces;

public interface IFeedService
{
    Task<List<FeedItemDto>> GetPersonalizedFeedAsync(int currentUserId, string? contentTypeFilter, int pageNumber, int pageSize);
    Task<List<FeedItemDto>> GetHotFeedAsync(int currentUserId, string window, int top = 10);
    Task<DashboardSummaryDto> GetDashboardSummaryAsync(int currentUserId);
}
