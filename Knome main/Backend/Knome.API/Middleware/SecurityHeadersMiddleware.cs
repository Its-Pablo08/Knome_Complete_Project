using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace Knome.API.Middleware;

public class SecurityHeadersMiddleware
{
    private readonly RequestDelegate _next;

    public SecurityHeadersMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var headers = context.Response.Headers;

        if (!headers.ContainsKey("X-Content-Type-Options"))
            headers["X-Content-Type-Options"] = "nosniff";

        if (!context.Request.Path.StartsWithSegments("/uploads"))
        {
            if (!headers.ContainsKey("X-Frame-Options"))
                headers["X-Frame-Options"] = "SAMEORIGIN";

            if (!headers.ContainsKey("Content-Security-Policy"))
                headers["Content-Security-Policy"] = "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: blob: http://localhost:5173 http://localhost:3000 http://localhost:5000 http://localhost:5095 http://localhost:5096; frame-ancestors 'self' http://localhost:5173 http://localhost:3000 http://localhost:5000 http://localhost:5095 http://localhost:5096;";
        }

        if (!headers.ContainsKey("X-XSS-Protection"))
            headers["X-XSS-Protection"] = "1; mode=block";

        if (!headers.ContainsKey("Referrer-Policy"))
            headers["Referrer-Policy"] = "strict-origin-when-cross-origin";

        if (!headers.ContainsKey("Permissions-Policy"))
            headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()";

        await _next(context);
    }
}
