using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.Models;

namespace Knome.API.Interfaces;

public interface IPodcastRepository
{
    // Series
    Task<PodcastSeries?> GetSeriesByIdAsync(int seriesId);
    Task<List<PodcastSeries>> GetAllSeriesAsync();
    Task<PodcastSeries> AddSeriesAsync(PodcastSeries series);
    Task UpdateSeriesAsync(PodcastSeries series);
    Task DeleteSeriesAsync(PodcastSeries series);

    // Episodes
    Task<Podcast?> GetPodcastByIdAsync(long podcastId);
    Task<List<Podcast>> GetPodcastsAsync(int? seriesId, int? categoryId, string? search, int pageNumber, int pageSize);
    Task<List<Podcast>> GetMyPodcastsAsync(int uploaderUserId, int pageNumber = 1, int pageSize = 20);
    Task<Podcast> AddPodcastAsync(Podcast podcast);
    Task UpdatePodcastAsync(Podcast podcast);
    Task DeletePodcastAsync(Podcast podcast);
    Task<int> IncrementViewCountAsync(long podcastId);
}
