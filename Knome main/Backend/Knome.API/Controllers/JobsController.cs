using System.Security.Claims;
using System.Threading.Tasks;
using Knome.API.Constants;
using Knome.API.DTOs.Jobs;
using Knome.API.DTOs.User;
using Knome.API.Exceptions;
using Knome.API.Interfaces;
using Knome.API.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Knome.API.Controllers;

[ApiController]
[Route("api/jobs")]
[Authorize]
public class JobsController : KnomeControllerBase
{
    private readonly IJobService _jobService;

    public JobsController(IJobService jobService)
    {
        _jobService = jobService;
    }

    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<PagedResultDto<JobDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetJobs(
        [FromQuery] int? departmentId,
        [FromQuery] string? status,
        [FromQuery] string? search,
        [FromQuery] string? location,
        [FromQuery] string? skills,
        [FromQuery] bool includeExpired = false,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20)
    {
        var result = await _jobService.GetPagedAsync(departmentId, status, search, location, skills, includeExpired, pageNumber, pageSize);
        return Ok(ApiResponse<PagedResultDto<JobDto>>.SuccessResponse(200, "Jobs retrieved successfully.", result));
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<JobDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetJob(int id)
    {
        var job = await _jobService.GetByIdAsync(id);
        if (job is null)
            throw new NotFoundException($"Job ID {id} not found.");
        return Ok(ApiResponse<JobDto>.SuccessResponse(200, "Job retrieved successfully.", job));
    }

    [HttpPost]
    [Authorize(Roles = Roles.HRAdmin + "," + Roles.SystemAdmin)]
    [ProducesResponseType(typeof(ApiResponse<JobDto>), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateJob([FromBody] CreateJobDto dto)
    {
        var created = await _jobService.CreateAsync(dto, GetCurrentUserId());
        return CreatedAtAction(nameof(GetJob), new { id = created.JobId }, ApiResponse<JobDto>.SuccessResponse(201, "Job created successfully.", created));
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.HRAdmin + "," + Roles.SystemAdmin)]
    [ProducesResponseType(typeof(ApiResponse<JobDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> UpdateJob(int id, [FromBody] UpdateJobDto dto)
    {
        var updated = await _jobService.UpdateAsync(id, dto);
        return Ok(ApiResponse<JobDto>.SuccessResponse(200, "Job updated successfully.", updated));
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.HRAdmin + "," + Roles.SystemAdmin)]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    public async Task<IActionResult> DeleteJob(int id)
    {
        var deleted = await _jobService.DeleteAsync(id);
        return Ok(ApiResponse<bool>.SuccessResponse(200, "Job deleted successfully.", deleted));
    }
}