using FluentValidation;
using Knome.API.DTOs.Notifications;

namespace Knome.API.Validators.Notifications;

public class CreateNotificationValidator : AbstractValidator<CreateNotificationDto>
{
    public CreateNotificationValidator()
    {
        RuleFor(x => x.RecipientUserId)
            .GreaterThan(0).WithMessage("RecipientUserId must be greater than 0.");

        RuleFor(x => x.NotificationType)
            .NotEmpty().WithMessage("NotificationType is required.")
            .MaximumLength(50).WithMessage("NotificationType cannot exceed 50 characters.");

        RuleFor(x => x.Message)
            .NotEmpty().WithMessage("Message is required.")
            .MaximumLength(500).WithMessage("Message cannot exceed 500 characters.");
    }
}
