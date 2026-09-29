using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Community
{
    public int CommunityId { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public string? BannerUrl { get; set; }

    public string? ThumbnailUrl { get; set; }

    public int? CategoryId { get; set; }

    public string? Rules { get; set; }

    public string? Faq { get; set; }

    public string CommunityType { get; set; } = null!;

    public int CreatedByUserId { get; set; }

    public DateTime CreatedDate { get; set; }

    public bool IsActive { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public virtual Category? Category { get; set; }

    public virtual ICollection<CommunityMember> CommunityMembers { get; set; } = new List<CommunityMember>();

    public virtual ICollection<CommunityPost> CommunityPosts { get; set; } = new List<CommunityPost>();

    public virtual User CreatedByUser { get; set; } = null!;

    public virtual ICollection<Post> Posts { get; set; } = new List<Post>();

    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
