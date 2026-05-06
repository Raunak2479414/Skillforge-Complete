-- ============================================================
-- SkillForge  –  Test Data Seed Script
-- ============================================================
-- All seed users share the password: Admin@123
--
-- BCrypt hashes cannot be computed in plain SQL.
-- Before running this script, generate the BCrypt hash once:
--
--   Option A – temporary code in Program.cs (before app.Run()):
--       Console.WriteLine(BCrypt.Net.BCrypt.HashPassword("Admin@123"));
--       app.Run();        // comment it back out after you get the hash
--
--   Option B – dotnet-script (install once: dotnet tool install -g dotnet-script):
--       echo "Console.WriteLine(BCrypt.Net.BCrypt.HashPassword(\"Admin@123\"));" | dotnet-script
--
-- Then replace <<BCRYPT_HASH>> below with the generated hash (starts with $2a$11$...).
-- ============================================================

BEGIN TRANSACTION;

-- ── Shared password hash (replace once) ─────────────────────────────────────
-- Paste your BCrypt hash for "Admin@123" here:
DECLARE @pwd VARCHAR(255) = '<<BCRYPT_HASH>>';


-- ── 1. Users ─────────────────────────────────────────────────────────────────
-- Roles stored as strings: Admin | HR | Trainer | Manager | Employee
INSERT INTO [User] (Name, Role, Email, Phone, Password, Status) VALUES
  ('Admin',     'Admin',    'admin@skillforge.com',   '9000000001', @pwd, 1),
  ('HRManager', 'HR',       'hr@skillforge.com',      '9000000002', @pwd, 1),
  ('Trainer',   'Trainer',  'trainer@skillforge.com', '9000000003', @pwd, 1),
  ('Alice',     'Employee', 'alice@skillforge.com',   '9000000004', @pwd, 1),
  ('Bob',       'Employee', 'bob@skillforge.com',     '9000000005', @pwd, 1);

-- Capture user IDs (rows inserted in order → IDs are sequential)
DECLARE @adminId   INT = (SELECT UserID FROM [User] WHERE Email = 'admin@skillforge.com');
DECLARE @hrId      INT = (SELECT UserID FROM [User] WHERE Email = 'hr@skillforge.com');
DECLARE @trainerId INT = (SELECT UserID FROM [User] WHERE Email = 'trainer@skillforge.com');
DECLARE @aliceId   INT = (SELECT UserID FROM [User] WHERE Email = 'alice@skillforge.com');
DECLARE @bobId     INT = (SELECT UserID FROM [User] WHERE Email = 'bob@skillforge.com');


-- ── 2. Competencies ──────────────────────────────────────────────────────────
-- Level stored as VARCHAR(15): Beginner | Intermediate | Advanced
INSERT INTO Competency (Name, Description, Level) VALUES
  ('JavaScrpt', 'Frontend JS scripting',      'Beginner'),
  ('Python',    'Backend Python scripting',   'Intermediate'),
  ('CloudArch', 'Cloud architecture design',  'Advanced');

DECLARE @compJsId    INT = (SELECT CompetencyID FROM Competency WHERE Name = 'JavaScrpt');
DECLARE @compPyId    INT = (SELECT CompetencyID FROM Competency WHERE Name = 'Python');
DECLARE @compCloudId INT = (SELECT CompetencyID FROM Competency WHERE Name = 'CloudArch');


-- ── 3. Courses ────────────────────────────────────────────────────────────────
-- Status = 1 (live) is required for certification issuance
INSERT INTO Course (Title, Description, TrainerID, Duration, Status) VALUES
  ('Web Dev',       'Web development course', @trainerId, 40.0, 1),
  ('Python Basics', 'Python fundamentals',    @trainerId, 30.0, 1);

DECLARE @courseWebId INT = (SELECT CourseID FROM Course WHERE Title = 'Web Dev');
DECLARE @coursePyId  INT = (SELECT CourseID FROM Course WHERE Title = 'Python Basics');


