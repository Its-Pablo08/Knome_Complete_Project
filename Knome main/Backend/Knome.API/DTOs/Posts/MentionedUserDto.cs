namespace Knome.API.DTOs.Posts;

public class MentionedUserDto
{
    public int UserId { get; set; }
    public string EmployeeId { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
}
