using System.Threading.Tasks;
using Knome.API.DTOs.Jobs;
using Knome.API.DTOs.User;

namespace Knome.API.Interfaces;

public interface IJobService
{
    Task<JobDto?> GetByIdAsync(int jobId);
    Task<PagedResultDto<JobDto>> GetPagedAsync(int? departmentId, string? status, string? search, string? location, string? skills, bool includeExpired, int pageNumber, int pageSize);
    Task<JobDto> CreateAsync(CreateJobDto dto, int postedByUserId);
    Task<JobDto> UpdateAsync(int jobId, UpdateJobDto dto);
    Task<bool> DeleteAsync(int jobId);
    Task<int> CloseExpiredJobsAsync();
}