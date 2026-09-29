using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class KarmaTransaction
{
    public long TransactionId { get; set; }

    public int UserId { get; set; }

    public string ActivityType { get; set; } = null!;

    public int PointsAwarded { get; set; }

    public string? RelatedContentType { get; set; }

    public long? RelatedContentId { get; set; }

    public DateTime CreatedDate { get; set; }

    public virtual User User { get; set; } = null!;
}
