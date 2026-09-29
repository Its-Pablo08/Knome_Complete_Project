namespace Knome.API.DTOs.Search;

/// <summary>
/// Request payload to record a search term in the user's search history.
/// </summary>
public class SaveSearchHistoryRequestDto
{
    public string SearchTerm { get; set; } = string.Empty;
}
