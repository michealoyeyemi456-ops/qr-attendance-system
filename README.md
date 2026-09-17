# QR Attendance System Using MS SQL and Apache

A complete, professional, responsive, and functional web-based QR Attendance Management System designed for tertiary institutions (Universities, Polytechnics, and Colleges of Technology).

---

## 🏛️ System Architecture

- **Frontend**: HTML5, CSS3 (Custom Responsive Academic Theme), Vanilla JavaScript (ES6+), FontAwesome 6, and `html5-qrcode` in-browser camera scanning engine.
- **Backend**: PHP (7.4 - 8.3+) running via **Apache HTTP Server** (`mod_rewrite`, `.htaccess` security policies).
- **Database Management System**: **Microsoft SQL Server (MS SQL)** 2016 / 2019 / 2022 / Azure SQL with production T-SQL schema (`database/database.sql`), constraints, unique indexes, and referential integrity.
- **Database Abstraction**: `config/database.php` automatically discovers and connects via:
  1. `pdo_sqlsrv` (Official Microsoft PHP SQL Server Driver)
  2. `odbc` (ODBC Driver 18/17 for SQL Server)
  3. `dblib` / FreeTDS
  4. Automatic portable engine fallback (`database/attendance_portable.db`) for immediate out-of-the-box evaluation.

---

## 📁 Directory & File Structure

```text
qr_attendance_mssql_apache/
├── .htaccess                      # Apache configuration, security headers, rewrite rules
├── index.php                      # Root entry point & role redirector
├── logout.php                     # Root sign-out proxy
├── database.sql                   # Root copy of MS SQL Server production DDL
├── README.md                      # Complete system documentation
│
├── config/
│   ├── config.php                 # Core settings, academic session, 75% threshold, session security
│   └── database.php               # Multi-driver MS SQL connection manager with portable fallback
│
├── database/
│   ├── database.sql               # Production Microsoft SQL Server T-SQL script with seed data
│   ├── seed.php                   # PHP schema seeder for driver initialization
│   ├── init_portable_db.py        # Python SQLite seed utility
│   └── attendance_portable.db     # Pre-seeded portable database
│
├── includes/
│   ├── functions.php              # Security, CSRF tokens, audit logging, attendance % calculator
│   ├── auth_guard.php             # Role-based authorization guard & session validation
│   ├── header.php                 # Reusable dashboard topbar & head tags
│   ├── sidebar.php                # Responsive role-specific navigation menu
│   └── footer.php                 # Reusable dashboard footer & script links
│
├── assets/
│   ├── css/
│   │   ├── style.css              # Global design system, academic navy/gold colors, cards, tables
│   │   └── dashboard.css          # Dashboard layout, KPI cards, projector screen, camera reticle
│   ├── js/
│   │   ├── app.js                 # UI interactions, sidebar toggle, search filters, clipboard helper
│   │   ├── scanner.js             # Camera QR scanning handler with synth audio beep & debouncing
│   │   └── session_live.js        # Countdown timer, live attendee polling, fullscreen projector
│   └── images/
│       └── logo.svg               # Vector academic emblem
│
├── auth/
│   ├── login.php                  # Unified sign-in with quick autofill demo buttons & CSRF
│   └── logout.php                 # Secure logout and audit logger
│
├── api/
│   ├── scan_qr.php                # Core QR attendance verification & recording endpoint
│   ├── session_live.php           # Real-time polling endpoint for lecturer projector screen
│   ├── auth.php                   # Authentication status API
│   └── stats.php                  # Aggregated institutional KPI counters
│
├── qr/
│   └── generate.php               # Native high-resolution vector SVG QR code generator
│
├── student/
│   ├── index.php                  # Student dashboard, active class alerts, % summary
│   ├── scan.php                   # In-browser camera QR code scanner & manual token fallback
│   ├── courses.php                # Registered courses, attendance progress bars, exam eligibility
│   └── history.php                # Timestamped attendance log filtered by course and status
│
├── lecturer/
│   ├── index.php                  # Lecturer dashboard, assigned courses, active session banner
│   ├── create_session.php         # Launch attendance session (course, classroom, duration)
│   ├── active_session.php         # Dedicated Projector Screen: large dynamic QR, countdown, live roster
│   ├── courses.php                # Assigned teaching courses and enrolled student rosters
│   ├── records.php                # Historical sessions log with turnout metrics
│   └── reports.php                # Course exam eligibility analytics & student attendance breakdown
│
├── admin/
│   ├── index.php                  # Executive KPI dashboard & database engine monitor
│   ├── students.php               # Manage Students (Full CRUD: create, edit, delete, status)
│   ├── lecturers.php              # Manage Lecturers (Full CRUD: staff ID, profile, department)
│   ├── departments.php            # Manage Departments, Programmes, and Classrooms
│   ├── courses.php                # Manage Courses and Lecturer Allocations
│   ├── registrations.php          # Manage Course Registrations / Student Enrolments
│   ├── sessions.php               # Institutional master session manager & remote close
│   ├── records.php                # Master attendance scan ledger with manual override
│   ├── audit.php                  # Security audit trail with category filtering
│   └── settings.php               # System settings (Academic session, semester, threshold %)
│
└── reports/
    ├── index.php                  # Central analytics hub & departmental performance
    └── export_csv.php             # CSV export engine (session roster, course report, master ledger)
```

