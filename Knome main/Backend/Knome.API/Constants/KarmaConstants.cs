namespace Knome.API.Constants;

public static class KarmaActivityTypes
{
    public const string CreatePost = "CreatePost";
    public const string CreateArticle = "CreateArticle";
    public const string CreateVideo = "CreateVideo";
    public const string CreatePodcast = "CreatePodcast";
    public const string ReceiveLike = "ReceiveLike";
    public const string ReceiveReaction = "ReceiveLike"; // Backward compatibility alias
    public const string ReceiveComment = "ReceiveComment";
    public const string ReceiveShare = "ReceiveShare";
    public const string CommunityParticipation = "CommunityParticipation";
    public const string AddComment = "AddComment";
    public const string AddLike = "AddLike";
    public const string AddShare = "AddShare";
    public const string ManualAward = "ManualAward";
    public const string Other = "Other";
}

public static class KarmaPoints
{
    public const int CreatePostPoints = 2;
    public const int CreateArticlePoints = 10;
    public const int CreateVideoPoints = 8;
    public const int CreatePodcastPoints = 8;
    public const int ReceiveLikePoints = 1;
    public const int ReceiveReactionPoints = 1; // Backward compatibility alias
    public const int ReceiveCommentPoints = 2;
    public const int ReceiveSharePoints = 3;
    public const int CommunityParticipationPoints = 5;
    public const int AddCommentPoints = 2;
    public const int AddLikePoints = 1;
    public const int AddSharePoints = 2;
}

public static class KarmaCaps
{
    public const int CreatePostDailyCap = 50;
    public const int CreateArticleDailyCap = 30;
    public const int CreateVideoDailyCap = 24;
    public const int CreatePodcastDailyCap = 24;
    public const int CommunityParticipationDailyCap = 5;
}

public static class BadgeLevels
{
    public const string Bronze = "Bronze";
    public const string Silver = "Silver";
    public const string Gold = "Gold";
    public const string Platinum = "Platinum";

    public static string ComputeBadge(int totalPoints)
    {
        if (totalPoints >= 5000) return Platinum;
        if (totalPoints >= 1000) return Gold;
        if (totalPoints >= 500) return Silver;
        if (totalPoints >= 100) return Bronze;
        return "Contributor";
    }

    /// <summary>Ordinal rank of a badge level (higher = better). Empty/unknown = 0.</summary>
    public static int Rank(string? level)
    {
        return level switch
        {
            Platinum => 4,
            Gold => 3,
            Silver => 2,
            Bronze => 1,
            _ => 0
        };
    }
}
