using System;

namespace Knome.API.DTOs.Abbreviations;

public class AbbreviationDto
{
    public int AbbreviationId { get; set; }
    public string ShortCode { get; set; } = string.Empty;
    public string Keyword { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int? CreatedBy { get; set; }
    public string? CreatedByName { get; set; }
    public DateTime CreatedDate { get; set; }
    public bool IsActive { get; set; }
}

public class CreateAbbreviationDto
{
    public string ShortCode { get; set; } = string.Empty;
    public string Keyword { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
}

public class UpdateAbbreviationDto
{
    public string ShortCode { get; set; } = string.Empty;
    public string Keyword { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
}
