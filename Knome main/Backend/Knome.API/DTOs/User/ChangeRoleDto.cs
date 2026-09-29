using System.Collections.Generic;

namespace Knome.API.DTOs.User;

public class ChangeRoleDto
{
    public List<string> RoleNames { get; set; } = new();
}
