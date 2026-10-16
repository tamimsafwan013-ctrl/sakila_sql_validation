USE sakila;
SELECT COUNT(*) FROM customer;

-- Check 1: Duplicate customer emails (expected: 0 rows)
-- Result : 0 rows returned , PASS 
SELECT email, COUNT(*) AS total
FROM customer
GROUP BY email
HAVING COUNT(*) > 1;

-- Check 2: Customers with missing email (expected: 0 rows)
-- Result : 0 rows returned , PASS 
SELECT customer_id, first_name, last_name
FROM customer
WHERE email IS NULL;

-- Check 3: Orphan rentals with no matching customer (expected: 0 rows)
-- Result : 0 rows returned , PASS 
SELECT r.rental_id
FROM rental r
LEFT JOIN customer c ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check 4: Payments pointing to a rental that does not exist (expected: 0 rows)
-- Result: 0 rows returned , PASS 
SELECT p.payment_id
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
WHERE p.rental_id IS NOT NULL AND r.rental_id IS NULL;

-- Check 5: Films with a zero or negative rental rate (expected: 0 rows)
-- Result: 0 rows returned , PASS 
SELECT film_id, title, rental_rate
FROM film
WHERE rental_rate <= 0;

-- Check 6: Rentals returned before they were rented (expected: 0 rows)
-- Result: 0 rows returned , PASS 
SELECT rental_id, rental_date, return_date
FROM rental
WHERE return_date < rental_date;

-- Check 7: Customers with no rentals at all (informational)
-- Result: 0 rows returned 
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
WHERE r.rental_id IS NULL;

-- Check 8: Top 5 customers by number of rentals (informational)
-- Result: 5 rows returned. Top customer_id = [148] with [46] rentals;
--         5th customer_id = [75] with [41] rentals.
SELECT customer_id, COUNT(*) AS total_rentals
FROM rental
GROUP BY customer_id
ORDER BY total_rentals DESC
LIMIT 5;

-- Check 9: Sum of rentals per customer equals total rentals (expected: both values equal)
-- Result: both values equal (16044), PASS
SELECT
  (SELECT COUNT(*) FROM rental) AS total_rentals_table,
  (SELECT SUM(cnt) FROM (SELECT COUNT(*) AS cnt FROM rental GROUP BY customer_id) t) AS total_from_customers;

-- Negative test: inject a duplicate email into a practice copy
DROP TABLE IF EXISTS customer_test;
CREATE TABLE customer_test AS SELECT * FROM customer;

UPDATE customer_test
SET email = (SELECT email FROM customer WHERE customer_id = 1)
WHERE customer_id = 2;


SET SQL_SAFE_UPDATES = 0;

-- Run the duplicate check on the copy (expected: 1 row, total = 2)
-- Result: 1 row returned( Total= 2), defect detected , check works 
SELECT email, COUNT(*) AS total
FROM customer_test
GROUP BY email
HAVING COUNT(*) > 1;

-- Negative test : missing email(expected: 1 row )  
-- Result: returned 1 row, first_name LINDA , last_name WILLIAMS 
UPDATE customer_test SET email = NULL WHERE customer_id = 3;

SELECT customer_id, first_name, last_name
FROM customer_test
WHERE email IS NULL;

-- Negative test : Injected orphan rental (customer_id = 9999) into rental_test
-- Result: 1 row returned (rental_id 1), defect detected, check works
DROP TABLE IF EXISTS rental_test;
CREATE TABLE rental_test AS SELECT * FROM rental;

UPDATE rental_test SET customer_id = 9999 WHERE rental_id = 1;

SELECT r.rental_id
FROM rental_test r
LEFT JOIN customer c ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Negative test : Returned before rented ( expected : 1 row ) 
-- Result : 1 row returned ( rental id = 2) , defect detected , check works 

UPDATE rental_test
SET return_date = DATE_SUB(rental_date, INTERVAL 1 DAY)
WHERE rental_id = 2;

SELECT rental_id, rental_date, return_date
FROM rental_test
WHERE return_date < rental_date;

DROP TABLE IF EXISTS customer_test;
DROP TABLE IF EXISTS rental_test;
SET SQL_SAFE_UPDATES = 1;