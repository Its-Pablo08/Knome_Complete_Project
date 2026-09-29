using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Reaction
{
    public long ReactionId { get; set; }

    public string ContentType { get; set; } = null!;

    public long ContentId { get; set; }

    public int UserId { get; set; }

    public string ReactionType { get; set; } = null!;

    public DateTime CreatedDate { get; set; }

    public virtual User User { get; set; } = null!;
}
