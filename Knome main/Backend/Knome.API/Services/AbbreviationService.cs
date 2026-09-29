using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using AutoMapper;
using Knome.API.Common;
using Knome.API.DTOs.Abbreviations;
using Knome.API.Exceptions;
using Knome.API.Interfaces;
using Knome.API.Models;

namespace Knome.API.Services;

public class AbbreviationService : IAbbreviationService
{
    private readonly IAbbreviationRepository _repo;
    private readonly IMapper _mapper;

    public AbbreviationService(IAbbreviationRepository repo, IMapper mapper)
    {
        _repo = repo;
        _mapper = mapper;
    }

    public async Task<List<AbbreviationDto>> GetAbbreviationsAsync(string? search, string? keyword, int pageNumber, int pageSize)
    {
        if (pageNumber <= 0) pageNumber = 1;
        if (pageSize <= 0 || pageSize > 500) pageSize = 100;

        var (items, _) = await _repo.GetAbbreviationsAsync(search, keyword, pageNumber, pageSize);
        return _mapper.Map<List<AbbreviationDto>>(items);
    }

    public async Task<AbbreviationDto?> GetByIdAsync(int id)
    {
        var item = await _repo.GetByIdAsync(id);
        return item != null ? _mapper.Map<AbbreviationDto>(item) : null;
    }

    public async Task<List<AbbreviationDto>> LookupAsync(string term)
    {
        var items = await _repo.LookupAsync(term);
        return _mapper.Map<List<AbbreviationDto>>(items);
    }

    public async Task<AbbreviationDto> CreateAsync(CreateAbbreviationDto dto, int currentUserId)
    {
        if (string.IsNullOrWhiteSpace(dto.Keyword))
            throw new BadRequestException("Keyword is mandatory and cannot be empty.");

        var exists = await _repo.ExistsAsync(dto.ShortCode, dto.Keyword);
        if (exists)
            throw new BadRequestException($"An abbreviation with ShortCode '{dto.ShortCode}' and Keyword '{dto.Keyword}' already exists.");

        var entity = _mapper.Map<Abbreviation>(dto);
        entity.CreatedBy = currentUserId > 0 ? currentUserId : null;
        entity.CreatedDate = KnomeTime.Now;
        entity.IsActive = true;

        var added = await _repo.AddAsync(entity);
        return _mapper.Map<AbbreviationDto>(added);
    }

    public async Task<AbbreviationDto> UpdateAsync(int id, UpdateAbbreviationDto dto, int currentUserId)
    {
        var existing = await _repo.GetByIdAsync(id);
        if (existing == null)
            throw new NotFoundException($"Abbreviation with ID {id} not found.");

        if (string.IsNullOrWhiteSpace(dto.Keyword))
            throw new BadRequestException("Keyword is mandatory and cannot be empty.");

        var exists = await _repo.ExistsAsync(dto.ShortCode, dto.Keyword, id);
        if (exists)
            throw new BadRequestException($"Another abbreviation with ShortCode '{dto.ShortCode}' and Keyword '{dto.Keyword}' already exists.");

        existing.ShortCode = dto.ShortCode.Trim();
        existing.Keyword = dto.Keyword.Trim();
        existing.Description = dto.Description.Trim();
        existing.IsActive = dto.IsActive;

        await _repo.UpdateAsync(existing);
        return _mapper.Map<AbbreviationDto>(existing);
    }

    public async Task<bool> DeleteAsync(int id, int currentUserId)
    {
        var existing = await _repo.GetByIdAsync(id);
        if (existing == null)
            throw new NotFoundException($"Abbreviation with ID {id} not found.");

        await _repo.DeleteAsync(existing);
        return true;
    }
}
