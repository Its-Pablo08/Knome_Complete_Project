using FluentValidation;
using Knome.API.DTOs.Podcasts;

namespace Knome.API.Validators.Podcasts;

public class CreatePodcastSeriesValidator : AbstractValidator<CreatePodcastSeriesDto>
{
    public CreatePodcastSeriesValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Podcast series title is required.")
            .MaximumLength(150).WithMessage("Podcast series title cannot exceed 150 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Podcast series description cannot exceed 500 characters.");
    }
}
