using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Video
{
    public long VideoId { get; set; }

    public int UploaderUserId { get; set; }

    public string Title { get; set; } = null!;

    public string? Description { get; set; }

    public int? CategoryId { get; set; }

    public string? ThumbnailUrl { get; set; }

    public string SourceType { get; set; } = null!;

    public string SourceUrl { get; set; } = null!;

    public int? FileSizeMb { get; set; }

    public int ViewCount { get; set; }

    public DateTime UploadedDate { get; set; }

    public virtual Category? Category { get; set; }

    public virtual User UploaderUser { get; set; } = null!;

    public virtual ICollection<VideoTag> VideoTags { get; set; } = new List<VideoTag>();
}
