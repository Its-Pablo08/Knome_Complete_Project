using Microsoft.AspNetCore.Http;

namespace Knome.API.DTOs.User;

public class UpdateProfileImageDto
{
    public IFormFile File { get; set; } = null!;
}
