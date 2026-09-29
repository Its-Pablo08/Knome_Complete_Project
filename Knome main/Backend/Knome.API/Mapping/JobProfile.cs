using AutoMapper;
using Knome.API.DTOs.Jobs;
using Knome.API.Models;

namespace Knome.API.Mapping;

public class JobProfile : Profile
{
    public JobProfile()
    {
        CreateMap<Job, JobDto>()
            .ForMember(d => d.DepartmentName, o => o.MapFrom(s => s.Department != null ? s.Department.Name : null))
            .ForMember(d => d.PostedByFullName, o => o.MapFrom(s => s.PostedByUser != null ? s.PostedByUser.FullName : null));
    }
}