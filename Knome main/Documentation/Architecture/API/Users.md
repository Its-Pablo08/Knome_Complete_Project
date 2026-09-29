# Knome.API — User Profile & Management Specification (`api/users`)

This document outlines the REST API endpoints, request/response schemas, validation rules, and authorization policies for the **User Profile and Management** module (`Phase 3`).

---

## 1. Authentication & Security Header
All endpoints require a valid **Symmetric HS256 JWT Bearer Token** in the `Authorization` header:
```http
Authorization: Bearer <your_jwt_token>
```

---

## 2. Employee Self-Service Endpoints

### 2.1 Get My Profile
Retrieves the complete profile, visibility settings, skills, interests, roles, and metrics (`FollowersCount`, `FollowingCount`, `MutualConnectionsCount`, `KarmaPoints`) of the authenticated user.

- **URL**: `GET /api/users/profile`
- **Authorization**: Required (`[Authorize]`)

#### Response (`200 OK`)
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Profile retrieved successfully.",
  "data": {
    "userId": 1,
    "employeeId": "EMP001",
    "fullName": "John Doe",
    "email": "john.doe@knome.local",
    "designation": "Senior Software Engineer",
    "departmentId": 1,
    "departmentName": "Technology",
    "location": "Bhopal HQ",
    "profilePhotoUrl": "/uploads/profiles/user_1_abc123.jpg",
    "bio": "Passionate ASP.NET Core 9 Architect building the Knome EEP module.",
    "bioVisibility": "Public",
    "networkVisibility": "Public",
    "photosVisibility": "Public",
    "interestsVisibility": "Public",
    "isActive": true,
    "suspendedUntil": null,
    "isPermanentlySuspended": false,
    "mobileNo": "+91-9876543210",
    "managerEmployeeId": "EMP000",
    "joiningDate": "2024-01-15",
    "lastLogin": "2026-07-09T06:30:00Z",
    "profileCompletion": 85,
    "skills": ["C#", ".NET 9", "EF Core", "System Architecture"],
    "interests": ["Cloud Computing", "AI/ML", "Microservices"],
    "roles": ["Employee"],
    "followersCount": 14,
    "followingCount": 22,
    "mutualConnectionsCount": 0,
    "karmaPoints": 150,
    "karmaBadgeLevel": "Bronze"
  }
}
```

---

### 2.2 Update My Profile
Updates general profile attributes including Bio, Location, Mobile Number, Skills, Interests, and DPDP Act visibility preferences (`FR-UP-02`, `FR-UP-04`).

- **URL**: `PUT /api/users/profile`
- **Authorization**: Required (`[Authorize]`)
- **Headers**: `Content-Type: application/json`

#### Request Payload
```json
{
  "bio": "Senior ASP.NET Core Architect & Tech Lead.",
  "location": "Indore Office",
  "mobileNo": "+91-9876543210",
  "bioVisibility": "Connections Only",
  "networkVisibility": "Public",
  "photosVisibility": "Public",
  "interestsVisibility": "Private",
  "skills": ["C#", ".NET 9", "Microservices", "Docker", "EF Core"],
  "interests": ["Kubernetes", "DevOps", "AI Agents"]
}
```

#### Validation Rules (`UpdateProfileValidator`)
- `bio`: Maximum 500 characters.
- `location`: Maximum 100 characters.
- `mobileNo`: Maximum 20 characters.
- `*Visibility`: Must be exact string `"Public"`, `"Connections Only"`, or `"Private"`.
- `skills` & `interests`: Maximum 30 items per list; each string max 100 characters.

---

### 2.3 Update My Bio
Dedicated endpoint for quick Bio and BioVisibility updates (`FR-UP-02`).

- **URL**: `PUT /api/users/profile/bio`
- **Authorization**: Required (`[Authorize]`)

#### Request Payload
```json
{
  "bio": "Quick update to my profile bio.",
  "bioVisibility": "Public"
}
```

---

### 2.4 Update My Skills
Dedicated endpoint for atomically syncing the user's skills list (`FR-UP-02`).

- **URL**: `PUT /api/users/profile/skills`
- **Authorization**: Required (`[Authorize]`)

#### Request Payload
```json
{
  "skills": ["C#", ".NET 9", "Azure", "SQL Server"]
}
```

---

### 2.5 Upload Profile Image
Uploads and resizes/stores the user's profile photo (`FR-UP-06`). Replaces any existing profile image on disk.

- **URL**: `POST /api/users/profile/image`
- **Authorization**: Required (`[Authorize]`)
- **Headers**: `Content-Type: multipart/form-data`

#### Form Parameters
| Parameter | Type | Description |
| :--- | :--- | :--- |
| `File` | `IFormFile` (Binary) | Image file (`.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`). Max size: `10 MB`. |

---

## 3. User Discovery & HR Administrator Endpoints

### 3.1 Get Paged & Filtered Users (`FR-UP-01`)
Retrieves a paginated list of users matching dynamic search and filter parameters. Restricted to administrators and community managers.

- **URL**: `GET /api/users?searchTerm=John&departmentId=1&roleName=Employee&isActive=true&pageNumber=1&pageSize=20`
- **Authorization**: Required (`[Authorize(Roles = "HR Administrator,System Administrator,Community Admin")]`)

#### Query Parameters (`UserFilterDto`)
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `searchTerm` | string | `null` | Partial match across `FullName`, `Email`, or `EmployeeId`. |
| `departmentId` | int | `null` | Exact department filter. |
| `roleName` | string | `null` | Exact role filter (`Employee`, `HR Administrator`, etc.). |
| `isActive` | bool | `null` | Filter by active vs inactive accounts. |
| `isSuspended` | bool | `null` | Filter by currently suspended accounts (`FR-SM-04`). |
| `pageNumber` | int | `1` | Page number (1-indexed). |
| `pageSize` | int | `20` | Items per page (1 to 100). |

#### Response (`200 OK`)
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Users retrieved successfully.",
  "data": {
    "items": [
      {
        "userId": 1,
        "employeeId": "EMP001",
        "fullName": "John Doe",
        "email": "john.doe@knome.local",
        "designation": "Senior Software Engineer",
        "departmentId": 1,
        "departmentName": "Technology",
        "location": "Bhopal HQ",
        "profilePhotoUrl": "/uploads/profiles/user_1_abc123.jpg",
        "isActive": true,
        "isPermanentlySuspended": false,
        "roles": ["Employee"]
      }
    ],
    "totalCount": 1,
    "pageNumber": 1,
    "pageSize": 20,
    "totalPages": 1,
    "hasPreviousPage": false,
    "hasNextPage": false
  }
}
```

