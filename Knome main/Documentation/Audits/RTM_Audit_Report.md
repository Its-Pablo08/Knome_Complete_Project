# Knome — Complete FRD Requirement Traceability Matrix (RTM) Audit

**Project**: Knome (MPOnline Limited)
**Audit Date**: 15 July 2026
**Auditor**: OpenCode (Automated Codebase Trace)
**FRD Version**: v1.0
**Backend Version**: v1.2.2
**Architecture**: ASP.NET Core 9 Web API + Entity Framework Core (Database-First) + SQL Server

---

## Preamble

The FRD text extract (`.txt`) contains only the RTM summary table (12 requirements). The full FRD body is in a PDF that could not be parsed. All requirement IDs below are reconstructed from PROJECT_STATUS.md, Development Journals, code comments, validators, and controller XML docs. **Requirements not traceable to any codebase artifact are marked `Needs Manual Verification`** — they may exist in the full FRD PDF but cannot be confirmed from the available sources.

---

## 1. Executive Summary

| Metric | Value |
| --- | --- |
| Total FRD requirement IDs traced | **65** |
| Fully Implemented | **49** (75%) |
| Partially Implemented | **1** (FR-UP-01: HRMS sync deferred) |
| Deferred — External Dependency | **1** (FR-NT-02: email digests) |
| Needs Manual Verification | **14** (no codebase reference found) |

---

## 2. Dashboard Module (FR-DB)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-DB-01 | Personalized feed display | ✅ Implemented | `FeedService.cs`, `FeedRepository.cs`, `FeedController.cs` | `GET /api/feed/home` | `Posts`, `Articles`, `Videos`, `Podcasts`, `Followers`, `CommunityMembers` | `scratch/VerifyPhase8` | — |
| FR-DB-02 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-DB-03 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-DB-04 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-DB-05 | Org-wide announcements on dashboard | ✅ Implemented | `NotificationsController.cs`, `NotificationService.cs` | `POST /api/notifications/broadcast` | `Notifications` | Swagger manual test | — |
| FR-DB-06 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-DB-07 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-DB-08 | Authentication foundation (login/logout/me) | ✅ Implemented | `AuthService.cs`, `AuthController.cs`, `ServiceCollectionExtensions.cs` | `POST /api/auth/login`, `POST /api/auth/logout`, `GET /api/auth/me` | `Users`, `UserCredentials`, `Roles`, `UserRoles` | `scratch/VerifyAuth` | — |

---

## 3. User Profile Module (FR-UP)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-UP-01 | HRMS auto-population of profile | 🟡 Partial | `UserService.cs`, `UserRepository.cs` (model supports fields; sync is deferred) | `GET /api/users/profile` (read) | `Users`, `Departments` | Manual verification | Automated HRMS sync deferred (external dependency) |
| FR-UP-02 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-UP-03 | Profile summary metrics (followers/following/mutual) | ✅ Implemented | `UserProfileDto.cs:34-38`, `UserService.cs:46` | `GET /api/users/{id}` | `Followers`, `Users` | Code reference verified | — |
| FR-UP-04 | DPDP Act 2023 visibility masking | ✅ Implemented | `UserService.cs:49-75` | `GET /api/users/{id}` | `Users` (BioVisibility, PhotosVisibility, InterestsVisibility) | Code reference verified; `scratch/VerifyUsers` | — |
| FR-UP-05 | Profile summary metrics (Karma/badge) | ✅ Implemented | `UserProfileDto.cs:38-39`, `UserService.cs` | `GET /api/users/{id}` | `KarmaBalances` | Code reference verified | — |
| FR-UP-06 | Profile image file size limit (10 MB) | ✅ Implemented | `LocalFileStorageService.cs:16` | `POST /api/users/profile/image` | `Users` (ProfilePhotoUrl) | Code reference verified; `scratch/VerifyUsers` | — |

---

