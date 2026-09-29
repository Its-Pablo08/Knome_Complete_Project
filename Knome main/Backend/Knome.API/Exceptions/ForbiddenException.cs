namespace Knome.API.Exceptions;

/// <summary>
/// Raised when an authenticated user is not permitted to perform an action
/// (e.g. a suspended account attempting to create content). Maps to HTTP 403.
/// </summary>
public class ForbiddenException : Exception
{
    public ForbiddenException(string message) : base(message)
    {
    }
}
