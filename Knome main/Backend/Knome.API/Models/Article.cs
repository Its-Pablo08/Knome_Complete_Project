using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Article
{
    public long ArticleId { get; set; }

    public int AuthorUserId { get; set; }

    public string Title { get; set; } = null!;

    public string? Description { get; set; }

    public string ContentHtml { get; set; } = null!;

    public int CategoryId { get; set; }

    public string Status { get; set; } = null!;

    public DateTime? ScheduledDate { get; set; }

    public DateTime? PublishedDate { get; set; }

    public int ViewCount { get; set; }

    public int UniqueReadCount { get; set; }

    public int AvgReadTimeSeconds { get; set; }

    public DateTime CreatedDate { get; set; }

    public virtual ICollection<ArticleAttachment> ArticleAttachments { get; set; } = new List<ArticleAttachment>();

    public virtual ICollection<ArticleTag> ArticleTags { get; set; } = new List<ArticleTag>();

    public virtual ICollection<ArticleVersion> ArticleVersions { get; set; } = new List<ArticleVersion>();

    public virtual User AuthorUser { get; set; } = null!;

    public virtual Category Category { get; set; } = null!;
}
