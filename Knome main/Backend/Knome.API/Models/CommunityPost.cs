using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class CommunityPost
{
    public int CommunityId { get; set; }

    public long PostId { get; set; }

    public bool IsPinned { get; set; }

    public virtual Community Community { get; set; } = null!;

    public virtual Post Post { get; set; } = null!;
}
