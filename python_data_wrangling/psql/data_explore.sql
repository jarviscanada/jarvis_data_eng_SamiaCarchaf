-- Show table schema
\d+ retail;

-- Show first 10 rows
SELECT * FROM retail LIMIT 10;

-- Q2: Check # of records
SELECT count(*) FROM retail;

-- Q3: number of clients (e.g. unique client ID)
SELECT count(DISTINCT customer_id) FROM retail;

-- Q4: invoice date range (e.g. max/min dates)
SELECT max(invoice_date), min(invoice_date) FROM retail;

-- Q5: number of SKU/merchants (e.g. unique stock code)
SELECT count(DISTINCT stock_code) FROM retail;

-- Q6: Calculate average invoice amount excluding invoices with a negative amount
SELECT avg(invoice_total)
FROM (
         SELECT invoice_no, sum(unit_price * quantity) AS invoice_total
         FROM retail
         GROUP BY invoice_no
         HAVING sum(unit_price * quantity) > 0
     ) AS invoice_totals;

-- Q7: Calculate total revenue (e.g. sum of unit_price * quantity)
SELECT sum(unit_price * quantity) FROM retail;

-- Q8: Calculate total revenue by YYYYMM
SELECT
    cast(extract(year FROM invoice_date) * 100 + extract(month FROM invoice_date) AS integer) AS yyyymm,
    sum(unit_price * quantity) AS sum
FROM retail
GROUP BY yyyymm
ORDER BY yyyymm;