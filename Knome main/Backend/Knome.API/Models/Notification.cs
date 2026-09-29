using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Notification
{
    public long NotificationId { get; set; }

    public int UserId { get; set; }

    public string EventType { get; set; } = null!;

    public string Message { get; set; } = null!;

    public string? RelatedContentType { get; set; }

    public long? RelatedContentId { get; set; }

    public bool IsRead { get; set; }

    public DateTime CreatedDate { get; set; }

    public virtual User User { get; set; } = null!;
}
