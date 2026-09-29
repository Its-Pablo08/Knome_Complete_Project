using AutoMapper;
using Knome.API.DTOs.Abbreviations;
using Knome.API.Models;

namespace Knome.API.Mapping;

public class AbbreviationProfile : Profile
{
    public AbbreviationProfile()
    {
        CreateMap<Abbreviation, AbbreviationDto>()
            .ForMember(dest => dest.CreatedByName, opt => opt.MapFrom(src => src.CreatedByNavigation != null ? src.CreatedByNavigation.FullName : null));

        CreateMap<CreateAbbreviationDto, Abbreviation>()
            .ForMember(dest => dest.AbbreviationId, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedBy, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedDate, opt => opt.Ignore())
            .ForMember(dest => dest.IsActive, opt => opt.MapFrom(_ => true))
            .ForMember(dest => dest.CreatedByNavigation, opt => opt.Ignore());

        CreateMap<UpdateAbbreviationDto, Abbreviation>()
            .ForMember(dest => dest.AbbreviationId, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedBy, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedDate, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedByNavigation, opt => opt.Ignore());
    }
}
