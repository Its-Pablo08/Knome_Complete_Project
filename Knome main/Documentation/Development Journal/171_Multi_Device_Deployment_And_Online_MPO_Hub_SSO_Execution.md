# Development Journal Entry 171: Multi-Device Deployment & Online MPO Hub SSO Execution

**Date:** 2026-09-28  
**Feature/Module:** Multi-Laptop Deployment / Online MPO Employee Hub SSO Integration  
**Type:** Platform Configuration, SSO Routing & Deployment Runbook  

---

## 1. Problem Description & Background

The objective is to run the Knome Enterprise Knowledge Platform on another laptop seamlessly and authenticate completely through the official online **MPO Employee Hub** (`https://counselling-1.mponline.demo.gov.in:3001/applications`) without encountering any connection refused, redirect loop, or database errors.

### Potential Failure Points Identified & Addressed:
1. **Hardcoded Machine Name in Database Connection**:
   - `Backend/Knome.API/appsettings.json` and `appsettings.Development.json` had `Server=LAPTOP-458;`, which fails on any other machine.
2. **SSO Redirection to Local Dev Ports (5001/8081)**:
   - `Login.jsx` was checking `isLocal = host === 'localhost'` and redirecting to `http://localhost:5001/login`, causing `ERR_CONNECTION_REFUSED` because the user is authenticating through the official online MPO Hub website (`https://counselling-1.mponline.demo.gov.in:3001`), not a local mock hub.
3. **Missing `/sso-callback` Route**:
   - MPO Hub SSO client registration uses both `/sso` and `/sso-callback`. If MPO Hub bounced to `/sso-callback?token=...`, React Router hit the wildcard fallback and dropped the authentication handshake.
4. **First-Time Launch Missing Dependencies**:
   - On a fresh laptop, `node_modules` is not yet installed. Running `START_KNOME.bat` would silently fail the frontend background job.

---

## 2. Changes Implemented

### 1. Database Connection Universalization
- **Files Modified**:
  - `Backend/Knome.API/appsettings.json`
  - `Backend/Knome.API/appsettings.Development.json`
- **Change**: Replaced `Server=LAPTOP-458;` with `Server=localhost;`. Tested and verified that `localhost` connects successfully to SQL Server.

### 2. SSO Redirection to Online MPO Hub
- **File Modified**: `knomeUI/frontend/src/pages/Login.jsx`
- **Change**: Updated `getSsoUrls()` to default `ehBase` to `https://counselling-1.mponline.demo.gov.in:3001`. Added support for `window.__USE_LOCAL_EH__` / `localStorage` override for local testing if ever required.

### 3. Dual SSO Route Support
- **File Modified**: `knomeUI/frontend/src/App.jsx`
- **Change**: Added `<Route path="/sso-callback" element={<SsoPage />} />` alongside `<Route path="/sso" element={<SsoPage />} />`.

### 4. Self-Healing Platform Launcher
- **File Modified**: `START_KNOME.ps1`
- **Change**: Added automatic dependency check:
  - Detects if `knomeUI/frontend/node_modules` exists; if missing, automatically runs `npm install`.
  - Performs an upfront SQL Server connectivity test to `Knome` on `localhost` and displays clear diagnostic feedback.

---

## 3. Step-by-Step Setup Guide on the Other Laptop

### Step 1: Install Software Prerequisites
Ensure the other laptop has:
1. **.NET 10 SDK**: `dotnet --version`
2. **Node.js (v18+ or v20+) & npm**: `node -v`
3. **Microsoft SQL Server (2019/2022 or Express)** with SSMS or sqlcmd

### Step 2: Restore the Knome Database
Open **SQL Server Management Studio (SSMS)** or PowerShell as Administrator and run:

```sql
RESTORE DATABASE [Knome]
FROM DISK = 'D:\Knome main\Database\Knome_Full_Backup.bak'
WITH REPLACE, RECOVERY;
```
*(Adjust the file path if cloned into another drive or directory).*

Ensure the `sa` user login is enabled with password `sa@123`, or update `ConnectionStrings:DefaultConnection` in `Backend/Knome.API/appsettings.json` with Windows Authentication (`Trusted_Connection=True`).

### Step 3: Start Knome Services
Open terminal in the project directory and run:

```powershell
.\START_KNOME.bat
```
This automatically:
- Installs frontend packages (`npm install`) if run for the first time.
- Verifies SQL Server database access.
- Launches Knome Backend API on `http://localhost:5095`.
- Launches Knome Frontend UI on `http://localhost:5173`.

### Step 4: Login via Online MPO Employee Hub
1. Open your browser on the other laptop.
2. Navigate to: **`https://counselling-1.mponline.demo.gov.in:3001/applications`**
3. Log in with your MPO credentials.
4. Click on the **Knome** application card.
5. The portal will redirect back to `http://localhost:5173/sso?token=...`, validate your credentials, auto-provision your Knome account, and grant access to the full Knome dashboard.

---

## 4. Verification

- `dotnet build -nologo` in `Backend/Knome.API`: 0 errors.
- `npm run build` in `knomeUI/frontend`: built successfully in 1.34s.
- IIS webroot bundle deployed to `C:\inetpub\wwwroot\knome`.
