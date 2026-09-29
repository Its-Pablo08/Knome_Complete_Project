# =====================================================================
# KNOME + EMPLOYEEHUB — IIS QUICK UPDATE SCRIPT
# Run this after making code changes to rebuild and redeploy to IIS
# Run as Administrator
# =====================================================================

param(
    [switch]$KnomeOnly,
    [switch]$EmployeeHubOnly
)

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Run as Administrator!" -ForegroundColor Red; exit 1
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " KNOME + EMPLOYEEHUB — IIS UPDATE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ─── Update Knome ────────────────────────────────────────────────────
if (-not $EmployeeHubOnly) {
    Write-Host "`n[KNOME] Building frontend..." -ForegroundColor Yellow
    Push-Location "D:\Knome main\knomeUI\frontend"
    npm run build
    Pop-Location

    Write-Host "[KNOME] Deploying to IIS..." -ForegroundColor Yellow
    if (Test-Path "C:\inetpub\wwwroot\knome") { Remove-Item "C:\inetpub\wwwroot\knome" -Recurse -Force }
    New-Item -ItemType Directory -Path "C:\inetpub\wwwroot\knome" -Force | Out-Null
    Copy-Item -Path "D:\Knome main\knomeUI\frontend\dist\*" -Destination "C:\inetpub\wwwroot\knome\" -Recurse -Force
    Write-Host "[KNOME] ✓ Deployed to http://localhost:8080" -ForegroundColor Green
}

# ─── Update EmployeeHub ───────────────────────────────────────────────
if (-not $KnomeOnly) {
    Write-Host "`n[EMPLOYEEHUB] Building frontend..." -ForegroundColor Yellow
    Push-Location "D:\EmployeeHub\src\EmployeeHub.Web"
    npm run build
    Pop-Location

    Write-Host "[EMPLOYEEHUB] Deploying to IIS..." -ForegroundColor Yellow
    if (Test-Path "C:\inetpub\wwwroot\employeehub") { Remove-Item "C:\inetpub\wwwroot\employeehub" -Recurse -Force }
    New-Item -ItemType Directory -Path "C:\inetpub\wwwroot\employeehub" -Force | Out-Null
    Copy-Item -Path "D:\EmployeeHub\src\EmployeeHub.Web\dist\*" -Destination "C:\inetpub\wwwroot\employeehub\" -Recurse -Force
    Write-Host "[EMPLOYEEHUB] ✓ Deployed to http://localhost:8081" -ForegroundColor Green
}

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host " UPDATE COMPLETE!" -ForegroundColor Green
Write-Host "  Knome:        http://localhost:8080" -ForegroundColor Cyan
Write-Host "  EmployeeHub:  http://localhost:8081" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Green
