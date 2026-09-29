using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.Models;

namespace Knome.API.Interfaces;

public interface IArticleRepository
{
    Task<Article?> GetArticleByIdAsync(long articleId);
    Task<List<Article>> GetArticlesAsync(int? categoryId, string? tag, string? status, string? search, int pageNumber, int pageSize, int currentUserId = 0);
    Task<List<Article>> GetMyArticlesAsync(int authorUserId, int pageNumber = 1, int pageSize = 20);
    Task<Article> AddArticleAsync(Article article, List<string> tags, List<string> attachmentUrls, ArticleVersion initialVersion);
    Task UpdateArticleAsync(Article article, List<string> tags, List<string> attachmentUrls, ArticleVersion? newVersionOrNull);
    Task DeleteArticleAsync(Article article);
    Task IncrementViewCountAsync(long articleId);
    Task<List<Article>> PublishDueScheduledArticlesAsync();
}
