using System;

namespace Knome.API.DTOs.Search;

/// <summary>
/// A previously executed search term for the signed-in user.
/// </summary>
public class SearchHistoryDto
{
    public string SearchTerm { get; set; } = string.Empty;
    public DateTime SearchedDate { get; set; }
}
