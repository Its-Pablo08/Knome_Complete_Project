using System.Threading.Tasks;
using Knome.API.DTOs.Audit;
using Knome.API.DTOs.User;
using Knome.API.Models;

namespace Knome.API.Interfaces;

public interface IAuditLogRepository
{
    Task<AuditLog> AddAsync(AuditLog entry);

    Task<AuditLog?> GetByIdAsync(long auditId);

    Task<PagedResultDto<AuditLog>> GetPagedAsync(AuditLogFilterDto filter);
}
