using FluentValidation;
using Knome.API.Constants;
using Knome.API.DTOs.Communities;

namespace Knome.API.Validators.Communities;

public class DecideMembershipValidator : AbstractValidator<DecideMembershipDto>
{
    public DecideMembershipValidator()
    {
        RuleFor(x => x.Status)
            .NotEmpty().WithMessage("Decision status cannot be empty.")
            .Must(CommunityMemberStatuses.IsValidDecision)
            .WithMessage($"Invalid decision status. Must be one of: {CommunityMemberStatuses.Approved}, {CommunityMemberStatuses.Rejected}, {CommunityMemberStatuses.Banned}.");
    }
}

public class CreateCommunityPostValidator : AbstractValidator<CreateCommunityPostDto>
{
    public CreateCommunityPostValidator()
    {
        RuleFor(x => x.ContentText)
            .NotEmpty().WithMessage("Post content cannot be empty.")
            .MaximumLength(1000).WithMessage("Post content cannot exceed 1000 characters.");
    }
}
