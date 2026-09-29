# Development Journal — Phase 20: SMTP Email Notifications

**Date:** 2026-08-12
**Developer:** Sourabh Sahu
**Phase:** SMTP Email Notification Infrastructure
**Status:** Complete

---

## Objective

Implement professional automated email notifications for the Knome platform covering two critical events:

1. **Role Assignment Pending** — Sent automatically when a new employee logs into Knome for the first time via EmployeeHub SSO and does not yet have a role assigned.
2. **Role Assigned** — Sent automatically when a System Administrator approves and assigns a role to the employee from the Knome Admin Console.

---

## Files Created Today

### 1. Backend/Knome.API/Configurations/SmtpSettings.cs — NEW

Configuration model for binding SmtpSettings section from appsettings.json.
Properties: Host, Port, SenderName, SenderEmail, Username, Password, EnableSsl

### 2. Backend/Knome.API/Interfaces/IEmailService.cs — NEW

Interface with 4 methods:
- SendEmailAsync() — Generic HTML email sender
- SendRolePendingEmailAsync() — Professional pending role notification
- SendRoleAssignedEmailAsync() — Professional role confirmation with role name
- SendTemplateEmailAsync() — Generic template helper

### 3. Backend/Knome.API/Services/EmailService.cs — NEW

Full MailKit-based implementation using Gmail SMTP.
- Uses MailKit for reliable TLS/STARTTLS support
- Uses HtmlEncoder.Default.Encode() to prevent HTML injection
- SendEmailAsync() is non-blocking (returns false on failure)
- Fully inline HTML emails for Gmail/Outlook compatibility

Templates:
- SendRolePendingEmailAsync: Indigo gradient header, amber warning box, employee details table
- SendRoleAssignedEmailAsync: Emerald green gradient header, role highlight card, CTA button

---

## Files Modified Today

### 4. Backend/Knome.API/Extensions/ServiceCollectionExtensions.cs

Updated AddApplicationServices() to accept IConfiguration.
Registered:
  services.Configure<SmtpSettings>(configuration.GetSection("SmtpSettings"));
  services.AddScoped<IEmailService, EmailService>();

### 5. Backend/Knome.API/Services/AuthService.cs

- Injected IEmailService and ILogger<AuthService>
- After first-time role request INSERT: dispatches SendRolePendingEmailAsync() as fire-and-forget
- Improved error logging with _logger.LogError

Trigger: First login of any unassigned employee from EmployeeHub SSO

### 6. Backend/Knome.API/Services/UserService.cs

- Injected IEmailService and ILogger<UserService>
- ApproveRoleRequestAsync(): dispatches SendRoleAssignedEmailAsync() with confirmed role name
- RegisterPendingRoleRequestAsync(): dispatches SendRolePendingEmailAsync()

Trigger: System Admin approves role request from Admin Console

### 7. Backend/Knome.API/appsettings.json

Added SmtpSettings:
  Host: smtp.gmail.com, Port: 587
  SenderName: Knome Portal Notifications
  SenderEmail: sourabh45sahu@gmail.com
  Username: sourabh45sahu@gmail.com
  Password: Gmail App Password (16-char)
  EnableSsl: true

### 8. NuGet Package: dotnet add package MailKit

---

## Frontend Bug Fix (Same Session)

Files Fixed:
- knomeUI/frontend/src/pages/CommunityView.jsx
- knomeUI/frontend/src/components/modals/DocumentViewerModal.jsx
- knomeUI/frontend/src/components/modals/UploadVideoModal.jsx
- knomeUI/frontend/src/components/modals/UploadPodcastModal.jsx

Bug: Failed to load resource: net::ERR_FILE_NOT_FOUND blob:http://localhost:5173/...

Root Cause: URL.revokeObjectURL() called immediately while video/audio/iframe still streaming from blob URL.

Fix: Delayed revocation by 2000ms via setTimeout with try/catch. Direct HTTP URLs bypass blob conversion entirely.

---

## Architecture Notes

- Email dispatch is always fire-and-forget (failures logged, not thrown)
- No new DB tables added
- No scaffolded models modified
- Changes only in Services/, Interfaces/, Configurations/, Extensions/

---

## Verification

- dotnet build: compilation successful
- Frontend npm run build: 515 modules, 0 errors
- IEmailService registered in DI
- SmtpSettings bound from appsettings.json

---

## Next Steps

1. Test end-to-end: Login unassigned employee — check inbox for Role Pending email
2. Approve role from Admin Console — check inbox for Role Assigned email
3. Move SMTP Password to User Secrets before production
4. Future: Email digest for Karma level milestones
