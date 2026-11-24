# Normalize a flat enrollments extract

A university's legacy system exports one wide table, `raw_enrollments`, already
loaded into DuckDB:

```sql
CREATE TABLE raw_enrollments (
    student_id      VARCHAR,
    student_name    VARCHAR,
    student_email   VARCHAR,
    course_code     VARCHAR,
    course_title    VARCHAR,
    dept_code       VARCHAR,
    dept_name       VARCHAR,
    semester        VARCHAR,   -- e.g. '2024-FALL'
    instructor_id   VARCHAR,
    instructor_name VARCHAR,
    grade           VARCHAR    -- NULL until the course is graded
);
```

Sample rows:

| student_id | student_name | course_code | course_title | dept_code | semester | instructor_id | grade |
|---|---|---|---|---|---|---|---|
| S1 | Ada Lind | CS101 | Intro to Programming | CS | 2024-FALL | I1 | A |
| S3 | Cleo Vik | CS101 | Intro to Programming | CS | 2025-SPRING | I2 | A |
| S1 | Ada Lind | CS201 | Data Structures | CS | 2025-SPRING | I2 | NULL |

Business rules:

- A student has exactly one name and one email.
- A course has one title and belongs to exactly one department. A department has one name.
- A course can be offered in several semesters. Each offering (a course in a
  semester) is taught by exactly one instructor, but different offerings of the
  same course can have different instructors.
- An instructor has one name.
- A student enrolls in a given offering at most once and gets at most one grade for it.

## Your task

Write a DuckDB SQL script that:

1. Creates a schema in third normal form (Boyce-Codd normal form is fine) that
   stores this data without redundancy. Declare a primary key on every table you
   create, and declare foreign keys between your tables.
2. Loads your tables from `raw_enrollments`.
3. Creates a view named `enrollments_flat` that joins your tables back together
   and returns exactly the 11 columns of `raw_enrollments`, with the same names,
   and the same rows.

Keep the original column names for every attribute you store (for example, a
course's title must be stored in a column named `course_title`). Do not modify
or drop `raw_enrollments`.

Return only the SQL script.
