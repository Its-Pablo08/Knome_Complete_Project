# =====================================================================
# KNOME + EMPLOYEEHUB — IIS INTEGRATION SETUP SCRIPT
# RUN AS ADMINISTRATOR
# 
# Sets up:
#   Knome Frontend       → http://localhost:8080
#   EmployeeHub Frontend → http://localhost:8081
#
# Backends run as self-hosted .NET processes (unchanged):
#   Knome API           → http://localhost:5095
#   EmployeeHub Gateway → http://localhost:5000
#   EmployeeHub API     → http://localhost:5100
# =====================================================================

param(
    [string]$KnomeDistPath        = "D:\Knome main\knomeUI\frontend\dist",
    [string]$EmployeeHubDistPath  = "D:\EmployeeHub\src\EmployeeHub.Web\dist",
    [int]   $KnomePort            = 8080,
    [int]   $EmployeeHubPort      = 8081
)

# ─── Check Admin ────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Please run this script as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell → Run as Administrator, then re-run this script." -ForegroundColor Yellow
    exit 1
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " KNOME + EMPLOYEEHUB — IIS SETUP" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ─── Step 0: Install URL Rewrite Module if missing ──────────────────
$urlRewriteKey = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\IIS Extensions\URL Rewrite\Installer" -ErrorAction SilentlyContinue
if (-not $urlRewriteKey) {
    Write-Host "`n[0/6] Installing IIS URL Rewrite Module (required for SPA routing)..." -ForegroundColor Yellow
    $urlRewriteInstaller = "$env:TEMP\rewrite_amd64_en-US.msi"
    Write-Host "      Downloading from Microsoft..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" `
            -OutFile $urlRewriteInstaller -UseBasicParsing
        Write-Host "      Installing URL Rewrite..." -ForegroundColor Gray
        Start-Process msiexec.exe -ArgumentList "/i `"$urlRewriteInstaller`" /quiet /norestart" -Wait
        Write-Host "      ✓ URL Rewrite Module installed" -ForegroundColor Green
        Remove-Item $urlRewriteInstaller -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "      WARNING: Could not auto-install URL Rewrite. Download manually from:" -ForegroundColor Yellow
        Write-Host "      https://www.iis.net/downloads/microsoft/url-rewrite" -ForegroundColor Cyan
        Write-Host "      Continuing without URL Rewrite (direct URL navigation may not work)..." -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[0/6] URL Rewrite Module already installed ✓" -ForegroundColor Green
}

# ─── Step 1: Load WebAdministration ─────────────────────────────────
try {
    Import-Module WebAdministration -ErrorAction Stop
    Write-Host "[1/6] IIS WebAdministration module loaded ✓" -ForegroundColor Green
} catch {
    Write-Host "ERROR: IIS WebAdministration module not found." -ForegroundColor Red
    Write-Host "Make sure IIS is installed with 'IIS Management Console' feature." -ForegroundColor Yellow
    exit 1
}

# ─── Step 2: Copy dist files to inetpub ─────────────────────────────
$KnomeIISPath       = "C:\inetpub\wwwroot\knome"
$EmployeeHubIISPath = "C:\inetpub\wwwroot\employeehub"

Write-Host "`n[2/6] Copying Knome dist → $KnomeIISPath" -ForegroundColor Yellow
if (Test-Path $KnomeIISPath) { Remove-Item $KnomeIISPath -Recurse -Force }
New-Item -ItemType Directory -Path $KnomeIISPath -Force | Out-Null
Copy-Item -Path "$KnomeDistPath\*" -Destination $KnomeIISPath -Recurse -Force
Write-Host "      ✓ Knome files copied ($((Get-ChildItem $KnomeIISPath -Recurse | Measure-Object).Count) files)" -ForegroundColor Green

Write-Host "`n[3/6] Copying EmployeeHub dist → $EmployeeHubIISPath" -ForegroundColor Yellow
if (Test-Path $EmployeeHubIISPath) { Remove-Item $EmployeeHubIISPath -Recurse -Force }
New-Item -ItemType Directory -Path $EmployeeHubIISPath -Force | Out-Null
Copy-Item -Path "$EmployeeHubDistPath\*" -Destination $EmployeeHubIISPath -Recurse -Force
Write-Host "      ✓ EmployeeHub files copied ($((Get-ChildItem $EmployeeHubIISPath -Recurse | Measure-Object).Count) files)" -ForegroundColor Green

