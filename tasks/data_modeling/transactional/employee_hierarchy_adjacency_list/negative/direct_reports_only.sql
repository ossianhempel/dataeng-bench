-- No integrity rules, and only counts direct reports one level deep.
CREATE TABLE employees AS SELECT * FROM raw_employees;
CREATE VIEW org_chart AS
SELECT e.employee_id, e.name,
       CASE WHEN e.manager_id IS NULL THEN 0 ELSE 1 END AS depth,
       coalesce(m.name || ' > ', '') || e.name AS path,
       (SELECT count(*) FROM employees r WHERE r.manager_id = e.employee_id) AS report_count
FROM employees e LEFT JOIN employees m ON m.employee_id = e.manager_id;
