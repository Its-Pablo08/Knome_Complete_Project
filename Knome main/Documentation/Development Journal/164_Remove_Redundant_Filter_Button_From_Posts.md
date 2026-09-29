# Dev Journal 164: Remove Redundant Filter Button & Collapsible Bar from Posts Page

## Context
In the Posts page (`/posts`), a bright blue "Filter" button was placed in the hero banner next to the primary "Write Post" button. Clicking this button toggled a collapsible bar with a secondary "Select Topic" popover.

## Analysis
The "Filter" button was identified as redundant:
1. **Universal Search**: The top navigation bar and `/search` already provide real-time search across all posts, discussions, keywords, and topics.
2. **Trending Tags in Sidebar**: The right sidebar of the Posts page already features the `TrendingTagsWidget`, where users can directly click any hashtag (e.g. `#MPOnline`, `#DotNet`) to instantly filter the feed.
3. **Primary Filter Tabs**: Beneath the hero banner, dedicated pills (`All Posts`, `🔥 Hot Posts`, and `⏰ Scheduled`) are already present, along with the active topic badge with a direct `[x]` clear button.
4. Having this additional button created UI clutter and opened an unnecessary extra container for something already accessible in one click from the sidebar and search.

## Changes Made
1. **`Posts.jsx`**:
   - Removed the bright blue `Filter` button from the hero action bar, leaving only the primary call-to-action: `[Write Post]`.
   - Removed the collapsible `{(showFilterBar || selectedTag !== 'All') && ...}` topic bar container and its unused dropdown state (`showFilterBar`, `isFilterOpen`, `tagSearch`, `filterRef`, `rawUniqueTags`, `filteredAvailableTags`).
   - Preserved full topic filtering: clicking any hashtag from post content, trending tags sidebar, or URL query param continues to filter the feed with the active badge chip.
2. **Build & Deployment**:
   - Production Vite build succeeded in 846ms with 0 errors.
   - Deployed fresh assets to IIS (`C:\inetpub\wwwroot\knome\`).
