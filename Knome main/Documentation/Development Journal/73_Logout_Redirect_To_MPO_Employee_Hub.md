# Dev Journal 73: Logout Redirect to MPO Employee Hub

**Date:** 15 September 2026  
**Module:** Authentication & Navigation Layout (`knomeUI/frontend`)  
**Phase:** 73  

## Problem Statement

Previously, logging out of Knome defaulted to reloading the local Knome root (`'/'`). The user requested that logging out of Knome should redirect to the central **MPO Employee Hub**:
> *"log out hone ke baad [MPO Employee Hub](https://counselling-1.mponline.demo.gov.in:3001/applications) is link par redirect ho jana"*

## Proposed Strategy & Implementation

1. **UserContext (`UserContext.jsx`)**:
   - Updated the `logout(customRedirectUrl)` handler so that when no custom URL is supplied, it defaults to:
     `https://counselling-1.mponline.demo.gov.in:3001/applications`.
   - Cleanses user tokens (`knome_jwt`, `accessToken`, `userProfile`, `knome_refresh`) and terminates active session before redirecting.
   - Preserves `customRedirectUrl === false` for callers like `SsoLogoutPage` that manage their own redirect.

2. **Navbar Dropdown (`Navbar.jsx`)**:
   - Updated the user profile menu **Log Out** button confirmation modal message:
     `"Are you sure you want to log out of Knome? You will be redirected to MPO Employee Hub."`
   - Invokes `logout('https://counselling-1.mponline.demo.gov.in:3001/applications')` upon confirmation.

3. **SSO Logout (`SsoLogoutPage.jsx`)**:
   - Updated `SsoLogoutPage` to pass `false` to `logout` so it clears local session state and cleanly executes the central MPO logout redirect to `returnUrl`.

## Verification

- Ran `npm run build` in `knomeUI/frontend`. Output: `✓ built in 1.34s` with 0 errors.
- Verified active Vite development server hot-reloaded the updated navigation and authentication context.
