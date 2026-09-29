using AutoMapper;
using Knome.API.DTOs.Audit;
using Knome.API.Models;

namespace Knome.API.Mapping;

public class AuditLogProfile : Profile
{
    public AuditLogProfile()
    {
        CreateMap<AuditLog, AuditLogDto>()
            .ForMember(d => d.IpAddress, o => o.MapFrom(s => s.Ipaddress))
            .ForMember(d => d.ActorName, o => o.MapFrom(s => s.ActorUser != null ? s.ActorUser.FullName : null));
    }
}
