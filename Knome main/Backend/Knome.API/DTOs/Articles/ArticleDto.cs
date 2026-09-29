using System;
using System.Collections.Generic;
using Knome.API.DTOs.Interactions;

namespace Knome.API.DTOs.Articles;

public class ArticleAttachmentDto
{
    public long AttachmentId { get; set; }
    public string FileUrl { get; set; } = string.Empty;
    public string FileType { get; set; } = string.Empty;
    public DateTime PublishedDate { get; set; }
}

public class ArticleDto

{
    public long ArticleId { get; set; }
    public int AuthorUserId { get; set; }
    public string AuthorEmployeeId { get; set; } = string.Empty;
    public string AuthorFullName { get; set; } = string.Empty;
    public string? AuthorDesignation { get; set; }
    public string? AuthorProfilePhotoUrl { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string ContentHtml { get; set; } = string.Empty;
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime? ScheduledDate { get; set; }
    public DateTime? PublishedDate { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ViewCount { get; set; }
    public int UniqueReadCount { get; set; }
    public int AvgReadTimeSeconds { get; set; }
    public List<string> Tags { get; set; } = new();
    public List<string> AttachmentUrls { get; set; } = new();
    public List<ArticleAttachmentDto> Attachments { get; set; } = new();
    public int VersionsCount { get; set; }
    public ContentSummaryDto? EngagementSummary { get; set; }
}
