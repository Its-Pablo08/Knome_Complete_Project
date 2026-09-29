# Development Journal – Phase 38: Community Module Comprehensive Architecture & Implementation Plan

**Date**: 9 September 2026  
**Phase**: Phase 38 – Community Module Architecture & Complete Integration Plan  
**Project**: Knome.API & Knome-Web (MPOnline Limited)  
**Status**: Plan Ready for Execution  

---

## 1. Executive Summary & Objective

The **Community Module** (`FR-CM-01..09`) is the organizational heart of **Knome**, providing tailored collaboration spaces for departments, domains, and guilds across MPOnline Limited.

While the backend (`CommunityController.cs`, `CommunityService.cs`, `CommunityRepository.cs`) offers a complete set of 17 REST endpoints, the frontend (`CommunityView.jsx`, `Communities.jsx`) currently utilizes local storage workarounds, lacks key API helper functions (e.g. `pinPost`, `addAdmin`, `removeAdmin`), and does not yet link posts created via the global "Write Post" modal to the `CommunityPosts` table in SQL Server.

This phase establishes the definitive end-to-end plan to:
1. **Bridge Backend & Frontend**: Provide full API integration for all community features.
2. **Enforce Core Governance Rules**: Support private join request workflows, sole admin safeguards, default community leave restrictions, and the 3-pinned posts limit.
3. **Cross-Feed Post Interoperability**: Ensure posts shared with a community audience populate both the main timeline and community discussions.
4. **Permanent Media Storage**: Shift community document/file uploads from Base64 local storage to the live backend media storage engine.

---

## 2. Key Pillars of the Plan

### Pillar 1: Full API Client Wiring (`apiService.js`)
Add missing functions to `communitiesApi`:
- `createPost(communityId, data)`
- `pinPost(communityId, postId, isPinned)`
- `addAdmin(communityId, targetUserId)`
- `removeAdmin(communityId, targetUserId)`

### Pillar 2: Cross-Feed Post Linking (`PostService.cs`)
When `AudienceType == "Community"` and `AudienceCommunityIds` has values, automatically create linking entries in `CommunityPosts` so posts appear directly in the community's feed.

### Pillar 3: Governance & Safeguards (`CommunityView.jsx`)
- **Default Org Community**: Display `🔒 Organization Mandatory Space` and disable leave button per `FR-CM-04`.
- **Private Community Join Flow**: Admin pending approvals queue using `getMembers(communityId, 'Pending')` and `decideMembership`.
- **Sole Admin Safeguard**: Promote/demote admins via backend endpoints; catch sole admin exception and prompt for successor assignment.
- **3-Pinned Posts Limit**: Enforce visual indicators and handle max 3 pin limit gracefully (`FR-CM-06`).

### Pillar 4: Files & Knowledge Hub
Replace client-side Base64 with genuine backend file uploads via `POST /api/media/upload`.

---

## 3. Verification Strategy
- Multi-user live testing (EMP001 as Community Admin, EMP002 as Member).
- Verification of Public, Private, and Default space workflows against live SQL Server database.
