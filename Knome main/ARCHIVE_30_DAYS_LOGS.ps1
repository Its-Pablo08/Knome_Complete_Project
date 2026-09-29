param (
    [int]$AgeInDays = 30,
    [string]$SourcePath = "\\172.16.8.11\Services\INTERNSHIP 2.0\Higher_Education\Knowme Summary\quick links\knome\logs",
    [string]$ArchivePath = "\\172.16.8.11\Services\INTERNSHIP 2.0\Higher_Education\Knowme Summary\quick links backup\logs backup",
    [string]$Action = "Move"
)

Clear-Host
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " KNOME 30-DAY SERILOG LOGS ARCHIVAL UTILITY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Source (Live):    $SourcePath" -ForegroundColor Gray
Write-Host " Target (Archive): $ArchivePath" -ForegroundColor Gray
Write-Host " Archival Filter:  Files older than $AgeInDays days" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Verify Paths
if (-not (Test-Path $SourcePath)) {
    Write-Host "[ERROR] Live logs source path is unreachable: $SourcePath" -ForegroundColor Red
    Write-Host "Please ensure network/VPN is connected." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $ArchivePath)) {
    Write-Host "[INFO] Creating archive destination folder: $ArchivePath" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $ArchivePath -Force | Out-Null
}

$CutoffDate = (Get-Date).AddDays(-$AgeInDays)
$CutoffStr = $CutoffDate.ToString("dd-MMM-yyyy HH:mm:ss")
Write-Host "`nScanning for log files older than: $CutoffStr..." -ForegroundColor White

# 2. Identify Files Matching Criteria
$FilesToArchive = Get-ChildItem -Path $SourcePath -File -Filter "knome-*.log" | Where-Object {
    $_.LastWriteTime -lt $CutoffDate
}

$Count = ($FilesToArchive | Measure-Object).Count
if ($Count -eq 0) {
    Write-Host "`n[OK] No log files older than $AgeInDays days found in live logs folder." -ForegroundColor Green
    Write-Host "All current log files are within the active 30-day window." -ForegroundColor Gray
    exit 0
}

$TotalBytes = ($FilesToArchive | Measure-Object -Property Length -Sum).Sum
$TotalMB = [math]::Round($TotalBytes / 1MB, 2)
Write-Host "Found $Count file(s) [$TotalMB MB] ready for archival." -ForegroundColor Yellow

# 3. Move matching files to Archive directory
foreach ($file in $FilesToArchive) {
    $dest = Join-Path $ArchivePath $file.Name
    if ($Action -eq "Move") {
        Write-Host "  -> Moving: $($file.Name) ($([math]::Round($file.Length / 1MB, 2)) MB)" -ForegroundColor Gray
        Move-Item -Path $file.FullName -Destination $dest -Force
    } else {
        Write-Host "  -> Copying: $($file.Name) ($([math]::Round($file.Length / 1MB, 2)) MB)" -ForegroundColor Gray
        Copy-Item -Path $file.FullName -Destination $dest -Force
    }
}

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host " [OK] LOG ARCHIVAL COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "  -> Total Archived: $Count files [$TotalMB MB]" -ForegroundColor Green
Write-Host "  -> Destination:    $ArchivePath" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