-- ── 4. Modules ────────────────────────────────────────────────────────────────
INSERT INTO [Module] (CourseID, Title, ContentURI, Duration, Status) VALUES
  (@courseWebId, 'HTML & CSS',       'https://cdn.skillforge/html', 10.0, 1),
  (@courseWebId, 'JavaScript Intro', 'https://cdn.skillforge/js',   15.0, 1),
  (@coursePyId,  'Python Syntax',    'https://cdn.skillforge/py1',  10.0, 1),
  (@coursePyId,  'Python OOP',       'https://cdn.skillforge/py2',  12.0, 1);


-- ── 5. Assessments ────────────────────────────────────────────────────────────
-- Type stored as strings: Quiz | Exam | Practical
-- MaxScore = 50 on the Practical → good for testing "score exceeds max" error
INSERT INTO Assessments (CourseID, Type, MaxScore, Date) VALUES
  (@courseWebId, 'Quiz',      100.0, GETDATE()),
  (@coursePyId,  'Exam',      100.0, GETDATE()),
  (@coursePyId,  'Practical',  50.0, GETDATE());

DECLARE @asmtWebQuizId     INT = (SELECT AssessmentID FROM Assessments WHERE CourseID = @courseWebId AND Type = 'Quiz');
DECLARE @asmtPyExamId      INT = (SELECT AssessmentID FROM Assessments WHERE CourseID = @coursePyId  AND Type = 'Exam');
DECLARE @asmtPyPracticalId INT = (SELECT AssessmentID FROM Assessments WHERE CourseID = @coursePyId  AND Type = 'Practical');


-- ── 6. Enrollments ───────────────────────────────────────────────────────────
INSERT INTO Enrollment (CourseID, EmployeeID, EnrollmentDate, Status) VALUES
  (@courseWebId, @aliceId, GETDATE(), 1),   -- Alice enrolled in Web Dev
  (@coursePyId,  @aliceId, GETDATE(), 1),   -- Alice enrolled in Python Basics
  (@coursePyId,  @bobId,   GETDATE(), 1);   -- Bob  enrolled in Python Basics

DECLARE @enrAliceWebId INT = (SELECT EnrollmentID FROM Enrollment WHERE CourseID = @courseWebId AND EmployeeID = @aliceId);
DECLARE @enrAlicePyId  INT = (SELECT EnrollmentID FROM Enrollment WHERE CourseID = @coursePyId  AND EmployeeID = @aliceId);
DECLARE @enrBobPyId    INT = (SELECT EnrollmentID FROM Enrollment WHERE CourseID = @coursePyId  AND EmployeeID = @bobId);


-- ── 7. Attendance ─────────────────────────────────────────────────────────────
INSERT INTO Attendance (EnrollmentID, AttendanceDate, Status) VALUES
  (@enrAliceWebId, GETDATE(), 1),
  (@enrAlicePyId,  GETDATE(), 1),
  (@enrBobPyId,    GETDATE(), 1);


-- ── 8. Results ───────────────────────────────────────────────────────────────
-- PK is composite (AssessmentID, EmployeeID) — no IDENTITY needed.
-- Status stored as strings: Pass | Fail
-- Score >= 35 (config default) → Pass
--
-- Alice passed both assessments → can be certified for Web Dev (done below)
--   and for Python Basics (test via POST /api/v1/Certification/certifications).
-- Bob has NO results → use him to test:
--   • ResultService.SubmitResultAsync  (submit on asmtPyExam or asmtPyPractical)
--   • CertificationService reject path (no passing result)
INSERT INTO Results (AssessmentID, EmployeeID, ResultID, Score, Status) VALUES
  (@asmtWebQuizId, @aliceId, 1, 85.0, 'Pass'),
  (@asmtPyExamId,  @aliceId, 2, 90.0, 'Pass');


