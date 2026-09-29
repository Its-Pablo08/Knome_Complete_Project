using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class NotificationPreference
{
    public int UserId { get; set; }

    public string EventType { get; set; } = null!;

    public bool BellEnabled { get; set; }

    public bool EmailEnabled { get; set; }

    public virtual User User { get; set; } = null!;
}
