using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.DTOs.Posts;

namespace Knome.API.Interfaces;

public interface IPostService
{
    Task<PostDto> GetPostAsync(long postId, int currentUserId);
    Task<List<PostDto>> GetPostsAsync(string? audienceType, string? search, int pageNumber, int pageSize, int currentUserId);
    Task<List<PostDto>> GetMyPostsAsync(int currentUserId, int pageNumber = 1, int pageSize = 20);
    Task<List<PostDto>> GetUserPostsAsync(int authorUserId, int currentUserId, int pageNumber = 1, int pageSize = 20);
    Task<PostDto> CreatePostAsync(int currentUserId, CreatePostDto dto);
    Task<PostDto> UpdatePostAsync(long postId, int currentUserId, UpdatePostDto dto);
    Task DeletePostAsync(long postId, int currentUserId);
    Task<int> IncrementViewCountAsync(long postId, int currentUserId = 0);
}
