using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.Models;

namespace Knome.API.Interfaces;

public interface IPostRepository
{
    Task<Post?> GetPostByIdAsync(long postId);
    Task<List<Post>> GetPostsAsync(string? audienceType, string? search, int pageNumber, int pageSize, int currentUserId = 0);
    Task<List<Post>> GetMyPostsAsync(int authorUserId, int pageNumber = 1, int pageSize = 20);
    Task<Post> AddPostAsync(Post post, List<string> attachmentUrls, List<string> attachmentTypes, List<int> mentionedUserIds);
    Task UpdatePostAsync(Post post, List<string> attachmentUrls, List<string> attachmentTypes, List<int> mentionedUserIds);
    Task DeletePostAsync(Post post);
    Task<List<Post>> PublishDueScheduledPostsAsync();
}
