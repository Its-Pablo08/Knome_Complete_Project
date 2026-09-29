using Knome.API.DTOs.Auth;

namespace Knome.API.Interfaces;

/// <summary>
/// Defines the authentication contract.
/// The current implementation uses EmployeeID + BCrypt password.
/// This interface is designed to be swapped for HRMS SSO without touching
/// controllers or the authorization pipeline.
/// </summary>
public interface IAuthService
{
    Task<LoginResponseDto> LoginAsync(LoginRequestDto request);
    Task<CurrentUserDto> GetCurrentUserAsync(int userId);
    Task<CurrentUserDto> GetCurrentUserByIdentifierAsync(string identifier);
}
