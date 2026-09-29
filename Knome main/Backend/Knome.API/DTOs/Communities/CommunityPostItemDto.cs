using System;
using System.Collections.Generic;
using Knome.API.DTOs.Interactions;

namespace Knome.API.DTOs.Communities;

public class CommunityPostItemDto
{
    public int CommunityId { get; set; }
    public long PostId { get; set; }
    public int AuthorUserId { get; set; }
    public string AuthorEmployeeId { get; set; } = null!;
    public string AuthorFullName { get; set; } = null!;
    public string? AuthorDesignation { get; set; }
    public string? AuthorProfilePhotoUrl { get; set; }
    public string ContentText { get; set; } = null!;
    public List<string> AttachmentUrls { get; set; } = new List<string>();
    public DateTime PublishedDate { get; set; }
    public bool IsPinned { get; set; }
    public ContentSummaryDto EngagementSummary { get; set; } = new ContentSummaryDto();
}

public class CreateCommunityPostDto
{
    public string ContentText { get; set; } = string.Empty;
    public List<string> AttachmentUrls { get; set; } = new();
    public List<string> AttachmentTypes { get; set; } = new();
}

public class PinCommunityPostDto
{
    public bool IsPinned { get; set; }
}
