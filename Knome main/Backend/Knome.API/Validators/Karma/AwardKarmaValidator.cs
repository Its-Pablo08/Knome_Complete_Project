using FluentValidation;
using Knome.API.DTOs.Karma;

namespace Knome.API.Validators.Karma;

public class AwardKarmaValidator : AbstractValidator<AwardKarmaDto>
{
    public AwardKarmaValidator()
    {
        RuleFor(x => x.UserId)
            .GreaterThan(0).WithMessage("User ID must be greater than 0.");

        RuleFor(x => x.ActivityType)
            .NotEmpty().WithMessage("Activity type is required.")
            .MaximumLength(40).WithMessage("Activity type must not exceed 40 characters.");

        RuleFor(x => x.PointsAwarded)
            .NotEmpty().WithMessage("Points awarded must be non-zero.");
    }
}
