# Phase 106: Footer "Powered by MPOnline Limited" Relocation to Bottom Bar

## Executive Summary
This phase relocates the **"Powered by MPOnline Limited"** brand block to the bottom bar of the global platform footer ([Footer.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/components/layout/Footer.jsx)), positioning it prominently in the middle between the copyright notice on the left and the headquarters address on the right, with enlarged logo sizing.

---

## 1. Problem & Requirement Analysis
- In previous revisions, "Powered by MPOnline Limited" was positioned in the top main row between the Knome brand block and the Support contacts.
- The user specifically requested:
  > *"ise footer mai © 2026 MPOnline Limited. All rights reserved. aur location_on State IT Park, Abbas Nagar near RGPV, Gandhi Nagar, Bhopal 462033 bich mai le aao thuda bada dikhna chahiye"*
  (Move the logo block to the center of the bottom bar between Copyright and Address, and make it slightly larger).

---

## 2. Layout & Architectural Changes

### A. Top Row Streamlining
- Left: `knomeLogoDark` wordmark, enterprise tagline (*"Connecting People & Knowledge"*), and social links (Facebook, Instagram, YouTube, LinkedIn, X).
- Right: Support & IT contact info (Phone: `0755-6720200` • Email: `knome-support@mponline.gov.in`).
- Clean, open, and balanced layout without absolute centering constraints.

### B. Bottom Sub-Bar Modernization
- Structure: Responsive flex row (`flex flex-col md:flex-row items-center justify-between gap-3 text-slate-400`).
- **Left**: Copyright statement (`© 2026 MPOnline Limited. All rights reserved.`).
- **Middle (bich mai)**:
  - **"Powered by"** label in `text-[12px] text-slate-300 font-medium tracking-wide`.
  - White logo container enlarged with `px-3 py-1 rounded-md shadow-xs`.
  - MPOnline logo enlarged to `h-5.5 sm:h-6 max-h-[24px]` (up from 18px), providing crisp brand visibility and readability of the state portal subtitle.
- **Right**: Official location with map pin (`State IT Park, Abbas Nagar near RGPV, Gandhi Nagar, Bhopal 462033`).

---

## 3. Verification & Deployment
- Production build verified with Vite (`npm run build`).
- Deployed cleanly to live IIS webroot (`C:\inetpub\wwwroot\knome`).
