# Data modeling tasks

19 tasks in two groups. Transactional (OLTP) tasks test schema design for
applications: normalization, keys, constraints and relationships. Analytical
(OLAP) tasks test modeling for reporting: grain, star schemas, slowly changing
dimensions, snapshot facts, bridges and Data Vault.

Task ideas come from common data and analytics engineering interview questions
and the modeling literature. Each task's `task.yaml` lists its sources. Prompts,
fixtures and reference answers are written for this benchmark.

## Transactional

| Task | Answer | Difficulty | What it tests |
|---|---|---|---|
| [normalize_enrollments_3nf](transactional/normalize_enrollments_3nf) | sql | medium | Decompose a flat extract into 3NF with keys; lossless rebuild view; graded for redundancy by functional dependency, not table names |
| [order_schema_constraints](transactional/order_schema_constraints) | sql | medium | Turn business rules into PK, FK, UNIQUE, CHECK and DEFAULT; graded by 6 must-accept and 22 must-reject inserts |
| [employee_hierarchy_adjacency_list](transactional/employee_hierarchy_adjacency_list) | sql | medium | Self-referencing FK, no self-management, recursive flattening with depth, path and total reports |
| [identify_normal_forms](transactional/identify_normal_forms) | structured | medium | Candidate keys and highest normal form (1NF to 4NF) of six relations, including the 3NF-not-BCNF and BCNF-not-4NF cases |
| [clinic_booking_er_design](transactional/clinic_booking_er_design) | rubric | hard | Open ER design: many-to-many, double-booking prevention, cancellation and reschedule history |

## Analytical

| Task | Answer | Difficulty | What it tests |
|---|---|---|---|
| [order_lines_fact_grain](analytical/order_lines_fact_grain) | sql | easy | Declare the grain; dedupe at-least-once deliveries keeping the latest version |
| [retail_star_schema](analytical/retail_star_schema) | sql | medium | Surrogate keys, unknown members, date dimension, key normalization, no lost facts |
| [scd2_from_snapshots](analytical/scd2_from_snapshots) | sql | medium | Type 2 from snapshots with Type 1 email, NULL-safe change detection, reverted changes, hard deletes |
| [scd2_point_in_time_join](analytical/scd2_point_in_time_join) | sql | medium | Half-open as-of join, facts before the first version, as-was versus as-is reporting |
| [order_fulfillment_accumulating_snapshot](analytical/order_fulfillment_accumulating_snapshot) | sql | medium | Milestones from out-of-order duplicate events, calendar-day lags, status precedence |
| [inventory_periodic_snapshot](analytical/inventory_periodic_snapshot) | sql | medium | Dense daily snapshot from movements, carry-forward, semi-additive averaging |
| [fan_trap_customer_summary](analytical/fan_trap_customer_summary) | sql | medium | Aggregate two one-to-many children without fan-out double counting |
| [promotion_coverage_factless](analytical/promotion_coverage_factless) | sql | medium | Coverage factless fact and "promoted but did not sell" |
| [multivalued_bridge_allocation](analytical/multivalued_bridge_allocation) | sql | hard | Weighted bridge table for joint accounts; weighted versus impact reporting |
| [data_vault_hub_link_satellite](analytical/data_vault_hub_link_satellite) | sql | hard | Hubs, link and satellite with normalized hash keys and change-only satellite loads |
| [classify_fact_tables_and_measures](analytical/classify_fact_tables_and_measures) | structured | easy | Fact table types and additive, semi-additive, non-additive measures |
| [scd_type_selection](analytical/scd_type_selection) | structured | medium | Choose SCD Type 0, 1, 2, 3, 4 or 6 from requirements |
| [subscription_mrr_dimensional_design](analytical/subscription_mrr_dimensional_design) | rubric | hard | Design a SaaS MRR model: grain, snapshot facts, MRR movements, churn and NRR |
| [dimensional_model_review](analytical/dimensional_model_review) | rubric | medium | Find mixed grain, fan-out, non-additive facts, smart keys and history loss in a model |

## Main sources

- R. Kimball and M. Ross, *The Data Warehouse Toolkit*, 3rd ed., Wiley, 2013.
- Kimball Group, [Dimensional Modeling Techniques](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/) and Design Tips.
- dbt Developer Hub, [snapshots](https://docs.getdbt.com/docs/build/snapshots) and [project structure](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview).
- D. Linstedt and M. Olschimke, *Building a Scalable Data Warehouse with Data Vault 2.0*, Morgan Kaufmann, 2015.
- E. F. Codd (1970, 1971), W. Kent (1983) and R. Fagin (1977) on the relational model and normal forms.
- Interview question collections such as [DataCamp](https://www.datacamp.com/blog/data-warehouse-interview-questions) and [Exponent](https://www.tryexponent.com/courses/data-engineering/data-modeling-interviews/data-modeling-intro).
