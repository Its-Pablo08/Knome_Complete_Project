using FluentValidation;
using Knome.API.DTOs.Jobs;

namespace Knome.API.Validators.Jobs;

public class UpdateJobValidator : AbstractValidator<UpdateJobDto>
{
    public UpdateJobValidator()
    {
        RuleFor(x => x.Title)
            .MaximumLength(200).WithMessage("Job title must not exceed 200 characters.")
            .When(x => x.Title != null);

        RuleFor(x => x.Description)
            .MaximumLength(50000).WithMessage("Job description must not exceed 50,000 characters.")
            .When(x => !string.IsNullOrEmpty(x.Description));

        RuleFor(x => x.SkillsRequired)
            .MaximumLength(500).WithMessage("Skills required must not exceed 500 characters.")
            .When(x => !string.IsNullOrEmpty(x.SkillsRequired));

        RuleFor(x => x.Location)
            .MaximumLength(150).WithMessage("Location must not exceed 150 characters.")
            .When(x => !string.IsNullOrEmpty(x.Location));

        RuleFor(x => x.ApplicationLink)
            .MaximumLength(400).WithMessage("Application link must not exceed 400 characters.")
            .When(x => x.ApplicationLink != null);

        RuleFor(x => x.Status)
            .Must(s => s == "Open" || s == "Closed" || s == "Draft")
            .WithMessage("Status must be Open, Closed, or Draft.")
            .When(x => x.Status != null);
    }
}