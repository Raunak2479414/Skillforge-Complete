use tmpDb6

select * from [User]
select * from [AuditLog]
select * from [Course]
select * from [Module]
select * from [Enrollment]
select * from [Attendance]
select * from [Assessments]
select * from [Results]
select * from [Certifications]
select * from [Competency]
select * from [SkillGap]
select * from [ComplianceRecord]
select * from [Audit]
select * from [Report]
select * from [ReportSchedule]
select * from [Notification]


-- Report was generated
SELECT * FROM Report ORDER BY GeneratedDate DESC;

-- Schedule's LastRun and NextRun were updated
SELECT ScheduleID, LastRun, NextRun FROM ReportSchedule;

-- Audit log notification was written
SELECT * FROM AuditLog WHERE Action = 'ScheduledReportGenerated' ORDER BY Timestamp DESC;


SELECT * FROM Report ORDER BY GeneratedDate DESC;

SELECT * FROM [Notification] WHERE UserID = 11
