# Development Journal: 97. Community Module 'Default' to 'Org' Terminology Standardization

**Date:** 2026-09-18  
**Author:** Antigravity Pairing Assistant  
**Status:** Completed  
**Associated Goal:** Standardize all "default" / "Default (Org)" / "Organization Default" community references across the Community module and Admin/Role consoles to the official "Org" / "Org Space" nomenclature.

---

## 1. Motivation & Context

In the Knome enterprise knowledge portal, organization-wide mandatory channels (such as *HR & People Ops* and *Finance & Accounting*) were previously labeled with a mix of terms including "Default", "Default (Org)", and "Organization Default (Auto-Assigned)". 

To ensure clear, modern, and unified terminology across all user-facing workflows, the term "Default" has been standardized to **"Org"** throughout the community creation modals, community detail views, management popups, role FAQ documentation, and admin console filters.

---

## 2. Changes Made

### A. Frontend (`knomeUI/frontend/src/`)

1. **`components/modals/CreateCommunityModal.jsx`**:
   - Updated visibility type formatting from `'Default'` to `'Org'`.
   - Normalised community object type generation to `'Org'`.
   - Updated Type Selector radio card title from `"Organization Default (Auto-Assigned)"` to `"Org (Auto-Assigned Organization Space)"`.
   - Updated Step 3 summary label from `"Default (Org)"` to `"Org"`.
   - Updated recipient counter header from `"🏢 Organization Employees"` to `"🏢 Org Employees"`.

2. **`components/modals/ManagementModals.jsx`**:
   - Changed dropdown option: `<option value="default">Org (Auto-subscribed)</option>`.
   - Updated helper footnote: `* Org type requires HR Admin privileges (FR-CM-04)`.

3. **`pages/CommunityView.jsx`**:
   - Standardized seed community entries (`HR & People Ops`, `Finance & Accounting`) `type: 'Default (Org)'` to `type: 'Org'`.
   - Updated leave restriction toast warning from `"Employees cannot leave a Default organization community (FR-CM-04)."` to `"Employees cannot leave an Org community (FR-CM-04)."`.
   - Updated lock badge tooltip from `"Official mandatory organization community..."` to `"Official mandatory Org community for all MPOnline employees (FR-CM-04)"`.

4. **`pages/Communities.jsx`**:
   - Updated inline comment and confirmed badge normalizer (`formatCommunityType`) maps both `'default'` and `'org'` to `'Org'`.
   - Discover filter tabs (`All`, `Public`, `Private`, `Org`) remain cleanly synchronized.

5. **`components/modals/RoleFaqModal.jsx`**:
   - Updated HR Admin key area from `'Default Communities'` to `'Org Communities'`.
   - Updated Community FAQ answer bullet point: `• **Org Communities:** Every employee is automatically enrolled into mandatory company-wide spaces like *MPOnline Official* and *General Knowledge*`.

6. **`pages/AdminConsole.jsx`**:
   - Renamed comment section to `{/* 4. Org Communities */}`.
   - Updated System Access Scope privilege description from `"organization-wide default community assignments"` to `"organization-wide Org community assignments"`.
   - Standardized role privilege text to use `"Admin"` instead of `"Administrator"`.

### B. Backend (`Backend/Knome.API/`)

1. **`Constants/CommunityConstants.cs`**:
   - Added `public const string Org = "Org";` to `CommunityTypes`.
   - Added `CommunityTypes.Org` to `CommunityTypes.All` and updated `CommunityTypes.IsValid(type)`.

2. **`Services/CommunityService.cs`**:
   - Updated `JoinCommunityAsync` auto-approval condition to include `CommunityTypes.Org`.
   - Updated `LeaveCommunityAsync` to prevent leaving `CommunityTypes.Org` as well as `CommunityTypes.Default`.

3. **`Repositories/CommunityRepository.cs`**:
   - In `GetUserCommunitiesAsync`, included `c.CommunityType == "Org"` alongside `c.CommunityType == "Default"`.

4. **`Services/UserService.cs`**:
   - In `GetProfileByIdAsync`, included `c.CommunityType == "Org"` in `CommonCommunitiesCount`.

---

## 3. Verification & Build Results

1. **Backend Compilation**:
   - Ran `dotnet build -t:Compile -nologo` in `Backend/Knome.API`:
     - Result: `Build succeeded. 0 Error(s)`.
2. **Frontend Build**:
   - Ran `npm run build` in `knomeUI/frontend`:
     - Result: `✓ built in 1.29s` with 0 errors.
3. **IIS Deployment Sync**:
   - Executed Robocopy to sync `knomeUI/frontend/dist` -> `C:\inetpub\wwwroot\knome`:
     - Result: Successful sync, all assets live on IIS.
4. **Authentication Portal Reminder**:
   - Users and admins authenticate through the official [MPO Employee Hub](https://counselling-1.mponline.demo.gov.in:3001/applications).
