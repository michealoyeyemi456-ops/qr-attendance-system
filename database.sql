-- ============================================================================
-- QR ATTENDANCE MANAGEMENT SYSTEM USING MS SQL AND APACHE
-- Target Database Management System: Microsoft SQL Server 2016 / 2019 / 2022 / Azure SQL
-- Author: Engineering Team
-- Date: 2026-09-17
-- ============================================================================

-- Ensure Database Exists (Run separately if creating DB from scratch)
-- IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'QRAttendanceDB')
-- BEGIN
--     CREATE DATABASE QRAttendanceDB;
-- END
-- GO
-- USE QRAttendanceDB;
-- GO

-- Disable foreign key constraints during teardown (if re-running)
-- ============================================================================

IF OBJECT_ID('dbo.AttendanceRecords', 'U') IS NOT NULL DROP TABLE dbo.AttendanceRecords;
IF OBJECT_ID('dbo.AttendanceSessions', 'U') IS NOT NULL DROP TABLE dbo.AttendanceSessions;
IF OBJECT_ID('dbo.CourseRegistrations', 'U') IS NOT NULL DROP TABLE dbo.CourseRegistrations;
IF OBJECT_ID('dbo.CourseLecturers', 'U') IS NOT NULL DROP TABLE dbo.CourseLecturers;
IF OBJECT_ID('dbo.Courses', 'U') IS NOT NULL DROP TABLE dbo.Courses;
IF OBJECT_ID('dbo.Students', 'U') IS NOT NULL DROP TABLE dbo.Students;
IF OBJECT_ID('dbo.Lecturers', 'U') IS NOT NULL DROP TABLE dbo.Lecturers;
IF OBJECT_ID('dbo.Classrooms', 'U') IS NOT NULL DROP TABLE dbo.Classrooms;
IF OBJECT_ID('dbo.Levels', 'U') IS NOT NULL DROP TABLE dbo.Levels;
IF OBJECT_ID('dbo.Programmes', 'U') IS NOT NULL DROP TABLE dbo.Programmes;
IF OBJECT_ID('dbo.Departments', 'U') IS NOT NULL DROP TABLE dbo.Departments;
IF OBJECT_ID('dbo.AuditLogs', 'U') IS NOT NULL DROP TABLE dbo.AuditLogs;
IF OBJECT_ID('dbo.SystemSettings', 'U') IS NOT NULL DROP TABLE dbo.SystemSettings;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;

-- 1. USERS TABLE
CREATE TABLE dbo.Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Admin', 'Lecturer', 'Student')),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active', 'Inactive', 'Suspended')),
    CreatedAt DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LastLogin DATETIME2 NULL
);

-- 2. DEPARTMENTS TABLE
CREATE TABLE dbo.Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentCode NVARCHAR(20) NOT NULL UNIQUE,
    DepartmentName NVARCHAR(100) NOT NULL,
    Faculty NVARCHAR(100) NOT NULL DEFAULT 'School of Applied Science & Technology'
);

-- 3. PROGRAMMES TABLE
CREATE TABLE dbo.Programmes (
    ProgrammeID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentID INT NOT NULL FOREIGN KEY REFERENCES dbo.Departments(DepartmentID) ON DELETE CASCADE,
    ProgrammeCode NVARCHAR(20) NOT NULL UNIQUE,
    ProgrammeName NVARCHAR(100) NOT NULL,
    DurationYears INT NOT NULL DEFAULT 2
);

-- 4. LEVELS TABLE
CREATE TABLE dbo.Levels (
    LevelID INT IDENTITY(1,1) PRIMARY KEY,
    LevelCode NVARCHAR(20) NOT NULL UNIQUE,
    LevelName NVARCHAR(50) NOT NULL
);

-- 5. CLASSROOMS TABLE
CREATE TABLE dbo.Classrooms (
    ClassroomID INT IDENTITY(1,1) PRIMARY KEY,
    RoomCode NVARCHAR(50) NOT NULL UNIQUE,
    RoomName NVARCHAR(100) NOT NULL,
    Capacity INT NOT NULL DEFAULT 60,
    Building NVARCHAR(100) NULL
);

