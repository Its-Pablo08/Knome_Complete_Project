using System.Collections.Generic;

namespace Knome.API.DTOs.Search;

/// <summary>
/// Paginated unified search result with per-type hit counts for faceted navigation.
/// </summary>
public class GlobalSearchResultDto
{
    public List<SearchItemDto> Items { get; set; } = new();

    /// <summary>Total filtered matches before pagination.</summary>
    public int TotalCount { get; set; }

    public int PageNumber { get; set; }
    public int PageSize { get; set; }

    /// <summary>Match counts grouped by content type (e.g. {"Post": 12, "User": 3}).</summary>
    public Dictionary<string, int> TypeCounts { get; set; } = new();
}
