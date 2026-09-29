using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class PodcastSeries
{
    public int SeriesId { get; set; }

    public string Title { get; set; } = null!;

    public string? Description { get; set; }

    public virtual ICollection<Podcast> Podcasts { get; set; } = new List<Podcast>();
}