---

## 👥 Seed User Accounts & Credentials

All default seed accounts use the universal password: **`Password123!`**

| Role | Username / ID | Email | Password | Full Name |
| :--- | :--- | :--- | :--- | :--- |
| **Administrator** | `admin` | `admin@fitas.edu.ng` | `Password123!` | System Administrator |
| **Lecturer** | `dr.ibrahim` | `a.ibrahim@fitas.edu.ng` | `Password123!` | Dr. Aliyu Ibrahim |
| **Lecturer** | `engr.adeyemi` | `o.adeyemi@fitas.edu.ng` | `Password123!` | Engr. Olumide Adeyemi |
| **Student** | `fitas/2024/001` | `chinedu.o@student.fitas.edu.ng` | `Password123!` | Chinedu Okonkwo |
| **Student** | `fitas/2024/002` | `amina.b@student.fitas.edu.ng` | `Password123!` | Amina Bello |
| **Student** | `fitas/2024/003` | `oluwaseun.a@student.fitas.edu.ng` | `Password123!` | Oluwaseun Adebayo |
| **Student** | `fitas/2024/004` | `fatima.s@student.fitas.edu.ng` | `Password123!` | Fatima Sanusi |
| **Student** | `fitas/2024/005` | `emeka.n@student.fitas.edu.ng` | `Password123!` | Emeka Nnamdi |

> **Tip**: The login page (`auth/login.php`) contains one-click demo autofill buttons for **Admin**, **Lecturer**, and **Student** for immediate testing without manual typing.

---

## ⚙️ Installation & Deployment Guide

### Option A: Running with Microsoft SQL Server & Apache

1. **Microsoft SQL Server Database Setup**:
   - Open **SQL Server Management Studio (SSMS)** or Azure Data Studio.
   - Create a database named `QRAttendanceDB` (or run `CREATE DATABASE QRAttendanceDB;`).
   - Open `database/database.sql` and execute the script against `QRAttendanceDB`. All tables, primary keys, foreign keys, unique constraints, and initial seed data will be created.

2. **Configure Database Connection**:
   - Open `config/database.php` and update the connection constants if your server settings differ:
     ```php
     private const DB_HOST = 'localhost';             // or your SQL Server instance e.g. localhost\SQLEXPRESS
     private const DB_PORT = '1433';
     private const DB_NAME = 'QRAttendanceDB';
     private const DB_USER = 'sa';
     private const DB_PASS = 'YourPasswordHere';
     ```
   - Alternatively, pass environment variables `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS`.

