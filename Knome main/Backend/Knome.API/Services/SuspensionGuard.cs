using Knome.API.Exceptions;
using Knome.API.Interfaces;
using Knome.API.Models;
using System.Threading.Tasks;

namespace Knome.API.Services;

/// <summary>
/// Single source of truth for account-suspension evaluation. Inject this into any
/// workflow that must reject suspended accounts instead of re-implementing the
/// suspension rule.
/// </summary>
public class SuspensionGuard : ISuspensionGuard
{
    private const string SuspendedMessage = "Your account is suspended by system admin.";

    private readonly IUserRepository _userRepository;

    public SuspensionGuard(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public bool IsSuspended(User user)
    {
        return user.IsPermanentlySuspended
            || (user.SuspendedUntil.HasValue && user.SuspendedUntil > Knome.API.Common.KnomeTime.Now);
    }

    public void EnsureNotSuspended(User user)
    {
        if (IsSuspended(user))
            throw new ForbiddenException(SuspendedMessage);
    }

    public async Task EnsureNotSuspendedAsync(int userId)
    {
        var user = await _userRepository.GetProfileByIdAsync(userId);
        if (user is null)
            throw new NotFoundException("User not found.");

        EnsureNotSuspended(user);
    }
}
