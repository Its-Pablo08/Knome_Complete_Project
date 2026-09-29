# Development Journal — Phase 89: Role-Based FAQ Guide Handbook & Navbar Action Button

**Date:** 2026-09-17  
**Author:** AI Agent & Pair Programmer  
**Status:** Completed & Verified  

---

## 1. Requirement Summary

The user requested:
> *"add FAQ button at top right corner for each role for using Knome properly"*

Key Objectives:
1. Place a permanent, responsive **FAQ button** in the top-right corner of the global navigation bar (`Navbar.jsx`), accessible on all pages.
2. Provide a role-tailored FAQ & platform handbook modal (`RoleFaqModal.jsx`) detailing step-by-step best practices and procedures for:
   - **Standard Employee**
   - **Community Administrator**
   - **HR Administrator**
   - **System Administrator**
3. Automatically detect the logged-in user's active role, default the modal to that role's tab, and mark it with a `"Your Role"` indicator chip while allowing full exploration of other roles.

---

## 2. Changes Implemented

### A. New Component: `RoleFaqModal.jsx`
- Location: `knomeUI/frontend/src/components/modals/RoleFaqModal.jsx`
- Features:
  - **Portal Mounted (`createPortal(..., document.body)`)**: Rendered with `z-[9999]`, immune to stacking context occlusion.
  - **Role Auto-Detection**: Inspects `currentUser.roleName`, `currentUser.roles`, and `currentUser.designation` to automatically open on the user's active role tab.
  - **Interactive Role Tabs**:
    1. **👤 Employee**: Feed & post composer (up to 400 chars, `@mentions`, `#hashtags`, 4 attachment types, audiences), scheduling engine (minimum 1 min, presets, privacy), Karma points & tier levels (Starter to Platinum), joining/creating communities, rich WYSIWYG article authoring, video/podcast streaming, reporting content, and DPDP Act 2023 privacy toggles.
    2. **👥 Community Administrator**: Role duties, approving/declining join requests, member directory invites, pinned announcements (enforcing 3-pinned limit per `FR-CM-06`), moderating posts and suspending disruptive members (with sole admin safeguard per `FR-CM-05`), and managing sidebar Rules & FAQs.
    3. **🪪 HR Administrator**: Openings board CRUD (`/jobs`) with automated `JobExpiryHostedService` lifecycle, org-wide broadcast notifications, reviewing and approving community proposals, and HR Analytics (`/hr-analytics`) workforce health insights.
    4. **🛡️ System Administrator**: Full governance scope, Content Moderation Queue & Report Preview Modal workflows (Dismiss, Delete, Suspend), user role assignments and promotions, disciplinary suspensions with JWT session invalidation (HTTP 403), and audit log inspection (`/api/audit/logs`).
  - **Search & Accordion Controls**: Includes a live search filter input for instant question/keyword lookup, expand/collapse toggles, category badges, and rich markdown formatting.

### B. Navbar Integration: `Navbar.jsx`
- Location: `knomeUI/frontend/src/components/layout/Navbar.jsx`
- Added the **FAQ Button** in the top-right actions cluster alongside Karma Badge, Theme Toggle, Notifications, and User Menu:
  ```jsx
  {/* ─── Role & Platform FAQ Guide Button ─── */}
  <button
      onClick={() => setIsFaqModalOpen(true)}
      title="Knome Role & Platform FAQs (How to use Knome properly)"
      className="relative flex items-center gap-1.5 px-2.5 sm:px-3 py-1.5 rounded-xl transition-all hover:scale-105 active:scale-95 cursor-pointer group"
      style={{
          background: isDark ? 'rgba(15, 23, 42, 0.8)' : 'rgba(241, 245, 249, 0.9)',
          border: '1px solid var(--border-mid)',
          boxShadow: isDark ? '0 2px 8px rgba(0,0,0,0.3)' : '0 1px 3px rgba(0,0,0,0.05)'
      }}
  >
      <span className="material-symbols-outlined text-[18px] text-indigo-600 dark:text-indigo-400 group-hover:rotate-12 transition-transform" style={{fontVariationSettings:"'FILL' 1"}}>
          help
      </span>
      <span className="text-[12px] font-bold text-slate-700 dark:text-slate-200">
          FAQ
      </span>
  </button>
  ```
- Added a secondary entry in the **User Avatar Menu** for easy access.
- Wired `RoleFaqModal` into the navbar modal mount points.

---

## 3. Verification

1. **Frontend Production Build**:
   - `npm run build` in `knomeUI/frontend` passed in **1.69s** with **0 errors**.
2. **IIS Deployment**:
   - Production bundle copied to `C:\inetpub\wwwroot\knome`.
3. **Backend Build**:
   - `dotnet build -nologo` in `Backend/Knome.API` compiled with **0 errors**.
4. **Interactive Verification**:
   - FAQ button renders with help icon and label in top-right corner.
   - Clicking opens the modal centered with role selector tabs, active role detection, search bar, and accordion questions.
