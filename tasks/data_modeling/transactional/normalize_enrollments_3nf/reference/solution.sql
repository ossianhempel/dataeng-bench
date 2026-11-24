CREATE TABLE departments (
    dept_code VARCHAR PRIMARY KEY,
    dept_name VARCHAR NOT NULL
);

CREATE TABLE courses (
    course_code  VARCHAR PRIMARY KEY,
    course_title VARCHAR NOT NULL,
    dept_code    VARCHAR NOT NULL REFERENCES departments (dept_code)
);

CREATE TABLE instructors (
    instructor_id   VARCHAR PRIMARY KEY,
    instructor_name VARCHAR NOT NULL
);

CREATE TABLE students (
    student_id    VARCHAR PRIMARY KEY,
    student_name  VARCHAR NOT NULL,
    student_email VARCHAR NOT NULL UNIQUE
);

CREATE TABLE course_offerings (
    course_code   VARCHAR NOT NULL REFERENCES courses (course_code),
    semester      VARCHAR NOT NULL,
    instructor_id VARCHAR NOT NULL REFERENCES instructors (instructor_id),
    PRIMARY KEY (course_code, semester)
);

CREATE TABLE enrollments (
    student_id  VARCHAR NOT NULL REFERENCES students (student_id),
    course_code VARCHAR NOT NULL,
    semester    VARCHAR NOT NULL,
    grade       VARCHAR,
    PRIMARY KEY (student_id, course_code, semester),
    FOREIGN KEY (course_code, semester) REFERENCES course_offerings (course_code, semester)
);

INSERT INTO departments SELECT DISTINCT dept_code, dept_name FROM raw_enrollments;
INSERT INTO courses SELECT DISTINCT course_code, course_title, dept_code FROM raw_enrollments;
INSERT INTO instructors SELECT DISTINCT instructor_id, instructor_name FROM raw_enrollments;
INSERT INTO students SELECT DISTINCT student_id, student_name, student_email FROM raw_enrollments;
INSERT INTO course_offerings SELECT DISTINCT course_code, semester, instructor_id FROM raw_enrollments;
INSERT INTO enrollments SELECT student_id, course_code, semester, grade FROM raw_enrollments;

CREATE VIEW enrollments_flat AS
SELECT
    s.student_id,
    s.student_name,
    s.student_email,
    c.course_code,
    c.course_title,
    d.dept_code,
    d.dept_name,
    e.semester,
    i.instructor_id,
    i.instructor_name,
    e.grade
FROM enrollments AS e
JOIN students AS s ON s.student_id = e.student_id
JOIN course_offerings AS o ON o.course_code = e.course_code AND o.semester = e.semester
JOIN courses AS c ON c.course_code = o.course_code
JOIN departments AS d ON d.dept_code = c.dept_code
JOIN instructors AS i ON i.instructor_id = o.instructor_id;
