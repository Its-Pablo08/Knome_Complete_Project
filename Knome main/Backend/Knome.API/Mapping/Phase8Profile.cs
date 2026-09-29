using AutoMapper;
using Knome.API.DTOs.Karma;
using Knome.API.Models;

namespace Knome.API.Mapping;

public class Phase8Profile : Profile
{
    public Phase8Profile()
    {
        CreateMap<KarmaTransaction, KarmaTransactionDto>();

        CreateMap<KarmaBalance, KarmaBalanceDto>()
            .ForMember(dest => dest.EmployeeId, opt => opt.MapFrom(src => src.User != null ? src.User.EmployeeId : string.Empty))
            .ForMember(dest => dest.FullName, opt => opt.MapFrom(src => src.User != null ? src.User.FullName : string.Empty))
            .ForMember(dest => dest.Designation, opt => opt.MapFrom(src => src.User != null ? src.User.Designation : null))
            .ForMember(dest => dest.ProfilePhotoUrl, opt => opt.MapFrom(src => src.User != null ? src.User.ProfilePhotoUrl : null))
            .ForMember(dest => dest.RecentTransactions, opt => opt.Ignore());

        CreateMap<KarmaBalance, LeaderboardEntryDto>()
            .ForMember(dest => dest.EmployeeId, opt => opt.MapFrom(src => src.User != null ? src.User.EmployeeId : string.Empty))
            .ForMember(dest => dest.FullName, opt => opt.MapFrom(src => src.User != null ? src.User.FullName : string.Empty))
            .ForMember(dest => dest.Designation, opt => opt.MapFrom(src => src.User != null ? src.User.Designation : null))
            .ForMember(dest => dest.ProfilePhotoUrl, opt => opt.MapFrom(src => src.User != null ? src.User.ProfilePhotoUrl : null))
            .ForMember(dest => dest.Rank, opt => opt.Ignore());
    }
}
