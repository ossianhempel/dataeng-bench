-- Classic mistake: treats instructor as a property of the course, not of the offering.
-- Courses then repeat per instructor, so course_code no longer identifies a row.
CREATE TABLE departments (dept_code VARCHAR PRIMARY KEY, dept_name VARCHAR);
CREATE TABLE instructors (instructor_id VARCHAR PRIMARY KEY, instructor_name VARCHAR);
CREATE TABLE students (student_id VARCHAR PRIMARY KEY, student_name VARCHAR, student_email VARCHAR);
CREATE TABLE courses (
    course_code VARCHAR, course_title VARCHAR, dept_code VARCHAR REFERENCES departments (dept_code),
    instructor_id VARCHAR REFERENCES instructors (instructor_id),
    PRIMARY KEY (course_code, instructor_id)
);
CREATE TABLE enrollments (
    student_id VARCHAR REFERENCES students (student_id), course_code VARCHAR, semester VARCHAR,
    instructor_id VARCHAR, grade VARCHAR,
    PRIMARY KEY (student_id, course_code, semester),
    FOREIGN KEY (course_code, instructor_id) REFERENCES courses (course_code, instructor_id)
);
INSERT INTO departments SELECT DISTINCT dept_code, dept_name FROM raw_enrollments;
INSERT INTO instructors SELECT DISTINCT instructor_id, instructor_name FROM raw_enrollments;
INSERT INTO students SELECT DISTINCT student_id, student_name, student_email FROM raw_enrollments;
INSERT INTO courses SELECT DISTINCT course_code, course_title, dept_code, instructor_id FROM raw_enrollments;
INSERT INTO enrollments SELECT student_id, course_code, semester, instructor_id, grade FROM raw_enrollments;
CREATE VIEW enrollments_flat AS
SELECT s.student_id, s.student_name, s.student_email, c.course_code, c.course_title, d.dept_code,
       d.dept_name, e.semester, i.instructor_id, i.instructor_name, e.grade
FROM enrollments e
JOIN students s USING (student_id)
JOIN courses c ON c.course_code = e.course_code AND c.instructor_id = e.instructor_id
JOIN departments d ON d.dept_code = c.dept_code
JOIN instructors i ON i.instructor_id = e.instructor_id;
