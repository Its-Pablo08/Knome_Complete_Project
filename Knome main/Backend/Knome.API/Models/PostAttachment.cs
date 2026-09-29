using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class PostAttachment
{
    public long AttachmentId { get; set; }

    public long PostId { get; set; }

    public string FileUrl { get; set; } = null!;

    public string FileType { get; set; } = null!;

    public DateTime PublishedDate { get; set; }

    public virtual Post Post { get; set; } = null!;
}
