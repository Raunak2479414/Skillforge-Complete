use tmpDb6

select *
from [User]

-- adding a user as a Employee
insert into [User]
    ([Name],[Email],[Role],[Phone],[Password],[Status])
VALUES('Employee', 'employee@employee.com', 'Employee', '1234567890', '$2a$12$9EYM9jKq85qt9xtp/cFXWOk3J17JzuHDEhz4NjikI/qoeYjPnNNkm', 1)
-- password is 'employee@employee123'

-- adding a user as a trainer
insert into [User]
    ([Name],[Email],[Role],[Phone],[Password],[Status])
VALUES('blaBla', 'blabla@blabla.com', 'Trainer', '1234567890', '$2a$12$U0qX8XP1CwYeTELPrGVd5eW3nLJQl05DHmFMo2AGWLudS.RUG0GPG', 1)
-- password is 'blabla@bla123'

-- adding a user as a Admin 
insert into [User]
    ([Name],[Email],[Role],[Phone],[Password],[Status])
VALUES('Admin', 'admin@admin.com', 'Admin', '1234567890', '$2a$12$HSFA7nVxYFthiluhv6fX/O/jDzR75IWfHtlxz6QNfCOJexCUe/bde', 1)
-- password is 'Admin@123'


-- adding a user as a HR
insert into [User]
    ([Name],[Email],[Role],[Phone],[Password],[Status])
VALUES('HR', 'hr@company.com', 'HR', '1234567890', '$2a$12$WIkYX3jCT1AztEYT.gWIyeEuQh3gblr.Cg1iyJYNMptCvePVPpveq', 1)
-- password is 'HR@123'


-- {
--   "name": "quekQuek",
--   "email": "quekQuek@quekQuek.com",
--   "role": "Employee",
--   "phone": "1234567890",
--   "password": "quekQuek@1234567890"
-- }


-- Courses

select *
from [Course]
-- adding a course
-- 1 -> live  0 -> not live

insert into [Course]
    ([Title],[Description],[TrainerID],[Duration],[Status])
values
    ('C# Basics', 'Learn the basics of C# programming language', 3, 30, 1)

insert into [Course]
    ([Title],[Description],[TrainerID],[Duration],[Status])
VALUES
    ('Web Dev', 'Web development course', 1, 40.0, 1),
    ('Python Basics', 'Python fundamentals', 1, 30.0, 1);

select * from [Course]    

-- Modules for Courses
INSERT INTO [Module] ([CourseID], [Title], [ContentURI], [Duration], [Status]) VALUES
  (2, 'HTML & CSS',       'https://cdn.skillforge/html', 10.0, 1),
  (2, 'JavaScript Intro', 'https://cdn.skillforge/js',   15.0, 1),
  (3,  'Python Syntax',    'https://cdn.skillforge/py1',  10.0, 1),
  (3,  'Python OOP',       'https://cdn.skillforge/py2',  12.0, 1);


select * from [Module]

-- 

select * from [Assessments]

select *
from [AuditLog]


select * from [Results]

select * from [Certifications]