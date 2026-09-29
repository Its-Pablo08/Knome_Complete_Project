namespace Knome.API.DTOs.Notifications;

public class NotificationPreferenceDto
{
    public int UserId { get; set; }
    public string EventType { get; set; } = null!;
    public bool BellEnabled { get; set; }
    public bool EmailEnabled { get; set; }
}