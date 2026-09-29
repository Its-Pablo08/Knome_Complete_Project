using System.Linq;
using AutoMapper;
using Knome.API.DTOs.Interactions;
using Knome.API.Models;

namespace Knome.API.Mapping;

public class InteractionProfile : Profile
{
    public InteractionProfile()
    {
        CreateMap<Comment, CommentDto>()
            .ForMember(dest => dest.AuthorEmployeeId, opt => opt.MapFrom(src => src.User != null ? src.User.EmployeeId : string.Empty))
            .ForMember(dest => dest.AuthorFullName, opt => opt.MapFrom(src => src.User != null ? src.User.FullName : "Unknown"))
            .ForMember(dest => dest.AuthorDesignation, opt => opt.MapFrom(src => src.User != null ? src.User.Designation : null))
            .ForMember(dest => dest.AuthorProfilePhotoUrl, opt => opt.MapFrom(src => src.User != null ? src.User.ProfilePhotoUrl : null))
            .ForMember(dest => dest.RepliesCount, opt => opt.MapFrom(src => src.InverseParentComment != null ? src.InverseParentComment.Count : 0))
            .ForMember(dest => dest.Replies, opt => opt.Ignore()); // Recursively mapped manually or via service query to prevent deep infinite loop

        CreateMap<Reaction, ReactionDto>()
            .ForMember(dest => dest.UserFullName, opt => opt.MapFrom(src => src.User != null ? src.User.FullName : "Unknown"))
            .ForMember(dest => dest.UserDesignation, opt => opt.MapFrom(src => src.User != null ? src.User.Designation : null))
            .ForMember(dest => dest.UserProfilePhotoUrl, opt => opt.MapFrom(src => src.User != null ? src.User.ProfilePhotoUrl : null));

        CreateMap<Share, ShareDto>()
            .ForMember(dest => dest.UserFullName, opt => opt.MapFrom(src => src.User != null ? src.User.FullName : "Unknown"));

        CreateMap<Bookmark, BookmarkDto>();

        CreateMap<ModerationReport, ModerationReportDto>()
            .ForMember(dest => dest.ReporterFullName, opt => opt.MapFrom(src => src.ReporterUser != null ? src.ReporterUser.FullName : "Unknown"))
            .ForMember(dest => dest.ModeratorFullName, opt => opt.MapFrom(src => src.ModeratorUser != null ? src.ModeratorUser.FullName : null));

        CreateMap<RestrictedKeyword, RestrictedKeywordItemDto>();
    }
}
