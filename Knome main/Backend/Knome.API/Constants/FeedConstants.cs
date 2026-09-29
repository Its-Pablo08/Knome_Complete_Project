namespace Knome.API.Constants;

public static class FeedWindows
{
    public const string Daily = "Daily";
    public const string Weekly = "Weekly";
    public const string Monthly = "Monthly";

    public static bool IsValid(string? window)
    {
        return window == Daily || window == Weekly || window == Monthly;
    }

    public static int GetHours(string window)
    {
        return window switch
        {
            Daily => 24,
            Weekly => 168,
            Monthly => 720,
            _ => 24
        };
    }
}

public static class AudienceTypes
{
    public const string Everyone = "Everyone";
    public const string FollowersOnly = "FollowersOnly";
    public const string Private = "Private";
}
