using System;
using System.Collections.Generic;
using Knome.API.DTOs.Interactions;

namespace Knome.API.DTOs.Posts;

public class PostAttachmentDto
{
    public long AttachmentId { get; set; }
    public string FileUrl { get; set; } = string.Empty;
    public string FileType { get; set; } = string.Empty;
    public DateTime PublishedDate { get; set; }
}

public class PostDto
{
    public long PostId { get; set; }
    public int AuthorUserId { get; set; }
    public string AuthorEmployeeId { get; set; } = string.Empty;
    public string AuthorFullName { get; set; } = string.Empty;
    public string? AuthorDesignation { get; set; }
    public string? AuthorProfilePhotoUrl { get; set; }
    public string ContentText { get; set; } = string.Empty;
    public string AudienceType { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime? ScheduledDate { get; set; }
    public DateTime? PublishedDate { get; set; }
    public DateTime CreatedDate { get; set; }
    public int ViewCount { get; set; }
    public List<string> AttachmentUrls { get; set; } = new();
    public List<PostAttachmentDto> Attachments { get; set; } = new();
    public List<MentionedUserDto> MentionedUsers { get; set; } = new();
    public int? CommunityId { get; set; }
    public string? CommunityName { get; set; }
    public string? SharedWithName { get; set; }
    public ContentSummaryDto? EngagementSummary { get; set; }
}
