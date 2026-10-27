# Student Attendance Management System - Setup & Deployment Guide

## Overview
This application is a complete, role-based Student Attendance Management App for colleges. It provides:
- Continuous real-time date and time display in **Asia/Kolkata** timezone.
- Three distinct roles: **OWNER/ADMIN**, **FACULTY**, and **CR**.
- Owner/Admin authentication with **Biometric / Fingerprint** and password fallback.
- Faculty & CR authentication using **Registration Number** and assigned password.
- Strict data rule: Initially populated with the **exact 64 student records ONLY for 3rd Year -> IT -> Section C**. All other year/branch/sections are empty.
- Navigation workflow: Year -> Branch -> Section -> Period Mode (Single / Multiple) -> Attendance Sheet -> Save -> Read-Only Faculty Report.
- Single period (exactly 1) vs Multiple periods (minimum 2, independent record for each period).
- Attendance screen with default **ABSENTEES** tab and **PRESENT** tab.
- Faculty edit permission: Permitted **ONLY before 6:00 PM IST on the same attendance date**. Permanently locked thereafter.
- CR permission: Strictly **CANNOT modify saved attendance**.
- Generated attendance report: Strictly **read-only**, copy to clipboard, and WhatsApp / native share forwarding.
- Student management: CR and Admin can add, edit, and delete student master records with confirmation.
- Automatic 7-day retention cleanup via Firebase Cloud Functions.

---

## 1. Pre-Configured Test Accounts

| Role | Username / Reg No | Password | Notes |
|---|---|---|---|
| **Admin** | `ADMIN` | `Admin@123` | Full access, user accounts, branch configuration, biometric login |
| **Faculty** | `FAC001` | `Faculty@123` | Can take attendance, edit before 6 PM IST, generate report |
| **CR** | `24B01A12D2` | `Cr@123` | 3rd Year IT-C Class Representative. Cannot edit saved records |

---

## 2. Running the Android Application

The app is built natively in Android with **Kotlin** and **Jetpack Compose (Material 3)**.

To compile and verify locally:
```bash
gradle assembleDebug
```
Or run the app on an Android device or emulator with API level 24+.

---

## 3. Firebase Deployment & Security Rules

### Deploying Firestore Security Rules
The included `firestore.rules` enforces:
1. Role-based document access.
2. CR cannot update saved attendance records.
3. Faculty can update attendance records only before the 6:00 PM IST cutoff on the attendance date.
4. Client-side manual deletion of attendance history is prohibited (`allow delete: if false;`).

To deploy the security rules:
```bash
firebase login
firebase use <YOUR_FIREBASE_PROJECT_ID>
firebase deploy --only firestore:rules
```

---

## 4. Automatic 7-Day Retention Cleanup (Cloud Functions)

The included Cloud Function in `functions/index.js` runs automatically on a schedule:
- **Schedule**: Every day at `00:00` (Midnight) in the `Asia/Kolkata` timezone (`0 0 * * *`).
- **Action**: Queries attendance records older than 7 days from their creation timestamp, deletes associated attendance details, and deletes the attendance record.
- Student master records are preserved and never deleted by the retention cleanup.

To deploy the retention Cloud Function:
```bash
cd functions
npm install
firebase deploy --only functions
```

---

## 5. Verification Checklist

1. [x] **Faculty login**: Login using `FAC001` / `Faculty@123`.
2. [x] **CR login**: Login using `24B01A12D2` / `Cr@123`.
3. [x] **Admin biometric**: Biometric auth with secure password fallback.
4. [x] **Password change**: Old password verified, minimum 6 characters.
5. [x] **Live date/time**: Continuously updated in `Asia/Kolkata`.
6. [x] **Student data**: Exact 64 students in 3rd Year IT-C; other sections empty.
7. [x] **Period modes**: Single (1 period), Multiple (at least 2 periods).
8. [x] **Subtabs**: ABSENTEES tab selected by default.
9. [x] **Save confirmation**: Summary dialog with date, day, year, branch, section, period, counts.
10. [x] **CR editing**: Saved attendance is strictly read-only for CR.
11. [x] **Faculty editing**: Permitted only before 6:00 PM IST on same date.
12. [x] **Faculty message**: Strictly read-only formatted text. Copy and forward available.
13. [x] **Student management**: CR and Admin can add, edit, and delete student records.
14. [x] **Retention cleanup**: Purges records older than 7 days without manual delete button.