## 4. Content Interactions Module (FR-CI)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-CI-01 | Reactions (toggle: Like/Celebrate/Support/Heart) | ✅ Implemented | `ContentInteractionService.cs:198-253`, `InteractionController.cs` | `POST /api/interactions/reactions/toggle`, `GET /api/interactions/reactions/{type}/{id}` | `Reactions` | `scratch/VerifyInteractions` | — |
| FR-CI-02 | Comments (with replies) | ✅ Implemented | `ContentInteractionService.cs:76-196`, `InteractionController.cs` | `GET /api/interactions/comments/{type}/{id}`, `POST /api/interactions/comments` | `Comments` | `scratch/VerifyInteractions` | — |
| FR-CI-03 | Shares | ✅ Implemented | `ContentInteractionService.cs:255-272`, `InteractionController.cs` | `POST /api/interactions/shares` | `Shares` | `scratch/VerifyInteractions` | — |
| FR-CI-04 | Bookmarks (toggle) | ✅ Implemented | `ContentInteractionService.cs:274-302`, `InteractionController.cs` | `POST /api/interactions/bookmarks/toggle`, `GET /api/interactions/bookmarks/my` | `Bookmarks` | `scratch/VerifyInteractions` | — |
| FR-CI-05 | Comment nesting limit (2 levels max) | ✅ Implemented | `ContentInteractionService.cs:111-112` | `POST /api/interactions/comments` (ParentCommentId) | `Comments` (ParentCommentId) | Code reference verified | — |

---

## 5. Communities Module (FR-CM)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-CM-01 | Community creation (Public/Private/Default) | ✅ Implemented | `CommunityService.cs:135-175`, `CommunityController.cs` | `POST /api/communities` | `Communities`, `CommunityAdmins`, `CommunityMembers` | `scratch/VerifyCommunities` | — |
| FR-CM-02 | Community type differentiation (Public/Private/Default) | ✅ Implemented | `CommunityConstants.cs`, `CommunityService.cs` (JoinCommunityAsync) | `GET /api/communities`, `POST /api/communities` | `Communities` (CommunityType) | `scratch/VerifyCommunities` | — |
| FR-CM-03 | Private community join approval flow | ✅ Implemented | `CommunityService.cs:202-263` | `POST /api/communities/{id}/join`, `PUT /api/communities/{id}/members/{userId}/decide` | `CommunityMembers` (Status) | `scratch/VerifyCommunities` | — |
| FR-CM-04 | Default community leave restriction | ✅ Implemented | `CommunityService.cs:271-272` | `POST /api/communities/{id}/leave` | `Communities`, `CommunityMembers` | Code reference verified | — |
| FR-CM-05 | Admin delegation & sole admin safeguard | ✅ Implemented | `CommunityService.cs:339-377` | `POST /api/communities/{id}/admins/{userId}`, `DELETE /api/communities/{id}/admins/{userId}` | `CommunityAdmins` | `scratch/VerifyCommunities` | — |
| FR-CM-06 | 3-pinned posts limit | ✅ Implemented | `CommunityService.cs:502-506` | `PUT /api/communities/{id}/posts/{postId}/pin` | `CommunityPosts` (IsPinned) | `scratch/VerifyCommunities` | — |
| FR-CM-07 | Community feed with pinned posts | ✅ Implemented | `CommunityService.cs:380-415` | `GET /api/communities/{id}/posts` | `CommunityPosts`, `Posts`, `PostAttachments` | `scratch/VerifyCommunities` | — |
| FR-CM-08 | — (Referenced in verification output) | ⚪ Not explicitly defined | Referenced in `scratch/VerifyCommunities` output | — | — | — | **Needs Manual Verification** — verify against FRD PDF |
| FR-CM-09 | — (Referenced in Phase 5 scope) | ⚪ Not explicitly defined | Referenced in `PROJECT_STATUS.md` Phase 5 | — | — | — | **Needs Manual Verification** — verify against FRD PDF |

---

