using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Post
{
    public long PostId { get; set; }

    public int AuthorUserId { get; set; }

    public string ContentText { get; set; } = null!;

    public string AudienceType { get; set; } = null!;

    public string Status { get; set; } = null!;

    public DateTime? ScheduledDate { get; set; }

    public DateTime? PublishedDate { get; set; }

    public DateTime CreatedDate { get; set; }

    public int ViewCount { get; set; }

    public virtual User AuthorUser { get; set; } = null!;

    public virtual ICollection<CommunityPost> CommunityPosts { get; set; } = new List<CommunityPost>();

    public virtual ICollection<PostAttachment> PostAttachments { get; set; } = new List<PostAttachment>();

    public virtual ICollection<Community> Communities { get; set; } = new List<Community>();

    public virtual ICollection<User> MentionedUsers { get; set; } = new List<User>();

    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
