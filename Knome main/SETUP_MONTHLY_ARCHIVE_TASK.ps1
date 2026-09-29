# ============================================================
# Setup Windows Scheduled Task for Knome Uploads Archival
# ============================================================

$TaskName = "Knome_Uploads_Archival_Scheduler"
$ScriptPath = "D:\Knome main\ARCHIVE_3_MONTHS_UPLOADS.ps1"

Write-Host "Creating Scheduled Task: $TaskName..." -ForegroundColor Cyan

$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""

# Trigger: Runs every Monday at 02:00 AM (Weekly check for 90-day-old files)
$Trigger = New-ScheduledTaskTrigger `
    -Weekly `
    -DaysOfWeek Monday `
    -At "02:00AM"

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
    -Description "Automated background archival of Knome uploads older than 3 months (90 days) to backup network share." `
    -Force | Out-Null

Write-Host "`n[OK] Task '$TaskName' registered successfully in Windows Task Scheduler!" -ForegroundColor Green
Write-Host "  -> Trigger: Weekly on Sunday at 02:00 AM (checks & archives files > 90 days old)" -ForegroundColor Gray
Write-Host "  -> Target:  $ScriptPath" -ForegroundColor Gray
