using FluentValidation;
using Knome.API.Constants;
using Knome.API.DTOs.Communities;

namespace Knome.API.Validators.Communities;

public class CreateCommunityValidator : AbstractValidator<CreateCommunityDto>
{
    public CreateCommunityValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Community name cannot be empty.")
            .MaximumLength(150).WithMessage("Community name cannot exceed 150 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(1000).WithMessage("Description cannot exceed 1000 characters.")
            .When(x => !string.IsNullOrEmpty(x.Description));

        RuleFor(x => x.BannerUrl)
            .MaximumLength(400).WithMessage("Banner URL cannot exceed 400 characters.")
            .When(x => !string.IsNullOrEmpty(x.BannerUrl));

        RuleFor(x => x.ThumbnailUrl)
            .MaximumLength(400).WithMessage("Thumbnail URL cannot exceed 400 characters.")
            .When(x => !string.IsNullOrEmpty(x.ThumbnailUrl));

        RuleFor(x => x.Rules)
            .MaximumLength(50000).WithMessage("Rules cannot exceed 50,000 characters.")
            .When(x => !string.IsNullOrEmpty(x.Rules));

        RuleFor(x => x.Faq)
            .MaximumLength(50000).WithMessage("FAQ cannot exceed 50,000 characters.")
            .When(x => !string.IsNullOrEmpty(x.Faq));

        RuleFor(x => x.CommunityType)
            .NotEmpty().WithMessage("Community type cannot be empty.")
            .Must(CommunityTypes.IsValid)
            .WithMessage($"Invalid community type. Must be one of: {string.Join(", ", CommunityTypes.All)}.");
    }
}

public class UpdateCommunityValidator : AbstractValidator<UpdateCommunityDto>
{
    public UpdateCommunityValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Community name cannot be empty.")
            .MaximumLength(150).WithMessage("Community name cannot exceed 150 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(1000).WithMessage("Description cannot exceed 1000 characters.")
            .When(x => !string.IsNullOrEmpty(x.Description));

        RuleFor(x => x.BannerUrl)
            .MaximumLength(400).WithMessage("Banner URL cannot exceed 400 characters.")
            .When(x => !string.IsNullOrEmpty(x.BannerUrl));

        RuleFor(x => x.ThumbnailUrl)
            .MaximumLength(400).WithMessage("Thumbnail URL cannot exceed 400 characters.")
            .When(x => !string.IsNullOrEmpty(x.ThumbnailUrl));

        RuleFor(x => x.Rules)
            .MaximumLength(50000).WithMessage("Rules cannot exceed 50,000 characters.")
            .When(x => !string.IsNullOrEmpty(x.Rules));

        RuleFor(x => x.Faq)
            .MaximumLength(50000).WithMessage("FAQ cannot exceed 50,000 characters.")
            .When(x => !string.IsNullOrEmpty(x.Faq));
    }
}
