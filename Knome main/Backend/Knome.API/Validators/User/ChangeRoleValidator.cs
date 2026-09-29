using System.Linq;
using FluentValidation;
using Knome.API.Constants;
using Knome.API.DTOs.User;

namespace Knome.API.Validators.User;

public class ChangeRoleValidator : AbstractValidator<ChangeRoleDto>
{
    private static readonly string[] ValidRoles =
    {
        Roles.Employee,
        Roles.CommunityAdmin,
        Roles.HRAdmin,
        Roles.SystemAdmin
    };

    public ChangeRoleValidator()
    {
        RuleFor(x => x.RoleNames)
            .NotEmpty().WithMessage("At least one role must be assigned.")
            .Must(roles => roles != null && roles.All(r => ValidRoles.Contains(r)))
            .WithMessage($"Invalid role name specified. Valid roles are: {string.Join(", ", ValidRoles)}");
    }
}
