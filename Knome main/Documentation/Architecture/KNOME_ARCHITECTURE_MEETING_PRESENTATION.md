# 🏛️ Knome Platform & Employee Hub: Enterprise Architecture Presentation

**Organization:** MPOnline Limited  
**Platform:** Knome Enterprise Knowledge & Media Platform + Employee Hub SSO  
**Architecture Standard:** 6-Layer Enterprise Distributed Architecture  

---

## 📊 1. Knome 6-Tier System Architecture Diagram

![Knome 6-Tier Architecture Diagram](./Knome_6_Tier_Architecture_Diagram.png)

---

## 🏛️ 2. Knome & Employee Hub Ecosystem Architecture

![Knome Platform & Employee Hub Enterprise Architecture](./Knome_Ecosystem_Architecture_Diagram.png)

---

## 🔄 3. Single Sign-On (SSO) Token Handshake Flow

![Single Sign-On SSO Token Handshake Sequence](./Knome_SSO_Sequence_Flow_Diagram.png)

---

## 1. High-Level Enterprise Ecosystem Architecture

```mermaid
graph TB
    subgraph Clients ["🖥️ Client Presentation Layer"]
        EH_Web["<b>Employee Hub Web Portal</b><br/>React / Vite (Port: 5001)<br/><i>Central Identity & Master HR Portal</i>"]
        Knome_Web["<b>Knome Knowledge Portal</b><br/>React / Vite (Port: 5173)<br/><i>Posts, Articles, Videos & Podcasts</i>"]
    end

    subgraph Security_Layer ["🛡️ Security & API Gateway Tier"]
        EH_Gateway["<b>Employee Hub Gateway</b><br/>YARP Reverse Proxy (Port: 5000)<br/><i>Rate Limiting & Security Headers</i>"]
    end

    subgraph Core_Services ["⚙️ Core Backend Services Tier"]
        EH_API["<b>EmployeeHub.API (IdP)</b><br/>ASP.NET Core 10 (Port: 5100)<br/>• Identity Provider & JWT Token Issuer<br/>• Master Employee Roster<br/>• Department & Role Governance"]
        Knome_API["<b>Knome.API (Resource Server)</b><br/>ASP.NET Core 10 (Port: 5095)<br/>• Feed & Content Interaction Engine<br/>• Video Streaming & Podcast Channels<br/>• Gamification (Karma Points Engine)<br/>• SignalR Realtime Notifications"]
    end

    subgraph Persistence ["💾 Enterprise Database Persistence (SQL Server)"]
        EH_DB[("<b>EmployeeHubDb</b><br/>Port: 1433<br/>Employees, Roles, Clients")]
        Knome_DB[("<b>Knome Database</b><br/>Port: 1433<br/>Posts, Articles, Media, Karma")]
    end

    %% Client Connections
    EH_Web -->|SSO Token & Redirect| Knome_Web
    EH_Web -->|REST API Requests| EH_Gateway
    EH_Gateway -->|Reverse Proxy| EH_API
    Knome_Web -->|Bearer JWT Authorized Calls| Knome_API

    %% Service to DB
    EH_API -->|EF Core Queries| EH_DB
    Knome_API -->|EF Core Queries| Knome_DB
    
    %% Shared Trust
    EH_API -.->|Shared HS256 Secret Trust| Knome_API

    classDef portal fill:#1e1b4b,stroke:#6366f1,stroke-width:2px,color:#fff;
    classDef gateway fill:#31104b,stroke:#a855f7,stroke-width:2px,color:#fff;
    classDef api fill:#0f172a,stroke:#3b82f6,stroke-width:2px,color:#fff;
    classDef db fill:#064e3b,stroke:#10b981,stroke-width:2px,color:#fff;

    class EH_Web,Knome_Web portal;
    class EH_Gateway gateway;
    class EH_API,Knome_API api;
    class EH_DB,Knome_DB db;
```

---

## 2. Knome Core Content & Media Engine

