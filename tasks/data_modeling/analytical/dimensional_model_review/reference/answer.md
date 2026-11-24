## Problems

1. **Mixed grain.** Header and line rows live in one fact table. `sum(line_amount)` works
   only because headers are NULL, `count(*)` counts headers and lines, and every query must
   remember `row_type`. A fact table should have one grain.
2. **Order-level amounts repeated per row.** `shipping_fee` and `order_total` appear on the
   header and on every line, so `sum(shipping_fee)` by segment is multiplied by lines + 1.
3. **Non-additive `margin_pct`.** Summing it is meaningless; averaging it weights a 1 kr line
   like a 10 000 kr line. Store `revenue_amount` and `cost_amount` (or `margin_amount`) and
   compute margin % = sum(margin) / sum(revenue).
4. **Text dates in DD/MM/YYYY.** They sort wrongly, need parsing in every query and can't be
   joined to a calendar. Use a DATE and a `date_key` to `dim_date`.
5. **Customer attributes in the fact, current values only.** `customer_segment` is today's
   segment, so "shipping fees by segment at the time of the order" can't be answered, and
   name/segment changes require rewriting the fact. Move them to a Type 2 `dim_customer`.
6. **Keys.** `product_key` embeds the category code, so a product that moves category gets a
   new key and history splits; `sale_key` is a text concatenation. Use integer surrogate keys.
   Guest checkouts should point to a "Guest" member row (e.g. key -2) instead of a NULL foreign
   key, so inner joins don't drop sales. `order_id` stays in the fact as a degenerate dimension.
7. **Snowflaked product hierarchy.** product → category → department adds two joins for the
   most common filter. Flatten category and department names into `dim_product`.

## Corrected model

- `fct_order_line` (grain: one row per order line): `date_key`, `customer_key`,
  `product_key`, `order_id` (degenerate), `line_number`, `quantity`, `revenue_amount`,
  `cost_amount`, `allocated_shipping_fee` (order fee allocated to lines by revenue share).
- `fct_order` (grain: one row per order): `date_key`, `customer_key`, `order_id`,
  `shipping_fee`, `order_total`, `line_count`. Use it for order counts and shipping fees.
- `dim_customer` (Type 2 on segment): `customer_key`, `customer_id`, `name`, `segment`,
  `valid_from`, `valid_to`, `is_current`; includes unknown and guest member rows.
- `dim_product`: `product_key`, `product_id`, `product_name`, `category`, `department`.
- `dim_date`: `date_key`, `date`, `month`, `quarter`, `year`, ...

In dbt, the raw source cleanup (date parsing, renaming) belongs in staging models; the facts
and dimensions above are marts.
