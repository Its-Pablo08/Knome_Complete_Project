using System.Security.Claims;
using Knome.API.Exceptions;
using Microsoft.AspNetCore.Mvc;

namespace Knome.API.Controllers;

/// <summary>
/// Base controller class for all Knome API controllers.
/// Provides unified JWT identity resolution (F-013) to prevent code duplication
/// across the 13+ controllers needing user extraction.
/// </summary>
[ApiController]
public abstract class KnomeControllerBase : ControllerBase
{
    /// <summary>
    /// Extracts the authenticated user ID from the JWT token claims.
    /// Uses dual-fallback check (ClaimTypes.NameIdentifier -> "sub") to ensure consistency across all auth schemes.
    /// </summary>
    protected int GetCurrentUserId()
    {
        var uidClaim = User.FindFirst("uid");
        if (uidClaim != null && int.TryParse(uidClaim.Value, out var uid))
        {
            return uid;
        }

        var claim = User.FindFirst(ClaimTypes.NameIdentifier);
        if (claim != null && int.TryParse(claim.Value, out var userId))
        {
            return userId;
        }

        var subClaim = User.FindFirst("sub");
        if (subClaim != null && int.TryParse(subClaim.Value, out var subUserId))
        {
            return subUserId;
        }

        throw new UnauthorizedException("User identity not found in token.");
    }
}