-- ── 9. Certifications ────────────────────────────────────────────────────────
-- Alice already certified for Web Dev.
-- Alice's Python Basics cert is intentionally NOT seeded → issue it via the API.
-- Status must be 'Active' | 'Revoked' | 'Expired'
INSERT INTO Certifications (EmployeeID, CourseID, IssueDate, ExpiryDate, Status) VALUES
  (@aliceId, @courseWebId, GETDATE(), DATEADD(YEAR, 1, GETDATE()), 'Active');

DECLARE @certId INT = SCOPE_IDENTITY();


-- ── 10. ComplianceRecord ──────────────────────────────────────────────────────
INSERT INTO ComplianceRecord (EmployeeID, CertificationID, Status, Date) VALUES
  (@aliceId, @certId, 1, GETDATE());


-- ── 11. SkillGap ─────────────────────────────────────────────────────────────
-- GapLevel stored as INT: Low = 0 | Medium = 1 | High = 2
INSERT INTO SkillGap (EmployeeID, CompetencyID, GapLevel, DateIdentified) VALUES
  (@aliceId, @compJsId,    0, GETDATE()),   -- Alice: Low gap in JavaScript
  (@bobId,   @compPyId,    1, GETDATE()),   -- Bob:   Medium gap in Python
  (@bobId,   @compCloudId, 2, GETDATE());   -- Bob:   High gap in Cloud


-- ── 12. AuditLog ─────────────────────────────────────────────────────────────
INSERT INTO AuditLog (UserID, Action, Resource, Timestamp) VALUES
  (@adminId, 'Certification Issued',     CONCAT('Certification/', @certId), GETDATE()),
  (@aliceId, 'Submit Assessment Result', 'Result',                           GETDATE());


-- ── 13. Audit ─────────────────────────────────────────────────────────────────
-- Scope stored as INT: Course = 0 | Employee = 1
INSERT INTO Audit (HRID, Scope, Findings, Date, Status) VALUES
  (@hrId, 0, 'All courses are fully compliant with Q1 2026 standards.', GETDATE(), 1);


-- ── 14. ReportSchedule ────────────────────────────────────────────────────────
-- Scope stored as VARCHAR(20): Course | Employee | Department
-- CronExpression: standard 5-field cron string
-- NextRun set to 1 minute from now so the BackgroundService picks it up quickly
INSERT INTO ReportSchedule (Scope, CronExpression, CreatedBy, CreatedAt, LastRun, NextRun, IsActive) VALUES
  ('Department', '0 9 * * 1',  @adminId, GETDATE(), NULL, DATEADD(MINUTE, 1, GETDATE()), 1),  -- Every Monday 9 AM
  ('Course',     '0 0 1 * *',  @adminId, GETDATE(), NULL, DATEADD(MINUTE, 2, GETDATE()), 1),  -- 1st of every month
  ('Employee',   '* * * * *',  @adminId, GETDATE(), NULL, DATEADD(MINUTE, 1, GETDATE()), 1);  -- Every minute (for quick testing)

DECLARE @scheduleId INT = (SELECT ScheduleID FROM ReportSchedule WHERE Scope = 'Department');


-- ── 15. Report ────────────────────────────────────────────────────────────────
-- Scope stored as VARCHAR(20): Course | Employee | Department
-- ScheduleID is nullable (NULL = manually generated, non-null = from a schedule)
INSERT INTO Report (Scope, Metrics, GeneratedDate, ScheduleID) VALUES
  ('Course',     '{"scope":"Course","totalEnrollments":3,"activeCertifications":1,"complianceRate":100.0,"totalSkillGaps":3}',     GETDATE(), NULL),
  ('Department', '{"scope":"Department","totalEnrollments":3,"activeCertifications":1,"complianceRate":100.0,"totalSkillGaps":3}', GETDATE(), @scheduleId);


