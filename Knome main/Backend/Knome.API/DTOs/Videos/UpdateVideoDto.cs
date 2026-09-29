using System.Collections.Generic;

namespace Knome.API.DTOs.Videos;

public class UpdateVideoDto
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int? CategoryId { get; set; }
    public string? ThumbnailUrl { get; set; }
    public string SourceType { get; set; } = "Stream";
    public string? SourceUrl { get; set; }
    public int? FileSizeMb { get; set; }
    public List<string> Tags { get; set; } = new();
}
