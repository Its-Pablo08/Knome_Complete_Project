namespace Knome.API.DTOs.Search;

/// <summary>
/// A single unified search hit. Heterogeneous entity ids are normalised to a long.
/// </summary>
public class SearchItemDto
{
    /// <summary>Entity type: User, Community, Post, Article, Video, Podcast, Job.</summary>
    public string ContentType { get; set; } = string.Empty;

    /// <summary>Entity primary key (long for content types, int for people/communities/jobs, widened for uniformity).</summary>
    public long Id { get; set; }

    public string Title { get; set; } = string.Empty;
    public string Summary { get; set; } = string.Empty;

    public string AuthorFullName { get; set; } = string.Empty;
    public string AuthorEmployeeId { get; set; } = string.Empty;

    public System.DateTime CreatedDate { get; set; }

    /// <summary>Live engagement score (reactions/comments etc.) enriched by the interaction service.</summary>
    public long EngagementScore { get; set; }

    /// <summary>Static popularity metric (view counts) used for popularity sorting.</summary>
    public int PopularityScore { get; set; }

    public string? ThumbnailUrl { get; set; }
    public string? AuthorProfilePhotoUrl { get; set; }
    public string? CategoryName { get; set; }
    public string? DepartmentName { get; set; }
    public System.Collections.Generic.List<string> Tags { get; set; } = new();
    public int CalculatedRelevanceScore { get; set; }
}
