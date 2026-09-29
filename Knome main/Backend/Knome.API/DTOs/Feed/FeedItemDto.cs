using System;
using System.Collections.Generic;
using Knome.API.DTOs.Interactions;

namespace Knome.API.DTOs.Feed;

public class FeedAttachmentDto
{
    public long AttachmentId { get; set; }
    public string FileUrl { get; set; } = string.Empty;
    public string FileType { get; set; } = string.Empty;
}

public class FeedItemDto
{
    public string ContentType { get; set; } = null!; // Post, Article, Video, Podcast
    public long ContentId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string TextSummary { get; set; } = string.Empty;
    public string ContentText { get; set; } = string.Empty;
    public string? AttachmentUrl { get; set; }
    public List<string> AttachmentUrls { get; set; } = new();
    public List<FeedAttachmentDto> Attachments { get; set; } = new();
    
    public int AuthorUserId { get; set; }
    public string AuthorEmployeeId { get; set; } = string.Empty;
    public string AuthorFullName { get; set; } = string.Empty;
    public string? AuthorDesignation { get; set; }
    public string? AuthorProfilePhotoUrl { get; set; }

    public DateTime PublishedDate { get; set; }
    public string AudienceType { get; set; } = "Everyone";
    public string Status { get; set; } = "Published";
    public DateTime? ScheduledDate { get; set; }
    public int? CommunityId { get; set; }
    public string? CommunityName { get; set; }
    public string? SharedWithName { get; set; }
    public List<int> AudienceUserIds { get; set; } = new();

    public ContentSummaryDto? EngagementSummary { get; set; }
    public decimal HotScore { get; set; }
}

