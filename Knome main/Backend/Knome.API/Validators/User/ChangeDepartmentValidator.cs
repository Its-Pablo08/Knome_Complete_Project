using FluentValidation;
using Knome.API.DTOs.User;

namespace Knome.API.Validators.User;

public class ChangeDepartmentValidator : AbstractValidator<ChangeDepartmentDto>
{
    public ChangeDepartmentValidator()
    {
        RuleFor(x => x.DepartmentId)
            .GreaterThan(0).WithMessage("DepartmentId must be greater than 0.");
    }
}
