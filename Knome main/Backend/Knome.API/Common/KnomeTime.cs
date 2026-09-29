using System;

namespace Knome.API.Common;

/// <summary>
/// Centralized enterprise time provider ensuring all Knome backend timestamps
/// are recorded in Indian Standard Time (IST, UTC+05:30) matching the local server/laptop clock.
/// </summary>
public static class KnomeTime
{
    private static readonly TimeZoneInfo IstZone;

    static KnomeTime()
    {
        try
        {
            IstZone = TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
        }
        catch
        {
            try
            {
                IstZone = TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
            }
            catch
            {
                IstZone = TimeZoneInfo.CreateCustomTimeZone("IST", TimeSpan.FromHours(5.5), "India Standard Time", "India Standard Time");
            }
        }
    }

    /// <summary>
    /// Current date and time in Indian Standard Time (IST, UTC+05:30)
    /// </summary>
    public static DateTime Now => TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, IstZone);

    /// <summary>
    /// Current date in Indian Standard Time (IST, UTC+05:30)
    /// </summary>
    public static DateOnly Today => DateOnly.FromDateTime(Now);
}
