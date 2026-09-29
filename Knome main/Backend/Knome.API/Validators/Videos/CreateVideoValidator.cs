using FluentValidation;
using Knome.API.Constants;
using Knome.API.DTOs.Videos;

namespace Knome.API.Validators.Videos;

public class CreateVideoValidator : AbstractValidator<CreateVideoDto>
{
    public CreateVideoValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Video title is required.")
            .MaximumLength(200).WithMessage("Video title cannot exceed 200 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(1000).WithMessage("Video description cannot exceed 1000 characters.");

        RuleFor(x => x.SourceType)
            .Must(VideoSourceTypes.IsValid).WithMessage("Source type must be 'Stream', 'OneDrive', or 'LocalUpload'.");

        RuleFor(x => x.SourceUrl)
            .NotEmpty().WithMessage("Video source URL is required.")
            .MaximumLength(400).WithMessage("Video source URL cannot exceed 400 characters.");

        RuleFor(x => x.ThumbnailUrl)
            .MaximumLength(400).WithMessage("Thumbnail URL cannot exceed 400 characters.");

        RuleFor(x => x.FileSizeMb)
            .LessThanOrEqualTo(MediaSizeLimits.MaxVideoSizeMb).When(x => x.FileSizeMb.HasValue)
            .WithMessage($"Video file size cannot exceed {MediaSizeLimits.MaxVideoSizeMb} MB per business rules (FR-VC-01).");
    }
}
