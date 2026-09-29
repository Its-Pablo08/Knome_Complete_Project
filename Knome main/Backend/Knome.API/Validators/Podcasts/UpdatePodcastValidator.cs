using FluentValidation;
using Knome.API.Constants;
using Knome.API.DTOs.Podcasts;

namespace Knome.API.Validators.Podcasts;

public class UpdatePodcastValidator : AbstractValidator<UpdatePodcastDto>
{
    public UpdatePodcastValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Podcast episode title is required.")
            .MaximumLength(200).WithMessage("Podcast episode title cannot exceed 200 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(1000).WithMessage("Podcast episode description cannot exceed 1000 characters.");

        RuleFor(x => x.CoverImageUrl)
            .MaximumLength(400).WithMessage("Cover image URL cannot exceed 400 characters.");

        RuleFor(x => x.FileSizeMb)
            .LessThanOrEqualTo(MediaSizeLimits.MaxPodcastSizeMb).When(x => x.FileSizeMb.HasValue)
            .WithMessage($"Podcast file size cannot exceed {MediaSizeLimits.MaxPodcastSizeMb} MB per business rules (FR-PD-02).");
    }
}
