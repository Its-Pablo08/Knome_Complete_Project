using AutoMapper;
using Knome.API.DTOs.Search;
using Knome.API.Models;

namespace Knome.API.Mapping;

public class SearchProfile : Profile
{
    public SearchProfile()
    {
        // User to SearchItemDto mapping
        CreateMap<User, SearchItemDto>()
            .ForMember(dest => dest.ContentType, opt => opt.MapFrom(src => "User"))
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => (long)src.UserId))
            .ForMember(dest => dest.Title, opt => opt.MapFrom(src => src.FullName))
            .ForMember(dest => dest.Summary, opt => opt.MapFrom(src => $"{src.Designation} | {src.Email}"))
            .ForMember(dest => dest.AuthorFullName, opt => opt.MapFrom(src => src.FullName))
            .ForMember(dest => dest.AuthorEmployeeId, opt => opt.MapFrom(src => src.EmployeeId))
            .ForMember(dest => dest.CreatedDate, opt => opt.MapFrom(src => src.CreatedDate))
            .ForMember(dest => dest.EngagementScore, opt => opt.MapFrom(src => 0L));

        // Community to SearchItemDto mapping
        CreateMap<Community, SearchItemDto>()
            .ForMember(dest => dest.ContentType, opt => opt.MapFrom(src => "Community"))
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => (long)src.CommunityId))
            .ForMember(dest => dest.Title, opt => opt.MapFrom(src => src.Name))
            .ForMember(dest => dest.Summary, opt => opt.MapFrom(src => src.Description ?? string.Empty))
            .ForMember(dest => dest.CreatedDate, opt => opt.MapFrom(src => src.CreatedDate));

        // Post to SearchItemDto mapping
        CreateMap<Post, SearchItemDto>()
            .ForMember(dest => dest.ContentType, opt => opt.MapFrom(src => "Post"))
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.PostId))
            .ForMember(dest => dest.Title, opt => opt.MapFrom(src => string.Empty))
            .ForMember(dest => dest.Summary, opt => opt.MapFrom(src => src.ContentText))
            .ForMember(dest => dest.AuthorFullName, opt => opt.MapFrom(src => src.AuthorUser != null ? src.AuthorUser.FullName : string.Empty))
            .ForMember(dest => dest.AuthorEmployeeId, opt => opt.MapFrom(src => src.AuthorUser != null ? src.AuthorUser.EmployeeId : string.Empty))
            .ForMember(dest => dest.CreatedDate, opt => opt.MapFrom(src => src.CreatedDate));

        // Article to SearchItemDto mapping
        CreateMap<Article, SearchItemDto>()
            .ForMember(dest => dest.ContentType, opt => opt.MapFrom(src => "Article"))
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.ArticleId))
            .ForMember(dest => dest.Title, opt => opt.MapFrom(src => src.Title))
            .ForMember(dest => dest.Summary, opt => opt.MapFrom(src => src.Description ?? string.Empty))
            .ForMember(dest => dest.AuthorFullName, opt => opt.MapFrom(src => src.AuthorUser != null ? src.AuthorUser.FullName : string.Empty))
            .ForMember(dest => dest.AuthorEmployeeId, opt => opt.MapFrom(src => src.AuthorUser != null ? src.AuthorUser.EmployeeId : string.Empty))
            .ForMember(dest => dest.CreatedDate, opt => opt.MapFrom(src => src.CreatedDate));

        // Video to SearchItemDto mapping
        CreateMap<Video, SearchItemDto>()
            .ForMember(dest => dest.ContentType, opt => opt.MapFrom(src => "Video"))
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.VideoId))
            .ForMember(dest => dest.Title, opt => opt.MapFrom(src => src.Title))
            .ForMember(dest => dest.Summary, opt => opt.MapFrom(src => src.Description ?? string.Empty))
            .ForMember(dest => dest.AuthorFullName, opt => opt.MapFrom(src => src.UploaderUser != null ? src.UploaderUser.FullName : string.Empty))
            .ForMember(dest => dest.AuthorEmployeeId, opt => opt.MapFrom(src => src.UploaderUser != null ? src.UploaderUser.EmployeeId : string.Empty))
            .ForMember(dest => dest.CreatedDate, opt => opt.MapFrom(src => src.UploadedDate))
            .ForMember(dest => dest.ThumbnailUrl, opt => opt.MapFrom(src => src.ThumbnailUrl));

        // Podcast to SearchItemDto mapping
        CreateMap<Podcast, SearchItemDto>()
            .ForMember(dest => dest.ContentType, opt => opt.MapFrom(src => "Podcast"))
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.PodcastId))
            .ForMember(dest => dest.Title, opt => opt.MapFrom(src => src.Title))
            .ForMember(dest => dest.Summary, opt => opt.MapFrom(src => src.Description ?? string.Empty))
            .ForMember(dest => dest.AuthorFullName, opt => opt.MapFrom(src => src.UploaderUser != null ? src.UploaderUser.FullName : string.Empty))
            .ForMember(dest => dest.AuthorEmployeeId, opt => opt.MapFrom(src => src.UploaderUser != null ? src.UploaderUser.EmployeeId : string.Empty))
            .ForMember(dest => dest.CreatedDate, opt => opt.MapFrom(src => src.UploadedDate))
            .ForMember(dest => dest.ThumbnailUrl, opt => opt.MapFrom(src => src.CoverImageUrl));

        // Job to SearchItemDto mapping
        CreateMap<Job, SearchItemDto>()
            .ForMember(dest => dest.ContentType, opt => opt.MapFrom(src => "Job"))
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => (long)src.JobId))
            .ForMember(dest => dest.Title, opt => opt.MapFrom(src => src.Title))
            .ForMember(dest => dest.Summary, opt => opt.MapFrom(src => src.Description))
            .ForMember(dest => dest.AuthorFullName, opt => opt.MapFrom(src => src.PostedByUser != null ? src.PostedByUser.FullName : string.Empty))
            .ForMember(dest => dest.AuthorEmployeeId, opt => opt.MapFrom(src => src.PostedByUser != null ? src.PostedByUser.EmployeeId : string.Empty))
            .ForMember(dest => dest.CreatedDate, opt => opt.MapFrom(src => src.PostedDate));
    }
}
