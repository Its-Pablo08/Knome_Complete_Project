using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;
using Serilog;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

try
{
    var builder = WebApplication.CreateBuilder(args);

    builder.Host.UseSerilog((context, services, configuration) => configuration
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext());

    // Add YARP Reverse Proxy services
    builder.Services.AddReverseProxy()
        .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

// Add Swagger / OpenAPI for Gateway diagnostic endpoints
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "Knome API Gateway (YARP)",
        Version = "v1",
        Description = "Layer 3 API Gateway & Layer 4 YARP Reverse Proxy for Knome Platform"
    });
});

// Configure CORS for Next.js BFF & React UI
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontendAndBff", policy =>
    {
        policy.WithOrigins("http://localhost:3000", "http://localhost:5173", "http://localhost:3001")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Gateway Rate Limiter
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("GatewayRatePolicy", opt =>
    {
        opt.PermitLimit = 100;
        opt.Window = TimeSpan.FromMinutes(1);
        opt.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        opt.QueueLimit = 10;
    });
});

var app = builder.Build();

// Enable Swagger UI on Gateway
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "Knome API Gateway v1"));
}

app.UseSerilogRequestLogging();
app.UseCors("AllowFrontendAndBff");
app.UseRateLimiter();

// Health Check Endpoint
app.MapGet("/health", () => Results.Ok(new
{
    Status = "Healthy",
    Layer = "Layer 3 API Gateway & Layer 4 YARP",
    Timestamp = DateTime.UtcNow
}));

// Map YARP endpoints
app.MapReverseProxy();

app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Gateway host terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
