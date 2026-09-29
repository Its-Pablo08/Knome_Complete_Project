using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Category
{
    public int CategoryId { get; set; }

    public string Name { get; set; } = null!;

    public string AppliesTo { get; set; } = null!;

    public virtual ICollection<Article> Articles { get; set; } = new List<Article>();

    public virtual ICollection<Community> Communities { get; set; } = new List<Community>();

    public virtual ICollection<Podcast> Podcasts { get; set; } = new List<Podcast>();

    public virtual ICollection<Video> Videos { get; set; } = new List<Video>();
}
