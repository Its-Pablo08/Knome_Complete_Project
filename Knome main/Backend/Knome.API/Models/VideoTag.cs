using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class VideoTag
{
    public long VideoId { get; set; }

    public string Tag { get; set; } = null!;

    public virtual Video Video { get; set; } = null!;
}
