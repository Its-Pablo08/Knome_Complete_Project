# Development Journal Entry 136: Remove Post Internal Job Button from Openings Page

**Date:** 2026-09-22  
**Feature/Module:** Openings / Jobs (`Jobs.jsx`)  
**Type:** UI/UX Simplification / Action Button Removal  

---

## 1. Problem Description & Background
On the Openings / Internal Opportunities page (`/jobs`), the hero header banner displayed a prominent call-to-action button:
- **`+ Post Internal Job`** (`add_circle` icon with teal-to-emerald gradient)

Per administrative and platform workflow requirements, internal job postings are managed through dedicated administrative/HR channels or external ATS integrations rather than standard direct self-service on this view. The user requested removal of this button.

---

## 2. Changes Made

### Frontend:
- **`knomeUI/frontend/src/pages/Jobs.jsx`**:
  - Removed the `Post Internal Job` button and its outer flex container in the hero banner.
  - Cleaned up unused imports and state variables (`useUser`, `CreateJobModal`, `currentUser`, `isCreateOpen`, `canPostJobs`).
  - Removed the unused `<CreateJobModal>` component instantiation at the bottom of the page, reducing bundle size from ~17 kB to ~7.46 kB.

---

## 3. Verification & Deployment
1. Built frontend production bundle:
   - `npm run build` in `knomeUI/frontend` passed cleanly in 1.80s (0 errors).
2. Deployed production assets to IIS webroot at `C:\inetpub\wwwroot\knome` via robocopy:
   - 43 files synchronized successfully with code 1.
