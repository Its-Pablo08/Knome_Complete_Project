using FluentValidation;
using Knome.API.DTOs.User;

namespace Knome.API.Validators.User;

public class UpdateSkillsValidator : AbstractValidator<UpdateSkillsDto>
{
    public UpdateSkillsValidator()
    {
        RuleFor(x => x.Skills)
            .NotNull().WithMessage("Skills list cannot be null.")
            .Must(s => s.Count <= 30).WithMessage("Cannot specify more than 30 skills.");

        RuleForEach(x => x.Skills)
            .NotEmpty().WithMessage("Skill cannot be empty.")
            .MaximumLength(100).WithMessage("Skill cannot exceed 100 characters.");
    }
}
