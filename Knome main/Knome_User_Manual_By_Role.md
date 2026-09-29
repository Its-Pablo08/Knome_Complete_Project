# Knome Enterprise Knowledge Management Platform
## Role-Based User Manual

**Target Audience:** All Knome Platform Users (Employees, Community Admins, HR Admins, System Admins)  
**Enterprise:** MPOnline Limited  
**Document Version:** 1.0.0  
**Language:** English  

---

# Table of Contents
1. [Overview & Role Hierarchy](#1-overview--role-hierarchy)
2. [Employee User Manual](#2-employee-user-manual)
3. [Community Administrator User Manual](#3-community-administrator-user-manual)
4. [HR Administrator User Manual](#4-hr-administrator-user-manual)
5. [System Administrator User Manual](#5-system-administrator-user-manual)
6. [Quick Troubleshooting & Support](#6-quick-troubleshooting--support)

---

## 1. Overview & Role Hierarchy

The **Knome** platform is built on Role-Based Access Control (RBAC). A user's assigned role determines their permissions, navigation options, dashboard widgets, and administrative controls across the platform.

```
+-----------------------------------------------------------------------+
|                       System Administrator                            |
|    (Governance, Audit Logs, User Suspensions, Keyword Blocklists)     |
+-----------------------------------+-----------------------------------+
                                    |
+-----------------------------------+-----------------------------------+
|                        HR Administrator                               |
|       (HR Analytics, Department Metrics, Job Vacancies, Broadcasts)   |
+-----------------------------------+-----------------------------------+
                                    |
+-----------------------------------+-----------------------------------+
|                      Community Administrator                          |
|    (Community Management, Join Request Approvals, Moderation)         |
+-----------------------------------+-----------------------------------+
                                    |
+-----------------------------------+-----------------------------------+
|                             Employee                                  |
|   (Feed Posts, Articles, Videos, Podcasts, Connections, Karma)        |
+-----------------------------------------------------------------------+
```

---

## 2. Employee User Manual

The **Employee** role is the primary self-service account for all staff members of MPOnline Limited.

### 2.1 Getting Started & Authentication
1. **Accessing Knome**: Navigate to `http://localhost:5173/login` (or production web URL).
2. **Logging In**: Enter your Employee ID (e.g., `EMP001`) and your password.
3. **Session Persistence**: Upon successful authentication, a JWT Bearer token is saved securely in your browser session.

### 2.2 Navigation & Main Dashboard
* **Home Dashboard (`/dashboard`)**: Displays your personal feed, upcoming events, quick stats, karma point balance, and colleague recommendations ("People You May Know").
* **Top Navigation Bar (`Navbar`)**:
  * **Global Search**: Type keywords to search across employees, posts, articles, videos, podcasts, and communities.
  * **Audio Player Shortcut**: Quick access to active background audio playback.
  * **Notification Bell**: Click to view real-time notifications for likes, comments, connection requests, and system alerts.
  * **Profile Menu**: Access your profile, saved bookmarks, notification settings, or log out.

### 2.3 Social Feed & Short Posts (`/posts`)
* **Creating a Post**:
  1. Click **"Create Post"** or the top status bar on the feed.
  2. Type your update text. You may include hashtags (e.g., `#MPOnline #ProjectUpdate`).
  3. Attach images or media files using the attachment button.
  4. Select visibility (Public to all employees, or targeted to a specific Community).
  5. Click **Publish Post**.
* **Interacting with Posts**:
  * **Reactions**: Click the Like/Clap button to appreciate a post.
  * **Comments**: Click Comment to open the inline thread and type nested replies.
  * **Bookmark**: Click the Bookmark icon to save the post into your custom categories.
  * **Share**: Share the post via internal link or direct message.

### 2.4 Articles & Long-Form Publishing (`/articles`)
* **Reading Articles**: Browse featured long-form technical write-ups, filter by category (e.g., Engineering, HR, Leadership), and view estimated reading times.
* **Publishing an Article**:
  1. Click **"Write Article"** button on the Articles page.
  2. Enter the Article Title, Subtitle, and select a Category.
  3. Write your content using full **Markdown** formatting support.
  4. Add tags (e.g., `csharp`, `dotnet`, `react`) and upload a cover header image.
  5. Save as a Draft or click **Publish Article**.

### 2.5 Video & Podcast Media Hubs (`/videos` & `/podcasts`)
* **Watching Videos (`/videos`)**: Browse technical demos, department presentations, and training streams. Click any video card to open the streaming video player modal.
* **Uploading Videos**: Click **"Upload Video"**, attach a video file, enter title/description, select category tags, and publish.
* **Listening to Podcasts (`/podcasts`)**: Browse audio series and episodes. Click **Play** on any episode to initialize the continuous **Global Audio Player** at the bottom of the page, allowing you to listen uninterrupted while navigating to other pages.

### 2.6 Networking & Connections (`/network`)
* **Connecting with Colleagues**:
  * View pending connection requests sent to you and click **Accept** or **Decline**.
  * Browse **"People You May Know"** recommendations and click **Connect**.
* **Following Colleagues**: Click **Follow** on any employee profile to receive their published articles and updates in your feed without formal connection.

### 2.7 Employee Communities (`/communities`)
* **Discovering Communities**: Browse public interest or department communities.
* **Joining Communities**: Click **Join** for public groups, or **Request to Join** for private/invite-only communities.
* **Participating**: Access dedicated community feed channels, post updates, and view community members.

### 2.8 Karma Points & Gamification (`/karma-history`)
* **Earning Karma**: Earn points automatically by creating posts (+10 pts), publishing articles (+25 pts), receiving likes (+2 pts), and maintaining daily streak activity.
* **Tracking Points**: View total accumulated Karma, view your transaction history, and check your rank on the monthly employee leaderboard.

### 2.9 Job Board & Internal Careers (`/jobs`)
* **Browsing Vacancies**: Explore internal job openings posted by HR across departments.
* **Applying**: Click on a job posting to view requirements, click **Apply Now**, and submit your internal profile application.

---

## 3. Community Administrator User Manual

The **Community Administrator** role possesses full administrative control over specific employee communities.

### 3.1 Community Setup & Configuration
1. **Launching a Community**:
   * Navigate to `/communities` and click **"Create Community"**.
   * Enter Community Name, Description, Cover Banner, and set Privacy Type:
     * **Public**: Any employee can join immediately.
     * **Private**: Requires Community Admin approval to join.
2. **Configuring Rules**: Define community guidelines and topic scopes.

### 3.2 Member Management & Approvals
* **Reviewing Join Requests**:
  * Open your Community View page (`/community/:id`).
  * Click the **"Pending Requests"** tab.
  * Review employee profiles requesting access and click **Approve** or **Reject**.
* **Managing Member Roles**:
  * View the Member Roster.
  * Promote active members to **Moderator** or **Co-Admin**.
  * Remove members who violate community guidelines.

### 3.3 Content Moderation & Curation
* **Pinning Announcements**: Pin important community posts or guidelines to the top of the community feed.
* **Deleting Off-Topic Posts**: Remove inappropriate or off-topic posts submitted to the community channel.

---

## 4. HR Administrator User Manual

The **HR Administrator** role manages organization-wide communication, internal mobility, and employee engagement metrics.

### 4.1 HR Analytics Dashboard (`/hr-analytics`)
* **Accessing Analytics**: Navigate to `/hr-analytics` via the main sidebar.
* **Department Participation**: View charts depicting employee engagement rates across all MPOnline departments.
* **Top Creators & Content Consumption**: Identify top article publishers, popular videos, and overall content consumption statistics.
* **Exporting Reports**: Export monthly engagement metrics for executive reviews.

### 4.2 Internal Job Vacancy Portal (`/jobs`)
* **Posting a Job Opening**:
  1. Navigate to `/jobs` and click **"Create Job Posting"**.
  2. Enter Job Title, Department, Work Location, Role Description, and Key Requirements.
  3. Set Application Deadline date.
  4. Click **Publish Vacancy**.
* **Managing Applications**:
  * Click on an active job posting to view internal applicants.
  * Review employee applicant profiles, skills, and current department details.
* **Closing Job Vacancies**: Click **Close Posting** when a position is filled or expired. (The backend `JobExpiryHostedService` also automatically archives expired listings).

### 4.3 HR Announcements & Broadcasts
* **Broadcast Alerts**: Publish company-wide announcements that display prominently at the top of all employee dashboards and send instant push notifications via SignalR.

---

## 5. System Administrator User Manual

The **System Administrator** role holds ultimate authority for security, audit logging, content moderation, user account status, and system governance.

### 5.1 Admin Console (`/admin-console`)
Navigate to `/admin-console` from the user profile dropdown or sidebar.

### 5.2 Audit Logs & Security Inspection
* **Viewing Audit Logs**: Inspect immutable system logs recording key security events (Logins, Failed Auth Attempts, Role Changes, Content Deletions, Account Suspensions).
* **Filtering Logs**: Filter by Date Range, Employee ID, Event Type, or IP Address.

### 5.3 Moderation Queue & Flagged Content
* **Reviewing Reports**: Access the **Content Moderation Queue** to inspect posts, articles, or comments flagged by users.
* **Moderation Actions**:
  * **Dismiss Report**: Mark the report as invalid.
  * **Delete Content**: Purge violating posts/comments from the database.
  * **Issue Warning**: Send a formal warning notification to the content creator.

### 5.4 User Account Governance & Suspensions
* **Managing User Accounts**: Search for any employee account in the Admin Console.
* **Suspending an Account**:
  1. Select the user account and click **Suspend Account**.
  2. Provide a mandatory reason for suspension.
  3. The `SuspensionGuard` backend service immediately blocks the user's JWT token from making any API calls.
* **Restoring Accounts**: Click **Reinstate Account** to clear suspension flags and restore platform access.

### 5.5 Keyword Blocklists & URL Security
* **Restricted Words**: Maintain a list of restricted keywords automatically flagged or blocked by client-side and server-side filters.
* **Blocked URLs**: Configure malicious or forbidden external domain links to prevent employees from posting unsafe web URLs.

---

## 6. Quick Troubleshooting & Support

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| **Login Failed** | Incorrect Employee ID or Password | Verify credentials (default test: `EMP001` / `Password@123`). Contact System Admin to reset password. |
| **"Account Suspended" Alert** | User account flagged for policy violation | Contact your System Administrator for audit review. |
| **Audio Stops When Changing Pages** | Audio played outside Global Audio Context | Ensure playback is triggered through the continuous `GlobalAudioPlayer`. |
| **Private Community Content Not Visible** | Membership pending approval | Check with the Community Admin to approve your pending join request. |
| **Unable to Post Job** | Insufficient Role Privileges | Job creation requires `HR Administrator` or `System Administrator` role. |

---
*Manual prepared for MPOnline Limited Knome Knowledge Management Platform.*
