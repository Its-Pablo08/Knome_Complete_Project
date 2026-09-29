using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class AuditLog
{
    public long AuditId { get; set; }

    public int ActorUserId { get; set; }

    public string Action { get; set; } = null!;

    public string TargetType { get; set; } = null!;

    public long TargetId { get; set; }

    public string? Reason { get; set; }

    public string? Ipaddress { get; set; }

    public DateTime Timestamp { get; set; }

    public string? OldValue { get; set; }

    public string? NewValue { get; set; }

    public virtual User ActorUser { get; set; } = null!;
}
