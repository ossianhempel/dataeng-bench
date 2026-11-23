-- Copies the flat table: lossless, but every redundancy is still there.
CREATE TABLE enrollments AS SELECT * FROM raw_enrollments;
ALTER TABLE enrollments ADD PRIMARY KEY (student_id, course_code, semester);
CREATE VIEW enrollments_flat AS SELECT * FROM enrollments;
