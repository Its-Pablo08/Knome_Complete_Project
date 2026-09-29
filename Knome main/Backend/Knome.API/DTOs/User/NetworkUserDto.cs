using System.Collections.Generic;

namespace Knome.API.DTOs.User;

public class NetworkUserDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public string? Designation { get; set; }
    public List<string> Roles { get; set; } = new();
    public string? Avatar { get; set; }
    public int MutualConnections { get; set; }
    public int CommonCommunities { get; set; }
    public bool IsFollowing { get; set; }
    public bool IsSuggested { get; set; }
    public string Reason { get; set; } = string.Empty;
    public int? RequestId { get; set; }
    public string ConnectionStatus { get; set; } = "None"; // None, PendingSent, PendingReceived, Connected
    public List<string> MutualConnectionAvatars { get; set; } = new();
}
