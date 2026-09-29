using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class ModerationReport
{
    public long ReportId { get; set; }

    public int ReporterUserId { get; set; }

    public string ContentType { get; set; } = null!;

    public long ContentId { get; set; }

    public string ReasonCode { get; set; } = null!;

    public string Status { get; set; } = null!;

    public int? ModeratorUserId { get; set; }

    public string? ActionTaken { get; set; }

    public DateTime ReportedDate { get; set; }

    public DateTime? ActionDate { get; set; }

    public virtual User? ModeratorUser { get; set; }

    public virtual User ReporterUser { get; set; } = null!;
}
