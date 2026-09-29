using System;

namespace Knome.API.DTOs.Interactions;

public class ShareDto
{
    public long ShareId { get; set; }
    public string ContentType { get; set; } = null!;
    public long ContentId { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = null!;
    public string SharedToType { get; set; } = null!;
    public long? TargetId { get; set; }
    public long? SharedToId
    {
        get => TargetId;
        set => TargetId = value;
    }
    public DateTime CreatedDate { get; set; }
}

public class CreateShareDto
{
    public string SharedToType { get; set; } = null!;
    public long? TargetId { get; set; }
    public long? SharedToId
    {
        get => TargetId;
        set => TargetId = value;
    }
}

public class BookmarkDto
{
    public int UserId { get; set; }
    public string ContentType { get; set; } = null!;
    public long ContentId { get; set; }
    public DateTime SavedDate { get; set; }
}
