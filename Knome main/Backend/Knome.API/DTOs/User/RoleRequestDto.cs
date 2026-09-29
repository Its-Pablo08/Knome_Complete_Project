using System;

namespace Knome.API.DTOs.User;

public class KnomeRoleRequestDto
{
    public int RequestId { get; set; }
    public string EmployeeId { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public int DepartmentId { get; set; }
    public string? DepartmentName { get; set; }
    public string Designation { get; set; } = string.Empty;
    public string RequestedRoleCode { get; set; } = "EMP";
    public string Status { get; set; } = "Pending";
    public int? AssignedRoleId { get; set; }
    public string? AssignedRoleName { get; set; }
    public string? AssignedBy { get; set; }
    public string? AdminComment { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
}

public class ApproveKnomeRoleRequestDto
{
    public string RoleName { get; set; } = "Employee"; // 'Employee', 'Community Admin', 'HR Administrator', 'System Administrator'
    public string? Comment { get; set; }
}

public class RejectKnomeRoleRequestDto
{
    public string? Reason { get; set; }
}

public class RegisterRoleRequestDto
{
    public string EmployeeId { get; set; } = string.Empty;
}

public class RoleRequestStatusDto
{
    public string EmployeeId { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string RoleStatus { get; set; } = "Pending";
    public bool HasApprovedRole { get; set; }
    public string? AssignedRoleName { get; set; }
    public List<string> Roles { get; set; } = new();
}
