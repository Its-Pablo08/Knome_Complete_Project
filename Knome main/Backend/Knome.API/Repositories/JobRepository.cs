using System.Linq;
using System.Threading.Tasks;
using Knome.API.Data;
using Knome.API.DTOs.Jobs;
using Knome.API.DTOs.User;
using Knome.API.Exceptions;
using Knome.API.Interfaces;
using Knome.API.Models;
using Microsoft.EntityFrameworkCore;

namespace Knome.API.Repositories;

public class JobRepository : IJobRepository
{
    private readonly KnomeDbContext _db;

    public JobRepository(KnomeDbContext db)
    {
        _db = db;
    }

    public async Task<JobDto?> GetByIdAsync(int jobId)
    {
        var job = await _db.Jobs
            .Include(j => j.Department)
            .Include(j => j.PostedByUser)
            .FirstOrDefaultAsync(j => j.JobId == jobId);

        return job is null ? null : MapToDto(job);
    }

    public async Task<PagedResultDto<JobDto>> GetPagedAsync(int? departmentId, string? status, string? search, string? location, string? skills, bool includeExpired, int pageNumber, int pageSize)
    {
        var today = Knome.API.Common.KnomeTime.Today;
        var query = _db.Jobs
            .Include(j => j.Department)
            .Include(j => j.PostedByUser)
            .AsQueryable();

        if (departmentId.HasValue)
            query = query.Where(j => j.DepartmentId == departmentId.Value);
        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(j => j.Status == status);
        if (!string.IsNullOrWhiteSpace(search))
            query = query.Where(j => j.Title.Contains(search) || j.Description.Contains(search));
        if (!string.IsNullOrWhiteSpace(location))
            query = query.Where(j => j.Location != null && j.Location.Contains(location));
        if (!string.IsNullOrWhiteSpace(skills))
            query = query.Where(j => j.SkillsRequired != null && j.SkillsRequired.Contains(skills));
        if (!includeExpired)
            query = query.Where(j => j.ClosingDate >= today);

        var total = await query.CountAsync();
        var page = pageNumber < 1 ? 1 : pageNumber;
        var size = pageSize < 1 ? 20 : pageSize;

        var items = await query
            .OrderByDescending(j => j.PostedDate)
            .Skip((page - 1) * size)
            .Take(size)
            .ToListAsync();

        return new PagedResultDto<JobDto>(items.Select(MapToDto).ToList(), total, page, size);
    }

    public async Task<int> CloseExpiredJobsAsync(DateOnly today)
    {
        var expired = await _db.Jobs
            .Where(j => j.Status == "Open" && j.ClosingDate < today)
            .ToListAsync();

        foreach (var job in expired)
            job.Status = "Closed";

        if (expired.Count == 0)
            return 0;

        await _db.SaveChangesAsync();
        return expired.Count;
    }

    public async Task<JobDto> AddAsync(CreateJobDto dto, int postedByUserId)
    {
        var job = new Job
        {
            Title = dto.Title,
            DepartmentId = dto.DepartmentId,
            Description = dto.Description,
            SkillsRequired = dto.SkillsRequired,
            Location = dto.Location,
            ClosingDate = dto.ClosingDate,
            ApplicationLink = dto.ApplicationLink,
            PostedByUserId = postedByUserId,
            PostedDate = Knome.API.Common.KnomeTime.Now,
            Status = dto.Status
        };

        _db.Jobs.Add(job);
        await _db.SaveChangesAsync();
        return MapToDto(job);
    }

    public async Task<JobDto> UpdateAsync(int jobId, UpdateJobDto dto)
    {
        var job = await _db.Jobs.FirstOrDefaultAsync(j => j.JobId == jobId);
        if (job == null)
            throw new NotFoundException($"Job ID {jobId} not found.");

        if (dto.Title != null)
            job.Title = dto.Title;
        if (dto.DepartmentId.HasValue)
            job.DepartmentId = dto.DepartmentId.Value;
        if (dto.Description != null)
            job.Description = dto.Description;
        if (dto.SkillsRequired != null)
            job.SkillsRequired = dto.SkillsRequired;
        if (dto.Location != null)
            job.Location = dto.Location;
        if (dto.ClosingDate.HasValue)
            job.ClosingDate = dto.ClosingDate.Value;
        if (dto.ApplicationLink != null)
            job.ApplicationLink = dto.ApplicationLink;
        if (dto.Status != null)
            job.Status = dto.Status;

        await _db.SaveChangesAsync();
        return MapToDto(job);
    }

    public async Task<bool> DeleteAsync(int jobId)
    {
        var job = await _db.Jobs.FirstOrDefaultAsync(j => j.JobId == jobId);
        if (job == null)
            return false;

        _db.Jobs.Remove(job);
        await _db.SaveChangesAsync();
        return true;
    }

    private static JobDto MapToDto(Job job)
    {
        return new JobDto
        {
            JobId = job.JobId,
            Title = job.Title,
            DepartmentId = job.DepartmentId,
            DepartmentName = job.Department?.Name,
            Description = job.Description,
            SkillsRequired = job.SkillsRequired,
            Location = job.Location,
            ClosingDate = job.ClosingDate,
            ApplicationLink = job.ApplicationLink,
            PostedDate = job.PostedDate,
            Status = job.Status,
            PostedByUserId = job.PostedByUserId,
            PostedByFullName = job.PostedByUser?.FullName
        };
    }
}