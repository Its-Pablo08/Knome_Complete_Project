using System.Collections.Generic;

namespace Knome.API.DTOs.User;

public class UpdateProfileDto
{
    public string? Bio { get; set; }
    public List<string>? Skills { get; set; }
    public List<string>? Interests { get; set; }
    public string? Location { get; set; }
    public string? MobileNo { get; set; }
    public string BioVisibility { get; set; } = "Public";
    public string NetworkVisibility { get; set; } = "Public";
    public string PhotosVisibility { get; set; } = "Public";
    public string InterestsVisibility { get; set; } = "Public";
}
