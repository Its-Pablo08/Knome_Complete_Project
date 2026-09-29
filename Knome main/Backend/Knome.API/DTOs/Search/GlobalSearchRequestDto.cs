using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Knome.API.DTOs.Search;

/// <summary>
/// Unified search request across users, communities, posts, articles, videos, podcasts, and jobs.
/// </summary>
public class GlobalSearchRequestDto
{
    /// <summary>Free-text keyword or phrase. Partial (contains) matching is supported.</summary>
    [MaxLength(100, ErrorMessage = "Search query cannot exceed 100 characters.")]
    public string Query { get; set; } = string.Empty;

    [Range(1, 1000, ErrorMessage = "Page number must be between 1 and 1000.")]
    public int PageNumber { get; set; } = 1;

    [Range(1, 100, ErrorMessage = "Page size must be between 1 and 100.")]
    public int PageSize { get; set; } = 20;

    /// <summary>Optional type filter: User, People, Community, Post, Article, Video, Podcast, Job, Hashtags, Documents, Content.</summary>
    [RegularExpression("^(?i)(User|Users|People|Community|Communities|Post|Posts|Article|Articles|Video|Videos|Podcast|Podcasts|Job|Jobs|Hashtags|Documents|Content|All)$",
        ErrorMessage = "Content type must be one of: User, People, Community, Post, Article, Video, Podcast, Job, Hashtags, Documents, Content.")]
    public string? ContentType { get; set; }

    /// <summary>Restrict results created/on or after this date (UTC).</summary>
    public DateTime? DateFrom { get; set; }

    /// <summary>Restrict results created/on or before this date (UTC).</summary>
    public DateTime? DateTo { get; set; }

    /// <summary>Filter by category (Articles, Videos, Podcasts, Communities).</summary>
    public int? CategoryId { get; set; }

    /// <summary>Filter by department (Users, Jobs, and content authors).</summary>
    public int? DepartmentId { get; set; }

    /// <summary>Filter content by author display name (contains match).</summary>
    public string? Author { get; set; }

    /// <summary>Tag-based search. Matches Articles and Videos that carry any of the given tags.</summary>
    public List<string>? Tags { get; set; }

    /// <summary>Sort key: relevance (default), date, or popularity.</summary>
    [RegularExpression("^(relevance|date|popularity)$",
        ErrorMessage = "SortBy must be one of: relevance, date, popularity.")]
    public string? SortBy { get; set; }

    /// <summary>Sort direction: asc or desc (default desc).</summary>
    [RegularExpression("^(asc|desc)$", ErrorMessage = "SortOrder must be asc or desc.")]
    public string? SortOrder { get; set; }
}
