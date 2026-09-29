using System.Collections.Generic;

namespace Knome.API.DTOs.User;

public class UpdateSkillsDto
{
    public List<string> Skills { get; set; } = new();
}
