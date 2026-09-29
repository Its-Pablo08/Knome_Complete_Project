using System.ComponentModel.DataAnnotations;

namespace Knome.API.DTOs.Notifications;

public class BroadcastNotificationDto
{
    [MaxLength(150)]
    public string? Title { get; set; }

    [Required]
    [MaxLength(400)]
    public string Message { get; set; } = null!;

    [MaxLength(20)]
    public string? RelatedContentType { get; set; }

    public long? RelatedContentId { get; set; }
}
