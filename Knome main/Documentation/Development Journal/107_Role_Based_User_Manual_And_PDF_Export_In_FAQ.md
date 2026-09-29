# Development Journal Entry #107: Role-Based User Manual, Strict Role Isolation & PDF Export in FAQ Modal

- **Date:** September 18, 2026
- **Module:** Help & Guidance / FAQ (`RoleFaqModal.jsx` & `roleManualsData.js`)
- **Focus:** Role-Based Standard Operating Procedure (SOP) User Manual, strict role isolation for standard employees, and client-side high-fidelity PDF manual export.

---

## 1. Problem Statement & User Request

The user requested:
> "in FAQ provide role based user manual and each employee is role provide only that partcular role user manual option and provide download pdf option"

Key requirements:
1. **Role-Based User Manual**: Provide comprehensive, structured Standard Operating Procedures (SOPs) and operational manuals within the global FAQ modal (`RoleFaqModal.jsx`).
2. **Role Isolation**: Each employee must only see and access their assigned role's user manual and FAQ guidance (e.g., standard employees only see `Employee Manual`). System Administrators retain master capability to inspect and edit across all 4 platform roles.
3. **Download PDF Manual**: Implement a prominent, high-fidelity **"Download PDF Manual"** button that exports an enterprise-formatted document with MPOnline Limited branding, document metadata, chapters, karma points tables, and FAQ reference appendix.

---

## 2. Architecture & Design Decisions

### A. Modular Manual Dataset & PDF Generator (`roleManualsData.js`)
Rather than bloating `RoleFaqModal.jsx` (which already had 1,140 lines), a modular data and export file was established at:
`knomeUI/frontend/src/utils/roleManualsData.js`.

This module defines comprehensive chapters for each role:
- **`employee` (Standard Employee)**:
  - Chapter 1: Workplace Identity & Profile Governance (DPDP Act 2023 privacy controls).
  - Chapter 2: Home Feed & Real-Time Content Publishing (Attachments up to 400MB, Targeted Audiences: Everyone / Specific Community / Specific Colleague).
  - Chapter 3: Post & Article Scheduling Pipeline (Background release queue, presets, Scheduled tab).
  - Chapter 4: Long-Form Rich WYSIWYG Articles (Formatting tools, banners, estimated read times).
  - Chapter 5: Multimedia Knowledge Channels (Videos up to 500MB, Podcasts up to 100MB, Saved Content).
  - Chapter 6: Communities & Departmental Collaboration (Org, Public, Private communities, Proposal workflow).
  - Chapter 7: Karma Gamification & Contributor Tiers (Points matrix table: Post +2, Article +5, Video/Podcast +3, Like +1, Comment +1; Starter to Platinum thresholds).
  - Chapter 8: Workplace Conduct, Safety & Incident Escalation (Reporting content, confidential investigations).
- **`communityAdmin` (Community Administrator)**:
  - Chapter 1: Community Administrator Mandate & Responsibilities.
  - Chapter 2: Membership Request Queue & Approvals.
  - Chapter 3: Curating Pinned Posts & Announcements (Strict 3-pinned posts rule).
  - Chapter 4: Community Guidelines, Rules & FAQ Customization.
  - Chapter 5: Channel-Level Disciplinary Actions & Suspensions (Community suspension vs Global system suspension).
- **`hrAdmin` (HR Administrator)**:
  - Chapter 1: HR Administrator Mandate & Strategic Scope.
  - Chapter 2: Internal Job Openings & Career Mobility (CRUD, deadlines, departments).
  - Chapter 3: Organization-Wide Notification Broadcasts (Priority levels, emergency alerts).
  - Chapter 4: Community Review & Approval Queue.
  - Chapter 5: Workforce Analytics & Engagement Dashboards.
- **`systemAdmin` (System Administrator)**:
  - Chapter 1: System Administrator Master Governance Mandate.
  - Chapter 2: User Governance & Role Management.
  - Chapter 3: Global Account Suspensions Protocol (Immediate JWT revocation, login lockout).
  - Chapter 4: Content Moderation Reports Queue (Reporter identity confidentiality).
  - Chapter 5: Immutable Audit Trail & Compliance Logging.
  - Chapter 6: Global FAQ & Operating Rules Master Editor.

### B. High-Resolution Print-Ready PDF Generation
Implemented `printRoleManualPdf(roleKey, manualData, roleFaqs, roleMeta)`:
- Renders in a dedicated hidden iframe.
- Embeds official MPOnline Limited header, document code (`MPO-KNOME-SOP-[ROLE]-2026`), classification, generation date, executive summary, and table of contents.
- Injects print stylesheets (`@media print`) with page break protection (`break-inside: avoid`), high-res typography, clean monochrome/accent headers, and formal legal disclaimer footer.
- Sets `document.title` to `MPOnline_Knome_[Role]_User_Manual_2026.pdf` so browser print automatically presets a professional filename when choosing **Save as PDF**.

### C. Strict Role Isolation in `RoleFaqModal.jsx`
- Non-admin users (`isSysAdmin === false`) are strictly confined to their active role (`accessibleRoles` filtered to `userRoleCategory`).
- The multi-role switcher tab bar is replaced with a single verified role indicator: `Assigned Role: [Role Title] Manual`.
- Only System Administrators see the full tab selector across Employee, Community Admin, HR Admin, and System Admin, along with the master inline FAQ/Rules editor.

### D. Dual-Tab Interface & Unified Search
- Mode switcher tabs:
  - **`📘 Official User Manual`**: Displays total chapter count badge, interactive Table of Contents pills, chapter accordion cards, numbered procedure steps, and data tables.
  - **`❓ Role FAQs & Rules`**: Displays total Q&As count badge, existing search accordion, and system admin edit controls.
- Search input intelligently filters both manual chapters (searching chapter titles, section content, bullet points, and steps) and FAQs simultaneously.

---

## 3. Files Created & Modified

1. **`knomeUI/frontend/src/utils/roleManualsData.js`** *(NEW)*:
   - Defined `ROLE_USER_MANUALS` for all 4 roles.
   - Built `printRoleManualPdf()` export function.
2. **`knomeUI/frontend/src/components/modals/RoleFaqModal.jsx`** *(MODIFIED)*:
   - Imported `ROLE_USER_MANUALS` and `printRoleManualPdf`.
   - Added view mode state (`activeTab = 'manual' | 'faqs'`).
   - Added `handleDownloadPdf` action handlers and loading state.
   - Added Chapter accordion toggles and search filtering for manual chapters.
   - Added prominent **"Download PDF Manual"** buttons in Header, Manual Banner, and Modal Footer.
   - Enforced strict single-role isolation for standard employees.

---

## 4. Verification & Results

1. **Frontend Production Build:**
   ```powershell
   npm run build
   ```
   Output: Built successfully in 821ms with 0 errors.
2. **IIS Deployment:**
   ```powershell
   robocopy "d:\Knome main\knomeUI\frontend\dist" "C:\inetpub\wwwroot\knome" /E /IS /IT
   ```
   Output: Synchronized 42 updated assets cleanly into IIS webroot.
3. **Backend API Verification:**
   ```powershell
   dotnet build -nologo
   ```
   Output: Build succeeded with 0 errors.
