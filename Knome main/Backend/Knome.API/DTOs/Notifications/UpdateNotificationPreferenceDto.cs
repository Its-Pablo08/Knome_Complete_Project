namespace Knome.API.DTOs.Notifications;

public class UpdateNotificationPreferenceDto
{
    public string EventType { get; set; } = null!;
    public bool BellEnabled { get; set; }
    public bool EmailEnabled { get; set; }
}