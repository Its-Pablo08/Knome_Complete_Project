# Dev Journal 74: Fix React Hooks Order in CommunityView

**Date:** 15 September 2026  
**Module:** Community Engine (`knomeUI/frontend/src/pages/CommunityView.jsx`)  
**Phase:** 74  

## Problem Statement

When navigating into a community, React runtime threw:
```
React has detected a change in the order of Hooks called by CommunityView.
Uncaught Error: Rendered more hooks than during the previous render.
   at useScrollLoading (useScrollLoading.js:13:45)
   at CommunityView (CommunityView.jsx:2328:83)
```

## Root Cause Analysis

In [CommunityView.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/pages/CommunityView.jsx), an early return was positioned at line 1356:
```jsx
if (isLoading || !community) {
    return (
        <div className="flex-1 flex items-center justify-center p-12 min-h-[60vh]">
            ...
        </div>
    );
}
```
However, the scroll loading hooks (`useScrollLoading`) and accompanying `useEffect` instances for posts, members, and files pagination were declared at line 2328, **after** the early return. 

On initial load (`isLoading = true`), React executed 63 hooks before returning early. Once data loaded (`isLoading = false`), React executed 64+ hooks, directly violating the **React Rules of Hooks** (hooks cannot be called conditionally or after an early return).

## Solution

1. Removed the conditional `if (isLoading || !community)` return from line 1356.
2. Relocated `if (isLoading || !community)` to right after all hooks (`useScrollLoading` and `useEffect` blocks) and immediately before the main JSX `return (<main ...>)`.
3. Ensured all 64+ hooks execute in identical order on every render regardless of loading state.

## Verification

- Ran `npm run build` in `knomeUI/frontend`. Output: `✓ built in 1.35s` with 0 errors.
- Running Vite dev server hot-reloaded the corrected hook pipeline without any runtime exceptions.
