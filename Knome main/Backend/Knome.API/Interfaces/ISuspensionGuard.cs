using Knome.API.Models;

namespace Knome.API.Interfaces;

/// <summary>
/// Centralized suspension validation reused across all content creation and
/// governance workflows. Eliminates duplicated suspension checks that previously
/// lived inline in individual services (e.g. AuthService, UserRepository).
/// </summary>
public interface ISuspensionGuard
{
    /// <summary>True when the user is currently suspended (permanent or time-bound).</summary>
    bool IsSuspended(User user);

    /// <summary>Throws <see cref="Exceptions.ForbiddenException"/> when the user is suspended.</summary>
    void EnsureNotSuspended(User user);

    /// <summary>Loads the user by id and throws when suspended or not found.</summary>
    Task EnsureNotSuspendedAsync(int userId);
}
