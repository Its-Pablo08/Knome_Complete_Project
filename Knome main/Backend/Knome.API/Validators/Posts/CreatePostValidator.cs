using FluentValidation;
using Knome.API.Constants;
using Knome.API.DTOs.Posts;

namespace Knome.API.Validators.Posts;

public class CreatePostValidator : AbstractValidator<CreatePostDto>
{
    public CreatePostValidator()
    {
        RuleFor(x => x.ContentText)
            .NotEmpty().WithMessage("Post content is required.")
            .MaximumLength(400).WithMessage("Quick-share posts can be at most 400 characters per business rules (FR-PC-01).");

        RuleFor(x => x.AudienceType)
            .Must(PostAudiences.IsValid).WithMessage("Audience type must be 'Everyone', 'Connections', or 'Community'.");

        RuleFor(x => x.Status)
            .Must(PostStatuses.IsValid).WithMessage("Status must be 'Published', 'Draft', 'Scheduled', or 'Archived'.");
    }
}
