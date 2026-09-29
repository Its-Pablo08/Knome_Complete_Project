# Development Journal: 169 — Rename HR Administrator & HR Approval to Administration in Community Approval Workflows

## Problem Statement

When an employee submits a new community request for governance review, the confirmation dialog and pending indicators previously stated:
- `⏳ AWAITING HR APPROVAL`
- `Your request to create "..." has been successfully sent to the HR Administrator for review.`
- `Status: Pending HR Approval`
- `🔔 You will receive a notification as soon as the HR Administrator approves your request.`

Per platform governance architecture (Phase 160 & 161), community approval is an administrative responsibility handled across all administration roles (Community Admin, HR Admin, System Admin), not solely the HR Administrator. The user requested renaming "HR Administration" / "HR Administrator" to **"Administration"** across the approval messages to reflect the unified governing body.

---

## Changes Implemented

### 1. Community Creation Success Modal ([`Communities.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/pages/Communities.jsx))
- **Status Badge**: Renamed `⏳ Awaiting HR Approval` to `⏳ Awaiting Administration Approval`.
- **Description Body**: Updated copy from `sent to the HR Administrator for review` to `sent to the Administration for review`.
- **Summary Row**: Updated status from `Pending HR Approval` to `Pending Administration Approval`.
- **Notification Advisory**: Updated to `You will receive a notification as soon as the Administration approves your request.`

### 2. Pending Communities Tab & Badges ([`Communities.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/pages/Communities.jsx))
- **Section Heading**: Renamed `Communities Submitted for HR Approval` to `Communities Submitted for Administration Approval`.
- **Section Description**: Renamed `being reviewed by the HR Administrator` to `being reviewed by the Administration`.
- **Card Badge**: Renamed `Under HR Review` badge to `Under Administration Review`.
- **Rejection Notification**: Updated rejection notification to state `was not approved by Administration`.

### 3. Community Submission Stepper Modal ([`CreateCommunityModal.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/components/modals/CreateCommunityModal.jsx))
- **Header Title**: Updated from `Submitted for HR Approval` to `Submitted for Administration Approval`.
- **Status Badge**: Updated from `⏳ Pending HR Admin Approval` to `⏳ Pending Administration Approval`.
- **Body Text**: Updated from `forwarded to the HR Admin for governance review` to `forwarded to the Administration for governance review`.
- **In-App Notification Dispatch**: Updated notification message to `Awaiting Administration Approval.`

### 4. Community View Pending Governance Banner ([`CommunityView.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/pages/CommunityView.jsx))
- **Banner Badges**: Renamed `Under HR Review` pills to `Under Administration Review`.
- **Creator Notice**: Renamed `once approved by the HR Administrator` to `once approved by the Administration`.

### 5. Role Manuals Guidance ([`roleManualsData.js`](file:///d:/Knome%20main/knomeUI/frontend/src/utils/roleManualsData.js))
- Updated community proposal guide from `HR Review Queue and is activated upon HR Administrator approval` to `Administration Review Queue and is activated upon Administration approval`.

---

## Verification

- **Vite Build**: Compiled production build cleanly in 904ms (`npm run build`, 0 errors).
- **IIS Deployment**: Mirrored bundle to `C:\inetpub\wwwroot\knome` and `C:\inetpub\wwwroot\assets`.
- **Visual Inspection**: Checked all 4 approval modal elements (`Awaiting Administration Approval`, `sent to the Administration for review`, `Pending Administration Approval`, `as soon as the Administration approves your request`).
