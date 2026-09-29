# Development Journal: 25. Restricted Keywords Database Seeding & Comprehensive Frontend Screening

## Context & Objectives
To ensure high governance, enterprise compliance, and workplace safety for MPOnline Knome platform, all requested offensive, spam, threat, NSFW, and sensitive PII terms were persisted in the SQL Server `RestrictedKeywords` table and screened in real-time across all frontend submission channels (posts, articles, comments, and nested replies).

Furthermore, per requirement, whenever any restricted word is typed in posts, articles, or comments, the **"Publish" / "Post" / "Submit" button is immediately hidden in real-time and replaced with a clear security warning badge**.

## Database Seeding
- **Server/DB**: `LAPTOP-458`, database `Knome`
- **Table**: `[dbo].[RestrictedKeywords]`
- **Seeded Terms**:
  - Abusive / Profanities: `chutiya`, `chutiye`, `bhenchod`, `behenchod`, `madarchod`, `bhosdike`, `harami`, `haraami`, `kaminey`, `saala`, `saale`, `gaand`, `lauda`, `choot`, `bc`, `mc`, `bsdk`, `mkc`, `bkl`
  - Spam / Phishing: `paisa kamao`, `free me paise`, `lottery jeeto`, `ghar baithe kamao`, `paytm cash`, `jaldi click karo`, `free recharge`
  - Threats / Harassment: `jaan se maar dunga`, `tujhe dekh lunga`, `maar dalunga`, `khatam kar dunga`
  - NSFW / Adult: `nude bhejo`, `hot video`, `sex chat`, `raand`, `mallu bhabhi`
  - PII / Credentials: `api key`, `password`, `aadhaar`, `credit card`, `pan card`, `cvv`, `bank account`
- Total database keyword count raised from 71 to 106.
- Master seed scripts updated:
  - `Documentation/Architecture/Seed_Additional_Restricted_Keywords.sql`
  - `Documentation/Architecture/Seed_Restricted_Keywords.sql`

## Frontend Implementation & Real-Time Button Hiding
- Updated `knomeUI/frontend/src/utils/restrictedWords.js` to include all terms in `RESTRICTED_WORDS`.
- Implemented HTML tag strip handling and word-boundary regex (`\b`) validation so substrings in legitimate words (like "Because" or "Machine") are never blocked.
- Configured real-time button suppression & warning banners across:
  - **Posts**: `CreatePostModal.jsx` (Publish/Draft buttons hidden, warning shown), `CommunityView.jsx` (Post button hidden, warning badge shown).
  - **Articles**: `Articles.jsx` (Header Publish button hidden in real-time, warning badge shown), `CreateArticleModal.jsx` (Publish Article button hidden, warning banner shown).
  - **Comments & Replies**: `PostCard.jsx`, `ArticleView.jsx`, `Podcasts.jsx`, `CommentsSection.jsx`, `VideoPlayerModal.jsx` (all submit/send/reply buttons hidden in real-time, warning badges shown).

## Verification
- Automated test script `scratch/test_restricted_keywords.js` passed all 46 test cases.
- Vite frontend build passed (`npm run build`).
- ASP.NET Core API build passed (`dotnet build -nologo`).
