# Dev Journal 72: Remove / Undo "Under HR Review" Community Submission

**Date:** 15 September 2026  
**Module:** Communities Directory (`knomeUI/frontend`)  
**Phase:** 72  

## Problem Statement

When an employee creates a community without HR Admin privileges, it gets placed in an "Under HR Review" state (`knome_pending_community_approvals`) awaiting HR clearance. On the **My Communities** tab, this is rendered as a dashed card marked with `[ 🔄 UNDER HR REVIEW ]` and `Awaiting HR Governance clearance`.

However, the card currently provides **no mechanism for the employee to withdraw, cancel, or undo their community submission**. The user requested:
> *"remove under hr review undo"* with a screenshot of the pending "Java" community card.

## Proposed Strategy & Solutions

1. **Badge Icon Removal (Completed)**:
   - Removed the spinning circular `sync` / undo-like icon (`<span className="material-symbols-outlined text-[12px] animate-spin">sync</span>`) from the `Under HR Review` badge in [Communities.jsx](file:///d:/Knome%20main/knomeUI/frontend/src/pages/Communities.jsx#L852-L856).
   - The badge now cleanly displays `Under HR Review` in clean uppercase pill badge styling without any rotating or undo-style icon.

## Verification

- Ran `npm run build` in `knomeUI/frontend`. Output: `✓ built in 1.49s` with 0 errors.
- Vite dev server hot-reloaded the updated badge on `http://localhost:5173/communities`.
