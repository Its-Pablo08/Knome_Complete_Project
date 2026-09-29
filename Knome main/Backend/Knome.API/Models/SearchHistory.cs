using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class SearchHistory
{
    public int UserId { get; set; }

    public string SearchTerm { get; set; } = null!;

    public DateTime SearchedDate { get; set; }

    public virtual User User { get; set; } = null!;
}
