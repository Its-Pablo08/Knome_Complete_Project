using System;
using System.Collections.Generic;

namespace Knome.API.DTOs.Audit;

public class SystemLogEntryDto
{
    public string Timestamp { get; set; } = string.Empty;
    public string Level { get; set; } = "INF";
    public string SourceContext { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string? Exception { get; set; }
    public string Raw { get; set; } = string.Empty;
}

public class SystemLogCountsDto
{
    public int Total { get; set; }
    public int Errors { get; set; }
    public int Warnings { get; set; }
    public int Info { get; set; }
    public int Debug { get; set; }
}

public class SystemLogFileInfo
{
    public string FileName { get; set; } = string.Empty;
    public string RelativePath { get; set; } = string.Empty;
    public string Date { get; set; } = string.Empty;
    public string DateDisplay { get; set; } = string.Empty;
    public long SizeBytes { get; set; }
    public DateTime LastModified { get; set; }
    public bool IsActive { get; set; }
}

public class SystemLogDateGroupDto
{
    public string Date { get; set; } = string.Empty;
    public string DateDisplay { get; set; } = string.Empty;
    public int FileCount { get; set; }
    public long TotalSizeBytes { get; set; }
    public bool HasActiveFile { get; set; }
    public List<SystemLogFileInfo> Files { get; set; } = new();
}

public class SystemLogHourlyBucketDto
{
    public int Hour { get; set; }
    public string HourLabel { get; set; } = string.Empty;
    public int Total { get; set; }
    public int Info { get; set; }
    public int Warnings { get; set; }
    public int Errors { get; set; }
    public int Debug { get; set; }
}

public class SystemLogDaySummaryDto
{
    public string Date { get; set; } = string.Empty;
    public string DateDisplay { get; set; } = string.Empty;
    public int FileCount { get; set; }
    public long TotalSizeBytes { get; set; }
    public bool IsSelected { get; set; }
}

public class SystemLogGraphAnalyticsDto
{
    public List<SystemLogHourlyBucketDto> HourlyActivity { get; set; } = new();
    public List<SystemLogDaySummaryDto> DaySummaries { get; set; } = new();
    public double ErrorPercentage { get; set; }
    public double WarningPercentage { get; set; }
    public double InfoPercentage { get; set; }
    public string HealthStatus { get; set; } = "Optimal"; // Optimal, Warning, Degraded
    public int PeakHour { get; set; }
    public int PeakHourEvents { get; set; }
}

public class SystemLogResponseDto
{
    public string LogFileName { get; set; } = string.Empty;
    public string RelativePath { get; set; } = string.Empty;
    public string SelectedDate { get; set; } = string.Empty;
    public string SelectedDateDisplay { get; set; } = string.Empty;
    public int TotalScannedLines { get; set; }
    public int ReturnedCount { get; set; }
    public SystemLogCountsDto Counts { get; set; } = new();
    public List<SystemLogFileInfo> AvailableFiles { get; set; } = new();
    public List<SystemLogDateGroupDto> DateGroups { get; set; } = new();
    public SystemLogGraphAnalyticsDto Analytics { get; set; } = new();
    public List<SystemLogEntryDto> Entries { get; set; } = new();
}
