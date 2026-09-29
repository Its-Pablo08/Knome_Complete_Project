using System.Linq;
using FluentValidation;
using Knome.API.DTOs.User;

namespace Knome.API.Validators.User;

public class UpdateBioValidator : AbstractValidator<UpdateBioDto>
{
    private static readonly string[] ValidVisibilities = { "Public", "Connections Only", "Private" };

    public UpdateBioValidator()
    {
        RuleFor(x => x.Bio)
            .MaximumLength(500).WithMessage("Bio cannot exceed 500 characters.");

        RuleFor(x => x.BioVisibility)
            .Must(v => ValidVisibilities.Contains(v))
            .WithMessage("Bio visibility must be 'Public', 'Connections Only', or 'Private'.");
    }
}
