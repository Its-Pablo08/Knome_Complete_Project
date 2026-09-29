using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class UserSkill
{
    public int UserId { get; set; }

    public string Skill { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
