using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class RestrictedKeyword
{
    public int KeywordId { get; set; }

    public string Keyword { get; set; } = null!;
}
