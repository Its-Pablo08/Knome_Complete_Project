using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class ArticleTag
{
    public long ArticleId { get; set; }

    public string Tag { get; set; } = null!;

    public virtual Article Article { get; set; } = null!;
}
