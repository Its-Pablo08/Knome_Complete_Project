# Phase 99: Community-Level Suspension Isolation & System Admin Platform Lockout Message

## Executive Summary
This phase separates the scope of **Community-Level Suspension** (managed by Community Administrators inside individual communities) from **Platform-Wide Suspension** (managed by System Administrators inside the Admin Console):
1. **Community Suspension**: Suspends access to that specific community only. The user cannot access that community's feed, posts, files, or members list, and is shown a dedicated *"Community Access Suspended"* screen. Their global Knome account remains fully active for other communities, posts, and articles.
2. **System Admin Console Suspension**: Completely locks the user out of Knome platform-wide, presenting the exact requested message: **"Your account is suspended by system admin"**.

---

## 1. Scope Separation & Architecture

| Level | Action Initiator | Scope | User Impact | Screen Displayed |
| :--- | :--- | :--- | :--- | :--- |
| **Community Suspension** | Community Admin / Moderator | Single Community | Blocked from that community only; other communities and Knome features remain active | *"Community Access Suspended: You have been suspended from this community by the Community Administrator."* |
| **Platform Suspension** | System Administrator | Entire Knome Platform | Blocked from the entire application; cannot view or access any page | *"Your account is suspended by system admin"* |

---

## 2. Implementation Steps

### A. Community Module Isolation (`CommunityView.jsx`)
- In `handleConfirmSuspendMember`:
  - Removed `adminApi.suspendUser` so suspending a community member does not disable their Knome account.
  - Persisted community-level suspension record into `knome_community_suspended_${communityId}` and updated backend membership status to `'Banned'`.
- In Access Verification:
  - Check if `currentUser` is in the community's suspended list or if `currentUserMembershipStatus === 'Banned'`.
  - When suspended, render a dedicated **Community Access Suspended** view:
    - Display suspension reason, duration, and restriction notice.
    - Prevent viewing posts, private files, or members.
    - Provide a *"Back to Communities"* navigation button.

### B. System Admin Console Global Lockout (`AuthGuard.jsx` & `UserContext.jsx`)
- In `AuthGuard.jsx`:
  - Show the prominent message: **"Your account is suspended by system admin"**.
  - Strict block preventing any Knome view or route rendering.
- In `UserContext.jsx`:
  - Retain suspended state across refreshes so suspended users cannot bypass the lock screen.

### C. Backend Authentication (`AuthService.cs`)
- When a suspended user attempts authentication:
  - Reject login with: `"Your account is suspended by system admin."`

---

## 3. Verification & Deployment
- Backend API build: `dotnet build -nologo`
- Frontend build: `npm run build`
- IIS deployment to `C:\inetpub\wwwroot\knome`
