using System.Linq;
using System.Threading.Tasks;
using Knome.API.Data;
using Knome.API.DTOs.Audit;
using Knome.API.DTOs.User;
using Knome.API.Interfaces;
using Knome.API.Models;
using Microsoft.EntityFrameworkCore;

namespace Knome.API.Repositories;

public class AuditLogRepository : IAuditLogRepository
{
    private readonly KnomeDbContext _context;

    public AuditLogRepository(KnomeDbContext context)
    {
        _context = context;
    }

    public async Task<AuditLog> AddAsync(AuditLog entry)
    {
        _context.AuditLogs.Add(entry);
        await _context.SaveChangesAsync();
        return entry;
    }

    public async Task<AuditLog?> GetByIdAsync(long auditId)
    {
        return await _context.AuditLogs
            .Include(a => a.ActorUser)
            .FirstOrDefaultAsync(a => a.AuditId == auditId);
    }

    public async Task<PagedResultDto<AuditLog>> GetPagedAsync(AuditLogFilterDto filter)
    {
        var query = _context.AuditLogs
            .Include(a => a.ActorUser)
            .AsQueryable();

        if (filter.ActorUserId.HasValue)
            query = query.Where(a => a.ActorUserId == filter.ActorUserId.Value);
        if (!string.IsNullOrWhiteSpace(filter.Action))
            query = query.Where(a => a.Action == filter.Action);
        if (!string.IsNullOrWhiteSpace(filter.TargetType))
            query = query.Where(a => a.TargetType == filter.TargetType);
        if (filter.TargetId.HasValue)
            query = query.Where(a => a.TargetId == filter.TargetId.Value);
        if (filter.From.HasValue)
            query = query.Where(a => a.Timestamp >= filter.From.Value);
        if (filter.To.HasValue)
            query = query.Where(a => a.Timestamp <= filter.To.Value);

        var total = await query.CountAsync();

        var page = filter.PageNumber < 1 ? 1 : filter.PageNumber;
        var size = filter.PageSize < 1 ? 20 : filter.PageSize;

        var items = await query
            .OrderByDescending(a => a.Timestamp)
            .Skip((page - 1) * size)
            .Take(size)
            .ToListAsync();

        return new PagedResultDto<AuditLog>(items, total, page, size);
    }
}
