using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.Models;

namespace Knome.API.Interfaces;

public interface IVideoRepository
{
    Task<Video?> GetVideoByIdAsync(long videoId);
    Task<List<Video>> GetVideosAsync(int? categoryId, string? tag, string? search, int pageNumber, int pageSize);
    Task<List<Video>> GetMyVideosAsync(int uploaderUserId, int pageNumber = 1, int pageSize = 20);
    Task<Video> AddVideoAsync(Video video, List<string> tags);
    Task UpdateVideoAsync(Video video, List<string> tags);
    Task DeleteVideoAsync(Video video);
    Task IncrementViewCountAsync(long videoId);
}
