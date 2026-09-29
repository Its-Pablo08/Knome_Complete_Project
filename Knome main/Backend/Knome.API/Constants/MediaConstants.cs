namespace Knome.API.Constants;

public static class VideoSourceTypes
{
    public const string Stream = "Stream";
    public const string OneDrive = "OneDrive";
    public const string LocalUpload = "LocalUpload";

    public static readonly string[] All = { Stream, OneDrive, LocalUpload };

    public static bool IsValid(string? sourceType)
    {
        if (string.IsNullOrWhiteSpace(sourceType)) return false;
        return sourceType == Stream || sourceType == OneDrive || sourceType == LocalUpload;
    }
}

public static class MediaSizeLimits
{
    public const int MaxVideoSizeMb = 500;
    public const int MaxPodcastSizeMb = 100;
}
