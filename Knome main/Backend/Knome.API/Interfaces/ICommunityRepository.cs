using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.Models;

namespace Knome.API.Interfaces;

public interface ICommunityRepository
{
    // Community CRUD & Discovery
    Task<Community?> GetCommunityByIdAsync(int communityId);
    Task<Community?> GetCommunityByIdAnyStatusAsync(int communityId);
    Task<List<Community>> GetPendingCommunitiesAsync();
    Task<List<Community>> GetCommunitiesAsync(int? categoryId, string? type, string? search, int pageNumber, int pageSize);
    Task<List<Community>> GetUserCommunitiesAsync(int userId);
    Task<Community> AddCommunityAsync(Community community);
    Task UpdateCommunityAsync(Community community);
    Task DeleteCommunityAsync(Community community);
    Task<bool> CommunityNameExistsAsync(string name, int? excludeCommunityId = null);

    // Community Admins (Users join table)
    Task<bool> IsCommunityAdminAsync(int communityId, int userId);
    Task AddCommunityAdminAsync(int communityId, int userId);
    Task RemoveCommunityAdminAsync(int communityId, int userId);
    Task<int> GetCommunityAdminsCountAsync(int communityId);

    // Members
    Task<CommunityMember?> GetMemberAsync(int communityId, int userId);
    Task<CommunityMember> AddMemberAsync(CommunityMember member);
    Task UpdateMemberAsync(CommunityMember member);
    Task RemoveMemberAsync(CommunityMember member);
    Task<List<CommunityMember>> GetMembersAsync(int communityId, string? status, int pageNumber, int pageSize);

    // Posts & Feed
    Task<CommunityPost?> GetCommunityPostAsync(int communityId, long postId);
    Task<CommunityPost> AddCommunityPostAsync(CommunityPost communityPost);
    Task UpdateCommunityPostAsync(CommunityPost communityPost);
    Task DeleteCommunityPostAsync(CommunityPost communityPost);
    Task<List<CommunityPost>> GetCommunityPostsAsync(int communityId, int pageNumber, int pageSize);
    Task<int> GetPinnedPostsCountAsync(int communityId);
}
