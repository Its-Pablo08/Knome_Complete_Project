using FluentValidation;
using Knome.API.Constants;
using Knome.API.DTOs.Interactions;

namespace Knome.API.Validators.Interactions;

public class CreateShareValidator : AbstractValidator<CreateShareDto>
{
    public CreateShareValidator()
    {
        RuleFor(x => x.SharedToType)
            .NotEmpty().WithMessage("SharedToType cannot be empty.")
            .Must(SharedToTypes.IsValid)
            .WithMessage($"Invalid shared target type. Must be one of: {string.Join(", ", SharedToTypes.All)}.");
    }
}

public class CreateReportValidator : AbstractValidator<CreateReportDto>
{
    public CreateReportValidator()
    {
        RuleFor(x => x.ReasonCode)
            .NotEmpty().WithMessage("Reason code cannot be empty.")
            .Must(ReportReasonCodes.IsValid)
            .WithMessage($"Invalid reason code. Must be one of: {string.Join(", ", ReportReasonCodes.All)}.");
    }
}
