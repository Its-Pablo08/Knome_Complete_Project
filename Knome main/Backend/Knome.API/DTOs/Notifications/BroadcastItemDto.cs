using System;

namespace Knome.API.DTOs.Notifications;

public class BroadcastItemDto
{
    public long Id { get; set; }
    public string Title { get; set; } = "Organization Announcement";
    public string Message { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public DateTime CreatedDate { get; set; }
    public string Sender { get; set; } = "HR Administration";
    public string EventType { get; set; } = "HRAnnouncement";
}
