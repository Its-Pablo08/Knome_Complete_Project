namespace Knome.API.DTOs.Karma;

public class AwardKarmaDto
{
    public int UserId { get; set; }
    public string ActivityType { get; set; } = null!;
    public int PointsAwarded { get; set; }
    public string? RelatedContentType { get; set; }
    public long? RelatedContentId { get; set; }
}
