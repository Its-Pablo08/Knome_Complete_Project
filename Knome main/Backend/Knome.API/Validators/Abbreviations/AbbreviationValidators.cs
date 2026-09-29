using FluentValidation;
using Knome.API.DTOs.Abbreviations;

namespace Knome.API.Validators.Abbreviations;

public class CreateAbbreviationValidator : AbstractValidator<CreateAbbreviationDto>
{
    public CreateAbbreviationValidator()
    {
        RuleFor(x => x.ShortCode)
            .NotEmpty().WithMessage("ShortCode is required.")
            .MaximumLength(50).WithMessage("ShortCode cannot exceed 50 characters.");

        RuleFor(x => x.Keyword)
            .NotEmpty().WithMessage("Keyword is required and mandatory.")
            .MaximumLength(100).WithMessage("Keyword cannot exceed 100 characters.");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Description is required.")
            .MaximumLength(500).WithMessage("Description cannot exceed 500 characters.");
    }
}

public class UpdateAbbreviationValidator : AbstractValidator<UpdateAbbreviationDto>
{
    public UpdateAbbreviationValidator()
    {
        RuleFor(x => x.ShortCode)
            .NotEmpty().WithMessage("ShortCode is required.")
            .MaximumLength(50).WithMessage("ShortCode cannot exceed 50 characters.");

        RuleFor(x => x.Keyword)
            .NotEmpty().WithMessage("Keyword is required and mandatory.")
            .MaximumLength(100).WithMessage("Keyword cannot exceed 100 characters.");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Description is required.")
            .MaximumLength(500).WithMessage("Description cannot exceed 500 characters.");
    }
}
