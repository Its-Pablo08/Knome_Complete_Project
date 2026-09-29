# Phase 118 — Remove Default Community Pre-selection in Share Modals

## Overview
When opening the "Share to Community" dialog (e.g. from post cards, articles, videos, podcasts, or profile shares), the application previously defaulted to selecting the first available community in the list (`Java` or index 0). Users reported that this automated pre-selection was unintended, as users should explicitly make their own community selection before sharing content.

## Root Cause Analysis
1. In `ArticleShareModal.jsx` and `ShareProfileModal.jsx`, when communities finished loading, `setSelectedCommunityId` had a fallback:
   ```javascript
   setSelectedCommunityId(prev => {
       const exists = combinedList.some(c => String(c.communityId || c.id) === String(prev));
       return exists ? prev : String(combinedList[0].communityId || combinedList[0].id);
   });
   ```
   Because `prev` initially evaluated to empty (`''`), it automatically assigned the ID of `combinedList[0]`.
2. Additionally, when the modal opened, `selectedCommunityId` was not explicitly cleared back to empty string in the open lifecycle effect.
3. Clicking on a selected community item did not allow toggling it off.

## Key Changes
1. **`ArticleShareModal.jsx`**:
   - Initialized `selectedCommunityId` to `''` when the modal opens (`isOpen`).
   - Removed the `combinedList[0]` fallback during community load; if no community was previously selected, `selectedCommunityId` remains empty string `''`.
   - Enhanced community card click handler to allow toggling selection on and off: `onClick={() => setSelectedCommunityId(prev => String(prev) === cId ? '' : cId)}`.
   - Kept "Share Post/Content to Community" button disabled (`disabled={isSharing || !selectedCommunityId}`) with `disabled:cursor-not-allowed` until a community is explicitly selected.
2. **`ShareProfileModal.jsx`**:
   - Cleared `selectedCommunityId` on modal open.
   - Removed `combinedList[0]` fallback on community list retrieval.
   - Allowed toggle selection on community items.
   - Added disabled cursor feedback on the submission button when no community is selected.
3. **`Videos.jsx` & `VideoPlayerModal.jsx`**:
   - Replaced legacy default `'1'` state initializer with empty string `''`.

## Verification
- Confirmed that opening the "Share to Community" modal leaves all community cards unselected (empty radio circle).
- Confirmed that the "Selected: [Community Name]" badge is hidden when nothing is selected.
- Confirmed that the share button is disabled with reduced opacity until the user explicitly selects a community.
- Confirmed that clicking any community card selects it and enables the button, and clicking it again unselects it.