3. **Deploy on Apache**:
   - Copy or symlink the project folder into your Apache `htdocs` or `www` directory (e.g. `C:\xampp\htdocs\qr_attendance_mssql_apache`).
   - Ensure `mod_rewrite` and `mod_headers` are enabled in `httpd.conf`.
   - Access the system at: `http://localhost/qr_attendance_mssql_apache/`

### Option B: Immediate Evaluation via Portable Engine

- If Microsoft SQL Server is not currently installed or running on your local development machine, `config/database.php` detects this automatically and routes queries through the pre-seeded high-fidelity portable engine (`database/attendance_portable.db`).
- Every feature—including live session projection, real-time attendee polling, QR code generation, camera scanning, student eligibility calculations, and CSV reports—operates smoothly.

---

## 🔒 Security & QR Attendance Verification Rules

1. **Dynamic Cryptographic QR Payload**:
   - When a lecturer launches a session, a cryptographically signed payload is generated combining the `SessionID`, `SessionToken`, and a secure HMAC salt signature.
2. **Strict Expiry Check**:
   - Scans are rejected if the lecture duration has lapsed (`CURRENT_TIME > EndTime`) or if the session has been closed manually by the lecturer or administrator.
3. **Course Enrolment Validation**:
   - Only students officially registered in `CourseRegistrations` for the specified course and semester can mark attendance.
4. **Duplicate Prevention**:
   - Enforced at both the business logic layer and the database constraint layer (`UNIQUE (SessionID, StudentID)`). If a student scans again, they receive a friendly alert showing their existing check-in time.
5. **Punctuality Grading**:
   - Students scanning within the first 20 minutes are marked as **`Present`**.
   - Students scanning after 20 minutes into the session are marked as **`Late`**.
6. **Immutable Audit Trail**:
   - Every system event (successful login, failed attempt, session launch, QR scan, manual override, student creation) is recorded in `AuditLogs` with timestamp and IP address.
7. **Exam Eligibility Policy**:
   - Students with attendance $\ge 75\%$ receive the green **Exam Eligible** badge. Students below 75% are flagged as **At Risk** or **Ineligible**.

---

## 🧪 Verification & Testing Workflow

1. **Admin Walkthrough**:
   - Sign in as `admin`.
   - View the **KPI Dashboard** with live server status, total students, and recent security logs.
   - Navigate to **Manage Students** or **Manage Lecturers** to perform CRUD operations.
   - Navigate to **Master Records** to view all campus check-ins or perform a manual attendance override.

2. **Lecturer Walkthrough**:
   - Sign in as `dr.ibrahim`.
   - Click **Launch New QR Session** (`lecturer/create_session.php`).
   - Select Course `COM 312`, Room `LAB-1`, Duration `30 Minutes`, and click **Start Live Session**.
   - The **Live Attendance Projector** (`lecturer/active_session.php`) appears:
     - Displays the vector QR code.
     - Displays the live countdown timer.
     - Shows the live attendee counter and real-time auto-refreshing roster.

3. **Student Walkthrough**:
   - Sign in as student `fitas/2024/003` (Oluwaseun Adebayo) in another tab or incognito window.
   - On the Student Dashboard, notice the **Live Lecture In Progress** banner for `COM 312`.
   - Click **Scan to Mark Attendance** (`student/scan.php`).
   - Point device camera at the QR code (or submit the session token).
   - Audio beep triggers, and instant success confirmation displays with course, lecturer, classroom, and status.
   - Return to the lecturer's projector screen: student `fitas/2024/003` automatically appears in the attendee roster in real time without refreshing!
   - Attempt to scan again: the system prevents duplicate attendance with an informational banner.
   - Visit **My Courses & %** (`student/courses.php`) and **Attendance History** (`student/history.php`) to see updated percentages and eligibility badges.

---

## 📄 License & Academic Attribution
Developed for tertiary academic institutional deployment using **Microsoft SQL Server** and **Apache HTTP Server**.
