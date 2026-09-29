using FluentValidation;
using Knome.API.DTOs.Notifications;

namespace Knome.API.Validators.Notifications;

public class UpdateNotificationPreferenceValidator : AbstractValidator<UpdateNotificationPreferenceDto>
{
    public UpdateNotificationPreferenceValidator()
    {
        RuleFor(x => x.EventType)
            .NotEmpty().WithMessage("EventType is required.")
            .MaximumLength(40).WithMessage("EventType cannot exceed 40 characters.");
    }
}
