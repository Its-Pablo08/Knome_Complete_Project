# ============================================================
# Setup Windows Scheduled Task for Knome Logs Archival (30 Days)
# ============================================================

$TaskName = "Knome_Logs_Archival_Scheduler"
$ScriptPath = "D:\Knome main\ARCHIVE_30_DAYS_LOGS.ps1"

Write-Host "Creating Scheduled Task: $TaskName..." -ForegroundColor Cyan

$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Action Move"

# Trigger: Runs Daily at 01:00 AM (checks for 30-day-old logs)
$Trigger = New-ScheduledTaskTrigger `
    -Daily `
    -At "01:00AM"

# Settings: Ensure it runs even if laptop on battery or wakes up
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -Description "Automated background archival of Knome Serilog logs older than 30 days to backup network share." `
    -Force | Out-Null

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "[OK] Task '$TaskName' registered successfully in Windows Task Scheduler!" -ForegroundColor Green
Write-Host "  -> Trigger: Daily at 01:00 AM (moves log files > 30 days old)" -ForegroundColor Gray
Write-Host "  -> Script:  $ScriptPath" -ForegroundColor Gray
Write-Host "  -> Target:  \\172.16.8.11\Services\INTERNSHIP 2.0\Higher_Education\Knowme Summary\quick links backup\logs backup" -ForegroundColor Gray
Write-Host "============================================================" -ForegroundColor Green
