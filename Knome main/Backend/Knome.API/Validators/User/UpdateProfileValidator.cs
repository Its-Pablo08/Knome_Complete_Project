using System.Linq;
using FluentValidation;
using Knome.API.DTOs.User;

namespace Knome.API.Validators.User;

public class UpdateProfileValidator : AbstractValidator<UpdateProfileDto>
{
    private static readonly string[] ValidVisibilities = { "Public", "Connections Only", "Private" };

    public UpdateProfileValidator()
    {
        RuleFor(x => x.Bio)
            .MaximumLength(500).WithMessage("Bio cannot exceed 500 characters.");

        RuleFor(x => x.Location)
            .MaximumLength(100).WithMessage("Location cannot exceed 100 characters.");

        RuleFor(x => x.MobileNo)
            .MaximumLength(20).WithMessage("Mobile number cannot exceed 20 characters.");

        RuleFor(x => x.BioVisibility)
            .Must(v => ValidVisibilities.Contains(v))
            .WithMessage("Bio visibility must be 'Public', 'Connections Only', or 'Private'.");

        RuleFor(x => x.NetworkVisibility)
            .Must(v => ValidVisibilities.Contains(v))
            .WithMessage("Network visibility must be 'Public', 'Connections Only', or 'Private'.");

        RuleFor(x => x.PhotosVisibility)
            .Must(v => ValidVisibilities.Contains(v))
            .WithMessage("Photos visibility must be 'Public', 'Connections Only', or 'Private'.");

        RuleFor(x => x.InterestsVisibility)
            .Must(v => ValidVisibilities.Contains(v))
            .WithMessage("Interests visibility must be 'Public', 'Connections Only', or 'Private'.");

        When(x => x.Skills != null, () =>
        {
            RuleFor(x => x.Skills)
                .Must(s => s!.Count <= 30).WithMessage("Cannot specify more than 30 skills.");
            RuleForEach(x => x.Skills)
                .NotEmpty().WithMessage("Skill cannot be empty.")
                .MaximumLength(100).WithMessage("Skill cannot exceed 100 characters.");
        });

        When(x => x.Interests != null, () =>
        {
            RuleFor(x => x.Interests)
                .Must(i => i!.Count <= 30).WithMessage("Cannot specify more than 30 interests.");
            RuleForEach(x => x.Interests)
                .NotEmpty().WithMessage("Interest cannot be empty.")
                .MaximumLength(100).WithMessage("Interest cannot exceed 100 characters.");
        });
    }
}
