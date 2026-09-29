# 57_Connection_Deduplication_And_Sent_Requests_Workflow.md

## Overview & Background
In the People Network page (`/suggested-people` / `Network.jsx`), two user-facing issues were identified:
1. **Duplicate & Self Users in Connections & Suggestions**:
   - The logged-in user (e.g., Loveneesh Sharma) was appearing under "People You May Know" suggestions because `currentUser.userId` comparison missed name or employee code variants across client demo rosters and backend identity models.
   - Colleague suggestions and 1st-degree connections could contain duplicate entries for the same individual (e.g., duplicate roster entries for Vilash Deshmukh under different employee IDs or naming suffixes).
   - Users already connected were not always excluded from "People You May Know".
2. **Sent Connection Requests Retention in Suggestions**:
   - When a user clicked "Connect" on a suggestion card, the card remained stuck in "People You May Know" with button status `[Pending • Cancel]`.
   - The user expected sent connection requests to immediately leave "People You May Know" and move into the **Connection Requests** tab under **Sent Connection Requests Pending**.

---

## Changes Implemented

### 1. Robust Self & Colleague Matching Engine (`Network.jsx`)
- **`isCurrentUser(u)`**:
  - Compares ID/userId, employee ID, email, and normalized names (stripping parentheses such as `(Old)` or `(System Admin)`).
  - Handles name normalization and phonetic matching (e.g. `Loveneesh Sharma` / `Lovnesh Sharma`) so current users are strictly excluded from Suggestions, Directory, Connections, and Requests.
- **`isSameUser(a, b)`**:
  - Compares ID/userId, employee code, and normalized name strings to accurately match users across backend data feeds, search results, and local storage caches.
- **`deduplicateUsers(list)`**:
  - Filters out self user via `isCurrentUser`.
  - Tracks `seenIds`, `seenEmpIds`, and `seenNames` using alphabetical cleaned keys.
  - Eliminates duplicate entries across all connection lists, suggestion feeds, and search directories.

### 2. Move Sent Connection Requests to Connection Requests Tab (`Network.jsx`)
- **Interactive `handleConnect(person)`**:
  - Immediately removes the targeted colleague from `suggestions` ("People You May Know").
  - Immediately prepends the colleague to `sentRequests` with status `PendingSent`.
  - Persists the sent request into client storage (`knome_sent_connection_requests`) to prevent flickering across network refreshes.
  - Displays affirmative toast: `✅ Connection request sent to ${person.name}! Moved to Connection Requests.`
- **Interactive `handleCancelRequest(person)`**:
  - Removes the colleague from `sentRequests` and cache.
  - Returns colleague to unrequested status across directory search.
- **Tab Header & Badge Synchronization**:
  - Enhanced the `Connection Requests` tab header button to display two distinct count badges:
    - Pink pill badge for received requests: `{pendingReceivedCount}`.
    - Blue pill badge for pending sent requests: `{sentRequests.length} sent`.
- **Sub-Filter Controls in Connection Requests Tab**:
  - Added filter pills in `activeTab === 'Requests'`:
    - `All Requests ({receivedRequests.length + sentRequests.length})`
    - `Received ({receivedRequests.length})`
    - `Sent Requests ({sentRequests.length})`
  - Allows users to easily switch between viewing their received invitations and tracking their sent pending requests.
- **Suggestions Exclusion**:
  - In `fetchAllNetworkData`, `suggestions` strictly excludes all users present in `connectionsList` (`Connected`), `sentRequests` (`PendingSent`), and `receivedRequests` (`PendingReceived`).

---

## Verification & Status
- **Build**: Frontend compiled with `npm run build` in 1.29s with 0 errors.
- **Backend API**: ASP.NET Core 10 builds cleanly with 0 errors.
- **Live State**:
  - Current logged-in user is never suggested to connect with themselves.
  - No duplicate users in "My 1st-Degree Connections".
  - Clicking "Connect" instantly removes the user card from Suggestions and places them in the Connection Requests tab.