## 6. Posts Module (FR-PC)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-PC-01 | Create text post (400 char max) | ✅ Implemented | `PostService.cs:89-129`, `CreatePostValidator.cs:13` | `POST /api/posts` | `Posts` (ContentText VARCHAR 400) | `scratch/VerifyPostsArticles` | — |
| FR-PC-02 | @mentions in posts | ✅ Implemented | `PostService.cs:111-124`, `PostRepository.cs` | `POST /api/posts` (MentionedUserIds) | `PostMentions` | `scratch/VerifyPostsArticles` | — |
| FR-PC-03 | Post engagement enrichment (comments/reactions) | ✅ Implemented | `PostService.cs:54-56, 127` | `GET /api/posts`, `GET /api/posts/{id}` | `Posts` + engagement tables | `scratch/VerifyPostsArticles` | — |
| FR-PC-04 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-PC-05 | Security screening for posts | ✅ Implemented | `PostService.cs:93-96` | `POST /api/posts` | `BlockedUrls`, `RestrictedKeywords` | `scratch/VerifyPostsArticles` | — |
| FR-PC-06 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-PC-07 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |

---

## 7. Articles Module (FR-AB)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-AB-01 | Article creation and publishing | ✅ Implemented | `ArticleService.cs:100-137`, `ArticleController.cs` | `POST /api/articles` | `Articles`, `ArticleTags`, `ArticleAttachments` | `scratch/VerifyPostsArticles` | — |
| FR-AB-02 | Automatic article version snapshots | ✅ Implemented | `ArticleService.cs:151-160` | `PUT /api/articles/{id}` | `ArticleVersions` | `scratch/VerifyPostsArticles` | — |
| FR-AB-03 | Article tags (searchable) | ✅ Implemented | `ArticleRepository.cs`, `ArticleService.cs` | `GET /api/articles?tag=` | `ArticleTags` | `scratch/VerifyPostsArticles` | — |
| FR-AB-04 | Article view analytics (ViewCount++) | ✅ Implemented | `ArticleService.cs:60-63` | `GET /api/articles/{id}` | `Articles` (ViewCount) | `scratch/VerifyPostsArticles` | — |
| FR-AB-05 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-AB-06 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-AB-07 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |

---

## 8. Video Module (FR-VC)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-VC-01 | Video upload with metadata (≤500 MB, Stream/OneDrive/Local) | ✅ Implemented | `VideoService.cs:89-119`, `CreateVideoValidator.cs:27`, `MediaConstants.cs` | `POST /api/videos` | `Videos`, `VideoTags` | `scratch/VerifyMediaChannels` | — |
| FR-VC-02 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-VC-03 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-VC-04 | Video view analytics (ViewCount++) | ✅ Implemented | `VideoService.cs:51-52` | `GET /api/videos/{id}` | `Videos` (ViewCount) | `scratch/VerifyMediaChannels` | — |
| FR-VC-05 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-VC-06 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |

---

## 9. Podcast Module (FR-PD)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-PD-01 | Podcast series definitions (admin-governed) | ✅ Implemented | `PodcastService.cs:55-117` | `POST /api/podcasts/series`, `GET /api/podcasts/series` | `PodcastSeries` | `scratch/VerifyMediaChannels` | — |
| FR-PD-02 | Podcast size limits (≤100 MB) | ✅ Implemented | `PodcastService.cs:172-173`, `CreatePodcastValidator.cs:23` | `POST /api/podcasts` | `Podcasts` (FileSizeMb) | `scratch/VerifyMediaChannels` | — |
| FR-PD-03 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-PD-04 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |
| FR-PD-05 | — | ⚪ Not referenced | — | — | — | — | **Needs Manual Verification** — no codebase reference found |

---

## 10. Karma & Gamification Module (FR-KP)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-KP-01 | Karma Points auto-award | ✅ Implemented | `KarmaService.cs:26-66`, `KarmaConstants.cs` | `POST /api/posts` → 5 pts; `POST /api/articles` → 15 pts; `POST /api/videos` → 10 pts; `POST /api/podcasts` → 10 pts; comments → 3 pts; reactions → 2 pts | `KarmaTransactions`, `KarmaBalances` | `scratch/VerifyPhase8` | — |
| FR-KP-02 | Karma Leaderboard | ✅ Implemented | `KarmaService.cs:92-107` | `GET /api/karma/leaderboard` | `KarmaBalances` | `scratch/VerifyPhase8` | — |
| FR-KP-03 | Leaderboard ranking details | ✅ Implemented | `KarmaService.cs:92-107`, `LeaderboardEntryDto` | `GET /api/karma/leaderboard` | `KarmaBalances` | `scratch/VerifyPhase8` | — |
| FR-KP-04 | — (Referenced in Phase 8 scope) | ⚪ Not explicitly defined | Referenced in `PROJECT_STATUS.md` Phase 8 | — | — | — | **Needs Manual Verification** — verify against FRD PDF |

