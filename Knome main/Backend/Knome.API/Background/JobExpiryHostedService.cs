using System;
using System.Threading;
using System.Threading.Tasks;
using Knome.API.Interfaces;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Knome.API.Background;

/// <summary>
/// Periodically closes job postings whose closing date has passed (FR-JB-03 auto-expire).
/// </summary>
public class JobExpiryHostedService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<JobExpiryHostedService> _logger;
    private static readonly TimeSpan Interval = TimeSpan.FromHours(6);

    public JobExpiryHostedService(IServiceScopeFactory scopeFactory, ILogger<JobExpiryHostedService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var jobService = scope.ServiceProvider.GetRequiredService<IJobService>();
                var closed = await jobService.CloseExpiredJobsAsync();
                if (closed > 0)
                    _logger.LogInformation("JobExpiry: auto-closed {Count} expired job posting(s).", closed);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "JobExpiry: failed to process expired jobs.");
            }

            await Task.Delay(Interval, stoppingToken);
        }
    }
}