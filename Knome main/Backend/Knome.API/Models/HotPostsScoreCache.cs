using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class HotPostsScoreCache
{
    public string ContentType { get; set; } = null!;

    public long ContentId { get; set; }

    public string Window { get; set; } = null!;

    public decimal Score { get; set; }

    public DateTime CalculatedAt { get; set; }
}