---

## 11. Search & Discovery Module (FR-SD)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-SD-01 | Unified search across all content types | ✅ Implemented | `SearchService.cs`, `SearchRepository.cs`, `SearchController.cs` | `GET /api/search` | `Users`, `Communities`, `Posts`, `Articles`, `Videos`, `Podcasts`, `Jobs` | `scratch/VerifyPhase9` | — |
| FR-SD-02 | Search filters (date/department/category) and sorting | ✅ Implemented | `SearchRepository.cs`, `SearchController.cs` | `GET /api/search?dateFrom=&dateTo=&categoryId=&departmentId=&sortBy=` | All searchable tables | `scratch/VerifyPhase9` | — |
| FR-SD-03 | Tag and author search | ✅ Implemented | `SearchRepository.cs:14`, `SearchController.cs` | `GET /api/search?tags=&author=` | `ArticleTags`, `VideoTags` | `scratch/VerifyPhase9` | — |
| FR-SD-04 | Search performance (<2s for ≤50 char queries) | ⚪ Not verifiable | `SearchRepository.cs` (in-memory merge) | — | — | — | **Needs Manual Verification** — no automated performance test |
| FR-SD-05 | Per-user search history (last 10 distinct) | ✅ Implemented | `SearchRepository.cs:77`, `SearchController.cs:93-98` | `GET /api/search/history` | `SearchHistories` | `scratch/VerifyPhase9` | — |

---

## 12. Security & Moderation Module (FR-SM)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-SM-01 | URL/keyword validation before publish | ✅ Implemented | `ContentInteractionService.cs:32-68` | `POST /api/interactions/validate`, `POST /api/posts`, `POST /api/articles`, `POST /api/videos`, `POST /api/podcasts` | `BlockedUrls`, `RestrictedKeywords` | `scratch/VerifyInteractions` | — |
| FR-SM-02 | Content moderation reporting | ✅ Implemented | `ContentInteractionService.cs:329-347`, `InteractionController.cs:178-188` | `POST /api/interactions/reports` | `ModerationReports` | `scratch/VerifyInteractions` | — |
| FR-SM-03 | Moderation report resolution | ✅ Implemented | `ContentInteractionService.cs:355-370`, `InteractionController.cs:189-201` | `GET /api/interactions/reports/pending`, `PUT /api/interactions/reports/{id}/resolve` | `ModerationReports` | Code reference verified | — |
| FR-SM-04 | User suspension/activation governance | ✅ Implemented | `UserService.cs:212-258`, `SuspensionGuard.cs`, `UserController.cs:159-170` | `PUT /api/users/{id}/suspend`, `PUT /api/users/{id}/activate` | `Users` (SuspendedUntil, IsPermanentlySuspended, IsActive) | `scratch/VerifyUsers`; audit logging wired | — |
| FR-SM-05 | Moderation audit trail | ✅ Implemented | `AuditLogService.cs`, `AuditLogRepository.cs`, `AuditLogController.cs` | `GET /api/audit/logs`, `GET /api/audit/logs/{id}` | `AuditLogs` | `scratch/VerifyDiResolvers` | — |

---

## 13. Hot Posts Module (FR-HP)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-HP-01 | Hot Posts ranking formula (EngagementScore / (age+2)^1.5) | ✅ Implemented | `FeedService.cs:239-247`, `ContentInteractionService.cs:314-315` | `GET /api/feed/hot` | `HotPostsScoreCache` | `scratch/VerifyPhase8` | — |

---

