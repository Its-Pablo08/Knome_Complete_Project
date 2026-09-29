using System;
using System.Collections.Generic;
using Knome.API.DTOs.Interactions;

namespace Knome.API.DTOs.Videos;

public class VideoDto
{
    public long VideoId { get; set; }
    public int UploaderUserId { get; set; }
    public string UploaderEmployeeId { get; set; } = string.Empty;
    public string UploaderFullName { get; set; } = string.Empty;
    public string? UploaderDesignation { get; set; }
    public string? UploaderProfilePhotoUrl { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int? CategoryId { get; set; }
    public string? CategoryName { get; set; }
    public string? ThumbnailUrl { get; set; }
    public string SourceType { get; set; } = string.Empty;
    public string SourceUrl { get; set; } = string.Empty;
    public int? FileSizeMb { get; set; }
    public int ViewCount { get; set; }
    public DateTime UploadedDate { get; set; }
    public List<string> Tags { get; set; } = new();
    public ContentSummaryDto? EngagementSummary { get; set; }
}
