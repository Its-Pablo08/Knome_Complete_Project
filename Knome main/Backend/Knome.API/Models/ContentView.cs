using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class ContentView
{
    public long ViewId { get; set; }

    public string ContentType { get; set; } = null!;

    public long ContentId { get; set; }

    public int UserId { get; set; }

    public DateTime ViewedDate { get; set; }

    public virtual User User { get; set; } = null!;
}
