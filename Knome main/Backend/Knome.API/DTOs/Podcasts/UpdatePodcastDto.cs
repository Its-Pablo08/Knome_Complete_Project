namespace Knome.API.DTOs.Podcasts;

public class UpdatePodcastDto
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? CoverImageUrl { get; set; }
    public string? AudioUrl { get; set; }
    public int? DurationSeconds { get; set; }
    public int? CategoryId { get; set; }
    public int? SeriesId { get; set; }
    public int? FileSizeMb { get; set; }
}
