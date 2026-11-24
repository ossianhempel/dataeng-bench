# Classify fact tables and measures

**Part 1.** For each business need, choose the fact table type that fits best:
`transaction`, `periodic_snapshot`, `accumulating_snapshot` or `factless`.

- **f1.** Record every item scanned at a supermarket checkout, with quantity and price.
- **f2.** Track each mortgage application through submitted, underwritten,
  approved and funded, including the days spent between steps.
- **f3.** Report every bank account's balance at the end of each month.
- **f4.** Record which students attended which class session. Nothing is
  measured; the attendance itself is the fact.
- **f5.** Store the stock level of every product in every warehouse at the end of each day.
- **f6.** Record which products were on promotion in which stores on each day,
  whether or not they sold, so analysts can find promoted products that did not sell.
- **f7.** Track each insurance claim from first notice through assessment,
  approval and payment, updating the row as the claim progresses.
- **f8.** Record each page view on a website, with time on page.

**Part 2.** Classify each measure as `additive` (can be summed across every
dimension), `semi_additive` (can be summed across some dimensions but not across
time) or `non_additive` (cannot be meaningfully summed).

- **m1.** Sales amount on a checkout line item.
- **m2.** Account balance in a monthly balance snapshot.
- **m3.** Unit price on a checkout line item.
- **m4.** Gross margin percentage on an order line.
- **m5.** Quantity on hand in a daily inventory snapshot.
- **m6.** Quantity sold on an order line.
- **m7.** Number of distinct customers who bought on a day.
- **m8.** Headcount in a month-end employee snapshot.

Answer with only a JSON object in this shape:

```json
{
  "fact_tables": {"f1": "transaction", "f2": "...", "...": "..."},
  "measures": {"m1": "additive", "m2": "...", "...": "..."}
}
```
