using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Follower
{
    public int FollowerUserId { get; set; }

    public int FollowingUserId { get; set; }

    public DateTime FollowedDate { get; set; }

    public virtual User FollowerUser { get; set; } = null!;

    public virtual User FollowingUser { get; set; } = null!;
}
