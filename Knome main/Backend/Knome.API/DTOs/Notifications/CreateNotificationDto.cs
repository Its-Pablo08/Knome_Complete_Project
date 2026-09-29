namespace Knome.API.DTOs.Notifications;

public class CreateNotificationDto
{
    public int RecipientUserId { get; set; }
    public string NotificationType { get; set; } = null!;
    public string Message { get; set; } = null!;
    public string? RelatedContentType { get; set; }
    public long? ReferenceId { get; set; }
}
