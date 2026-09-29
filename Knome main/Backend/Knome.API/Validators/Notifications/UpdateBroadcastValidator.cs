using FluentValidation;
using Knome.API.DTOs.Notifications;

namespace Knome.API.Validators.Notifications;

public class UpdateBroadcastValidator : AbstractValidator<UpdateBroadcastDto>
{
    public UpdateBroadcastValidator()
    {
        RuleFor(x => x.Message)
            .NotEmpty().WithMessage("Broadcast announcement message is required.")
            .MaximumLength(400).WithMessage("Broadcast message cannot exceed 400 characters.");

        RuleFor(x => x.Title)
            .MaximumLength(150).WithMessage("Title cannot exceed 150 characters.");
    }
}
