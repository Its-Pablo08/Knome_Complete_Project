using System;
using Knome.API.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;

namespace Knome.API;

public class Program
{
    public static int Main(string[] args)
    {
        // Configure Serilog bootstrap logger
        Log.Logger = new LoggerConfiguration()
            .WriteTo.Console()
            .CreateBootstrapLogger();

        try
        {
            Log.Information("Starting Knome API Host...");

            var builder = WebApplication.CreateBuilder(args);

            // Configure Kestrel to allow large file uploads (500 MB)
            builder.WebHost.ConfigureKestrel(options =>
            {
                options.Limits.MaxRequestBodySize = 500L * 1024L * 1024L;
            });

            // Configure Serilog as the logging provider
            builder.Host.UseSerilog((context, services, configuration) => configuration
                .ReadFrom.Configuration(context.Configuration)
                .ReadFrom.Services(services)
                .Enrich.FromLogContext()
                .Enrich.With<Knome.API.Logging.PiiScrubbingEnricher>());

            // Register infrastructure services (CORS, DbContext, Repository, AutoMapper, FluentValidation, Swagger)
            builder.Services.AddInfrastructure(builder.Configuration);

            // Background workers
            builder.Services.AddHostedService<Knome.API.Background.JobExpiryHostedService>();
            builder.Services.AddHostedService<Knome.API.Background.DataArchivalHostedService>();
            builder.Services.AddHostedService<Knome.API.Background.ScheduledPostHostedService>();

            var app = builder.Build();

            // Configure the HTTP request pipeline
            app.UseInfrastructure();

            app.Run();

            return 0;
        }
        catch (Exception ex)
        {
            Log.Fatal(ex, "Host terminated unexpectedly");
            return 1;
        }
        finally
        {
            Log.CloseAndFlush();
        }
    }
}
