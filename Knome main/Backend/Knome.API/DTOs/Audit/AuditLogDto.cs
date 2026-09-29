namespace Knome.API.DTOs.Audit;

public class AuditLogDto
{
    public long AuditId { get; set; }
    public int ActorUserId { get; set; }
    public string? ActorName { get; set; }
    public string Action { get; set; } = null!;
    public string TargetType { get; set; } = null!;
    public long TargetId { get; set; }
    public string? Reason { get; set; }
    public string? IpAddress { get; set; }
    public DateTime Timestamp { get; set; }
    public string? OldValue { get; set; }
    public string? NewValue { get; set; }
}
