# Dev Journal: 94 - Community Catalog Synchronization, Compact Card Sizing, and Delete Button Relocation

## Context & User Problem
The user noticed three key aspects regarding the Community view:
1. **Catalog Discrepancy**: "Why are there differences in both community?" — The Community Moderation section in `/admin-console` displayed 19 enterprise channels (such as "Engineering & Tech", "HR & People Ops", "Product Design & UX", etc.), while the Discover tab on `/community` only returned "HR test" when searching for "hr", creating confusion between the admin catalog and user-facing communities.
2. **Card Dimensions**: "Decrease the size of box of community" — The previous community cards were excessively large (`h-36` 144px cover banners, `min-h-[350px]`, large padding), occupying too much vertical viewport space and showing fewer cards per row.
3. **Delete Button Placement**: "Delete button in bottom right of box" — The administrative delete button was previously overlaid on the top-left of the cover photo banner next to the photo change icon, which cluttered the cover imagery and felt misplaced.

## Architectural Changes & Implementation

### 1. Unified Community Catalog Data Source (`apiService.js`, `Communities.jsx`, `AdminConsole.jsx`)
- **Root Cause**: `AdminConsole.jsx` had 8 built-in enterprise channels hardcoded into its local state, while `Communities.jsx` only fetched dynamic SQL/API communities and custom creations.
- **Solution**:
  - Exported `DEFAULT_ENTERPRISE_COMMUNITIES` in `src/utils/apiService.js` as the single canonical source of enterprise channels.
  - In `Communities.jsx` (`loadCommunities`), merged `DEFAULT_ENTERPRISE_COMMUNITIES` with backend API communities and local custom communities, filtering out deleted IDs.
  - In `AdminConsole.jsx` (`fetchCommunities`), imported and merged the same `DEFAULT_ENTERPRISE_COMMUNITIES` with API and custom communities with shared deletion exclusion.
  - As a result, searching "hr" returns both "HR & People Ops" (the enterprise channel) and "HR test" (the dynamic custom community) consistently across both views.

### 2. Compact Community Card Design (`Communities.jsx`)
- **Responsive Grid**: Scaled from 3 columns to 4 columns on large screens: `grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4`.
- **Banner Height**: Reduced from `h-36` (144px) to `h-24 sm:h-26` (~96px to 104px).
- **Avatar & Badges**: Compacted avatar from `w-10 h-10` to `w-7 h-7 sm:w-8 sm:h-8`, policy/type pills to `text-[9px] font-black`.
- **Card Padding**: Decreased from `p-4 sm:p-5` to `p-3 sm:p-3.5`.
- **Typography & Layout**:
  - Title: `text-[13px] sm:text-[14px]` with `line-clamp-1`.
  - Description: `text-[11px] line-clamp-2` with `min-h-[32px]`.
  - Minimum card height: Reduced from `min-h-[350px]` to `min-h-[230px]` (~35-40% height reduction).

### 3. Delete Button Relocated to Bottom Right of Box (`Communities.jsx`)
- Removed the red delete button from the top-left of the cover image banner.
- Kept only the subtle camera upload icon on the banner for photo edits.
- Relocated the delete button into the card's bottom-right footer alongside the activity status indicator:
  ```jsx
  {isSysAdmin && (
      <button 
          onClick={(e) => handleDeleteCommunityCard(e, community)}
          className="w-5.5 h-5.5 rounded-md bg-rose-50 text-rose-500 hover:bg-rose-500 hover:text-white dark:bg-rose-500/10 dark:text-rose-400 dark:hover:bg-rose-500 dark:hover:text-white flex items-center justify-center transition-all hover:scale-105 cursor-pointer ml-1"
          title="Remove Community"
      >
          <span className="material-symbols-outlined text-[13px]">delete</span>
      </button>
  )}
  ```

## Verification
- `npm run build` completed with 0 errors.
- Deployed production artifacts to IIS (`C:\inetpub\wwwroot\knome`).
- Verified responsive layout and card proportions.
