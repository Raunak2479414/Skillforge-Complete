-- ============================================================
-- SkillForge  –  Employee End-to-End Flow Seed Script
-- ============================================================
-- This script creates a complete employee journey:
--   User → Course + Module → Enrollment → Assessment →
--   Result (Pass) → Certification → ComplianceRecord → SkillGap
--
-- Password for all users: Test@1234
-- Replace <<BCRYPT_HASH>> with a BCrypt hash of "Test@1234" before running.
--
-- Generate the hash (run once in Program.cs before app.Run()):
--     Console.WriteLine(BCrypt.Net.BCrypt.HashPassword("Test@1234"));
-- ============================================================

BEGIN TRANSACTION;

-- ── Password hash ────────────────────────────────────────────────────────────
DECLARE @pwd VARCHAR(255) = '$2a$12$Rs64XbPQ8rd96XyQcEuo4uS1tiirbuZF1UlZwMhfXrXEjIskqFnqS';


-- ── 1. Users ─────────────────────────────────────────────────────────────────
-- Trainer is required as FK on Course
INSERT INTO [User] (Name, Role, Email, Phone, Password, Status) VALUES
    ('John Smith',  'Trainer',  'john.smith@skillforge.com',  '9100000001', @pwd, 1),
    ('Emma Davis',  'Employee', 'emma.davis@skillforge.com',  '9100000002', @pwd, 1);

DECLARE @trainerId  INT = (SELECT UserID FROM [User] WHERE Email = 'john.smith@skillforge.com');
DECLARE @employeeId INT = (SELECT UserID FROM [User] WHERE Email = 'emma.davis@skillforge.com');


-- ── 2. Competencies ──────────────────────────────────────────────────────────
-- Name is VARCHAR(10) — keep it short
-- Level: Beginner | Intermediate | Advanced
INSERT INTO Competency (Name, Description, Level) VALUES
    ('ReactJS',   'React frontend development',    'Beginner'),
    ('NodeJS',    'Node.js backend development',   'Intermediate'),
    ('Docker',    'Container & DevOps basics',     'Advanced');

DECLARE @compReactId  INT = (SELECT CompetencyID FROM Competency WHERE Name = 'ReactJS');
DECLARE @compNodeId   INT = (SELECT CompetencyID FROM Competency WHERE Name = 'NodeJS');
DECLARE @compDockerId INT = (SELECT CompetencyID FROM Competency WHERE Name = 'Docker');


-- ── 3. Course ────────────────────────────────────────────────────────────────
-- Title: VARCHAR(20)  |  Description: VARCHAR(50)
-- Status = 1 (live) is required for assessment and certification
INSERT INTO Course (Title, Description, TrainerID, Duration, Status) VALUES
    ('Full Stack Dev', 'Full stack web development', @trainerId, 60.0, 1);

DECLARE @courseId INT = (SELECT CourseID FROM Course WHERE Title = 'Full Stack Dev');


-- ── 4. Modules ───────────────────────────────────────────────────────────────
-- Title: VARCHAR(20)  |  ContentURI: VARCHAR(50)
INSERT INTO [Module] (CourseID, Title, ContentURI, Duration, Status) VALUES
    (@courseId, 'React Fundamentals', 'https://cdn.skillforge/react',  20.0, 1),
    (@courseId, 'Node & Express',     'https://cdn.skillforge/node',   20.0, 1),
    (@courseId, 'Docker & Deploy',    'https://cdn.skillforge/docker', 20.0, 1);


-- ── 5. Enrollment ────────────────────────────────────────────────────────────
INSERT INTO Enrollment (CourseID, EmployeeID, EnrollmentDate, Status) VALUES
    (@courseId, @employeeId, GETDATE(), 1);

DECLARE @enrollmentId INT = (SELECT EnrollmentID FROM Enrollment
                              WHERE CourseID = @courseId AND EmployeeID = @employeeId);


