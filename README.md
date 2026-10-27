Attendance Manager is a native Android app for colleges to take and report student attendance. It supports three roles (Admin, Faculty and Class Representative), each with its own permissions. Faculty pick a year, branch and section, choose single or multiple periods, mark absentees or present students, and save. The app then generates a read-only report that can be copied or shared on WhatsApp. Faculty can edit a record only until 6:00 PM IST on the same day, and CRs can never edit saved records. Built with Kotlin, Jetpack Compose (Material 3) and a Room database.

Key features

Role-based login: Admin (with fingerprint login and password fallback), Faculty and CR (registration number plus password)
Live date and time in the Asia/Kolkata timezone
Year → Branch → Section → Period selection flow
Single period or multiple periods, with an independent record for each period
Attendance sheet with ABSENTEES and PRESENT tabs, plus a save-confirmation summary
Time-locked editing for faculty, and read-only access for CRs
Read-only report with copy and WhatsApp/native share
Student management (add, edit, delete) for Admin and CR
Attendance history view, and a password-change screen
Preloaded with 64 students for 3rd Year IT Section C

Tech stack: Kotlin, Jetpack Compose (Material 3), Room (SQLite), MVVM with ViewModel and repository layers, Android Biometric. Also included: Firestore security rules and a scheduled Cloud Function for a 7-day record cleanup.

One thing to be accurate about: the Firebase rules and cleanup function are written but not connected to the app yet, because the app currently stores data locally on each device. On a resume or portfolio, I’d list it as “Firebase-ready” rather than claiming cloud sync, unless we wire up Firestore.

If you want, I can write this as a resume bullet set or a full README.md for your GitHub repo.