using System.Collections.Generic;

namespace Knome.API.DTOs.Articles;

public class ArticleDetailDto : ArticleDto
{
    public List<ArticleVersionDto> Versions { get; set; } = new();
}
