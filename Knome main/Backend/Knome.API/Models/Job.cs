using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Job
{
    public int JobId { get; set; }

    public string Title { get; set; } = null!;

    public int? DepartmentId { get; set; }

    public string Description { get; set; } = null!;

    public string? SkillsRequired { get; set; }

    public string? Location { get; set; }

    public DateOnly ClosingDate { get; set; }

    public string ApplicationLink { get; set; } = null!;

    public int PostedByUserId { get; set; }

    public DateTime PostedDate { get; set; }

    public string Status { get; set; } = null!;

    public virtual Department? Department { get; set; }

    public virtual User PostedByUser { get; set; } = null!;
}