---

### 3.2 Get User Profile by ID (DPDP Act Masked)
Retrieves another user's profile. Enforces Indian DPDP Act 2023 visibility preferences (`FR-UP-04`). If the calling user is not an HR/System Administrator and the target user has set `BioVisibility`, `PhotosVisibility`, or `InterestsVisibility` to `Private` (or `Connections Only` without mutual follow), those fields are automatically returned as `null` / empty list.

- **URL**: `GET /api/users/{id}`
- **Authorization**: Required (`[Authorize]`)

---

### 3.3 Change User Department
HR Admin endpoint to reassign an employee to a new department (`FR-UP-01`).

- **URL**: `PUT /api/users/{id}/department`
- **Authorization**: Required (`[Authorize(Roles = "HR Administrator,System Administrator")]`)

#### Request Payload
```json
{
  "departmentId": 2
}
```

---

### 3.4 Change User Roles
HR Admin endpoint to assign or modify a user's platform roles.

- **URL**: `PUT /api/users/{id}/roles`
- **Authorization**: Required (`[Authorize(Roles = "HR Administrator,System Administrator")]`)

#### Request Payload
```json
{
  "roleNames": ["Employee", "Community Admin"]
}
```

---

### 3.5 Suspend User (`FR-SM-04`)
HR Admin endpoint to temporarily or permanently suspend a user account per platform governance rules. Suspended users cannot post or interact (`IsActive = false`).

- **URL**: `PUT /api/users/{id}/suspend`
- **Authorization**: Required (`[Authorize(Roles = "HR Administrator,System Administrator")]`)

#### Request Payload (Temporary Suspension)
```json
{
  "suspendedUntil": "2026-08-08T12:00:00Z",
  "isPermanent": false,
  "reason": "Temporary suspension pending investigation."
}
```

#### Request Payload (Permanent Suspension)
```json
{
  "suspendedUntil": null,
  "isPermanent": true,
  "reason": "Severe policy violation."
}
```

---

### 3.6 Activate User
Reactivates a previously suspended or inactive user account.

- **URL**: `PUT /api/users/{id}/activate`
- **Authorization**: Required (`[Authorize(Roles = "HR Administrator,System Administrator")]`)

---

## 4. Error Responses

### `400 Bad Request` (Validation Error)
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Bio cannot exceed 500 characters.",
  "errors": ["Bio cannot exceed 500 characters."]
}
```

### `403 Forbidden` (Role Authorization Failure)
```json
{
  "success": false,
  "statusCode": 403,
  "message": "You do not have permission to access this resource.",
  "errors": null
}
```

### `404 Not Found`
```json
{
  "success": false,
  "statusCode": 404,
  "message": "User with ID 999 not found.",
  "errors": null
}
```
