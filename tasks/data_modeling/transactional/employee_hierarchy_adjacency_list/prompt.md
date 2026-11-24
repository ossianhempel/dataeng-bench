# Model an employee hierarchy

HR exports employees with their direct manager into DuckDB:

```sql
CREATE TABLE raw_employees (employee_id INTEGER, name VARCHAR, manager_id INTEGER);
```

The CEO has `manager_id = NULL`. Rows are in no particular order.

## Your task

Write a DuckDB SQL script that:

1. Creates a table `employees` (`employee_id`, `name`, `manager_id`) where the
   database enforces these rules:
   - `employee_id` identifies an employee and every employee has a name.
   - `manager_id` is either NULL or the id of an existing employee.
   - Nobody is their own manager.
2. Loads it from `raw_employees`. Note that DuckDB checks a foreign key against
   the rows that existed before the INSERT statement started, so rows inserted by
   the same statement cannot reference each other: insert the hierarchy one level
   per statement, managers first. The hierarchy is at most 6 levels deep.
3. Creates a view `org_chart` with one row per employee and columns:
   - `employee_id`, `name`
   - `depth`: 0 for the CEO, 1 for their direct reports, and so on
   - `path`: names from the CEO down to the employee joined with `' > '`
     (for example `'Ada > Bo > Dee'`)
   - `report_count`: number of people below the employee at any depth

Do not modify `raw_employees`. Return only the SQL script.
