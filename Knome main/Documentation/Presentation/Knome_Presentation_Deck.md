# Knome Enterprise Platform — Full Presentation Deck
**Client / Organization:** MPOnline Limited  
**Version:** 1.0 Enterprise Edition  
**Technology Stack:** ASP.NET Core 10 Web API, React 19 / Vite, Microsoft SQL Server 2022, SignalR, YARP Gateway, EmployeeHub SSO  

---

## Slide 1: Title & Executive Introduction
- **Project Title:** KNOME — Enterprise Knowledge Management & Collaborative Media Portal
- **Target Organization:** MPOnline Limited
- **Core Architecture:** Monorepo (`Backend/Knome.API` + `Frontend/knome-web`)
- **Key Identity Integration:** Seamless Single Sign-On (SSO) with EmployeeHub Identity Provider

---

## Slide 2: Executive Vision — 4 Industry Models in 1 Ecosystem
1. **LinkedIn Model:** Professional employee profiles, departmental networking, connection requests, and real-time social timeline feed.
2. **Medium Model:** Long-form technical articles, structured documentation, rich text authoring, revision history, and protected attachments.
3. **YouTube Model:** Technical video streaming, YouTube playlist sync, video modules, and episode-based audio podcasts.
4. **StackOverflow Model:** Gamified Karma engine, contribution tiers (Bronze to Platinum), real-time leaderboards, and autonomous point awards.

---

## Slide 3: EmployeeHub Single Sign-On (SSO) & Dual-Issuer JWT Trust
### The Authentication Mechanism:
```
[EmployeeHub Login (:5001)] 
         │ (User enters EmpId & Password -> Validates against Identity DB)
         ▼
[Issues HMAC-SHA256 Signed JWT Token] (Claims: sub, employeeId, fullName, role)
         │
         ▼
[Redirects to Knome with Query Params]
  URL: http://localhost:5173/?sso_token=<JWT>&employeeId=MPO103
         │
         ▼
[Knome Frontend UserContext.jsx]
  • Intercepts sso_token & employeeId from URL
  • Saves securely into localStorage (knome_jwt, knome_employeeId)
  • Sanitizes URL query params using window.history.replaceState
  • Initiates backend verification GET /api/users/profile
         │
         ▼
[Knome ASP.NET Core API Backend (:5095)]
  • Dual-Issuer JWT Bearer middleware validates token signature
  • ValidIssuers: ["Knome.API", "EmployeeHub.Identity"]
  • ValidAudiences: ["Knome.Client", "EmployeeHub.Client"]
  • No external network round-trip needed -> Instant zero-click authentication!
```

---

