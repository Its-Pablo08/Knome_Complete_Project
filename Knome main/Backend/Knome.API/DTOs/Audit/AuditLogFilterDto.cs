using System.ComponentModel.DataAnnotations;

namespace Knome.API.DTOs.Audit;

/// <summary>
/// Query parameters for listing audit-log entries. All filters are optional;
/// results are ordered by Timestamp descending and paginated.
/// </summary>
public class AuditLogFilterDto
{
    public int? ActorUserId { get; set; }
    public string? Action { get; set; }
    public string? TargetType { get; set; }
    public long? TargetId { get; set; }
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }

    [Range(1, 1000, ErrorMessage = "Page number must be between 1 and 1000.")]
    public int PageNumber { get; set; } = 1;

    [Range(1, 100, ErrorMessage = "Page size must be between 1 and 100.")]
    public int PageSize { get; set; } = 20;
}
