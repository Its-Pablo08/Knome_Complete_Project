# Knome Enterprise Platform — RBAC & Communities Specification Document
**Client / Enterprise:** MPOnline Limited  
**Version:** 1.0 (Enterprise Specification)  
**Security Standard:** HMAC-SHA256 Dual-Issuer JWT, BCrypt Work Factor 11, Normalized Relational SQL Server 2022  

---

## 1. Executive Summary & Governance Objectives
The **Knome Enterprise Knowledge & Collaboration Platform** implements a strict multi-tier **Role-Based Access Control (RBAC)** architecture alongside a granular **Community Space Classification System** (Public, Private, and Organization Default). 

This design ensures:
1. **Confidentiality:** Sensitive departmental discussions and intellectual property remain isolated within approved boundaries.
2. **Accountability:** Full traceability with immutable audit logging across all administrative and moderation actions.
3. **Productivity:** Frictionless, self-service participation for standard employees without compromising corporate security.

---

## 2. Four-Tier RBAC Architecture

| Role | Role Code | Target User Base | Permissions & Scope |
| :--- | :---: | :--- | :--- |
| **Employee** | `EMP` | All standard MPOnline personnel | • Self-service authoring (Feed Posts, Knowledge Articles, Videos, Podcasts).<br>• Discover and join Public communities; submit join requests for Private communities.<br>• Like, comment, share, bookmark content, and earn Karma points.<br>• View personalized feeds, leaderboards, and departmental directory. |
| **Community Admin** | `CADM` | Department leads & community creators | • Full moderation within designated community spaces.<br>• Review, approve, or reject pending community join requests.<br>• Pin critical announcements, edit group guidelines, and manage FAQs.<br>• Remove disruptive members and appoint co-moderators. |
| **HR Administrator** | `HRADM` | HR & Internal Operations Leads | • Review, approve, or reject employee community creation requests.<br>• Publish organization-wide broadcasts and mandatory corporate notices.<br>• Full access to **HR Analytics (RPT-01 to RPT-05)**.<br>• Export workforce metrics to CSV and Excel (.xls). |
| **System Administrator** | `SYSADM` | IT Security & Infrastructure Leads | • Sovereign platform administration and RBAC role assignment.<br>• Access immutable **Security Audit Logs** (tracking user actions, timestamps, and IP addresses).<br>• Activate, deactivate, or suspend user accounts.<br>• Monitor YARP gateway routing, background services, and live SQL Server status. |

---

## 3. Community Classifications: Public, Private & Default

```
                                  ┌────────────────────────────────────────────────────────┐
                                  │               KNOME COMMUNITY CLASSIFICATION           │
                                  └───────────────────────────┬────────────────────────────┘
                                                              │
                    ┌─────────────────────────────────────────┼────────────────────────────────────────┐
                    │                                         │                                        │
                    ▼                                         ▼                                        ▼
      ┌───────────────────────────┐             ┌───────────────────────────┐            ┌───────────────────────────┐
      │     PUBLIC COMMUNITY      │             │     PRIVATE COMMUNITY     │            │    ORGANIZATION DEFAULT   │
      ├───────────────────────────┤             ├───────────────────────────┤            ├───────────────────────────┤
      │ • Instant 1-Click Join    │             │ • Join Request Queue      │            │ • Auto-Enrolled at Signup │
      │ • Open to All Employees   │             │ • Admin Approval Required │            │ • HR/SysAdmin Created     │
      │ • Public Feed Discovery   │             │ • Internal Feed Hidden    │            │ • Mandatory Corporate Hub │
      └───────────────────────────┘             └───────────────────────────┘            └───────────────────────────┘
```

### 1. Public Communities
- **Access Model:** Open to all active MPOnline employees.
- **Joining Behavior:** Instant self-enrollment (`status: 'Approved'`); no approval delay.
- **Content Visibility:** All posts, videos, articles, and discussions are publicly indexable in search and feed.
- **Best Suited For:** Technical interest groups (e.g., *Frontend Guild*, *DotNet Core Experts*), cultural clubs, sports forums.

### 2. Private Communities
- **Access Model:** Restricted focus groups and confidential project teams.
- **Joining Behavior:** Employee clicks `Request to Join` (`status: 'Pending'`). A Community Admin or HR Administrator reviews the applicant before granting access.
- **Content Visibility:** The community title and description appear in the directory, but the feed, files, and discussions are hidden until approved.
- **Best Suited For:** Specific project pods (e.g., *Project Phoenix*, *Knome Core Architecture*), Leadership Council, Legal/Finance workgroups.

### 3. Organization Default Communities
- **Access Model:** Mandatory organization-wide spaces pre-configured for every employee.
- **Joining Behavior:** Automated enrollment upon user registration / HRMS onboarding.
- **Creation Authority:** Created exclusively by **HR Administrators** or **System Administrators**.
- **Best Suited For:** *All MPOnline Official*, *Corporate Announcements*, *Mandatory Compliance Hub*.

---

## 4. Feature Comparison Matrix

| Feature / Attribute | Public Community | Private Community | Organization Default Community |
| :--- | :--- | :--- | :--- |
| **Join Method** | 1-Click Self Join | Join Request -> Admin Approval | Pre-Allocated / Auto-Enrolled |
| **Creator Permission** | Employee (with HR Approval) or Admin | Employee (with HR Approval) or Admin | HR Administrator / System Admin Only |
| **Feed Visibility** | Entire Organization | Approved Community Members Only | All Enrolled Employees |
| **Discussion Permissions** | All Members | Approved Members | Open Discussions or Broadcast Only |
| **Document Sharing** | In-App Sandboxed Viewer | In-App Sandboxed Viewer | In-App Sandboxed Viewer |
| **Moderator RBAC** | Community Admin & HR Admin | Community Admin & HR Admin | HR Administrator & System Admin |

---

## 5. Document Security & Protection Guidelines
1. **Zero External Downloads:** All technical manuals, briefs, and PDFs open exclusively in Knome’s sandboxed `DocumentViewerModal`.
2. **Suppressed Print & Save Ribbons:** PDF download buttons and browser print shortcuts are disabled (`#toolbar=0&navpanes=0`).
3. **Standardized 2-Option Share Modal:** Content can only be shared to:
   - `Share to Community` (Post to specialized team space).
   - `Share with Users` (Send direct peer-to-peer notification).
4. **Audit Trail Compliance:** Every membership change, moderation action, and community status update is written to `dbo.AuditLogs`.

---

## 6. How to Print or Save as PDF
To generate the formal, styled PDF document:
1. Open [Knome_RBAC_and_Communities_Architecture.html](file:///d:/Knome%20main/Documentation/Architecture/Knome_RBAC_and_Communities_Architecture.html) in your browser.
2. Click the top **"Save / Print as PDF"** button (or press `Ctrl + P`).
3. Set Destination to **"Save as PDF"** and click **Save**.
