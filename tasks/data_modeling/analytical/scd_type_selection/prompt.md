# Choose slowly changing dimension types

You are designing dimensions for an HR and customer analytics warehouse. For each
attribute and requirement below, pick the Kimball slowly changing dimension
(SCD) technique that fits best. Answer with the type number:

- `0` retain original
- `1` overwrite
- `2` add new row
- `3` add new attribute (prior value column)
- `4` add mini-dimension
- `6` add Type 1 attributes to a Type 2 dimension (hybrid: full history plus the current value on every row)

Attributes:

- **a1.** `employee.hire_date`: set once; business rules say reports must always
  show the value originally recorded, even if someone edits it later in the HR system.
- **a2.** `employee.email`: changes occasionally; nobody needs to know old emails.
- **a3.** `employee.department`: headcount and cost reports must attribute each
  month to the department the employee belonged to at that time.
- **a4.** `customer.sales_region`: after a one-time territory realignment,
  managers want to compare results under the new region and the region just
  before the realignment, side by side. Older history is not needed.
- **a5.** `customer.name`: corrections of spelling mistakes only.
- **a6.** `customer.credit_score_band`, `customer.income_band`: in a dimension of
  50 million customers, these bands change for many customers every month and
  analysts filter and group facts by them over time.
- **a7.** `employee.job_title`: analysts need every past title with its dates,
  and also want to group all of an employee's historical facts by their current title
  without a self-join.

Answer with only a JSON object in this shape:

```json
{"a1": 0, "a2": 1, "...": "..."}
```
