# IIS Deployment Guide — Knome & EmployeeHub

> **Comprehensive deployment manual for hosting Knome Enterprise Knowledge Platform and EmployeeHub on Internet Information Services (IIS) across any Windows PC / Server.**

---

## 1. System Architecture & Topology

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Windows Host / Server                            │
│                                                                             │
│  ┌───────────────────────────────┐       ┌───────────────────────────────┐  │
│  │   IIS Site: Knome             │       │   IIS Site: EmployeeHub       │  │
│  │   Port: 8080                  │       │   Port: 8081                  │  │
│  │   Physical Path:              │       │   Physical Path:              │  │
│  │   C:\inetpub\wwwroot\knome    │       │   C:\inetpub\wwwroot\employee │  │
│  │   AppPool: KnomeAppPool       │       │   AppPool: EmployeeHubAppPool │  │
│  └──────────────┬────────────────┘       └──────────────┬────────────────┘  │
│                 │                                       │                   │
│                 ▼                                       ▼                   │
│  ┌───────────────────────────────┐       ┌───────────────────────────────┐  │
│  │   Knome Backend API           │       │   EmployeeHub Gateway (YARP)  │  │
│  │   Port: 5095 (ASP.NET Core)   │       │   Port: 5000 (ASP.NET Core)   │  │
│  │   Database: Knome (SQL Server)│       │   Database: EmployeeHub       │  │
│  └───────────────────────────────┘       └───────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Prerequisites & Software Requirements

Before setting up on a new laptop/server, install the following:

1. **Windows OS**: Windows 10 / 11 (Pro / Enterprise) or Windows Server 2019 / 2022.
2. **IIS (Internet Information Services)**:
   - Enable via **Turn Windows features on or off** (or PowerShell):
     ```powershell
     Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-ManagementConsole -All
     ```
3. **.NET SDK**: .NET 10.0 (or .NET 9.0/8.0 as required by the backend solutions).
4. **Node.js & npm**: Node.js v18+ or v20+ LTS.
5. **MS SQL Server**: SQL Server 2019 / 2022 (or Express) with database seeded.

---

## 3. Step-by-Step Deployment Instructions

### Step 1: Clone Repositories & Verify Paths
Ensure both repositories are placed on your machine (e.g., `D:\Knome main` and `D:\EmployeeHub`).

```powershell
# Set directory locations
$KnomeDir = "D:\Knome main"
$EHDir    = "D:\EmployeeHub"
```

---

### Step 2: Configure Backend API Settings

In `Backend/Knome.API/appsettings.json`, ensure **`AllowedHosts`** is set to `*` to allow requests from both `localhost` and Network IP addresses (e.g. `172.16.x.x`):

```json
{
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=Knome;Trusted_Connection=true;TrustServerCertificate=true;"
  }
}
```

---

### Step 3: Build the Frontends for Production

Generate the optimized production builds for both SPAs:

```powershell
# 1. Build Knome Frontend
cd "D:\Knome main\knomeUI\frontend"
npm install
npm run build
# Output will be generated at: D:\Knome main\knomeUI\frontend\dist

# 2. Build EmployeeHub Frontend
cd "D:\EmployeeHub\src\EmployeeHub.Web"
npm install
npm run build
# Output will be generated at: D:\EmployeeHub\src\EmployeeHub.Web\dist
```

---

### Step 4: Add `web.config` for React Router SPA Support

Create `web.config` inside each build output folder (`dist/`) so that direct URL navigation and page reloads do not return `404 Not Found`:

#### `D:\Knome main\knomeUI\frontend\dist\web.config` & `D:\EmployeeHub\src\EmployeeHub.Web\dist\web.config`

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <!-- Register MIME Types for Modern Web Assets -->
    <staticContent>
      <remove fileExtension=".js" />
      <mimeMap fileExtension=".js"    mimeType="application/javascript" />
      <remove fileExtension=".mjs" />
      <mimeMap fileExtension=".mjs"   mimeType="application/javascript" />
      <remove fileExtension=".json" />
      <mimeMap fileExtension=".json"  mimeType="application/json" />
      <remove fileExtension=".css" />
      <mimeMap fileExtension=".css"   mimeType="text/css" />
      <remove fileExtension=".svg" />
      <mimeMap fileExtension=".svg"   mimeType="image/svg+xml" />
      <remove fileExtension=".woff" />
      <mimeMap fileExtension=".woff"  mimeType="font/woff" />
      <remove fileExtension=".woff2" />
      <mimeMap fileExtension=".woff2" mimeType="font/woff2" />
      <remove fileExtension=".webp" />
      <mimeMap fileExtension=".webp"  mimeType="image/webp" />
      <remove fileExtension=".pdf" />
      <mimeMap fileExtension=".pdf"   mimeType="application/pdf" />
    </staticContent>

    <!-- Default Landing Page -->
    <defaultDocument>
      <files>
        <clear />
        <add value="index.html" />
      </files>
    </defaultDocument>

    <!-- Client-Side Routing Fallback (SPA Support) -->
    <httpErrors errorMode="Custom" existingResponse="Replace">
      <remove statusCode="404" subStatusCode="-1" />
      <error statusCode="404" path="index.html" responseMode="File" />
    </httpErrors>
  </system.webServer>
