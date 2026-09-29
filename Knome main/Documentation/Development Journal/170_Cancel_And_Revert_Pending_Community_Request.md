# Development Journal: 170 — Cancel & Revert Pending Community Creation Request

## Problem Statement

When an employee submitted a new community proposal for administration review, the pending community was displayed under the **"Communities Submitted for Administration Approval"** section in the **"My Communities"** tab and inside the community review clearance banner. However, there was no way for the creator to revert or cancel their request if they changed their mind, submitted by mistake, or needed to adjust details.

The user requested adding a **Cancel button** so that users can revert/cancel their community creation request.

---

## Architecture & Implementation

### 1. Backend Creator Deletion Authorization ([`CommunityService.cs`](file:///d:/Knome%20main/Backend/Knome.API/Services/CommunityService.cs))
- In `DeleteCommunityAsync`, explicitly authorized the community creator (`community.CreatedByUserId == currentUserId`) to delete/cancel their own community proposal without requiring administrative role checks:
  ```csharp
  var isCreator = community.CreatedByUserId == currentUserId;
  if (!isCreator)
  {
      await CheckIsAdminOrSysAdminAsync(communityId, currentUserId);
  }
  ```
- Marks `IsActive = false` and `ApprovalStatus = "Deleted"`.

### 2. Communities Page Cancel Button & Workflow ([`Communities.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/pages/Communities.jsx))
- **Handler `handleCancelPendingCommunity`**:
  - Prompts standard confirmation dialog: *"Are you sure you want to cancel and revert your request for '{name}'? This community creation proposal will be withdrawn and removed."*
  - Automatically records the community ID into `knome_deleted_community_ids` so refresh never resurrects it.
  - Purges the community from `knome_pending_community_approvals` and `knome_custom_communities`.
  - Removes the item immediately from UI state (`pendingApprovals` and `communities`).
  - Sends `DELETE /api/communities/{id}` to backend to deactivate and mark as deleted in SQL Server database.
  - Broadcasts `community-created` and `community-approval-requested` window events to keep all tabs/windows in sync.
- **Pending Community Card UI**:
  - Updated footer to display status on the left and a prominent, elegant **`[Cancel]`** action button with icon and hover effects.
  - Updated text from `Awaiting HR clearance` to clean `Awaiting clearance`.
- **Creation Success Modal**:
  - Added a secondary action button `Cancel / Revert this request` directly below Done/View buttons in the post-submission popup modal.

### 3. Community View Clearance Banner Cancel Button ([`CommunityView.jsx`](file:///d:/Knome%20main/knomeUI/frontend/src/pages/CommunityView.jsx))
- Implemented `handleCancelCommunityRequest` inside `CommunityView.jsx`.
- Added a `[Cancel Request]` action button directly inside the creator's **"Under Administration Review / Your Community is Awaiting Administrator Clearance"** banner. Clicking it confirms, purges the request, notifies backend, displays feedback toast, and redirects back to `/community`.

---

## Verification

- **Frontend Production Build**: Vite compiled in 869ms (`npm run build`, 0 errors).
- **IIS Deployment**: Deployed bundle to `C:\inetpub\wwwroot\knome` and `C:\inetpub\wwwroot\assets`.
- **Card Action**: The pending card in `My Communities` now displays a clear `Cancel` button allowing users to revert the request with instant feedback.
