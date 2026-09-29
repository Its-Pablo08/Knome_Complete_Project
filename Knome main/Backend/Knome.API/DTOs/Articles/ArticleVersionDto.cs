using System;

namespace Knome.API.DTOs.Articles;

public class ArticleVersionDto
{
    public long VersionId { get; set; }
    public long ArticleId { get; set; }
    public string ContentHtml { get; set; } = string.Empty;
    public int EditedByUserId { get; set; }
    public string EditedByUserName { get; set; } = string.Empty;
    public DateTime EditedDate { get; set; }
}
