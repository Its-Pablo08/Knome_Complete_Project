param (
    [int]$AgeInDays = 90,
    [string]$SourcePath = "\\172.16.8.11\Services\INTERNSHIP 2.0\Higher_Education\Knowme Summary\quick links\knome\uploads",
    [string]$ArchivePath = "\\172.16.8.11\Services\INTERNSHIP 2.0\Higher_Education\Knowme Summary\quick links backup\knome backup\uploads",
    [switch]$MoveFiles = $false
)

Clear-Host
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " KNOME 3-MONTH UPLOADS ARCHIVAL UTILITY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Source (Live):    $SourcePath" -ForegroundColor Gray
Write-Host " Target (Archive): $ArchivePath" -ForegroundColor Gray
Write-Host " Archival Filter:  Files older than $AgeInDays days (3 Months)" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Verify Paths
if (-not (Test-Path $SourcePath)) {
    Write-Host "[ERROR] Live uploads source path is unreachable: $SourcePath" -ForegroundColor Red
    Write-Host "Please ensure network/VPN is connected." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $ArchivePath)) {
    Write-Host "[INFO] Creating archive destination folder: $ArchivePath" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $ArchivePath -Force | Out-Null
}

$CutoffDate = (Get-Date).AddDays(-$AgeInDays)
$CutoffStr = $CutoffDate.ToString("dd-MMM-yyyy HH:mm:ss")
Write-Host "`nScanning for files created or modified before: $CutoffStr..." -ForegroundColor White

# 2. Preview Files Matching Criteria
$FilesToArchive = Get-ChildItem -Path $SourcePath -Recurse -File | Where-Object {
    $_.LastWriteTime -lt $CutoffDate
}

$Count = ($FilesToArchive | Measure-Object).Count
if ($Count -eq 0) {
    Write-Host "`n[OK] No files older than $AgeInDays days found in live uploads folder." -ForegroundColor Green
    Write-Host "All current files are within the active 3-month window." -ForegroundColor Gray
    exit 0
}

$TotalBytes = ($FilesToArchive | Measure-Object -Property Length -Sum).Sum
$TotalMB = [math]::Round($TotalBytes / 1MB, 2)

Write-Host "Found $Count file(s) [$TotalMB MB] ready for archival." -ForegroundColor Yellow

# 3. Execute Archival via Robocopy with /MINAGE filter
if ($MoveFiles) {
    Write-Host "`n[MODE: MOVE] Archiving and moving old files to backup..." -ForegroundColor Yellow
    robocopy "$SourcePath" "$ArchivePath" /E /MINAGE:$AgeInDays /MOV /R:2 /W:2 | Out-Null
} else {
    Write-Host "`n[MODE: COPY] Archiving old files (preserving live copy)..." -ForegroundColor Cyan
    robocopy "$SourcePath" "$ArchivePath" /E /MINAGE:$AgeInDays /R:2 /W:2 | Out-Null
}

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host " [OK] ARCHIVAL COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "  -> Total Archived: $Count files [$TotalMB MB]" -ForegroundColor Green
Write-Host "  -> Location:       $ArchivePath" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
