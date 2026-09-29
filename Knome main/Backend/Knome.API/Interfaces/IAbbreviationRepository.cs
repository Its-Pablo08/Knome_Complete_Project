using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.Models;

namespace Knome.API.Interfaces;

public interface IAbbreviationRepository
{
    Task<(List<Abbreviation> Items, int TotalCount)> GetAbbreviationsAsync(string? search, string? keyword, int pageNumber, int pageSize);
    Task<Abbreviation?> GetByIdAsync(int id);
    Task<List<Abbreviation>> LookupAsync(string term);
    Task<bool> ExistsAsync(string shortCode, string keyword, int? excludeId = null);
    Task<Abbreviation> AddAsync(Abbreviation entity);
    Task UpdateAsync(Abbreviation entity);
    Task DeleteAsync(Abbreviation entity);
}
