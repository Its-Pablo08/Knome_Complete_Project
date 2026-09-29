using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.DTOs.Search;

namespace Knome.API.Interfaces;

public interface ISearchRepository
{
    Task<GlobalSearchResultDto> SearchGlobalAsync(GlobalSearchRequestDto request);
    Task<List<SearchItemDto>> SearchUsersAsync(string query, int pageNumber, int pageSize);
    Task<List<SearchItemDto>> SearchCommunitiesAsync(string query, int pageNumber, int pageSize);
    Task<List<SearchItemDto>> SearchContentAsync(string query, string? contentType, int pageNumber, int pageSize);

    Task RecordSearchAsync(int userId, string term);
    Task<List<SearchHistoryDto>> GetRecentSearchesAsync(int userId, int count = 10);
    Task ClearSearchHistoryAsync(int userId, string? term = null);
    Task<List<SearchSuggestionDto>> GetSuggestionsAsync(string query, int count = 8);
    Task<List<string>> GetTrendingSearchesAsync(int count = 10);
}
