# 🏘️ Multi-Society Management App — Project Overview

> A scalable, role-based mobile application to manage multiple residential societies within a single unified system.

---

## 📌 Project Summary

This application is a **multi-tenant society management platform** where multiple residential societies operate within a single system. Each society's data is completely isolated using a `societyId`-based structure. The app is built as a single Flutter mobile application that serves all user roles — from top-level administrators down to security guards and residents.

---

## 👥 Roles & Access Control

The system is built around **4 clearly defined roles**:

| Role | Scope | Key Responsibilities |
|------|-------|----------------------|
| **Super Admin** | Platform-wide | Manage all societies, onboard Society Admins, platform-level settings |
| **Society Admin** | Single society | Manage residents, approve payments, handle complaints, post notices |
| **Resident** | Own unit only | View/pay maintenance dues, raise complaints, manage visitors, read notices |
| **Security Guard** | Society gate | Log visitor entry & exit only |

> Each user's role is stored in Firestore and identified at login, which then routes them to their respective dashboard.

---

## 🔐 Authentication System

- **Login Method**: Mobile number → OTP verification
- **Provider**: Firebase Authentication (Phone Auth)
- **Session Management**: Session-based login to avoid repeated OTP prompts
  - Reduces Firebase Phone Auth costs
  - Smooth re-login experience for returning users
- **Post-Login Flow**: Role identified from Firestore → redirect to role-specific dashboard

---

## ⚙️ Core Features

### 1. 💳 Maintenance Payment Tracking
- Residents can view their monthly/quarterly dues
- Payment is made externally (bank transfer, etc.)
- Resident submits **screenshot** as proof of payment
- Society Admin **reviews and approves/rejects** the submission
- Payment history maintained per resident

### 2. 📢 Complaint Management
- Residents raise complaints (plumbing, electricity, cleanliness, etc.)
- Society Admin views, responds to, and resolves complaints
- Status tracking: `Open → In Progress → Resolved`
- Complaint history accessible to both parties

### 3. 🚪 Visitor Management
- Residents can **pre-register expected visitors**
- Security Guard logs **actual entry and exit** of visitors
- Society Admin can view visitor logs for security audit
- Timestamps and visitor details recorded per entry

### 4. 📋 Notice Board
- Society Admin posts announcements/notices
- All residents of that society receive the notice
- Super Admin can optionally post platform-wide notices

### 5. 🔔 Push Notifications
- Powered by **Firebase Cloud Messaging (FCM)**
- Triggered on:
  - Payment approved/rejected
  - New complaint response
  - Visitor arrival
  - New notice posted
- Role-aware targeting (notify only relevant users)

---

## 🗂️ Data Architecture (Firestore)

All data is scoped under a **`societyId`** to ensure complete isolation between societies.

```
/societies/{societyId}/
    ├── users/            → All users belonging to this society (role, unitNo, fcmToken)
    ├── payments/         → Maintenance payment records per resident
    ├── complaints/       → Raised complaints with status and thread
    ├── visitors/         → Visitor logs (name, purpose, entry/exit time)
    └── notices/          → Notice board posts

/admins/                  → Super Admin records (platform-level)
```

### Key Design Decisions
- `societyId` is attached to every document for query-level isolation
- Firebase Security Rules enforce role-based read/write access
- Firestore indexes configured for query performance

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter (Dart) — Single codebase for all roles |
| **Database** | Firebase Firestore (NoSQL, real-time) |
| **Authentication** | Firebase Authentication (Phone/OTP) |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **Storage** | Firebase Storage (payment screenshots) |
| **Backend Logic** | Firebase Security Rules + optional Cloud Functions |

---

## 📱 App Folder Structure (High-Level)

```
lib/
├── main.dart
├── core/
│   ├── auth/               → OTP login, session management
│   ├── routing/            → Role-based navigation
│   └── models/             → User, Payment, Complaint, Visitor, Notice
├── features/
│   ├── super_admin/        → Platform dashboard
│   ├── society_admin/      → Society management dashboard
│   ├── resident/           → Resident portal
│   └── security_guard/     → Visitor log screen
└── shared/
    ├── widgets/            → Reusable UI components
    └── services/           → Firebase service wrappers
```

