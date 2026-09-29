using System;
using FluentValidation;
using Knome.API.DTOs.User;

namespace Knome.API.Validators.User;

public class SuspendUserValidator : AbstractValidator<SuspendUserDto>
{
    public SuspendUserValidator()
    {
        RuleFor(x => x)
            .Must(x => x.IsPermanent || (x.SuspendedUntil.HasValue && x.SuspendedUntil > Knome.API.Common.KnomeTime.Now))
            .WithMessage("Must specify either IsPermanent = true OR a future SuspendedUntil timestamp.");

        RuleFor(x => x.Reason)
            .MaximumLength(500).WithMessage("Suspension reason cannot exceed 500 characters.");
    }
}