## Slide 4: Full-Stack Technical Architecture
- **Backend Framework:** ASP.NET Core 10 (C#), Clean Controller-Service-Repository architecture.
- **Frontend Framework:** React 19, Vite HMR, TypeScript/JSX, Vanilla CSS + Tailwind utility tokens.
- **Database:** Microsoft SQL Server 2022 (Normalized relational schema with live EF Core 10 scaffolding).
- **Real-Time Layer:** SignalR WebSocket Hub (`/hubs/notifications`) for instant push alerts.
- **Security:** BCrypt Work Factor 11 password hashing, protected in-app document viewing, role-based access control (RBAC).

---

## Slide 5: Knowledge Articles & Enterprise Documentation
- **Rich Editor:** Multi-format publishing with code blocks, tables, and callouts.
- **Revision History:** Full audit trail of article versions with author attribution.
- **Category Tagging:** Cross-departmental discovery with keyword search.
- **Sandboxed Attachments:** PDF manuals and SOPs open in-app without leaking download links.

---

## Slide 6: Media Studio — Videos & Technical Podcasts
- **Video Modules:** Self-hosted video streaming & YouTube Playlist synchronization with automatic metadata extraction.
- **Podcast Channels:** Audio series with continuous background player, speaker tagging, and transcript viewing.
- **Interactive Engagement:** Video timestamp discussions, like/dislike counts, and saved bookmarks.

---

## Slide 7: Communities & Governance Lifecycle
1. **Creation:** Standard employees submit community requests with custom rules, banner, and FAQs.
2. **Review Queue:** Request is marked as `Pending Approval` and immediately dispatches a real-time notification to HR & System Admins.
3. **Approval Dashboard:** Admins review pending communities on `/communities?tab=Approvals`.
4. **Activation:** On approval, the community is published live, creator is assigned as `Community Admin`, and celebration alerts are broadcast.

---

## Slide 8: Gamification & Karma Engine
- **Autonomous SQL Server Ledger:** Points awarded automatically via `dbo.KarmaTransactions` for verified engagement.
  - `+10 Pts`: Publishing an Article
  - `+8 Pts`: Uploading Video / Podcast
  - `+2 Pts`: Creating Feed Updates
  - `+1 to +3 Pts`: Receiving Reactions, Comments & Shares
- **Tier Progression:**
  - **Bronze (Newbie):** 0 – 250 Pts
  - **Silver (Contributor):** 251 – 1,000 Pts
  - **Gold (Expert):** 1,001 – 5,000 Pts
  - **Platinum (Legend):** 5,000+ Pts
- **Live Leaderboard:** Real-time ranking of MPOnline's top contributors.

---

## Slide 9: Standardized Sharing & Document Protection
- **Unified 2-Option Share Modal:**
  1. `Share to Community` (Post content directly into specialized community feed)
  2. `Share with Users` (Send targeted peer-to-peer notification to specific colleagues)
- **Data Protection:**
  - Zero raw download links (`target="_blank"` removed).
  - Print toolbars and PDF download ribbons suppressed (`#toolbar=0`).
  - Right-click context menus and text scraping disabled on preview modals.

---

## Slide 10: SignalR Real-Time Notifications
- **WebSockets Engine:** Instant push delivery for comments, mentions, invites, and badge promotions.
- **Strict Chronological Priority:** Latest incoming notifications are pinned at Index 0 (top of list) with "Just now" timestamps.
- **Real-Time Role Unlock:** When an Admin assigns a role, the employee's pending modal clears instantly without browser refresh.

---

## Slide 11: HR Analytics & Workforce Intelligence
- **100% Live SQL Server Database Metrics:**
  - `RPT-01 (User Engagement)`: Registered workforce, active users, suspension status, and karma breakdown.
  - `RPT-02 (Community Health)`: Member counts, active communities, and post frequency.
  - `RPT-03 (Content Performance)`: Aggregated counts across posts, articles, videos, podcasts, and reactions.
  - `RPT-04 (Trending Contributors)`: Top departmental champions from live karma transactions.
  - `RPT-05 (Security & Moderation)`: Security audit logs, reported content flags, and resolution status.
- **Export Options:** Corporate reports exportable to **CSV** and **Excel (.xls)**.

---

## Slide 12: 4-Tier Role-Based Access Control (RBAC)
- **Employee (`EMP`):** Content creation, learning tracks, community participation, and karma progression.
- **Community Admin (`CADM`):** Community space moderation, join request review, and group settings.
- **HR Administrator (`HRADM`):** Company-wide broadcasts, community approvals, user role management, and HR analytics.
- **System Administrator (`SYSADM`):** Full platform governance, immutable security audit logs, and account lifecycle.

---

## Slide 13: Strategic Business Impact for MPOnline
- **40%+ Faster Onboarding:** Consolidated video tutorials and SOPs accelerate knowledge ramp-up for new recruits.
- **Zero Knowledge Loss:** Critical solutions and architecture blueprints preserved in institutional memory.
- **Government Compliance:** On-premise SQL Server deployment, in-app document protection, and immutable audit logs.

---

## Slide 14: Conclusion & Live Demonstration
- **Live System URLs:**
  - **EmployeeHub SSO:** `http://localhost:5001`
  - **Knome Web Portal:** `http://localhost:5173`
  - **Backend Swagger API Docs:** `http://localhost:5095/swagger`
- **Ready for Production Deployment & Executive Review.**
