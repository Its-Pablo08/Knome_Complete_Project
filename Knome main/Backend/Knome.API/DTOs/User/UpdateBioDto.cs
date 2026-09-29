namespace Knome.API.DTOs.User;

public class UpdateBioDto
{
    public string? Bio { get; set; }
    public string BioVisibility { get; set; } = "Public";
}