-- 6. LECTURERS TABLE
CREATE TABLE dbo.Lecturers (
    LecturerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES dbo.Users(UserID) ON DELETE CASCADE,
    DepartmentID INT NOT NULL FOREIGN KEY REFERENCES dbo.Departments(DepartmentID),
    StaffID NVARCHAR(50) NOT NULL UNIQUE,
    Title NVARCHAR(20) NOT NULL DEFAULT 'Lecturer',
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Phone NVARCHAR(20) NULL,
    OfficeNumber NVARCHAR(50) NULL
);

-- 7. STUDENTS TABLE
CREATE TABLE dbo.Students (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES dbo.Users(UserID) ON DELETE CASCADE,
    DepartmentID INT NOT NULL FOREIGN KEY REFERENCES dbo.Departments(DepartmentID),
    ProgrammeID INT NOT NULL FOREIGN KEY REFERENCES dbo.Programmes(ProgrammeID),
    LevelID INT NOT NULL FOREIGN KEY REFERENCES dbo.Levels(LevelID),
    MatricNo NVARCHAR(50) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Phone NVARCHAR(20) NULL,
    AcademicSession NVARCHAR(20) NOT NULL DEFAULT '2025/2026'
);

-- 8. COURSES TABLE
CREATE TABLE dbo.Courses (
    CourseID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentID INT NOT NULL FOREIGN KEY REFERENCES dbo.Departments(DepartmentID),
    LevelID INT NOT NULL FOREIGN KEY REFERENCES dbo.Levels(LevelID),
    CourseCode NVARCHAR(20) NOT NULL UNIQUE,
    CourseTitle NVARCHAR(150) NOT NULL,
    CreditUnits INT NOT NULL DEFAULT 3,
    Semester NVARCHAR(20) NOT NULL DEFAULT 'First Semester'
);

-- 9. COURSE LECTURER ALLOCATIONS
CREATE TABLE dbo.CourseLecturers (
    AllocationID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID INT NOT NULL FOREIGN KEY REFERENCES dbo.Courses(CourseID) ON DELETE CASCADE,
    LecturerID INT NOT NULL FOREIGN KEY REFERENCES dbo.Lecturers(LecturerID) ON DELETE CASCADE,
    AcademicSession NVARCHAR(20) NOT NULL DEFAULT '2025/2026',
    Semester NVARCHAR(20) NOT NULL DEFAULT 'First Semester',
    CONSTRAINT UQ_Course_Lecturer_Session UNIQUE (CourseID, LecturerID, AcademicSession, Semester)
);

-- 10. COURSE REGISTRATIONS (Students enrolled in courses)
CREATE TABLE dbo.CourseRegistrations (
    RegistrationID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL FOREIGN KEY REFERENCES dbo.Students(StudentID) ON DELETE CASCADE,
    CourseID INT NOT NULL FOREIGN KEY REFERENCES dbo.Courses(CourseID) ON DELETE CASCADE,
    AcademicSession NVARCHAR(20) NOT NULL DEFAULT '2025/2026',
    Semester NVARCHAR(20) NOT NULL DEFAULT 'First Semester',
    RegisteredAt DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT UQ_Student_Course_Session UNIQUE (StudentID, CourseID, AcademicSession, Semester)
);

-- 11. ATTENDANCE SESSIONS
CREATE TABLE dbo.AttendanceSessions (
    SessionID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID INT NOT NULL FOREIGN KEY REFERENCES dbo.Courses(CourseID),
    LecturerID INT NOT NULL FOREIGN KEY REFERENCES dbo.Lecturers(LecturerID),
    ClassroomID INT NOT NULL FOREIGN KEY REFERENCES dbo.Classrooms(ClassroomID),
    SessionDate DATE NOT NULL,
    StartTime TIME(0) NOT NULL,
    EndTime TIME(0) NOT NULL,
    DurationMinutes INT NOT NULL DEFAULT 30,
    SessionToken NVARCHAR(100) NOT NULL UNIQUE,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active', 'Closed', 'Cancelled')),
    CreatedAt DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ClosedAt DATETIME2 NULL
);