# ─── Step 3: Create App Pools ────────────────────────────────────────
Write-Host "`n[4/6] Creating IIS Application Pools..." -ForegroundColor Yellow

$pools = @{
    "KnomeAppPool"       = $KnomeIISPath
    "EmployeeHubAppPool" = $EmployeeHubIISPath
}

foreach ($pool in $pools.Keys) {
    if (Get-WebConfiguration "system.applicationHost/applicationPools/add[@name='$pool']") {
        Write-Host "      App Pool '$pool' already exists, updating..." -ForegroundColor Gray
        Stop-WebAppPool -Name $pool -ErrorAction SilentlyContinue
    } else {
        New-WebAppPool -Name $pool | Out-Null
    }
    Set-ItemProperty "IIS:\AppPools\$pool" -Name processModel.identityType -Value ApplicationPoolIdentity
    Set-ItemProperty "IIS:\AppPools\$pool" -Name managedRuntimeVersion     -Value ""  # Static files — no managed runtime
    Write-Host "      ✓ App Pool '$pool' ready" -ForegroundColor Green
}

# ─── Step 4: Create IIS Sites ────────────────────────────────────────
Write-Host "`n[5/6] Creating IIS Sites..." -ForegroundColor Yellow

# Remove old sites
foreach ($siteName in @("Knome", "EmployeeHub")) {
    if (Get-Website -Name $siteName -ErrorAction SilentlyContinue) {
        Write-Host "      Removing existing site '$siteName'..." -ForegroundColor Gray
        Stop-Website -Name $siteName -ErrorAction SilentlyContinue
        Remove-Website -Name $siteName
    }
}

# Create Knome Site
New-Website -Name "Knome" `
    -PhysicalPath $KnomeIISPath `
    -ApplicationPool "KnomeAppPool" `
    -Port $KnomePort `
    -IPAddress "*" `
    -Force | Out-Null
Write-Host "      ✓ Knome site: http://localhost:$KnomePort" -ForegroundColor Green

# Create EmployeeHub Site
New-Website -Name "EmployeeHub" `
    -PhysicalPath $EmployeeHubIISPath `
    -ApplicationPool "EmployeeHubAppPool" `
    -Port $EmployeeHubPort `
    -IPAddress "*" `
    -Force | Out-Null
Write-Host "      ✓ EmployeeHub site: http://localhost:$EmployeeHubPort" -ForegroundColor Green

# ─── Step 5: Start Sites ─────────────────────────────────────────────
Write-Host "`n[6/6] Starting IIS Sites..." -ForegroundColor Yellow
Start-WebAppPool -Name "KnomeAppPool"
Start-WebAppPool -Name "EmployeeHubAppPool"
Start-Website -Name "Knome"
Start-Website -Name "EmployeeHub"

# ─── Verify ──────────────────────────────────────────────────────────
Start-Sleep -Seconds 2
$knomeStatus = (Get-Website -Name "Knome").State
$ehStatus    = (Get-Website -Name "EmployeeHub").State
Write-Host "      Knome site status:       $knomeStatus" -ForegroundColor $(if ($knomeStatus -eq "Started") { "Green" } else { "Red" })
Write-Host "      EmployeeHub site status: $ehStatus"    -ForegroundColor $(if ($ehStatus    -eq "Started") { "Green" } else { "Red" })

# ─── Final Summary ───────────────────────────────────────────────────
Write-Host "`n============================================================" -ForegroundColor Green
Write-Host " IIS SETUP COMPLETE!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  Knome Portal:        http://localhost:$KnomePort" -ForegroundColor Cyan
Write-Host "  EmployeeHub Portal:  http://localhost:$EmployeeHubPort" -ForegroundColor Cyan
Write-Host "" 
Write-Host " IMPORTANT: Also run the backend START scripts:" -ForegroundColor Yellow
Write-Host "  Knome:        & 'D:\Knome main\START_KNOME.ps1'" -ForegroundColor White
Write-Host "  EmployeeHub:  & 'D:\EmployeeHub\START_EMPLOYEEHUB.ps1'" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host " To UPDATE after code changes, run:" -ForegroundColor Yellow
Write-Host "  & 'D:\Knome main\UPDATE_IIS.ps1'" -ForegroundColor Cyan
