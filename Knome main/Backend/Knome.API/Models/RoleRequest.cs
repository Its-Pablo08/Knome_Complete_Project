using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class RoleRequest
{
    public int RequestId { get; set; }

    public string EmployeeId { get; set; } = null!;

    public string FullName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public int DepartmentId { get; set; }

    public string? DepartmentName { get; set; }

    public string Designation { get; set; } = null!;

    public string RequestedRoleCode { get; set; } = null!;

    public string Status { get; set; } = null!;

    public int? AssignedRoleId { get; set; }

    public string? AssignedRoleName { get; set; }

    public string? AssignedBy { get; set; }

    public string? AdminComment { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? ProcessedAt { get; set; }
}
