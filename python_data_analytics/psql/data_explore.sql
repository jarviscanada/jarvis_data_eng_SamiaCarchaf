-- Create indexes for faster filtering
CREATE INDEX IF NOT EXISTS idx_company ON complaints(company);
CREATE INDEX IF NOT EXISTS idx_date ON complaints(date_received);

-- Create reusable CTE for bureau complaints
WITH bureau_complaints AS (
    SELECT *
    FROM complaints
    WHERE company IN (
                      'EQUIFAX, INC.',
                      'Experian Information Solutions Inc.',
                      'TRANSUNION INTERMEDIATE HOLDINGS, INC.'
        )
)

-- Show table schema
         \d+ complaints;

-- Show first 10 rows
SELECT * FROM complaints LIMIT 10;

-- Q1: Check # of records
SELECT COUNT(*) FROM complaints;

-- Q2: Number of unique companies
SELECT COUNT(DISTINCT company) FROM complaints;

-- Q3: Date range
SELECT MIN(date_received), MAX(date_received) FROM complaints;

-- Q4: Number of unique products
SELECT COUNT(DISTINCT product) FROM complaints;

-- Q5: Top 10 companies by complaint volume
SELECT company, COUNT(*) AS complaint_count
FROM complaints
GROUP BY company
ORDER BY complaint_count DESC
    LIMIT 10;

-- Q6: Most common issues
SELECT issue, COUNT(*) AS count
FROM complaints
GROUP BY issue
ORDER BY count DESC
    LIMIT 10;

-- Q7: Complaints by year
SELECT
    SUBSTRING(date_received, 7, 4)::INT AS year,
    COUNT(*) AS count
FROM complaints
GROUP BY year
ORDER BY year;
-----
-- Business Q1: Which bureau has the most complaints?
SELECT company, COUNT(*) AS complaint_count
FROM bureau_complaints
GROUP BY company
ORDER BY complaint_count DESC;

-- Business Q2: Most common issues for the 3 bureaus
SELECT issue, COUNT(*) AS count
FROM bureau_complaints
GROUP BY issue
ORDER BY count DESC
    LIMIT 10;

-- Business Q3: Resolution quality per bureau
SELECT
    company,
    company_response,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY company), 2) AS percentage
FROM bureau_complaints
GROUP BY company, company_response
ORDER BY company, count DESC;

-- Business Q4: Timely response rate per bureau
SELECT
    company,
    timely_response,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY company), 2) AS percentage
FROM bureau_complaints
GROUP BY company, timely_response
ORDER BY company;

-- Business Q5: Complaints by year per bureau
SELECT
    company,
    SUBSTRING(date_received, 7, 4)::INT AS year,
    COUNT(*) AS count
FROM bureau_complaints
GROUP BY company, year
ORDER BY year, company;