---

## 🗺️ User Flow Diagrams

### Login Flow
```
App Launch
    │
    ▼
Phone Number Input
    │
    ▼
OTP Sent (Firebase Auth)
    │
    ▼
OTP Verified
    │
    ▼
Fetch User Role from Firestore
    │
    ├─── Super Admin ──────► Platform Dashboard
    ├─── Society Admin ────► Society Dashboard
    ├─── Resident ─────────► Resident Dashboard
    └─── Security Guard ───► Visitor Log Screen
```

### Maintenance Payment Flow
```
Resident views dues
    │
    ▼
Makes payment externally (bank/wallet)
    │
    ▼
Uploads screenshot in app
    │
    ▼
Society Admin receives FCM notification
    │
    ▼
Admin reviews screenshot
    │
    ├─── Approved ──► Resident notified ✅
    └─── Rejected ──► Resident notified ❌ (with reason)
```

### Visitor Flow
```
Resident pre-registers visitor (optional)
    │
    ▼
Visitor arrives at gate
    │
    ▼
Security Guard logs entry (name, purpose, time)
    │
    ▼
Resident receives FCM notification
    │
    ▼
Security Guard logs exit time
```

---

## 🚀 MVP Scope

The MVP will include:

- [x] OTP-based login with session management
- [x] Role detection & role-based dashboard routing
- [x] Super Admin: society & admin management
- [x] Society Admin: resident management, payment approvals, complaint handling, posting notices
- [x] Resident: dues view, payment screenshot submission, complaint raising, visitor pre-registration, notice board
- [x] Security Guard: visitor entry/exit logging
- [x] Push notifications for key events
- [x] Society-level data isolation via `societyId`

---

## 🔮 Future Enhancements (Post-MVP)

| Feature | Description |
|---------|-------------|
| **Separate Admin Web Panel** | Browser-based dashboard for Society/Super Admins |
| **Online Payment Gateway** | In-app payments via JazzCash / EasyPaisa / Stripe |
| **Document Management** | Store society bylaws, NOCs, lease agreements |
| **Staff Management** | Manage housekeeping, maintenance staff |
| **Parking Management** | Allocate and track parking slots |
| **Emergency SOS** | One-tap alert to security/admin |
| **Analytics Dashboard** | Payment collection rates, complaint trends |
| **Multi-language Support** | Urdu + English UI |

---

## 🔒 Security Considerations

- Firebase Security Rules enforce role-based access at the database level
- No resident can read another resident's data
- Society data is completely isolated from other societies
- All file uploads (screenshots) stored in private Firebase Storage paths
- Admin accounts can only be created by Super Admin
- Phone number is the only identity — no password storage needed

---

## 📊 Cost Optimization Strategy

- **Session-based login** avoids repeated OTP SMS costs (Firebase Phone Auth charges per SMS)
- Firestore reads minimized through proper data modeling and local caching
- FCM push notifications are completely free
- Firebase Spark (free tier) sufficient for MVP testing
- Upgrade to Blaze (pay-as-you-go) as the platform scales

---

## 📅 Development Phases

| Phase | Deliverable | Status |
|-------|-------------|--------|
| **Phase 1** | Project setup, Firebase config, auth + role routing | 🟡 Planned |
| **Phase 2** | Society Admin & Resident core features | 🟡 Planned |
| **Phase 3** | Visitor management + Security Guard flow | 🟡 Planned |
| **Phase 4** | Push notifications + Notice board | 🟡 Planned |
| **Phase 5** | Super Admin panel | 🟡 Planned |
| **Phase 6** | Testing, bug fixes, UI polish | 🟡 Planned |
| **Phase 7** | MVP release | 🟡 Planned |

---

*Document created: April 2026 | Stack: Flutter + Firebase | Type: MVP*
