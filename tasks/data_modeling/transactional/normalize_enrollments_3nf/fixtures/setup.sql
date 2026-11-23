CREATE TABLE raw_enrollments (
    student_id      VARCHAR,
    student_name    VARCHAR,
    student_email   VARCHAR,
    course_code     VARCHAR,
    course_title    VARCHAR,
    dept_code       VARCHAR,
    dept_name       VARCHAR,
    semester        VARCHAR,
    instructor_id   VARCHAR,
    instructor_name VARCHAR,
    grade           VARCHAR
);

INSERT INTO raw_enrollments VALUES
    ('S1', 'Ada Lind',     'ada@uni.test',   'CS101', 'Intro to Programming', 'CS',   'Computer Science', '2024-FALL',   'I1', 'Dr. Holm',   'A'),
    ('S2', 'Bo Strand',    'bo@uni.test',    'CS101', 'Intro to Programming', 'CS',   'Computer Science', '2024-FALL',   'I1', 'Dr. Holm',   'B'),
    ('S3', 'Cleo Vik',     'cleo@uni.test',  'CS101', 'Intro to Programming', 'CS',   'Computer Science', '2025-SPRING', 'I2', 'Dr. Berg',   'A'),
    ('S1', 'Ada Lind',     'ada@uni.test',   'CS201', 'Data Structures',      'CS',   'Computer Science', '2025-SPRING', 'I2', 'Dr. Berg',   NULL),
    ('S2', 'Bo Strand',    'bo@uni.test',    'MA110', 'Linear Algebra',       'MATH', 'Mathematics',      '2024-FALL',   'I3', 'Dr. Sund',   'C'),
    ('S4', 'Dag Ek',       'dag@uni.test',   'MA110', 'Linear Algebra',       'MATH', 'Mathematics',      '2024-FALL',   'I3', 'Dr. Sund',   'B'),
    ('S4', 'Dag Ek',       'dag@uni.test',   'MA110', 'Linear Algebra',       'MATH', 'Mathematics',      '2025-SPRING', 'I3', 'Dr. Sund',   'A'),
    ('S3', 'Cleo Vik',     'cleo@uni.test',  'MA210', 'Probability',          'MATH', 'Mathematics',      '2025-SPRING', 'I1', 'Dr. Holm',   'B'),
    ('S5', 'Eva Norr',     'eva@uni.test',   'EC100', 'Microeconomics',       'ECON', 'Economics',        '2024-FALL',   'I4', 'Dr. Falk',   'A'),
    ('S5', 'Eva Norr',     'eva@uni.test',   'CS101', 'Intro to Programming', 'CS',   'Computer Science', '2025-SPRING', 'I2', 'Dr. Berg',   'B'),
    ('S6', 'Finn Ås',      'finn@uni.test',  'EC100', 'Microeconomics',       'ECON', 'Economics',        '2024-FALL',   'I4', 'Dr. Falk',   NULL),
    ('S6', 'Finn Ås',      'finn@uni.test',  'CS201', 'Data Structures',      'CS',   'Computer Science', '2025-SPRING', 'I2', 'Dr. Berg',   'C');
