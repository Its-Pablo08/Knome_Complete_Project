using FluentValidation;
using Knome.API.DTOs.Jobs;

namespace Knome.API.Validators.Jobs;

public class CreateJobValidator : AbstractValidator<CreateJobDto>
{
    public CreateJobValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Job title is required.")
            .MaximumLength(200).WithMessage("Job title must not exceed 200 characters.");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Job description is required.")
            .MaximumLength(50000).WithMessage("Job description must not exceed 50,000 characters.");

        RuleFor(x => x.SkillsRequired)
            .MaximumLength(500).WithMessage("Skills required must not exceed 500 characters.")
            .When(x => !string.IsNullOrEmpty(x.SkillsRequired));

        RuleFor(x => x.Location)
            .MaximumLength(150).WithMessage("Location must not exceed 150 characters.")
            .When(x => !string.IsNullOrEmpty(x.Location));

        RuleFor(x => x.ApplicationLink)
            .NotEmpty().WithMessage("Application link is required.")
            .MaximumLength(400).WithMessage("Application link must not exceed 400 characters.");

        RuleFor(x => x.ClosingDate)
            .Must(d => d >= Knome.API.Common.KnomeTime.Today)
            .WithMessage("Closing date must be today or in the future.");

        RuleFor(x => x.Status)
            .NotEmpty().WithMessage("Status is required.")
            .Must(s => s == "Open" || s == "Closed" || s == "Draft")
            .WithMessage("Status must be Open, Closed, or Draft.");
    }
}