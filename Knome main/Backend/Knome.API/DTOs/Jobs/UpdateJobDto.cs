using System;

namespace Knome.API.DTOs.Jobs;

public class UpdateJobDto
{
    public string? Title { get; set; }
    public int? DepartmentId { get; set; }
    public string? Description { get; set; }
    public string? SkillsRequired { get; set; }
    public string? Location { get; set; }
    public DateOnly? ClosingDate { get; set; }
    public string? ApplicationLink { get; set; }
    public string? Status { get; set; }
}