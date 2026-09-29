using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Comment
{
    public long CommentId { get; set; }

    public string ContentType { get; set; } = null!;

    public long ContentId { get; set; }

    public int UserId { get; set; }

    public long? ParentCommentId { get; set; }

    public string CommentText { get; set; } = null!;

    public string? ImageUrl { get; set; }

    public DateTime CreatedDate { get; set; }

    public virtual ICollection<Comment> InverseParentComment { get; set; } = new List<Comment>();

    public virtual Comment? ParentComment { get; set; }

    public virtual User User { get; set; } = null!;
}
