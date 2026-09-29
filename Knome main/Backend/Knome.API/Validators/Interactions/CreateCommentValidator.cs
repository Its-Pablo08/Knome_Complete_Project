using FluentValidation;
using Knome.API.DTOs.Interactions;

namespace Knome.API.Validators.Interactions;

public class CreateCommentValidator : AbstractValidator<CreateCommentDto>
{
    public CreateCommentValidator()
    {
        RuleFor(x => x.CommentText)
            .NotEmpty().WithMessage("Comment text cannot be empty.")
            .MaximumLength(1000).WithMessage("Comment text cannot exceed 1000 characters.");

        RuleFor(x => x.ImageUrl)
            .MaximumLength(500).WithMessage("Image URL cannot exceed 500 characters.")
            .When(x => !string.IsNullOrEmpty(x.ImageUrl));
    }
}

public class UpdateCommentValidator : AbstractValidator<UpdateCommentDto>
{
    public UpdateCommentValidator()
    {
        RuleFor(x => x.CommentText)
            .NotEmpty().WithMessage("Comment text cannot be empty.")
            .MaximumLength(1000).WithMessage("Comment text cannot exceed 1000 characters.");

        RuleFor(x => x.ImageUrl)
            .MaximumLength(500).WithMessage("Image URL cannot exceed 500 characters.")
            .When(x => !string.IsNullOrEmpty(x.ImageUrl));
    }
}
