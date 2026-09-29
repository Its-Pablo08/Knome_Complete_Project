using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class ArticleAttachment
{
    public long AttachmentId { get; set; }

    public long ArticleId { get; set; }

    public string FileUrl { get; set; } = null!;

    public string FileType { get; set; } = null!;

    public DateTime PublishedDate { get; set; }

    public virtual Article Article { get; set; } = null!;
}
