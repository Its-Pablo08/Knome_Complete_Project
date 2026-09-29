using FluentValidation;
using Knome.API.Constants;
using Knome.API.DTOs.Articles;

namespace Knome.API.Validators.Articles;

public class UpdateArticleValidator : AbstractValidator<UpdateArticleDto>
{
    public UpdateArticleValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Article title is required.")
            .MaximumLength(150).WithMessage("Article title cannot exceed 150 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Article description cannot exceed 500 characters.");

        RuleFor(x => x.ContentHtml)
            .NotEmpty().WithMessage("Article HTML content is required.")
            .MaximumLength(100000).WithMessage("Article HTML content cannot exceed 100,000 characters.");

        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("Valid Category ID is required.");

        RuleFor(x => x.Status)
            .Must(ArticleStatuses.IsValid).WithMessage("Status must be 'Published', 'Draft', 'Scheduled', or 'Archived'.");
    }
}
