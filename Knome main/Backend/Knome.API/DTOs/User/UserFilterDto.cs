namespace Knome.API.DTOs.User;

public class UserFilterDto
{
    public string? SearchTerm { get; set; }
    public int? DepartmentId { get; set; }
    public string? RoleName { get; set; }
    public bool? IsActive { get; set; }
    public bool? IsSuspended { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}
