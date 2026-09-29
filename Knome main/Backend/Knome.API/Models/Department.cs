using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Department
{
    public int DepartmentId { get; set; }

    public string Name { get; set; } = null!;

    public string? DepartmentCode { get; set; }

    public virtual ICollection<Job> Jobs { get; set; } = new List<Job>();

    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
