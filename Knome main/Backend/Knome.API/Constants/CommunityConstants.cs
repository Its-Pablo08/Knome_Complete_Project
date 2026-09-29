namespace Knome.API.Constants;

public static class CommunityTypes
{
    public const string Public = "Public";
    public const string Private = "Private";
    public const string Default = "Default";
    public const string Org = "Org";

    public static readonly string[] All = { Public, Private, Default, Org };

    public static bool IsValid(string? type)
    {
        if (string.IsNullOrWhiteSpace(type)) return false;
        return type == Public || type == Private || type == Default || type == Org;
    }
}

public static class CommunityMemberTypes
{
    public const string Subscriber = "Subscriber";
    public const string Contributor = "Contributor";
    public const string Member = "Contributor";
    public const string Moderator = "Admin";
    public const string Admin = "Admin";

    public static readonly string[] All = { Subscriber, Contributor, Moderator, Admin };
}

public static class CommunityMemberStatuses
{
    public const string Approved = "Approved";
    public const string Pending = "Pending";
    public const string Rejected = "Rejected";
    public const string Banned = "Banned";

    public static readonly string[] All = { Approved, Pending, Rejected, Banned };

    public static bool IsValidDecision(string? status)
    {
        if (string.IsNullOrWhiteSpace(status)) return false;
        return status == Approved || status == Rejected || status == Banned;
    }
}