-- ── 16. Notifications ────────────────────────────────────────────────────────
-- Status: 'Unread' | 'Read'  (check constraint)
-- Category: freeform VARCHAR(50) — matches what NotificationService emits
--   Alice → 1 Certification (Web Dev cert issued) + 1 Enrollment (Python Basics)
--   Admin → 1 Report (scheduled department report generated)
--   Bob   → 1 Certification (seeded as Read to verify filter excludes it)
INSERT INTO Notification (UserID, CourseID, Message, Category, Status, CreatedDate) VALUES
  (@aliceId, @courseWebId, 'Your certification (ID: 1) has been issued.',                                          'Certification', 'Unread', GETDATE()),
  (@aliceId, @coursePyId,  'You have been enrolled in Python Basics.',                                             'Enrollment',    'Unread', DATEADD(MINUTE, -5, GETDATE())),
  (@adminId, NULL,         'Scheduled report (ID: 1) for scope ''Department'' has been generated.',                'Report',        'Unread', DATEADD(MINUTE, -2, GETDATE())),
  (@bobId,   @coursePyId,  'Your certification (ID: 2) has been issued.',                                          'Certification', 'Read',   DATEADD(DAY, -1, GETDATE()));


COMMIT TRANSACTION;

-- ============================================================
-- Seed complete.
--
-- TEST SCENARIOS
-- ──────────────────────────────────────────────────────────
-- 1. Login as Admin    → POST /api/Auth/login  { email: "admin@skillforge.com",   password: "Admin@123" }
-- 2. Login as HR       → POST /api/Auth/login  { email: "hr@skillforge.com",      password: "Admin@123" }
-- 3. Login as Trainer  → POST /api/Auth/login  { email: "trainer@skillforge.com", password: "Admin@123" }
-- 4. Login as Alice    → POST /api/Auth/login  { email: "alice@skillforge.com",   password: "Admin@123" }
-- 5. Login as Bob      → POST /api/Auth/login  { email: "bob@skillforge.com",     password: "Admin@123" }
--
-- CERTIFICATION API TESTS (requires Admin or HR JWT):
-- A. Issue Python Basics cert for Alice (should PASS — she has a passing result):
--       POST /api/v1/Certification/certifications
--       { "employeeId": <aliceId>, "courseId": <pythonBasicsId> }
--
-- B. Issue cert for Bob (should FAIL — no passing result):
--       POST /api/v1/Certification/certifications
--       { "employeeId": <bobId>, "courseId": <pythonBasicsId> }
--
-- C. Issue Web Dev cert for Alice again (should FAIL — already Active):
--       POST /api/v1/Certification/certifications
--       { "employeeId": <aliceId>, "courseId": <webDevId> }
--
-- RESULT API TESTS:
-- D. Submit Bob's result on the Python Practical (MaxScore = 50, PassingScore = 35):
--       Score 45  → Pass
--       Score 20  → Fail
--       Score 55  → 400 Bad Request (exceeds MaxScore)
--
-- E. Submit a duplicate result for Alice on Web Dev Quiz → 400 Bad Request
--
-- REPORT SCHEDULE API TESTS (requires Admin JWT):
-- F. Create a new schedule (every minute, for quick testing):
--       POST /api/v1/reports/schedule
--       { "scope": "Department", "cronExpression": "* * * * *" }
--       → 201 Created  { scheduleID, nextRun (IST), isActive: true }
--
-- G. Create a schedule with a bad cron expression:
--       POST /api/v1/reports/schedule
--       { "scope": "Course", "cronExpression": "invalid cron" }
--       → 400 Bad Request  { message: "Invalid cron expression..." }
--
-- H. List all schedules:
--       GET /api/v1/reports/schedules
--       → 200 OK  [ { scheduleID, scope, cronExpression, nextRun, isActive } ]
--
-- I. Wait ~1 minute after seeding, then verify automatic execution in the DB:
--       SELECT * FROM Report          ORDER BY GeneratedDate DESC;   -- new row added
--       SELECT LastRun, NextRun FROM ReportSchedule WHERE IsActive = 1;
--       SELECT * FROM AuditLog WHERE Action = 'ScheduledReportGenerated';
--
-- J. Test role guard — login as Alice (Employee) and call POST /api/v1/reports/schedule
--       → 403 Forbidden
-- ============================================================
