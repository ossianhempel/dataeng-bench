CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    name        VARCHAR NOT NULL,
    manager_id  INTEGER REFERENCES employees (employee_id),
    CHECK (manager_id IS NULL OR manager_id <> employee_id)
);

-- DuckDB checks foreign keys against rows that existed before each statement,
-- so load one level per statement, top-down. The hierarchy is at most 6 levels deep.
CREATE TEMP TABLE employee_levels AS
WITH RECURSIVE levels AS (
    SELECT employee_id, name, manager_id, 0 AS depth
    FROM raw_employees WHERE manager_id IS NULL
    UNION ALL
    SELECT r.employee_id, r.name, r.manager_id, l.depth + 1
    FROM raw_employees AS r JOIN levels AS l ON r.manager_id = l.employee_id
)
SELECT * FROM levels;

INSERT INTO employees SELECT employee_id, name, manager_id FROM employee_levels WHERE depth = 0;
INSERT INTO employees SELECT employee_id, name, manager_id FROM employee_levels WHERE depth = 1;
INSERT INTO employees SELECT employee_id, name, manager_id FROM employee_levels WHERE depth = 2;
INSERT INTO employees SELECT employee_id, name, manager_id FROM employee_levels WHERE depth = 3;
INSERT INTO employees SELECT employee_id, name, manager_id FROM employee_levels WHERE depth = 4;
INSERT INTO employees SELECT employee_id, name, manager_id FROM employee_levels WHERE depth = 5;
DROP TABLE employee_levels;

CREATE VIEW org_chart AS
WITH RECURSIVE tree AS (
    SELECT employee_id, name, 0 AS depth, name AS path, [employee_id] AS ancestors
    FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.name, t.depth + 1, t.path || ' > ' || e.name,
           list_append(t.ancestors, e.employee_id)
    FROM employees AS e JOIN tree AS t ON e.manager_id = t.employee_id
)
SELECT
    t.employee_id,
    t.name,
    t.depth,
    t.path,
    (SELECT count(*) FROM tree AS d
     WHERE list_contains(d.ancestors, t.employee_id) AND d.employee_id <> t.employee_id) AS report_count
FROM tree AS t;
