using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Knome.API.Hubs;

public class NotificationHub : Hub
{
    public override async Task OnConnectedAsync()
    {
        var userIdClaim = Context.User?.FindFirst("uid")?.Value
            ?? Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value
            ?? Context.User?.FindFirst("sub")?.Value;

        if (int.TryParse(userIdClaim, out var userId))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"User_{userId}");
        }
        else
        {
            var identifier = Context.User?.FindFirst(ClaimTypes.Email)?.Value
                ?? Context.User?.FindFirst("email")?.Value
                ?? Context.User?.FindFirst("employeeId")?.Value
                ?? Context.User?.FindFirst("empId")?.Value;

            if (!string.IsNullOrEmpty(identifier))
            {
                var httpContext = Context.GetHttpContext();
                if (httpContext != null)
                {
                    var authService = httpContext.RequestServices.GetService<Knome.API.Interfaces.IAuthService>();
                    if (authService != null)
                    {
                        try
                        {
                            var currentUserDto = await authService.GetCurrentUserByIdentifierAsync(identifier);
                            if (currentUserDto != null && currentUserDto.UserId > 0)
                            {
                                await Groups.AddToGroupAsync(Context.ConnectionId, $"User_{currentUserDto.UserId}");
                            }
                        }
                        catch { }
                    }
                }
            }
        }

        await base.OnConnectedAsync();
    }

    public async Task JoinUserGroup(int userId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"User_{userId}");
    }

    public async Task LeaveUserGroup(int userId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"User_{userId}");
    }
}
