using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class Abbreviation
{
    public int AbbreviationId { get; set; }

    public string ShortCode { get; set; } = null!;

    public string Keyword { get; set; } = null!;

    public string Description { get; set; } = null!;

    public int? CreatedBy { get; set; }

    public DateTime CreatedDate { get; set; }

    public bool IsActive { get; set; }

    public virtual User? CreatedByNavigation { get; set; }
}
