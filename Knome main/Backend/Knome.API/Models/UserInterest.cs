using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class UserInterest
{
    public int UserId { get; set; }

    public string Interest { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
