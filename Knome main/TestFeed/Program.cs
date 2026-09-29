using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Knome.API.Data;
using Knome.API.Repositories;
using Knome.API.Constants;
using System.Collections.Generic;

class Program
{
    static async Task Main(string[] args)
    {
        var options = new DbContextOptionsBuilder<KnomeDbContext>()
            .UseSqlServer("Server=localhost;Database=Knome;Integrated Security=True;TrustServerCertificate=True;")
            .Options;
            
        using var db = new KnomeDbContext(options);
        var repo = new FeedRepository(db);
        
        int currentUserId = 4;
        var followedUserIds = await repo.GetFollowedUserIdsAsync(currentUserId);
        var myCommunityIds = await repo.GetMyCommunityIdsAsync(currentUserId);
        
        var posts = await repo.GetCandidatePostsAsync(followedUserIds, myCommunityIds, currentUserId, 50);
        Console.WriteLine("Posts found: " + posts.Count);
        
        foreach (var p in posts)
        {
            Console.WriteLine("PostId: " + p.PostId + ", Audience: " + p.AudienceType + ", Date: " + p.CreatedDate + ", Text: " + (p.ContentText != null ? p.ContentText.Substring(0, Math.Min(10, p.ContentText.Length)) : "NULL"));
        }
    }
}
