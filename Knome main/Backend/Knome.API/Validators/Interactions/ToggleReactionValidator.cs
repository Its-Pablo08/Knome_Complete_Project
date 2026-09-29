using FluentValidation;
using Knome.API.Constants;
using Knome.API.DTOs.Interactions;

namespace Knome.API.Validators.Interactions;

public class ToggleReactionValidator : AbstractValidator<ToggleReactionDto>
{
    public ToggleReactionValidator()
    {
        RuleFor(x => x.ReactionType)
            .NotEmpty().WithMessage("Reaction type cannot be empty.")
            .Must(ReactionTypes.IsValid)
            .WithMessage($"Invalid reaction type. Must be one of: {string.Join(", ", ReactionTypes.All)}.");
    }
}
