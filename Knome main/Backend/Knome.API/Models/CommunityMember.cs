using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class CommunityMember
{
    public int CommunityId { get; set; }

    public int UserId { get; set; }

    public string MemberType { get; set; } = null!;

    public string Status { get; set; } = null!;

    public DateTime RequestedDate { get; set; }

    public DateTime? DecidedDate { get; set; }

    public int? ApprovedByUserId { get; set; }

    public virtual User? ApprovedByUser { get; set; }

    public virtual Community Community { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
