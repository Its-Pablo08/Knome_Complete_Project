using System;

namespace Knome.API.DTOs.Jobs;

public class CreateJobDto
{
    public string Title { get; set; } = null!;
    public int? DepartmentId { get; set; }
    public string Description { get; set; } = null!;
    public string? SkillsRequired { get; set; }
    public string? Location { get; set; }
    public DateOnly ClosingDate { get; set; }
    public string ApplicationLink { get; set; } = null!;
    public string Status { get; set; } = null!;
}