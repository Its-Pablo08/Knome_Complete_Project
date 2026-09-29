using System.Collections.Generic;
using System.Threading.Tasks;
using Knome.API.DTOs.User;

namespace Knome.API.Interfaces;

/// <summary>
/// Feature repository contract for User operations that require eager loading,
/// complex filtering, and many-to-many collection management.
/// Extends data access cleanly beyond generic CRUD without leaking EF Core abstractions.
/// </summary>
public interface IUserRepository : IRepository<Models.User>
{
    Task<Models.User?> GetProfileByIdAsync(int userId);
    Task<PagedResultDto<Models.User>> GetPagedUsersAsync(UserFilterDto filter);
    Task UpdateUserSkillsAsync(int userId, List<string> skills);
    Task UpdateUserInterestsAsync(int userId, List<string> interests);
    Task UpdateUserRolesAsync(int userId, List<string> roleNames);
    Task<int> GetMutualConnectionsCountAsync(int userId1, int userId2);
    Task<bool> DepartmentExistsAsync(int departmentId);
    Task<List<int>> GetAllActiveUserIdsAsync();
    Task<bool> IsFollowingAsync(int followerUserId, int followingUserId);
    Task AddFollowerAsync(int followerUserId, int followingUserId);
    Task RemoveFollowerAsync(int followerUserId, int followingUserId);
    Task SaveChangesAsync();
    Task<List<Models.User>> GetNetworkSuggestionsAsync(int userId, int limit);
    Task<List<Models.User>> GetFollowersAsync(int userId);
    Task<List<Models.User>> GetFollowingAsync(int userId);
    Task<Models.ConnectionRequest?> GetConnectionRequestAsync(int senderId, int receiverId);
    Task AddConnectionRequestAsync(Models.ConnectionRequest request);
    Task UpdateConnectionRequestAsync(Models.ConnectionRequest request);
    Task RemoveConnectionRequestAsync(Models.ConnectionRequest request);
    Task AddBidirectionalFollowAsync(int userId1, int userId2);
    Task RemoveBidirectionalFollowAsync(int userId1, int userId2);
    Task<List<Models.User>> GetMutualConnectionsAsync(int userId1, int userId2);
    Task<List<Models.ConnectionRequest>> GetPendingReceivedConnectionRequestsAsync(int userId);
    Task<List<Models.ConnectionRequest>> GetPendingSentConnectionRequestsAsync(int userId);
    Task<List<Models.User>> GetConnectionsAsync(int userId);
}
