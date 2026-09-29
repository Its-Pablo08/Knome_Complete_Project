using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.DTOs.Notifications;

namespace Knome.API.Interfaces;

/// <summary>
/// Generic, event-driven notification engine. Modules publish notifications by
/// calling <see cref="PublishAsync"/> or <see cref="PublishBroadcastAsync"/> with an
/// <see cref="NotificationTypes"/> category. The notification core is never modified
/// when a new producer module is added.
/// </summary>
public interface INotificationService
{
    /// <summary>Publish a single notification to one recipient.</summary>
    Task<NotificationDto?> PublishAsync(
        int recipientUserId,
        string eventType,
        string message,
        string? relatedContentType = null,
        long? relatedContentId = null);

    /// <summary>Publish the same notification to many recipients (e.g. a new job posting).</summary>
    Task PublishBroadcastAsync(
        string eventType,
        string message,
        string? relatedContentType,
        long? relatedContentId,
        IEnumerable<int> candidateUserIds);

    Task<List<NotificationDto>> GetForUserAsync(int userId, bool unreadOnly = false, int pageNumber = 1, int pageSize = 20);
    Task<int> GetUnreadCountAsync(int userId);
    Task<bool> MarkAsReadAsync(long notificationId, int userId);
    Task MarkAllAsReadAsync(int userId);
    Task<bool> DeleteNotificationAsync(long notificationId, int userId);
    Task<NotificationDto?> CreateNotificationAsync(CreateNotificationDto dto, int senderUserId);
    Task<List<NotificationPreferenceDto>> GetPreferencesAsync(int userId);
    Task UpdatePreferencesAsync(int userId, List<UpdateNotificationPreferenceDto> preferences);
    Task<List<BroadcastItemDto>> GetBroadcastAnnouncementsAsync();
    Task<bool> UpdateBroadcastAsync(long id, string newMessage);
    Task<bool> DeleteBroadcastAsync(long id);
}