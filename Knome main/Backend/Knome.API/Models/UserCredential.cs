using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class UserCredential
{
    public int UserId { get; set; }

    public string PasswordHash { get; set; } = null!;

    public string? PasswordSalt { get; set; }

    public DateTime LastUpdated { get; set; }

    public virtual User User { get; set; } = null!;
}
