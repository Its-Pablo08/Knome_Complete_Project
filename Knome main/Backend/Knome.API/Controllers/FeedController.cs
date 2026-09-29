using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Knome.API.Constants;
using Knome.API.DTOs.Feed;
using Knome.API.Exceptions;
using Knome.API.Interfaces;
using Knome.API.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Knome.API.Controllers;

[ApiController]
[Route("api/feed")]
[Authorize]
public class FeedController : KnomeControllerBase
{
    private readonly IFeedService _feedService;

    public FeedController(IFeedService feedService)
    {
        _feedService = feedService;
    }

    [HttpGet("home")]
    [ProducesResponseType(typeof(ApiResponse<List<FeedItemDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetPersonalizedHomeFeed([FromQuery] string? contentType = null, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20)
    {
        var result = await _feedService.GetPersonalizedFeedAsync(GetCurrentUserId(), contentType, pageNumber, pageSize);
        return Ok(ApiResponse<List<FeedItemDto>>.SuccessResponse(200, "Personalized home feed retrieved successfully.", result));
    }

    [HttpGet("hot")]
    [ProducesResponseType(typeof(ApiResponse<List<FeedItemDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetHotFeed([FromQuery] string window = FeedWindows.Daily, [FromQuery] int top = 10)
    {
        var result = await _feedService.GetHotFeedAsync(GetCurrentUserId(), window, top);
        return Ok(ApiResponse<List<FeedItemDto>>.SuccessResponse(200, $"Hot posts ({window}) retrieved successfully.", result));
    }

    [HttpGet("dashboard")]
    [ProducesResponseType(typeof(ApiResponse<DashboardSummaryDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetDashboardSummary()
    {
        var result = await _feedService.GetDashboardSummaryAsync(GetCurrentUserId());
        return Ok(ApiResponse<DashboardSummaryDto>.SuccessResponse(200, "Dashboard summary retrieved successfully.", result));
    }
}
