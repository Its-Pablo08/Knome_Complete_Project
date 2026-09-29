# Dev Journal 75: Community Admin Protection and Member Management Modals

**Date:** 15 September 2026  
**Module:** Community Engine (`knomeUI/frontend/src/pages/CommunityView.jsx`, `Backend/Knome.API/Services/CommunityService.cs`)  
**Phase:** 75  

## Problem Statement

1. **Sole Community Administrator Removal Risk**: When a community has only one Community Administrator, removing or suspending them left the community without administrative leadership.
2. **Missing Suspension Period Selection**: When clicking "Suspend", there was only a binary confirmation without allowing administrators to specify the duration of suspension or track suspension reasons.
3. **Redundant "Set as Member" Button**: For existing Community Administrators, the button read "Set as Member", which created accidental demotions and role confusion.
4. **Member Removal Confirmation**: Member removal required an explicit, informative confirmation modal detailing the consequences of removal.

## Architectural Changes & Solution

### 1. Frontend Enhancements (`knomeUI/frontend/src/pages/CommunityView.jsx`)

- **Removed "Set as Member" Button for Community Admins**:
  - Replaced the ternary toggle button so that `Make Administrator` is only rendered for regular members (`!isCommAdmin`).
  - Community Administrators no longer display a demotion button.

- **Sole Community Administrator Protection**:
  - Implemented `getAdminCount()` to count active Community Administrators (`Admin`, `Moderator`, `Community Administrator`).
  - In `handleInitiateRemoveMember` and `handleInitiateSuspendMember`, if target member is an admin and `adminsCount <= 1`, action is blocked and a dedicated `AdminProtectionWarningModal` popup opens explaining that another member must first be designated as Community Administrator via `Make Administrator`.

- **Rich Suspension Duration Modal (`SuspendMemberModal`)**:
  - Built a modal asking for the suspension duration:
    - `1 Day` (24 Hours)
    - `3 Days`
    - `7 Days` (1 Week - Default)
    - `14 Days` (2 Weeks)
    - `30 Days` (1 Month)
    - `Indefinite / Permanent` (Until manual review)
    - `Custom End Date` (Calendar date picker)
  - Added structured suspension reason categories (Violation of community guidelines, Inappropriate behavior, Spam, Harassment, etc.) plus optional note input.
  - Recorded `suspendedUntil`, `suspensionDuration`, and `suspensionReason` in the suspended member object.
  - Enhanced the Suspended Members UI in the Admin tab to display duration badges, expiry info, and reason text.

- **Dedicated Remove Member Confirmation Modal (`RemoveMemberModal`)**:
  - Built an explicit modal showing the member's profile card, avatar, designation, and community role.
  - Provides contextual warning (e.g. informing that remaining administrators will continue leading if removing a secondary admin, or warning of lost access for regular members).

- **Modal Layout & Responsive Viewport Safeguard**:
  - Configured outer container with `overflow-y-auto p-4 sm:p-6 min-h-full items-center justify-center` and modal card with `my-auto max-h-[85vh] flex flex-col`.
  - Added `shrink-0` to header/footer and `flex-1 min-h-0 overflow-y-auto` to the modal body so the popup never clips or cuts off on smaller laptop screens.
  - Removed `(कितने समय के लिए सस्पेंड करना है)` from the duration label, leaving the clean English header `Suspension Duration`.

- **Dynamic Admin Name in "About Community" Sidebar**:
  - Bound `Admin: [Name]` in the "About Community" sidebar to `communityAdminDisplay` which dynamically resolves the current active Community Administrator(s) from `membersList`.
  - As soon as a member is promoted to Community Administrator (via "Make Administrator"), the sidebar admin name immediately updates to show their name.

- **Community Administrator Pinned to Top of Members List**:
  - Sorted `filteredMembers` so that members with `isCommAdmin` (Community Administrator) are always prioritized at the very top of the `Members & Roles` list, followed by regular members alphabetically.

### 2. Backend Safeguards (`Backend/Knome.API/Services/CommunityService.cs`)

- In `DecideMembershipAsync`, added verification ensuring that if a target user is an active Community Administrator and `adminsCount <= 1`, attempting to ban or reject them throws `BadRequestException("Cannot remove or suspend the sole remaining Community Admin. Promote another member to Community Administrator first.")`.

## Verification & Deployment

1. **Frontend Production Build**: Ran `npm run build` in `knomeUI/frontend` — succeeded cleanly in 750ms with 0 errors.
2. **IIS Deployment**: Updated `C:\inetpub\wwwroot\knome` with production distribution build.
