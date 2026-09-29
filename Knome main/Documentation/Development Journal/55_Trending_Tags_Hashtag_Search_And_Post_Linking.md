# Dev Journal 55: Trending Tags Real-time Hashtag Matching, Unified Hashtag Search & Post Deep-Linking

## 1. Problem Statement
1. **Disconnected Trending Tags**: The Dashboard `TrendingTagsWidget` previously used a static list (`DEFAULT_PROJECT_TAGS`) and only inspected local storage cache, leading to disconnected tags that did not match real hashtags extracted from posts, articles, and media across the platform.
2. **Hashtag Search Failure (0 Results)**: When users searched for hashtags (e.g. `#MPOnline`, `#devops`, `#DotNet`, `#sql`), the backend search engine (`SearchRepository.cs`) strictly looked for literal string contains on `ql = "#mponline"`. Posts containing the keyword without `#` (or community posts with `AudienceType == 'Community'`) were filtered out, resulting in `Found 0 results for "#MPOnline"`.
3. **Empty Post Titles in Search**: In `SearchRepository.cs`, `Title` for `Post` search items was hardcoded to `string.Empty`, causing search cards to lack clear title headers.
4. **Broken Post Result Navigation**: In `Search.jsx`, clicking a search result of `contentType === 'Post'` fell into `else { navigate('/'); }`, which redirected to Home instead of opening the post.
5. **No Deep-Link Support for Tag Filtering on Posts Page**: In `Posts.jsx`, URL query params such as `?tag=...` or `?q=...` were ignored upon navigation.

## 2. Root Cause Analysis
- **`SearchRepository.cs`**:
  - `NormalisedQuery(req)` preserved the `#` character (e.g., `#mponline`), but articles, videos, and many posts had either no `#` prefix in tag tables or general keyword presence.
  - `QueryPosts` had `p.AudienceType == "Everyone"`, which strictly omitted all community posts (e.g., posts created within the DevOps & AI community).
  - If `HasTags(req)` was true, `QueryPosts` returned an empty list immediately instead of checking if posts contained the tags in `ContentText`.
- **`Search.jsx`**:
  - `handleItemClick` had no explicit branch for `type === 'Post'`, routing users to `/`.
- **`TrendingTagsWidget.jsx`**:
  - Never queried `postsApi.getPosts()`, resulting in completely static tags.
- **`PostCard.jsx`**:
  - `renderFormattedText` only handled `http/https` URLs, leaving hashtags as static non-interactive text.

## 3. Implementation Details

### Backend (`SearchRepository.cs`)
- Added `GetQueryTerms(req)` helper: splits query into raw (`#tag`) and clean (`tag`) terms.
- Updated `QueryPosts`:
  - Matches either raw query or clean query.
  - Expands audience scope to include both `Everyone` and `Community` posts (`p.AudienceType == "Everyone" || p.AudienceType == "Community"`).
  - Matches `req.Tags` against post `ContentText`.
  - Dynamically projects informative snippet `Title` (`p.ContentText.Substring(0, 60)`).
- Updated `QueryArticles`, `QueryVideos`, `QueryCommunities`, `QueryJobs`, and `QueryPodcasts`:
  - Matches both raw query and clean query against titles, descriptions, content HTML, and tag tables (`ArticleTags`, `VideoTags`).
- Updated `RelevanceScore`:
  - Scores against both raw and clean token sets.

### Frontend
- **`TrendingTagsWidget.jsx`**:
  - Dynamically fetches posts from `postsApi.getPosts(null, null, 1, 100)` on mount.
  - Extracts all hashtags matching `/#([a-zA-Z0-9_\u0900-\u097F]+)/g`.
  - Filters out purely numeric tags from automated test runs.
  - Aggregates frequency counts and ranks hashtags by real platform popularity.
  - Displays each tag with its post count badge (e.g., `#DotNet (5)`, `#MPOnline (5)`, `#devops (8)`).
  - On clicking any hashtag, directly navigates to `/search?q=${encodeURIComponent('#' + tag)}`.
- **`Search.jsx`**:
  - Added `type === 'Post'` case in `handleItemClick`: navigates directly to `/posts?id=${id}`.
  - Updated post search result header to render `{res.title || `${res.authorFullName || 'Employee'}'s Post`}` with highlighted search keywords.
- **`Posts.jsx`**:
  - Reads `tag`, `hashtag`, and `q` from `location.search` URL parameters.
  - Synchronizes `selectedTag` and `searchQuery` dynamically when navigating between views.
  - Performs case-insensitive matching across `post.tags` and `post.content`.
- **`PostCard.jsx`**:
  - Updated `renderFormattedText` to detect `/#([a-zA-Z0-9_\u0900-\u097F]+)/g` and render them as interactive indigo clickable links that navigate to search.

## 4. Verification Results
- Scratch verification script `verify_all_hashtags.ps1` executed against live backend API on port 5095:
  - `#MPOnline`: 25 global hits, 5 matching posts.
  - `#DotNet`: 11 global hits, 5 matching posts.
  - `#devops`: 10 global hits, 8 matching posts.
  - `#kubernetes`: 4 global hits, 3 matching posts.
  - `#Engineering`: 12 global hits, 4 matching posts.
  - `#sql`: 14 global hits, 7 matching posts.
- Frontend build `npm run build` completed cleanly in 828ms with 0 errors.
- Dev server on port 5173 verified returning 200 OK.
