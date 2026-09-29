using FluentValidation;
using Knome.API.DTOs.Auth;

namespace Knome.API.Validators.Auth;

public class LoginRequestValidator : AbstractValidator<LoginRequestDto>
{
    public LoginRequestValidator()
    {
        RuleFor(x => x.EmployeeId)
            .NotEmpty().WithMessage("Employee ID or Email is required.")
            .MaximumLength(150).WithMessage("Employee ID or Email must not exceed 150 characters.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.")
            .MinimumLength(6).WithMessage("Password must be at least 6 characters.")
            .MaximumLength(100).WithMessage("Password must not exceed 100 characters.");
    }
}
