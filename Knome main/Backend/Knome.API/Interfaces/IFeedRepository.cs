using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.Models;

namespace Knome.API.Interfaces;

public interface IFeedRepository
{
    Task<List<int>> GetFollowedUserIdsAsync(int userId);
    Task<List<int>> GetMyCommunityIdsAsync(int userId);
    Task<List<Post>> GetCandidatePostsAsync(List<int> followedUserIds, List<int> myCommunityIds, int currentUserId, int limit);
    Task<List<Article>> GetCandidateArticlesAsync(List<int> followedUserIds, int currentUserId, int limit);
    Task<List<Video>> GetCandidateVideosAsync(List<int> followedUserIds, int currentUserId, int limit);
    Task<List<Podcast>> GetCandidatePodcastsAsync(List<int> followedUserIds, int currentUserId, int limit);
    Task UpdateOrAddHotScoreCacheAsync(HotPostsScoreCache cache);
    Task<List<HotPostsScoreCache>> GetCachedHotScoresAsync(string window, int limit);
}
