# Sakila Database Validation

SQL data validation checks on the MySQL Sakila sample database (DVD rental store), written and run in MySQL Workbench.

## What I tested
| # | Check | Expected | Result |
|---|-------|----------|--------|
| 1 | Duplicate customer emails | 0 rows | PASS |
| 2 | Missing customer emails | 0 rows | PASS |
| 3 | Orphan rentals (no customer) | 0 rows | PASS |
| 4 | Orphan payments (no rental) | 0 rows | [result] |
| 5 | Zero or negative rental rate | 0 rows | [result] |
| 6 | Returned before rented | 0 rows | [result] |
| 7 | Customers with no rentals | informational | [result] |
| 8 | Top 5 customers by rentals | informational | Top customer_id 148 (46 rentals), 5th customer_id 75 (41 rentals) |
| 9 | Rental count reconciliation | values equal | [result] |

## Negative tests
To prove each check can catch a real defect, I injected errors into copies of the tables (original data untouched):
- Duplicate email in `customer_test`: check returned 1 row (total = 2)
- Missing email in `customer_test`: check returned 1 row (customer_id 3)
- Orphan rental (customer_id 9999) in `rental_test`: check returned 1 row (rental_id 1)
- Return date before rental date in `rental_test`: check returned 1 row (rental_id 2)

## Lesson learned
My first orphan test used customer_id 99999, which failed with Error 1264 (out of range for SMALLINT UNSIGNED). The check returned 0 rows, which looked like a pass but was actually a failed setup. I confirmed the defect was injected before trusting the result.

## How to run
1. Install MySQL Server and Workbench.
2. Load `sakila-schema.sql` then `sakila-data.sql`.
3. Open `sakila.sql` and run each query.

## Skills shown
SQL (JOIN, GROUP BY, HAVING, subqueries), data integrity testing, negative testing, test documentation.