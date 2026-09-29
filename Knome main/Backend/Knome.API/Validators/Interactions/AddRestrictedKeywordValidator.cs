using FluentValidation;
using Knome.API.DTOs.Interactions;

namespace Knome.API.Validators.Interactions;

public class AddRestrictedKeywordValidator : AbstractValidator<AddRestrictedKeywordDto>
{
    public AddRestrictedKeywordValidator()
    {
        RuleFor(x => x.Keyword)
            .NotEmpty().WithMessage("Keyword is required.")
            .MaximumLength(100).WithMessage("Keyword must not exceed 100 characters.");
    }
}
