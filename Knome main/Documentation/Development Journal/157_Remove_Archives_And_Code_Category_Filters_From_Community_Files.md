# Phase 157 — Remove Archives & Code Filters from Community Files & Media Toolbar

## Overview
Per user feedback, removed the **Archives** (`folder_zip`) and **Code & Scripts** (`code`) category filter pill buttons from the Files & Media toolbar inside `CommunityView.jsx`.

## Changes Made
1. **[CommunityView.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/pages/CommunityView.jsx)**:
   - **Toolbar Category Pills**: Removed `{ id: 'Archive', label: 'Archives' }` and `{ id: 'Code', label: 'Code & Scripts' }` from the filter pill array. The toolbar now exclusively presents the four core categories:
     - `All Assets` (`inventory_2`)
     - `Documents` (`description`)
     - `Images` (`image`)
     - `Videos` (`movie`)
   - **Category Counter & Filtering**:
     - Updated `fileCategoryCounts` to only calculate counts for `All`, `Document`, `Image`, and `Video`.
     - In `detectFileTypeAndCategory`, categorized any archive formats (`.zip`, `.rar`, `.7z`, `.tar`, `.gz`) and code formats (`.js`, `.ts`, `.cs`, `.py`, `.sql`, etc.) under the institutional `Document` category.
     - In `filteredFiles`, ensured selecting the `Document` filter seamlessly includes institutional documents, archives, and code files.
   - **Upload Modal Copy & Badges**:
     - Updated description to: `"Institutional documents, presentations & media up to 50 MB"`.
     - Removed `ZIP` and `CODE` chips from the format pill row, keeping `['PDF', 'DOCX', 'XLSX', 'PPTX', 'PNG/JPG', 'MP4']`.

## Verification
- Frontend production bundle built cleanly in 2.02s (`npm run build`).
- Deployed and synchronized updated distribution to IIS (`C:\inetpub\wwwroot\knome`).
