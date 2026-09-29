using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class BlockedUrl
{
    public int BlockedUrlId { get; set; }

    public string UrlPattern { get; set; } = null!;

    public string? Reason { get; set; }
}
