using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class ArticleVersion
{
    public long VersionId { get; set; }

    public long ArticleId { get; set; }

    public string ContentHtml { get; set; } = null!;

    public int EditedByUserId { get; set; }

    public DateTime EditedDate { get; set; }

    public virtual Article Article { get; set; } = null!;

    public virtual User EditedByUser { get; set; } = null!;
}
