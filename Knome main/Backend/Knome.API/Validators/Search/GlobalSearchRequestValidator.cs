using FluentValidation;
using Knome.API.DTOs.Search;

namespace Knome.API.Validators.Search;

public class GlobalSearchRequestValidator : AbstractValidator<GlobalSearchRequestDto>
{
    private static readonly HashSet<string> ValidTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        "User", "Users", "People", "Community", "Communities", "Post", "Posts",
        "Article", "Articles", "Video", "Videos", "Podcast", "Podcasts", "Job", "Jobs",
        "Hashtags", "Documents", "Content", "All"
    };
    private static readonly string[] ValidSortBy = { "relevance", "date", "popularity" };
    private static readonly string[] ValidSortOrder = { "asc", "desc" };

    public GlobalSearchRequestValidator()
    {
        RuleFor(x => x.Query)
            .MaximumLength(100).WithMessage("Search query cannot exceed 100 characters.");

        RuleFor(x => x.PageNumber)
            .GreaterThan(0).WithMessage("Page number must be greater than 0.")
            .LessThanOrEqualTo(1000).WithMessage("Page number cannot exceed 1000.");

        RuleFor(x => x.PageSize)
            .InclusiveBetween(1, 100).WithMessage("Page size must be between 1 and 100.");

        RuleFor(x => x.ContentType)
            .Must(t => t == null || ValidTypes.Contains(t))
            .WithMessage("Content type must be one of: User, People, Community, Post, Article, Video, Podcast, Job, Hashtags, Documents, Content.")
            .When(x => !string.IsNullOrEmpty(x.ContentType));

        RuleFor(x => x.SortBy)
            .Must(s => s == null || ValidSortBy.Contains(s.ToLower()))
            .WithMessage("SortBy must be one of: relevance, date, popularity.")
            .When(x => !string.IsNullOrEmpty(x.SortBy));

        RuleFor(x => x.SortOrder)
            .Must(s => s == null || ValidSortOrder.Contains(s.ToLower()))
            .WithMessage("SortOrder must be asc or desc.")
            .When(x => !string.IsNullOrEmpty(x.SortOrder));
    }
}
