using System.Collections.Generic;
using Knome.API.DTOs.Karma;

namespace Knome.API.DTOs.Feed;

public class DashboardSummaryDto
{
    public KarmaBalanceDto? CurrentUserKarma { get; set; }
    public int UnreadNotificationsCount { get; set; }
    public List<FeedItemDto> PersonalizedFeed { get; set; } = new();
    public List<FeedItemDto> TopHotPosts { get; set; } = new();
}
