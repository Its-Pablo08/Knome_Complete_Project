# Development Journal — 119: Shared Article, Video, Podcast & Post Direct Redirection In Community Feed

## Date & Session
- **Date**: 2026-09-21
- **Focus**: Fixing community feed redirection when clicking on shared articles, videos, podcasts, profiles, and posts.

## Problem Statement
When articles, videos, podcasts, or posts were shared to a community feed, clicking on the shared content quote card or clicking the bottom action button always dispatched navigation to `/posts?id={id}` (or failed to navigate to the underlying article/video).
Specifically:
1. In the database, item `10050` is an **Article** titled *"Best Practices for Building Scalable REST APIs with ASP.NET Core"* authored by Deepak Simrodia.
2. In `PostCard.jsx`, `<ArticleShareModal>` previously defaulted `contentType="Post"`, causing articles shared from general feeds to be misidentified as posts.
3. In `CommunityView.jsx`, both the Quote Card and the bottom action button (`[Open Post]`) hardcoded navigation to `/posts?id=${id}` instead of `/article-view?id=${id}`.
4. The action button statically read `Open Post` even when the shared content was an Article, Video, Podcast, or Employee Profile.

## Implementation Details

### 1. Centralized Shared Content Resolver (`apiService.js`)
Added and exported `resolveSharedTarget(post)` in `src/utils/apiService.js`:
- Inspects content URLs (`/article-view?id=`, `/videos?id=`, `/podcasts?id=`, `/profile?id=`, `/posts?id=`), post types, and shared objects (`sharedArticle`, `sharedVideo`, `sharedPodcast`, `sharedProfile`, `sharedContent`).
- Includes backward-compatibility heuristics for historical items (such as article `10050` / *"Best Practices for Building Scalable REST APIs with ASP.NET Core"*).
- Returns typed target: `{ type, id, url, label, actionText, icon }`.

### 2. Community View Feed (`CommunityView.jsx`)
- **Quote Card Click**: Clicking anywhere on the shared quote card calls `navigate(target.url)` (e.g. `/article-view?id=10050`).
- **Dynamic Badge & Styling**:
  - `Article`: Emerald badge `Shared Article`, `menu_book` icon, emerald border accents.
  - `Video`: Rose badge `Shared Video`, `smart_display` icon.
  - `Podcast`: Pink badge `Shared Podcast`, `podcasts` icon.
  - `Profile`: Indigo badge `Shared Profile`, `person` icon.
  - `Post`: Blue badge `Shared Post`, `repeat` icon.
- **Top Link**: Dynamically displays `Read Article ↗`, `Watch Video ↗`, `Listen Podcast ↗`, `View Profile ↗`, or `Open Post ↗`.
- **Subtext Prompt**: Dynamically prompts *"Click to open and read full article"*, *"Click to open and watch full video"*, etc.
- **Bottom Action Button**: Dynamically displays `Read Article`, `Watch Video`, `Listen Podcast`, `View Profile`, or `Open Post` with matching icons and styling, invoking `handleOpenPost(post)`.
- **Card Deduplication**: Prevents duplicate quote cards from appearing when explicit interactive article/video/podcast preview cards are already rendered.
- **Dynamic Re-share**: In the community re-share modal, passes dynamic `contentType={shareTarget?.type || 'Post'}`.

### 3. Post Card Widget (`PostCard.jsx`)
- Imported `resolveSharedTarget`.
- Updated Quote Card click handler, dynamic badges, and action text.
- Updated the three-dots menu "Open Post" action to redirect directly to the resolved target URL (`/article-view?id=...`, `/videos?id=...`, etc.).
- Passed dynamic `contentType` to `ArticleShareModal`.

### 4. Article Pages (`Articles.jsx` & `ArticleView.jsx`)
- Explicitly set `contentType="Article"` on `ArticleShareModal` invocations.

## Verification & Build
- `npm run build` completed cleanly with 0 errors in 975ms.
- Deployed latest distribution bundle to IIS production site at `C:\inetpub\wwwroot\knome\`.
