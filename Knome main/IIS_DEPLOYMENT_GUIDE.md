# IIS Deployment Guide — Quick Reference

The complete step-by-step English documentation for deploying Knome and EmployeeHub to IIS on any Windows machine/server is available in the documentation folder:

👉 **[Documentation/IIS_Deployment_Guide.md](file:///D:/Knome%20main/Documentation/IIS_Deployment_Guide.md)**

---

## ⚡ Quick Start Deployment (3 Steps)

### 1. Build Both Frontends
```powershell
cd "D:\Knome main\knomeUI\frontend" ; npm run build
cd "D:\EmployeeHub\src\EmployeeHub.Web" ; npm run build
```

### 2. Run Automated IIS Setup (As Administrator)
```powershell
& "D:\Knome main\SETUP_IIS.ps1"
```

### 3. Open Firewall Ports (As Administrator)
```powershell
netsh advfirewall firewall add rule name="Knome IIS 8080" dir=in action=allow protocol=TCP localport=8080 profile=any
netsh advfirewall firewall add rule name="EmployeeHub IIS 8081" dir=in action=allow protocol=TCP localport=8081 profile=any
netsh advfirewall firewall add rule name="Knome API 5095" dir=in action=allow protocol=TCP localport=5095 profile=any
netsh advfirewall firewall add rule name="EH Gateway 5000" dir=in action=allow protocol=TCP localport=5000 profile=any
```

---

## 🔄 Updating Code After Changes
```powershell
& "D:\Knome main\UPDATE_IIS.ps1"
```
