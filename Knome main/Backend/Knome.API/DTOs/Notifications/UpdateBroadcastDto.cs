using System.ComponentModel.DataAnnotations;

namespace Knome.API.DTOs.Notifications;

public class UpdateBroadcastDto
{
    [MaxLength(150)]
    public string? Title { get; set; }

    [Required]
    [MaxLength(400)]
    public string Message { get; set; } = null!;
}
