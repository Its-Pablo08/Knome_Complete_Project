using System;

namespace Knome.API.DTOs.User;

public class SuspendUserDto
{
    public DateTime? SuspendedUntil { get; set; }
    public bool IsPermanent { get; set; }
    public string? Reason { get; set; }
}
