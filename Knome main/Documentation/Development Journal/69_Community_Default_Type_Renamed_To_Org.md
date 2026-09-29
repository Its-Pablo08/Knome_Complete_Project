# 69: Community Default Type Renamed to Org

**Date:** 2026-09-15  
**Scope:** Community Catalog (`Communities.jsx`), Profile (`Profile.jsx`), Admin Console (`AdminConsole.jsx`), and Production IIS Deployment  
**Status:** Completed  

---

## 1. Requirement & Objectives
The user requested:
> *"yaha default ka name change karke org kardo community mai"*  
*(accompanied by a screenshot of the Communities page where card badges displayed `DEFAULT (ORG)` and `DEFAULT`)*

**Objectives:**
1. Rename all instances of `DEFAULT` and `DEFAULT (ORG)` community badges to **`ORG`**.
2. Normalize community type mapping in `Communities.jsx` via `formatCommunityType` so default organization communities uniformly resolve to `'Org'`.
3. Update filter pills in `Communities.jsx` from `Default (Org)` to `Org`.
4. Update `Profile.jsx` and `AdminConsole.jsx` community badges from `Default Org` / `Default (Org)` to `Org`.
5. Compile frontend bundle via Vite and deploy directly to IIS (`C:\inetpub\wwwroot\knome\`).

---

## 2. Changes Made

### 1. `Communities.jsx`
- Added normalization utility `formatCommunityType`:
  ```javascript
  export const formatCommunityType = (type) => {
      const t = String(type || '').trim().toLowerCase();
      if (t.includes('default') || t.includes('org')) return 'Org';
      if (t.includes('private')) return 'Private';
      return 'Public';
  };
  ```
- Applied `formatCommunityType` in `apiMapped` and custom community loaders.
- Updated community card badge at line 921 to render `formatCommunityType(community.type)` (displaying **`ORG`** with uppercase styling).
- Updated filter pills list and logic from `Default (Org)` to `Org`.

### 2. `Profile.jsx`
- Updated community space badge from `Default Org` to `Org`.

### 3. `AdminConsole.jsx`
- Updated default organization community channel type values from `Default (Org)` to `Org`.

---

## 3. Verification & Deployment
1. Compiled production frontend bundle with `npm run build`:
   - Completed in 995ms with 0 errors (`✓ built in 995ms`).
2. Deployed output files to IIS webroot (`C:\inetpub\wwwroot\knome\`).
3. Verified HTTP 200 on Vite dev server (`:5173`) and IIS site (`:8080`).
