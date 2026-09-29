using FluentValidation;
using Knome.API.Constants;
using Knome.API.DTOs.Interactions;

namespace Knome.API.Validators.Interactions;

public class ResolveReportValidator : AbstractValidator<ResolveReportDto>
{
    public ResolveReportValidator()
    {
        RuleFor(x => x.Status)
            .NotEmpty().WithMessage("Status cannot be empty.")
            .Must(s => s == ReportStatuses.UnderReview || s == ReportStatuses.Resolved || s == ReportStatuses.Dismissed)
            .WithMessage($"Status must be one of: {ReportStatuses.UnderReview}, {ReportStatuses.Resolved}, {ReportStatuses.Dismissed}.");

        RuleFor(x => x.ActionTaken)
            .MaximumLength(40).WithMessage("Action taken summary cannot exceed 40 characters due to database schema constraints.")
            .When(x => !string.IsNullOrEmpty(x.ActionTaken));
    }
}