```mermaid
graph LR
    subgraph Content_Creation ["✍️ Content Creation"]
        P_Create["📝 Posts & Status"]
        A_Create["📰 Rich Articles (HTML)"]
        V_Create["🎥 Video Uploads"]
        PC_Create["🎙️ Podcast Episodes"]
    end

    subgraph Knome_Engine ["⚡ Knome Processing Engine"]
        Mod_Filter["🛡️ Word Restriction & Moderation"]
        Feed_Ranker["🎯 Personalized Feed Ranking"]
        Karma_Calc["⭐ Karma Points & Daily Capping"]
        Notif_Broadcaster["🔔 SignalR Real-Time Broadcaster"]
    end

    subgraph Consumption ["👥 Community Engagement"]
        Feed_UI["🏠 Central Dashboard Feed"]
        Comm_Hub["🏢 8+ Enterprise Communities"]
        Leaderboard["🏆 Karma Leaderboard & Rewards"]
        Job_Portal["💼 Internal Job Exchange"]
    end

    P_Create & A_Create & V_Create & PC_Create --> Mod_Filter
    Mod_Filter --> Feed_Ranker & Karma_Calc & Notif_Broadcaster
    Feed_Ranker --> Feed_UI & Comm_Hub
    Karma_Calc --> Leaderboard
    Notif_Broadcaster --> Feed_UI & Job_Portal

    classDef create fill:#1e293b,stroke:#38bdf8,stroke-width:2px,color:#fff;
    classDef engine fill:#312e81,stroke:#818cf8,stroke-width:2px,color:#fff;
    classDef consume fill:#14532d,stroke:#4ade80,stroke-width:2px,color:#fff;

    class P_Create,A_Create,V_Create,PC_Create create;
    class Mod_Filter,Feed_Ranker,Karma_Calc,Notif_Broadcaster engine;
    class Feed_UI,Comm_Hub,Leaderboard,Job_Portal consume;
```

---

## 3. Single Sign-Out (Global Logout) Orchestration

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 Employee
    participant Knome_UI as 💻 Knome Web (5173)
    participant Knome_API as ⚙️ Knome.API (5095)
    participant EH_UI as 🌐 Employee Hub (5001)

    User->>Knome_UI: 1. Click "Log Out" in Profile Menu
    Knome_UI->>Knome_API: 2. POST /api/auth/logout (Revoke Refresh Token)
    Note over Knome_UI: Clears knome_jwt, knome_employeeId from localStorage
    Knome_UI->>EH_UI: 3. Redirect to http://localhost:5001/?logout=true
    Note over EH_UI: Receives logout signal, removes eh_jwt & active session
    EH_UI-->>User: 4. Display Clean Employee Sign In Portal (Global Logout Complete)
```

---

## 4. Key Architecture Highlights for Meeting Presentation

### 1. 🔐 Security & Identity Federation
- **Decoupled Identity Provider (IdP)**: Authentication is centralized in Employee Hub, removing duplicate credential management.
- **JWT (HS256) Shared Key**: Cryptographic signature validation with role claims (`System Administrator`, `Community Admin`, `HR Administrator`, `Employee`).
- **Zero Raw Password Storage**: Passwords hashed using standard BCrypt (Work Factor 11).

### 2. ⚡ Resilient & High Performance
- **Client Resiliency & Offline Fallback**: Frontend handles network dropouts gracefully without crashing.
- **Rate Limiting & DDoS Protection**: AspNetCore Rate Limiting on critical endpoints.
- **Clean Architecture Separation**: Controllers (Thin HTTP routers) ➔ Services (Business Logic) ➔ Repositories (Data Access) ➔ SQL Server.

### 3. 🎮 Enterprise Gamification & Real-Time Sync
- **Automated Karma Points Engine**: Points for content creation (+10 for Articles, +8 for Media, +2 for Posts) with daily anti-spam capping.
- **SignalR Push Notifications**: Live notification delivery for comments, likes, and official broadcasts.
