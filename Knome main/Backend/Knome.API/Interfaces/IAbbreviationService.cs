using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.DTOs.Abbreviations;

namespace Knome.API.Interfaces;

public interface IAbbreviationService
{
    Task<List<AbbreviationDto>> GetAbbreviationsAsync(string? search, string? keyword, int pageNumber, int pageSize);
    Task<AbbreviationDto?> GetByIdAsync(int id);
    Task<List<AbbreviationDto>> LookupAsync(string term);
    Task<AbbreviationDto> CreateAsync(CreateAbbreviationDto dto, int currentUserId);
    Task<AbbreviationDto> UpdateAsync(int id, UpdateAbbreviationDto dto, int currentUserId);
    Task<bool> DeleteAsync(int id, int currentUserId);
}
