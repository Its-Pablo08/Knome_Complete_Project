using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Podcast
{
    public long PodcastId { get; set; }

    public int UploaderUserId { get; set; }

    public string Title { get; set; } = null!;

    public string? Description { get; set; }

    public string? CoverImageUrl { get; set; }

    public int? DurationSeconds { get; set; }

    public int? CategoryId { get; set; }

    public int? SeriesId { get; set; }

    public int? FileSizeMb { get; set; }

    public DateTime UploadedDate { get; set; }

    public string? AudioUrl { get; set; }

    public int ViewCount { get; set; }

    public bool IsActive { get; set; }

    public virtual Category? Category { get; set; }

    public virtual PodcastSeries? Series { get; set; }

    public virtual User UploaderUser { get; set; } = null!;
}
