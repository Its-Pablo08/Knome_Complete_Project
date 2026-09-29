using System.Collections.Generic;

namespace Knome.API.DTOs.Articles;

public class CreateArticleDto
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string ContentHtml { get; set; } = string.Empty;
    public int CategoryId { get; set; }
    public string Status { get; set; } = "Published";
    public DateTime? ScheduledDate { get; set; }
    public List<string> Tags { get; set; } = new();
    public List<string> AttachmentUrls { get; set; } = new();
}
