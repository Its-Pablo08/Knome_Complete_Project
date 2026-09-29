using FluentValidation;
using Knome.API.DTOs.Notifications;

namespace Knome.API.Validators.Notifications;

public class BroadcastNotificationValidator : AbstractValidator<BroadcastNotificationDto>
{
    public BroadcastNotificationValidator()
    {
        RuleFor(x => x.Message)
            .NotEmpty().WithMessage("Broadcast announcement message is required.")
            .MaximumLength(400).WithMessage("Broadcast message cannot exceed 400 characters.");

        RuleFor(x => x.RelatedContentType)
            .MaximumLength(20).WithMessage("Related content type cannot exceed 20 characters.");
    }
}
