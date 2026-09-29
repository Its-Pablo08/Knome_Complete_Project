using System.Threading.Tasks;
using Knome.API.DTOs.Audit;
using Knome.API.DTOs.User;

namespace Knome.API.Interfaces;

/// <summary>
/// Records and exposes immutable audit-trail entries for governance actions
/// (moderation, suspension, etc.) per FR-SM-05.
/// </summary>
public interface IAuditLogService
{
    Task RecordAsync(
        int actorUserId,
        string action,
        string targetType,
        long targetId,
        string? reason = null,
        string? ipAddress = null);

    Task<AuditLogDto?> GetByIdAsync(long auditId);

    Task<PagedResultDto<AuditLogDto>> GetPagedAsync(AuditLogFilterDto filter);
}