-- 12. ATTENDANCE RECORDS
CREATE TABLE dbo.AttendanceRecords (
    RecordID INT IDENTITY(1,1) PRIMARY KEY,
    SessionID INT NOT NULL FOREIGN KEY REFERENCES dbo.AttendanceSessions(SessionID) ON DELETE CASCADE,
    StudentID INT NOT NULL FOREIGN KEY REFERENCES dbo.Students(StudentID) ON DELETE CASCADE,
    CourseID INT NOT NULL FOREIGN KEY REFERENCES dbo.Courses(CourseID),
    MarkedAt DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ScanMethod NVARCHAR(30) NOT NULL DEFAULT 'QR_CAMERA' CHECK (ScanMethod IN ('QR_CAMERA', 'MANUAL_TOKEN', 'ADMIN_OVERRIDE', 'LECTURER_MANUAL')),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Present' CHECK (Status IN ('Present', 'Late', 'Excused')),
    IPAddress NVARCHAR(50) NULL,
    UserAgent NVARCHAR(255) NULL,
    CONSTRAINT UQ_Session_Student UNIQUE (SessionID, StudentID)
);

-- 13. AUDIT LOGS TABLE
CREATE TABLE dbo.AuditLogs (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL FOREIGN KEY REFERENCES dbo.Users(UserID) ON DELETE SET NULL,
    Action NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    Details NVARCHAR(MAX) NULL,
    IPAddress NVARCHAR(50) NULL,
    Timestamp DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 14. SYSTEM SETTINGS TABLE
CREATE TABLE dbo.SystemSettings (
    SettingKey NVARCHAR(50) PRIMARY KEY,
    SettingValue NVARCHAR(255) NOT NULL,
    Description NVARCHAR(255) NULL,
    UpdatedAt DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- PERFORMANCE INDEXES
-- ============================================================================
CREATE INDEX IX_Users_Username ON dbo.Users(Username);
CREATE INDEX IX_Users_Role ON dbo.Users(Role);
CREATE INDEX IX_Students_MatricNo ON dbo.Students(MatricNo);
CREATE INDEX IX_Students_DepartmentID ON dbo.Students(DepartmentID);
CREATE INDEX IX_Lecturers_StaffID ON dbo.Lecturers(StaffID);
CREATE INDEX IX_Courses_CourseCode ON dbo.Courses(CourseCode);
CREATE INDEX IX_Sessions_Token ON dbo.AttendanceSessions(SessionToken);
CREATE INDEX IX_Sessions_Status ON dbo.AttendanceSessions(Status);
CREATE INDEX IX_Records_Session_Student ON dbo.AttendanceRecords(SessionID, StudentID);
CREATE INDEX IX_Records_Course_Student ON dbo.AttendanceRecords(CourseID, StudentID);
CREATE INDEX IX_Registrations_Student_Course ON dbo.CourseRegistrations(StudentID, CourseID);

-- ============================================================================
-- SYSTEM SETTINGS SEED DATA
-- ============================================================================
INSERT INTO dbo.SystemSettings (SettingKey, SettingValue, Description) VALUES
('INSTITUTION_NAME', 'Federal Institute of Technology & Applied Sciences', 'Name of the tertiary institution'),
('INSTITUTION_CODE', 'FITAS', 'Short institution code / acronym'),
('ACADEMIC_SESSION', '2025/2026', 'Current active academic session'),
('SEMESTER', 'First Semester', 'Current active academic semester'),
('ATTENDANCE_THRESHOLD', '75', 'Minimum percentage attendance required for exam eligibility'),
('DEFAULT_SESSION_DURATION', '30', 'Default attendance session validity duration in minutes'),
('QR_REFRESH_INTERVAL', '15', 'QR code display auto-refresh interval in seconds');

-- ============================================================================
-- DEPARTMENTS SEED DATA
-- ============================================================================
INSERT INTO dbo.Departments (DepartmentCode, DepartmentName, Faculty) VALUES
('CSC', 'Computer Science', 'School of Applied Science & Technology'),
('EEE', 'Electrical & Electronic Engineering', 'School of Engineering'),
('STA', 'Statistics & Mathematics', 'School of Applied Science & Technology'),
('SLT', 'Science Laboratory Technology', 'School of Pure & Applied Sciences');

-- ============================================================================
-- PROGRAMMES SEED DATA
-- ============================================================================
INSERT INTO dbo.Programmes (DepartmentID, ProgrammeCode, ProgrammeName, DurationYears) VALUES
(1, 'ND-CSC', 'National Diploma in Computer Science', 2),
(1, 'HND-CSC', 'Higher National Diploma in Computer Science', 2),
(2, 'ND-EEE', 'National Diploma in Electrical/Electronics Engineering', 2),
(3, 'ND-STA', 'National Diploma in Statistics', 2);

-- ============================================================================
-- LEVELS SEED DATA
-- ============================================================================
INSERT INTO dbo.Levels (LevelCode, LevelName) VALUES
('ND1', 'National Diploma I (ND I)'),
('ND2', 'National Diploma II (ND II)'),
('HND1', 'Higher National Diploma I (HND I)'),
('HND2', 'Higher National Diploma II (HND II)');

-- ============================================================================
-- CLASSROOMS SEED DATA
-- ============================================================================
INSERT INTO dbo.Classrooms (RoomCode, RoomName, Capacity, Building) VALUES
('LAB-1', 'Main Computer Lab 1', 75, 'ICT Complex, Block A'),
('LAB-2', 'Advanced Software Lab 2', 60, 'ICT Complex, Block B'),
('HALL-A', 'Auditorium Hall A', 250, 'Academic Complex Ground Floor'),
('LT-04', 'Lecture Theater 04', 120, 'Science Building Level 2'),
('CR-102', 'Classroom 102', 50, 'Engineering Wing 1');

-- ============================================================================
-- USERS & CREDENTIALS
-- Default Password for all seed accounts: Password123!
-- Hash generated using PHP password_hash('Password123!', PASSWORD_BCRYPT)
-- ============================================================================
INSERT INTO dbo.Users (Username, PasswordHash, Email, Role, Status) VALUES
('admin', '$2y$10$bFoBCw0Q3895cPxTKSl./u94feMWyVBVSrS5PgjhCHq6JRKgJuu42', 'admin@fitas.edu.ng', 'Admin', 'Active'),
('dr.ibrahim', '$2y$10$bFoBCw0Q3895cPxTKSl./u94feMWyVBVSrS5PgjhCHq6JRKgJuu42', 'a.ibrahim@fitas.edu.ng', 'Lecturer', 'Active'),
('engr.adeyemi', '$2y$10$bFoBCw0Q3895cPxTKSl./u94feMWyVBVSrS5PgjhCHq6JRKgJuu42', 'o.adeyemi@fitas.edu.ng', 'Lecturer', 'Active'),
('dr.musa', '$2y$10$bFoBCw0Q3895cPxTKSl./u94feMWyVBVSrS5PgjhCHq6JRKgJuu42', 'b.musa@fitas.edu.ng', 'Lecturer', 'Active'),
('fitas/2024/001', '$2y$10$bFoBCw0Q3895cPxTKSl./u94feMWyVBVSrS5PgjhCHq6JRKgJuu42', 'chinedu.o@student.fitas.edu.ng', 'Student', 'Active'),
('fitas/2024/002', '$2y$10$bFoBCw0Q3895cPxTKSl./u94feMWyVBVSrS5PgjhCHq6JRKgJuu42', 'amina.b@student.fitas.edu.ng', 'Student', 'Active'),
('fitas/2024/003', '$2y$10$bFoBCw0Q3895cPxTKSl./u94feMWyVBVSrS5PgjhCHq6JRKgJuu42', 'oluwaseun.a@student.fitas.edu.ng', 'Student', 'Active'),
('fitas/2024/004', '$2y$10$bFoBCw0Q3895cPxTKSl./u94feMWyVBVSrS5PgjhCHq6JRKgJuu42', 'fatima.s@student.fitas.edu.ng', 'Student', 'Active'),
('fitas/2024/005', '$2y$10$bFoBCw0Q3895cPxTKSl./u94feMWyVBVSrS5PgjhCHq6JRKgJuu42', 'emeka.n@student.fitas.edu.ng', 'Student', 'Active');

-- LECTURERS PROFILE
INSERT INTO dbo.Lecturers (UserID, DepartmentID, StaffID, Title, FirstName, LastName, Phone, OfficeNumber) VALUES
(2, 1, 'FITAS/STF/CSC01', 'Dr.', 'Aliyu', 'Ibrahim', '08031234567', 'ICT Complex Rm 204'),
(3, 1, 'FITAS/STF/CSC02', 'Engr.', 'Olumide', 'Adeyemi', '08029876543', 'ICT Complex Rm 208'),
(4, 2, 'FITAS/STF/EEE01', 'Dr.', 'Bello', 'Musa', '08134567890', 'Engineering Wing B-12');

-- STUDENTS PROFILE
INSERT INTO dbo.Students (UserID, DepartmentID, ProgrammeID, LevelID, MatricNo, FirstName, LastName, Phone, AcademicSession) VALUES
(5, 1, 2, 3, 'FITAS/HND/CSC/24/001', 'Chinedu', 'Okonkwo', '08051112233', '2025/2026'),
(6, 1, 2, 3, 'FITAS/HND/CSC/24/002', 'Amina', 'Bello', '08072223344', '2025/2026'),
(7, 1, 2, 3, 'FITAS/HND/CSC/24/003', 'Oluwaseun', 'Adebayo', '08093334455', '2025/2026'),
(8, 1, 2, 3, 'FITAS/HND/CSC/24/004', 'Fatima', 'Sanusi', '08084445566', '2025/2026'),
(9, 1, 2, 3, 'FITAS/HND/CSC/24/005', 'Emeka', 'Nnamdi', '08065556677', '2025/2026');

-- COURSES SEED DATA
INSERT INTO dbo.Courses (DepartmentID, LevelID, CourseCode, CourseTitle, CreditUnits, Semester) VALUES
(1, 3, 'COM 311', 'Operating Systems & Architecture', 3, 'First Semester'),
(1, 3, 'COM 312', 'Database Design & Management (MS SQL)', 3, 'First Semester'),
(1, 3, 'COM 313', 'Computer Programming Using C++/Java', 4, 'First Semester'),
(1, 3, 'COM 314', 'Software Engineering Methodologies', 3, 'First Semester'),
(1, 3, 'GNS 301', 'Communication in English & Research', 2, 'First Semester');

-- COURSE ALLOCATIONS TO LECTURERS
INSERT INTO dbo.CourseLecturers (CourseID, LecturerID, AcademicSession, Semester) VALUES
(1, 1, '2025/2026', 'First Semester'),
(2, 1, '2025/2026', 'First Semester'),
(3, 2, '2025/2026', 'First Semester'),
(4, 2, '2025/2026', 'First Semester');

-- COURSE REGISTRATIONS
INSERT INTO dbo.CourseRegistrations (StudentID, CourseID, AcademicSession, Semester) VALUES
(1, 1, '2025/2026', 'First Semester'),
(1, 2, '2025/2026', 'First Semester'),
(1, 3, '2025/2026', 'First Semester'),
(1, 4, '2025/2026', 'First Semester'),
(2, 1, '2025/2026', 'First Semester'),
(2, 2, '2025/2026', 'First Semester'),
(2, 3, '2025/2026', 'First Semester'),
(2, 4, '2025/2026', 'First Semester'),
(3, 1, '2025/2026', 'First Semester'),
(3, 2, '2025/2026', 'First Semester'),
(3, 3, '2025/2026', 'First Semester'),
(3, 4, '2025/2026', 'First Semester'),
(4, 1, '2025/2026', 'First Semester'),
(4, 2, '2025/2026', 'First Semester'),
(4, 3, '2025/2026', 'First Semester'),
(4, 4, '2025/2026', 'First Semester'),
(5, 1, '2025/2026', 'First Semester'),
(5, 2, '2025/2026', 'First Semester'),
(5, 3, '2025/2026', 'First Semester'),
(5, 4, '2025/2026', 'First Semester');

-- ATTENDANCE SESSIONS SEED DATA
INSERT INTO dbo.AttendanceSessions (CourseID, LecturerID, ClassroomID, SessionDate, StartTime, EndTime, DurationMinutes, SessionToken, Status, CreatedAt, ClosedAt) VALUES
(2, 1, 1, CAST(DATEADD(day, -7, CURRENT_TIMESTAMP) AS DATE), '09:00:00', '09:30:00', 30, 'SES-COM312-HIST01-SEC982', 'Closed', DATEADD(day, -7, CURRENT_TIMESTAMP), DATEADD(minute, 30, DATEADD(day, -7, CURRENT_TIMESTAMP))),
(2, 1, 1, CAST(DATEADD(day, -3, CURRENT_TIMESTAMP) AS DATE), '09:00:00', '09:30:00', 30, 'SES-COM312-HIST02-SEC105', 'Closed', DATEADD(day, -3, CURRENT_TIMESTAMP), DATEADD(minute, 30, DATEADD(day, -3, CURRENT_TIMESTAMP))),
(2, 1, 1, CAST(CURRENT_TIMESTAMP AS DATE), CAST(CURRENT_TIMESTAMP AS TIME(0)), CAST(DATEADD(minute, 60, CURRENT_TIMESTAMP) AS TIME(0)), 60, 'SES-COM312-LIVE-ACTIVE-TK8421', 'Active', CURRENT_TIMESTAMP, NULL);

-- ATTENDANCE RECORDS SEED DATA
INSERT INTO dbo.AttendanceRecords (SessionID, StudentID, CourseID, MarkedAt, ScanMethod, Status, IPAddress) VALUES
(1, 1, 2, DATEADD(minute, 4, DATEADD(day, -7, CURRENT_TIMESTAMP)), 'QR_CAMERA', 'Present', '192.168.1.101'),
(1, 2, 2, DATEADD(minute, 7, DATEADD(day, -7, CURRENT_TIMESTAMP)), 'QR_CAMERA', 'Present', '192.168.1.102'),
(1, 3, 2, DATEADD(minute, 11, DATEADD(day, -7, CURRENT_TIMESTAMP)), 'QR_CAMERA', 'Present', '192.168.1.103'),
(1, 4, 2, DATEADD(minute, 14, DATEADD(day, -7, CURRENT_TIMESTAMP)), 'QR_CAMERA', 'Present', '192.168.1.104'),
(1, 5, 2, DATEADD(minute, 26, DATEADD(day, -7, CURRENT_TIMESTAMP)), 'QR_CAMERA', 'Late', '192.168.1.105');

INSERT INTO dbo.AttendanceRecords (SessionID, StudentID, CourseID, MarkedAt, ScanMethod, Status, IPAddress) VALUES
(2, 1, 2, DATEADD(minute, 5, DATEADD(day, -3, CURRENT_TIMESTAMP)), 'QR_CAMERA', 'Present', '192.168.1.101'),
(2, 2, 2, DATEADD(minute, 6, DATEADD(day, -3, CURRENT_TIMESTAMP)), 'QR_CAMERA', 'Present', '192.168.1.102'),
(2, 3, 2, DATEADD(minute, 9, DATEADD(day, -3, CURRENT_TIMESTAMP)), 'QR_CAMERA', 'Present', '192.168.1.103');

INSERT INTO dbo.AttendanceRecords (SessionID, StudentID, CourseID, MarkedAt, ScanMethod, Status, IPAddress) VALUES
(3, 1, 2, DATEADD(minute, 2, CURRENT_TIMESTAMP), 'QR_CAMERA', 'Present', '192.168.1.101'),
(3, 2, 2, DATEADD(minute, 4, CURRENT_TIMESTAMP), 'QR_CAMERA', 'Present', '192.168.1.102');

-- AUDIT LOGS INITIAL SEED DATA
INSERT INTO dbo.AuditLogs (UserID, Action, Category, Details, IPAddress) VALUES
(1, 'SYSTEM_INITIALIZATION', 'ADMIN', 'Initialized MS SQL schema, academic settings, and security credentials', '127.0.0.1'),
(2, 'SESSION_CREATED', 'SESSION', 'Created live attendance session for COM 312 in Room LAB-1', '192.168.1.50'),
(5, 'QR_ATTENDANCE_RECORDED', 'ATTENDANCE', 'Student Chinedu Okonkwo scanned QR code for COM 312', '192.168.1.101'),
(6, 'QR_ATTENDANCE_RECORDED', 'ATTENDANCE', 'Student Amina Bello scanned QR code for COM 312', '192.168.1.102');