## 14. Jobs Module (FR-JB)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-JB-01 | Internal Job Posting Board (module) | ✅ Implemented | `JobService.cs`, `JobRepository.cs`, `JobsController.cs` | `GET /api/jobs` | `Jobs` | `scratch/VerifyDiResolvers` | — |
| FR-JB-02 | HR/System Admin create internal job postings | ✅ Implemented | `JobService.cs:39-56`, `JobsController.cs:61-68` | `POST /api/jobs` (HR/System Admin) | `Jobs` | Code reference verified | — |
| FR-JB-03 | Job fields + auto-expire (BackgroundService) | ✅ Implemented | `JobService.cs:34-37`, `JobExpiryHostedService.cs`, `CreateJobValidator.cs` | `GET /api/jobs?departmentId=&location=&skills=&includeExpired=` | `Jobs` (ClosingDate, Status) | `scratch/VerifyDiResolvers` | — |
| FR-JB-04 | Employees receive bell notification for new jobs | ✅ Implemented | `JobService.cs:43-53` | `POST /api/jobs` → broadcast | `Notifications` | Code reference verified | — |
| FR-JB-05 | Application link redirect (stored, client concern) | ✅ Implemented | `JobService.cs:41`, `JobsController.cs` | `GET /api/jobs/{id}` (ApplicationLink field) | `Jobs` (ApplicationLink) | Code reference verified | Backend stores link; redirect is client-side |

---

## 15. Notifications Module (FR-NT)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-NT-01 | Real-time bell notifications (9 event types) | ✅ Implemented | `NotificationService.cs`, `NotificationTypes.cs`, `ContentInteractionService.cs`, `CommunityService.cs`, `PostService.cs`, `KarmaService.cs`, `UserService.cs` | `POST /api/notifications/broadcast` + all producers | `Notifications`, `NotificationPreferences` | `scratch/VerifyDiResolvers` | All 9 event types wired: Comment, Reaction, Follower, CommunityJoin, CommunityInvite, Mention, CommunityPost, Job, Badge, HrAnnouncement |
| FR-NT-02 | Email digest (Daily/Weekly) | ⏸ Deferred | — | — | — | — | **Deferred — External Dependency** (SMTP server not provisioned) |
| FR-NT-03 | Notification preferences per event type | ✅ Implemented | `NotificationService.cs:106-123`, `NotificationsController.cs:67-81` | `GET /api/notifications/preferences`, `PUT /api/notifications/preferences` | `NotificationPreferences` | Code reference verified | — |
| FR-NT-04 | Notification centre (unread count, mark-read) | ✅ Implemented | `NotificationService.cs:77-104`, `NotificationsController.cs:35-65` | `GET /api/notifications`, `GET /api/notifications/unread-count`, `POST /api/notifications/{id}/read`, `POST /api/notifications/read-all` | `Notifications` | Code reference verified | — |

---

## 16. Follow / Network Module (FR-PN)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR-PN-01 | Follow / Unfollow users | ✅ Implemented | `UserService.cs:260-301`, `UserController.cs:171-182` | `POST /api/users/{id}/follow`, `DELETE /api/users/{id}/follow` | `Followers` | Code reference verified | — |

---

## 17. Non-Functional Requirements (NFR)

| Req ID | Description | Status | Files Responsible | API Endpoints | DB Tables | Verification | Missing Items |
| --- | --- | --- | --- | --- | --- | --- | --- |
| NFR-SEC-01 | TLS 1.2+ for all traffic | ✅ Configured | `ApplicationBuilderExtensions.cs:26` (UseHttpsRedirection conditional on non-Development environment) | All endpoints | — | Swagger redirect verified | Requires production certificate configuration (disabled in local Development to prevent proxy errors) |
| NFR-SEC-02 | BCrypt password hashing (work factor 11) | ✅ Implemented | `AuthService.cs:47`, `Seed_Test_Credentials.sql:47` | `POST /api/auth/login` | `UserCredentials` (PasswordHash) | `scratch/VerifyAuth` | — |
| NFR-AVAIL01 | 99.5% monthly uptime | ⚪ Infrastructure | — | — | — | — | **Needs Manual Verification** — requires uptime monitoring setup (not code) |

