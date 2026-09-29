using System;
using System.Collections.Generic;

namespace Knome.API.DTOs.Karma;

public class KarmaBalanceDto
{
    public int UserId { get; set; }
    public string EmployeeId { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string? Designation { get; set; }
    public string? ProfilePhotoUrl { get; set; }
    public int TotalPoints { get; set; }
    public string BadgeLevel { get; set; } = null!;
    public DateTime LastUpdated { get; set; }
    public List<KarmaTransactionDto> RecentTransactions { get; set; } = new();
}
