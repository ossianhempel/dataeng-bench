# Identify candidate keys and normal forms

For each relation below, the listed functional dependencies (FDs) are the only
ones that hold, apart from those implied by them. Attributes are atomic, so
every relation is at least in first normal form.

**q1.** `order_line(order_id, product_id, quantity, product_name, list_price)`
- order_id, product_id → quantity
- product_id → product_name, list_price

**q2.** `employee(employee_id, dept_id, dept_location)`
- employee_id → dept_id
- dept_id → dept_location

**q3.** `tutoring(student, subject, tutor)`
- student, subject → tutor
- tutor → subject

**q4.** `flight_leg(flight_no, flight_date, gate, pilot_id)`
- flight_no, flight_date → gate, pilot_id

**q5.** `country(country_code, country_name, capital)`
- country_code → country_name, capital
- country_name → country_code

**q6.** `employee_profile(employee_id, skill, language)`
- No non-trivial FDs hold. An employee's skills and the languages they speak
  are independent of each other, and the table stores every combination of an
  employee's skills with their languages.

For each relation, give:

- `candidate_keys`: every candidate key, each as a list of attribute names.
- `highest_normal_form`: the highest normal form it satisfies, one of `1NF`,
  `2NF`, `3NF`, `BCNF`, `4NF`.
- `violating_determinant`: if the relation is not in BCNF, the attributes on the
  left side of an FD that breaks BCNF (pick the one that causes the lowest
  normal form violation); otherwise an empty list.

Answer with only a JSON object in this shape:

```json
{
  "q1": {"candidate_keys": [["a", "b"]], "highest_normal_form": "2NF", "violating_determinant": ["a"]},
  "q2": {"...": "..."}
}
```
