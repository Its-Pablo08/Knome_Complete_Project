using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Knome.API.Data;
using Knome.API.Interfaces;
using Knome.API.Models;
using Microsoft.EntityFrameworkCore;

namespace Knome.API.Repositories;

public class AbbreviationRepository : IAbbreviationRepository
{
    private readonly KnomeDbContext _context;

    public AbbreviationRepository(KnomeDbContext context)
    {
        _context = context;
    }

    public async Task<(List<Abbreviation> Items, int TotalCount)> GetAbbreviationsAsync(string? search, string? keyword, int pageNumber, int pageSize)
    {
        var query = _context.Abbreviations
            .Include(a => a.CreatedByNavigation)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var cleanKeyword = keyword.Trim().ToLower();
            query = query.Where(a => a.Keyword.ToLower().Contains(cleanKeyword));
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var cleanSearch = search.Trim().ToLower();
            query = query.Where(a => a.ShortCode.ToLower().Contains(cleanSearch) ||
                                     a.Keyword.ToLower().Contains(cleanSearch) ||
                                     a.Description.ToLower().Contains(cleanSearch));
        }

        var total = await query.CountAsync();
        var items = await query
            .OrderBy(a => a.ShortCode)
            .ThenBy(a => a.Keyword)
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (items, total);
    }

    public async Task<Abbreviation?> GetByIdAsync(int id)
    {
        return await _context.Abbreviations
            .Include(a => a.CreatedByNavigation)
            .FirstOrDefaultAsync(a => a.AbbreviationId == id);
    }

    public async Task<List<Abbreviation>> LookupAsync(string term)
    {
        if (string.IsNullOrWhiteSpace(term))
            return new List<Abbreviation>();

        var clean = term.Trim().ToLower();
        return await _context.Abbreviations
            .Include(a => a.CreatedByNavigation)
            .Where(a => a.IsActive && (a.ShortCode.ToLower() == clean || a.Keyword.ToLower() == clean || a.ShortCode.ToLower().Contains(clean)))
            .OrderBy(a => a.ShortCode)
            .Take(20)
            .ToListAsync();
    }

    public async Task<bool> ExistsAsync(string shortCode, string keyword, int? excludeId = null)
    {
        var cleanCode = shortCode.Trim().ToLower();
        var cleanKey = keyword.Trim().ToLower();
        var query = _context.Abbreviations
            .Where(a => a.ShortCode.ToLower() == cleanCode && a.Keyword.ToLower() == cleanKey);

        if (excludeId.HasValue)
            query = query.Where(a => a.AbbreviationId != excludeId.Value);

        return await query.AnyAsync();
    }

    public async Task<Abbreviation> AddAsync(Abbreviation entity)
    {
        _context.Abbreviations.Add(entity);
        await _context.SaveChangesAsync();
        return entity;
    }

    public async Task UpdateAsync(Abbreviation entity)
    {
        _context.Abbreviations.Update(entity);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Abbreviation entity)
    {
        _context.Abbreviations.Remove(entity);
        await _context.SaveChangesAsync();
    }
}
