namespace Knome.API.DTOs.Jobs;

public class JobDto
{
    public int JobId { get; set; }
    public string Title { get; set; } = null!;
    public int? DepartmentId { get; set; }
    public string? DepartmentName { get; set; }
    public string Description { get; set; } = null!;
    public string? SkillsRequired { get; set; }
    public string? Location { get; set; }
    public DateOnly ClosingDate { get; set; }
    public string ApplicationLink { get; set; } = null!;
    public DateTime PostedDate { get; set; }
    public string Status { get; set; } = null!;
    public int PostedByUserId { get; set; }
    public string? PostedByFullName { get; set; }
}