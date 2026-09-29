using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Share
{
    public long ShareId { get; set; }

    public string ContentType { get; set; } = null!;

    public long ContentId { get; set; }

    public int UserId { get; set; }

    public string SharedToType { get; set; } = null!;

    public long? TargetId { get; set; }

    public DateTime CreatedDate { get; set; }

    public virtual User User { get; set; } = null!;
}
