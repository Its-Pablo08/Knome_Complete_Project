# EmployeeHub & Knome Platform Integration Documentation

This document details the exact **6-Layer Enterprise Distributed Architecture** for **EmployeeHub** and its integration with **Knome Platform**.

---

## 🏛️ Exact 6-Layer Architecture Specification

| Layer | Component Name | Technology | Port | Access Boundary & Role |
| :--- | :--- | :--- | :--- | :--- |
| **Layer 1** | **React UI** | React 18 / Vite | **`5173`** | **Public Client Presentation** — Modern React/TypeScript SSO login, directory, and employee profile console. |
| **Layer 2** | **Next.js BFF** | Next.js App Router | **`3000`** | **Client-Facing BFF Proxy** — Session management, HTTP-only auth cookies, request aggregation. |
| **Layer 3** | **API Gateway** | ASP.NET Core 10 | **`5000`** | **Gateway Security & Middleware** — Gateway rate limiting, CORS policies, centralized `/health` probes. |
| **Layer 4** | **YARP Reverse Proxy** | `Yarp.ReverseProxy` | **`5000`** | **Internal Cluster Proxy Engine** — Dynamic high-throughput routing (`/api/*` ➔ Backend cluster). |
| **Layer 5** | **Backend API & Repos** | ASP.NET Core 10 | **`5095`** | **Internal Business & Data Services** — Identity verification, SSO token broker, BCrypt hashing. |
| **Layer 6** | **Database Layer** | MS SQL Server | **`1433`** | **Internal Database Source-of-Truth** — `EmployeeHubDb` (Knome-compatible schema with DPDP Act 2023 visibility). |

---

## 🚀 How to Run (2 Terminals)

### Terminal 1: Run EmployeeHub (All 6 Layers)
```powershell
powershell -ExecutionPolicy Bypass -File "d:\EmployeeHub\START_EMPLOYEEHUB.ps1"
```

### Terminal 2: Run Knome Platform
```powershell
powershell -ExecutionPolicy Bypass -File "d:\Knome main\START_KNOME.ps1"
```
