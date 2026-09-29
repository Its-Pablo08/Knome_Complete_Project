namespace Knome.API.DTOs.Search;

/// <summary>
/// Lightweight DTO for real-time search suggestions overlay (navbar dropdown).
/// </summary>
public class SearchSuggestionDto
{
    public long Id { get; set; }
    public string ContentType { get; set; } = string.Empty; // User, Post, Article, Video, Podcast, Community, Hashtag, Document, Job
    public string Title { get; set; } = string.Empty;
    public string Subtitle { get; set; } = string.Empty;
    public string? ThumbnailUrl { get; set; }
    public string? CategoryName { get; set; }
}
