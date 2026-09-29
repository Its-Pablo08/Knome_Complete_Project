using AutoMapper;
using Knome.API.DTOs.Notifications;
using Knome.API.Models;

namespace Knome.API.Mapping;

public class NotificationProfile : Profile
{
    public NotificationProfile()
    {
        CreateMap<Notification, NotificationDto>();
        CreateMap<NotificationPreference, NotificationPreferenceDto>();
    }
}