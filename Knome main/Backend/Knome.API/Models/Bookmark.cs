using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Bookmark
{
    public int UserId { get; set; }

    public string ContentType { get; set; } = null!;

    public long ContentId { get; set; }

    public DateTime SavedDate { get; set; }

    public virtual User User { get; set; } = null!;
}
