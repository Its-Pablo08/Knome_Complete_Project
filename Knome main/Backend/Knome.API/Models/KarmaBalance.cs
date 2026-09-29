using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class KarmaBalance
{
    public int UserId { get; set; }

    public int TotalPoints { get; set; }

    public string BadgeLevel { get; set; } = null!;

    public DateTime LastUpdated { get; set; }

    public virtual User User { get; set; } = null!;
}
