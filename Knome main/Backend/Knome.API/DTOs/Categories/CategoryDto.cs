using System.ComponentModel.DataAnnotations;

namespace Knome.API.DTOs.Categories;

public class CategoryDto
{
    public int CategoryId { get; set; }
    public string Name { get; set; } = null!;
    public string AppliesTo { get; set; } = null!;
}

public class CreateCategoryDto
{
    [Required(ErrorMessage = "Category name is required.")]
    [StringLength(100, ErrorMessage = "Category name cannot exceed 100 characters.")]
    public string Name { get; set; } = null!;
}