-- ── 6. Attendance ─────────────────────────────────────────────────────────────
INSERT INTO Attendance (EnrollmentID, AttendanceDate, Status) VALUES
    (@enrollmentId, GETDATE(),              1),
    (@enrollmentId, DATEADD(DAY, -6, GETDATE()), 1),
    (@enrollmentId, DATEADD(DAY, -5, GETDATE()), 1),
    (@enrollmentId, DATEADD(DAY, -4, GETDATE()), 1),
    (@enrollmentId, DATEADD(DAY, -3, GETDATE()), 1);


-- ── 7. Assessment ────────────────────────────────────────────────────────────
-- Type: Quiz | Exam | Practical
-- MaxScore: DECIMAL(4,1)
INSERT INTO Assessments (CourseID, Type, MaxScore, Date) VALUES
    (@courseId, 'Exam', 100.0, GETDATE());

DECLARE @assessmentId INT = (SELECT AssessmentID FROM Assessments
                               WHERE CourseID = @courseId AND Type = 'Exam');


-- ── 8. Result (Pass) ─────────────────────────────────────────────────────────
-- Composite PK: (AssessmentID, EmployeeID)
-- Score >= 35 (default passing score in appsettings.json) → Pass
-- ResultID is a regular column (not the PK)
INSERT INTO Results (AssessmentID, EmployeeID, ResultID, Score, Status) VALUES
    (@assessmentId, @employeeId, 100, 78.0, 'Pass');


-- ── 9. Certification ─────────────────────────────────────────────────────────
-- Status: Active | Revoked | Expired
-- ExpiryDate must be > IssueDate (check constraint)
INSERT INTO Certifications (EmployeeID, CourseID, IssueDate, ExpiryDate, Status) VALUES
    (@employeeId, @courseId, GETDATE(), DATEADD(YEAR, 1, GETDATE()), 'Active');

DECLARE @certId INT = SCOPE_IDENTITY();


-- ── 10. ComplianceRecord ─────────────────────────────────────────────────────
-- Status = 1 → compliant (certification is active and not expired)
INSERT INTO ComplianceRecord (EmployeeID, CertificationID, Status, Date) VALUES
    (@employeeId, @certId, 1, GETDATE());


-- ── 11. SkillGap ─────────────────────────────────────────────────────────────
-- GapLevel stored as INT: 0 = Low | 1 = Medium | 2 = High
INSERT INTO SkillGap (EmployeeID, CompetencyID, GapLevel, DateIdentified) VALUES
    (@employeeId, @compReactId,  0, GETDATE()),   -- Low gap in React
    (@employeeId, @compNodeId,   1, GETDATE()),   -- Medium gap in Node
    (@employeeId, @compDockerId, 2, GETDATE());   -- High gap in Docker


COMMIT TRANSACTION;

-- ============================================================
-- Flow complete. Test the following endpoints using Swagger:
--
-- 1. Login as the new employee:
--       POST /api/v1/Auth/login
--       { "email": "emma.davis@skillforge.com", "password": "Test@1234" }
--
-- 2. Login as trainer:
--       POST /api/v1/Auth/login
--       { "email": "john.smith@skillforge.com", "password": "Test@1234" }
--
-- 3. View compliance summary (login as Admin/HR first):
--       GET /api/v1/ComplianceRecord/Summary
--       → Emma should appear as compliant
--
-- 4. Refresh compliance records:
--       GET /api/v1/ComplianceRecord/Refresh
--
-- 5. View skill gaps (login as Manager/Admin):
--       GET /api/v1/SkillGap
--       → Emma should have 3 gaps (Low/Medium/High)
--
-- 6. Try issuing Emma's certification again (should FAIL — already Active):
--       POST /api/v1/Certification/certifications
--       { "employeeId": <emma's ID>, "courseId": <Full Stack Dev ID> }
--       → 409 Conflict
--
-- 7. Verify result was saved:
--       SELECT * FROM Results WHERE EmployeeID = <emma's ID>;
--       Score = 78.0, Status = 'Pass'
--
-- 8. Check audit log entries:
--       SELECT * FROM AuditLog ORDER BY Timestamp DESC;
-- ============================================================
