using System;
using System.Threading.Tasks;
using Knome.API.Constants;
using Knome.API.DTOs.Jobs;
using Knome.API.DTOs.User;
using Knome.API.Exceptions;
using Knome.API.Interfaces;

namespace Knome.API.Services;

public class JobService : IJobService
{
    private readonly IJobRepository _repository;
    private readonly IUserRepository _userRepository;
    private readonly INotificationService _notificationService;

    public JobService(IJobRepository repository, IUserRepository userRepository, INotificationService notificationService)
    {
        _repository = repository;
        _userRepository = userRepository;
        _notificationService = notificationService;
    }

    public async Task<JobDto?> GetByIdAsync(int jobId)
    {
        return await _repository.GetByIdAsync(jobId);
    }

    public async Task<PagedResultDto<JobDto>> GetPagedAsync(int? departmentId, string? status, string? search, string? location, string? skills, bool includeExpired, int pageNumber, int pageSize)
    {
        return await _repository.GetPagedAsync(departmentId, status, search, location, skills, includeExpired, pageNumber, pageSize);
    }

    public async Task<int> CloseExpiredJobsAsync()
    {
        return await _repository.CloseExpiredJobsAsync(Knome.API.Common.KnomeTime.Today);
    }

    public async Task<JobDto> CreateAsync(CreateJobDto dto, int postedByUserId)
    {
        // FK existence validation (GBV-001)
        if (dto.DepartmentId.HasValue)
        {
            var deptExists = await _userRepository.DepartmentExistsAsync(dto.DepartmentId.Value);
            if (!deptExists)
                throw new BadRequestException($"Department ID {dto.DepartmentId.Value} does not exist.");
        }

        var job = await _repository.AddAsync(dto, postedByUserId);

        // Jobs is one of several notification producers; the notification core is unchanged.
        var recipientIds = await _userRepository.GetAllActiveUserIdsAsync();
        if (recipientIds.Count > 0)
        {
            await _notificationService.PublishBroadcastAsync(
                NotificationTypes.Job,
                $"New job posted: {job.Title}",
                relatedContentType: NotificationContentTypes.Job,
                relatedContentId: job.JobId,
                candidateUserIds: recipientIds);
        }

        return job;
    }

    public async Task<JobDto> UpdateAsync(int jobId, UpdateJobDto dto)
    {
        // FK existence validation (GBV-001)
        if (dto.DepartmentId.HasValue)
        {
            var deptExists = await _userRepository.DepartmentExistsAsync(dto.DepartmentId.Value);
            if (!deptExists)
                throw new BadRequestException($"Department ID {dto.DepartmentId.Value} does not exist.");
        }

        return await _repository.UpdateAsync(jobId, dto);
    }

    public async Task<bool> DeleteAsync(int jobId)
    {
        return await _repository.DeleteAsync(jobId);
    }
}