using Knome.API.Constants;
using Knome.API.DTOs.Auth;
using Knome.API.Interfaces;
using Knome.API.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace Knome.API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : KnomeControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    /// <summary>
    /// Authenticate using Employee ID and password. Returns a JWT token.
    /// </summary>
    [HttpPost("login")]
    [EnableRateLimiting("LoginRateLimiter")]
    [ProducesResponseType(typeof(ApiResponse<LoginResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
    {
        var result = await _authService.LoginAsync(request);
        return Ok(ApiResponse<LoginResponseDto>.SuccessResponse(200, "Login successful.", result));
    }

    /// <summary>
    /// Invalidate the current session. The client must discard the token.
    /// </summary>
    [HttpPost("logout")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status200OK)]
    public IActionResult Logout([FromBody] LogoutRequestDto? request = null)
    {
        // JWT is stateless — logout is handled client-side by discarding the token.
        // When HRMS SSO is integrated, this endpoint will call the SSO logout flow.
        return Ok(ApiResponse.SuccessResponse(200, "Logged out successfully."));
    }

    /// <summary>
    /// Returns the authenticated user's profile derived from the JWT claims.
    /// Supports both Knome symmetric tokens and MPO OIDC RS256 tokens.
    /// </summary>
    [HttpGet("me")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<CurrentUserDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Me()
    {
        // 1. Check for numeric UserId in uid, NameIdentifier or sub claim
        var uidClaim = User.FindFirst("uid")?.Value
                    ?? User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
                    ?? User.FindFirst("sub")?.Value;

        var emailClaim = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value
                      ?? User.FindFirst("email")?.Value
                      ?? User.FindFirst(System.Security.Claims.ClaimTypes.Name)?.Value
                      ?? User.FindFirst("name")?.Value;

        var empIdClaim = User.FindFirst("employeeId")?.Value
                      ?? User.FindFirst("empId")?.Value;

        CurrentUserDto? currentUser = null;

        if (int.TryParse(uidClaim, out var userId))
        {
            currentUser = await _authService.GetCurrentUserAsync(userId);
        }
        else
        {
            var identifier = emailClaim ?? empIdClaim ?? uidClaim;
            if (string.IsNullOrEmpty(identifier))
                return Unauthorized(ApiResponse.FailureResponse(401, "Invalid token: Missing identity claims."));

            currentUser = await _authService.GetCurrentUserByIdentifierAsync(identifier);
        }

        return Ok(ApiResponse<CurrentUserDto>.SuccessResponse(200, ApiConstants.Messages.Success, currentUser));
    }
}
