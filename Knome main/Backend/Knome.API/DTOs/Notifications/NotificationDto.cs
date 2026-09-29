using System;

namespace Knome.API.DTOs.Notifications;

public class NotificationDto
{
    public long NotificationId { get; set; }
    public int UserId { get; set; }
    public int RecipientUserId => UserId;
    public int? SenderUserId { get; set; }
    public string? SenderName { get; set; }
    public string? SenderAvatar { get; set; }
    public string EventType { get; set; } = null!;
    public string NotificationType => EventType;
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = null!;
    public string? RelatedContentType { get; set; }
    public long? RelatedContentId { get; set; }
    public long? ReferenceId => RelatedContentId;
    public string? TargetUrl { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedDate { get; set; }
    public DateTime CreatedAt => CreatedDate;
    public DateTime? ReadAt { get; set; }
    public bool IsDeleted { get; set; }
}