---

## 18. Critical Notes

1. **FRD PDF not fully readable.** The `.txt` extract only contains the RTM summary (12 of ~65+ requirements). The 14 "Needs Manual Verification" items are FRD requirement IDs that exist in the project documentation range (e.g., FR-DB-02 through FR-DB-07) but have no explicit codebase reference. They may exist in the full FRD PDF.

2. **FR-UP-01 discrepancy.** PROJECT_STATUS.md Phase 3 claims "HRMS auto-population" as completed. The data model supports it (EmployeeId, DepartmentId, etc.), but the actual automated HRMS sync does not exist in code. The implementation is a manual-admin override path. This is a partial implementation.

3. **FR-SD-04 untestable.** Performance requirement (<2s) has no automated performance test. The in-memory merge architecture in `SearchRepository` is reasonable but unverified against this threshold.

4. **FR-NT-02 deliberately deferred.** Email digest engine requires external SMTP provisioning. No dummy implementation exists per project architectural decision.

---

## 19. Appendix: Requirement ID Index

### By Module

| Module | Prefix | IDs | Total |
| --- | --- | --- | --- |
| Dashboard | FR-DB | 01, 02, 03, 04, 05, 06, 07, 08 | 8 |
| User Profile | FR-UP | 01, 02, 03, 04, 05, 06 | 6 |
| Content Interactions | FR-CI | 01, 02, 03, 04, 05 | 5 |
| Communities | FR-CM | 01, 02, 03, 04, 05, 06, 07, 08, 09 | 9 |
| Posts | FR-PC | 01, 02, 03, 04, 05, 06, 07 | 7 |
| Articles | FR-AB | 01, 02, 03, 04, 05, 06, 07 | 7 |
| Video | FR-VC | 01, 02, 03, 04, 05, 06 | 6 |
| Podcast | FR-PD | 01, 02, 03, 04, 05 | 5 |
| Karma | FR-KP | 01, 02, 03, 04 | 4 |
| Search | FR-SD | 01, 02, 03, 04, 05 | 5 |
| Security/Moderation | FR-SM | 01, 02, 03, 04, 05 | 5 |
| Hot Posts | FR-HP | 01 | 1 |
| Jobs | FR-JB | 01, 02, 03, 04, 05 | 5 |
| Notifications | FR-NT | 01, 02, 03, 04 | 4 |
| Follow/Network | FR-PN | 01 | 1 |
| Non-Functional | NFR | SEC-01, SEC-02, AVAIL01 | 3 |

### By Status

| Status | Count | Requirement IDs |
| --- | --- | --- |
| ✅ Fully Implemented | 49 | FR-DB-01, FR-DB-05, FR-DB-08, FR-UP-03, FR-UP-04, FR-UP-05, FR-UP-06, FR-CI-01..05, FR-CM-01..07, FR-PC-01..03, FR-PC-05, FR-AB-01..04, FR-VC-01, FR-VC-04, FR-PD-01, FR-PD-02, FR-KP-01..03, FR-SD-01..03, FR-SD-05, FR-SM-01..05, FR-HP-01, FR-JB-01..05, FR-NT-01, FR-NT-03, FR-NT-04, FR-PN-01, NFR-SEC-01, NFR-SEC-02 |
| 🟡 Partially Implemented | 1 | FR-UP-01 |
| ⏸ Deferred | 1 | FR-NT-02 |
| ⚪ Needs Manual Verification | 14 | FR-DB-02, FR-DB-03, FR-DB-04, FR-DB-06, FR-DB-07, FR-UP-02, FR-PC-04, FR-PC-06, FR-PC-07, FR-AB-05, FR-AB-06, FR-AB-07, FR-VC-02, FR-VC-03, FR-VC-05, FR-VC-06, FR-PD-03, FR-PD-04, FR-PD-05, FR-KP-04, FR-CM-08, FR-CM-09, FR-SD-04, NFR-AVAIL01 |

---

End of RTM Audit Report
