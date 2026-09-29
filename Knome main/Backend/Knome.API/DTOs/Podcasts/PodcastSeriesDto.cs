namespace Knome.API.DTOs.Podcasts;

public class PodcastSeriesDto
{
    public int SeriesId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int EpisodeCount { get; set; }
}
