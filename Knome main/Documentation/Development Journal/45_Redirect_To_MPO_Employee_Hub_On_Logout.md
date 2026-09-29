# 45. Redirect to MPO Employee Hub on Logout

## Overview
User requested that whenever any user logs out of Knome, they must be redirected to the MPO Employee Hub applications portal:
`https://counselling-1.mponline.demo.gov.in:3001/applications`

## Changes Made
1. **`UserContext.jsx`**:
   - Updated `logout(customRedirectUrl)`:
     - Invalidates token with backend `authApi.logout(refreshToken)` (if present).
     - Clears all session and local storage tokens (`knome_jwt`, `accessToken`, `userProfile`, `knome_refresh`, `knome_employeeId`).
     - Resets `currentUser` to `null` and `isAuthenticated` to `false`.
     - Redirects browser to `https://counselling-1.mponline.demo.gov.in:3001/applications`.
2. **`SsoLogoutPage.jsx`**:
   - Default return URL updated to `https://counselling-1.mponline.demo.gov.in:3001/applications`.
3. **`AuthGuard.jsx`**:
   - Button text updated to reflect "Log Out & Return to MPO Employee Hub".

## Verification
- `npm run build` executed and succeeded with 0 errors.
