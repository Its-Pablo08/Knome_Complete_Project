using FluentValidation;
using Knome.API.DTOs.User;

namespace Knome.API.Validators.User;

public class UserFilterValidator : AbstractValidator<UserFilterDto>
{
    public UserFilterValidator()
    {
        RuleFor(x => x.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("PageNumber must be at least 1.");

        RuleFor(x => x.PageSize)
            .InclusiveBetween(1, 100).WithMessage("PageSize must be between 1 and 100.");
    }
}