</configuration>
```

---

### Step 5: Run the Automated IIS Setup Script

Open **PowerShell as Administrator** and execute [`SETUP_IIS.ps1`](file:///D:/Knome%20main/SETUP_IIS.ps1):

```powershell
& "D:\Knome main\SETUP_IIS.ps1"
```

#### What the automated script does:
1. Copies all static files to `C:\inetpub\wwwroot\knome` and `C:\inetpub\wwwroot\employeehub`.
2. Creates isolated IIS Application Pools:
   - `KnomeAppPool` (No Managed Runtime, Static Files)
   - `EmployeeHubAppPool` (No Managed Runtime, Static Files)
3. Creates and starts IIS Web Sites:
   - **Knome**: Port **`8080`** (`http://*:8080`)
   - **EmployeeHub**: Port **`8081`** (`http://*:8081`)

---

### Step 6: Configure Windows Firewall

To allow other laptops/phones connected to the same WiFi or LAN to access the portals and backend APIs, run in Administrator PowerShell:

```powershell
# Open Web Portal Ports
netsh advfirewall firewall add rule name="Knome IIS 8080" dir=in action=allow protocol=TCP localport=8080 profile=any
netsh advfirewall firewall add rule name="EmployeeHub IIS 8081" dir=in action=allow protocol=TCP localport=8081 profile=any

# Open Backend API Ports
netsh advfirewall firewall add rule name="Knome API 5095" dir=in action=allow protocol=TCP localport=5095 profile=any
netsh advfirewall firewall add rule name="EH Gateway 5000" dir=in action=allow protocol=TCP localport=5000 profile=any
```

---

### Step 7: Launch Backend Services

Run the launcher scripts in their respective terminals to keep backend APIs running:

```powershell
# In Terminal 1 (Knome Backend):
cd "D:\Knome main\Backend\Knome.API"
dotnet run --launch-profile http

# In Terminal 2 (EmployeeHub Backend Stack):
cd "D:\EmployeeHub"
& ".\START_EMPLOYEEHUB.ps1"
```

---

## 4. Redeployment & Updates (Single Command)

Whenever you make any code changes to either the Knome or EmployeeHub frontend, run the update script as Administrator:

```powershell
& "D:\Knome main\UPDATE_IIS.ps1"
```

This automatically:
- Recompiles both Vite frontends.
- Copies the updated bundle directly into IIS `wwwroot`.
- Keeps IIS sites running without downtime.

---

## 5. Live Endpoint Reference Table

| Service / App | Host Machine URL | LAN / WiFi Network URL |
| :--- | :--- | :--- |
| **Knome Web Portal** | `http://localhost:8080` | `http://<IP_ADDRESS>:8080` |
| **EmployeeHub Portal** | `http://localhost:8081` | `http://<IP_ADDRESS>:8081` |
| **Knome Backend API** | `http://localhost:5095/swagger` | `http://<IP_ADDRESS>:5095/swagger` |
| **EmployeeHub Gateway** | `http://localhost:5000/api` | `http://<IP_ADDRESS>:5000/api` |

---

## 6. Common Troubleshooting & FAQs

### Q1: `HTTP 500.19 Internal Server Error` on initial load?
- **Cause**: An unrecognized XML tag (like `<rewrite>`) was used when URL Rewrite Module wasn't installed.
- **Fix**: Use the standard `httpErrors` fallback provided in our `web.config` above.

### Q2: Images or uploads not showing when accessed from another laptop via IP?
- **Cause**: Backend `AllowedHosts` restricted host headers.
- **Fix**: Set `"AllowedHosts": "*"` in `Backend/Knome.API/appsettings.json`.

### Q3: `404 Not Found` when refreshing a page (e.g. `/articles`, `/profile`)?
- **Cause**: IIS looking for a physical directory instead of routing through `index.html`.
- **Fix**: Ensure `web.config` is present in `C:\inetpub\wwwroot\knome\` and `C:\inetpub\wwwroot\employeehub\`.

### Q4: Clicking "Launch Knome" in EmployeeHub fails on another laptop?
- **Cause**: Hardcoded `localhost` in URL redirects.
- **Fix**: `Dashboard.tsx` and `api.ts` use `window.location.hostname` dynamically so redirects use the host's actual IP address.
