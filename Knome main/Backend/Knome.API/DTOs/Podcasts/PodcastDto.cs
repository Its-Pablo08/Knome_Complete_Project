using System;
using Knome.API.DTOs.Interactions;

namespace Knome.API.DTOs.Podcasts;

public class PodcastDto
{
    public long PodcastId { get; set; }
    public int UploaderUserId { get; set; }
    public string UploaderEmployeeId { get; set; } = string.Empty;
    public string UploaderFullName { get; set; } = string.Empty;
    public string? UploaderDesignation { get; set; }
    public string? UploaderProfilePhotoUrl { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? CoverImageUrl { get; set; }
    public string? AudioUrl { get; set; }
    public int? DurationSeconds { get; set; }
    public int? CategoryId { get; set; }
    public string? CategoryName { get; set; }
    public int? SeriesId { get; set; }
    public string? SeriesTitle { get; set; }
    public int? FileSizeMb { get; set; }
    public DateTime UploadedDate { get; set; }
    public int ViewCount { get; set; }
    public bool IsActive { get; set; } = true;
    public ContentSummaryDto? EngagementSummary { get; set; }
}
