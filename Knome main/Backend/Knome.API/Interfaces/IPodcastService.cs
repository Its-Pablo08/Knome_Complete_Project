using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.DTOs.Podcasts;

namespace Knome.API.Interfaces;

public interface IPodcastService
{
    // Series
    Task<PodcastSeriesDto> GetSeriesByIdAsync(int seriesId);
    Task<List<PodcastSeriesDto>> GetAllSeriesAsync();
    Task<PodcastSeriesDto> CreateSeriesAsync(int currentUserId, CreatePodcastSeriesDto dto);
    Task<PodcastSeriesDto> UpdateSeriesAsync(int seriesId, int currentUserId, UpdatePodcastSeriesDto dto);
    Task DeleteSeriesAsync(int seriesId, int currentUserId);

    // Episodes
    Task<PodcastDto> GetPodcastAsync(long podcastId, int currentUserId);
    Task<List<PodcastDto>> GetPodcastsAsync(int? seriesId, int? categoryId, string? search, int pageNumber, int pageSize, int currentUserId);
    Task<List<PodcastDto>> GetMyPodcastsAsync(int currentUserId, int pageNumber = 1, int pageSize = 20);
    Task<List<PodcastDto>> GetUserPodcastsAsync(int hostUserId, int currentUserId, int pageNumber = 1, int pageSize = 20);
    Task<PodcastDto> CreatePodcastAsync(int currentUserId, CreatePodcastDto dto);
    Task<PodcastDto> UpdatePodcastAsync(long podcastId, int currentUserId, UpdatePodcastDto dto);
    Task DeletePodcastAsync(long podcastId, int currentUserId);
    Task<int> IncrementViewCountAsync(long podcastId, int currentUserId = 0);
}
