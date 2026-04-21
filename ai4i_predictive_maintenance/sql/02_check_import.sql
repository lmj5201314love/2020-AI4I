/*
Day 4 - Import validation checks
Project: AI4I 2020 Predictive Maintenance

Purpose:
Validate the MySQL table that has already been imported through MySQL Workbench.
This script should be run from VSCode after connecting to MySQL.

Expected database and table:
- schema: predictive_maintenance2020
- table: ai4i2020

Expected reference results from pandas checks:
- total rows: 10000
- Machine_failure: 0 = 9661, 1 = 339
- Type: L = 6000, M = 2997, H = 1003
- failure type counts: TWF = 46, HDF = 115, PWF = 95, OSF = 98, RNF = 19
*/

USE predictive_maintenance2020;

-- 1. Confirm the table exists.
SHOW TABLES LIKE 'ai4i2020';

-- 2. Confirm the table structure and column names.
DESCRIBE ai4i2020;

-- 3. Check total row count. Expected: 10000.
SELECT
    COUNT(*) AS total_rows
FROM ai4i2020;

-- 4. Preview the first 10 rows.
SELECT *
FROM ai4i2020
ORDER BY UDI
LIMIT 10;

-- 5. Check product type distribution. Expected: L=6000, M=2997, H=1003.
SELECT
    Type,
    COUNT(*) AS total_cnt,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ai4i2020), 2) AS sample_pct
FROM ai4i2020
GROUP BY Type
ORDER BY total_cnt DESC;

-- 6. Check target label distribution. Expected: 0=9661, 1=339.
SELECT
    Machine_failure,
    COUNT(*) AS total_cnt,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ai4i2020), 2) AS sample_pct
FROM ai4i2020
GROUP BY Machine_failure
ORDER BY Machine_failure;

-- 7. Check each specific failure type count.
SELECT 'TWF' AS failure_type, SUM(TWF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'HDF' AS failure_type, SUM(HDF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'PWF' AS failure_type, SUM(PWF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'OSF' AS failure_type, SUM(OSF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'RNF' AS failure_type, SUM(RNF) AS fail_cnt FROM ai4i2020;

-- 8. Day 3 echo: failure rate by product type.
-- This is more meaningful than comparing raw failure counts because Type sample sizes are imbalanced.
SELECT
    Type,
    COUNT(*) AS total_cnt,
    SUM(Machine_failure) AS fail_cnt,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020
GROUP BY Type
ORDER BY fail_rate_pct DESC;

-- 9. Day 3 echo: failure rate by tool wear group.
-- The bins mirror the first-round EDA in the notebook.
SELECT
    CASE
        WHEN Tool_wear BETWEEN 0 AND 50 THEN '0-50'
        WHEN Tool_wear BETWEEN 51 AND 100 THEN '51-100'
        WHEN Tool_wear BETWEEN 101 AND 150 THEN '101-150'
        WHEN Tool_wear BETWEEN 151 AND 200 THEN '151-200'
        WHEN Tool_wear BETWEEN 201 AND 300 THEN '201-300'
        ELSE 'other'
    END AS wear_group,
    COUNT(*) AS total_cnt,
    SUM(Machine_failure) AS fail_cnt,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020
GROUP BY wear_group
ORDER BY
    CASE wear_group
        WHEN '0-50' THEN 1
        WHEN '51-100' THEN 2
        WHEN '101-150' THEN 3
        WHEN '151-200' THEN 4
        WHEN '201-300' THEN 5
        ELSE 6
    END;

-- 10. Light label-consistency check between total failure label and specific failure flags.
SELECT
    SUM(CASE WHEN (TWF + HDF + PWF + OSF + RNF) > 0 THEN 1 ELSE 0 END) AS rows_with_any_failure_type,
    SUM(CASE WHEN (TWF + HDF + PWF + OSF + RNF) > 1 THEN 1 ELSE 0 END) AS rows_with_multiple_failure_types,
    SUM(CASE WHEN Machine_failure = 1 AND (TWF + HDF + PWF + OSF + RNF) = 0 THEN 1 ELSE 0 END) AS machine_failure_1_without_type,
    SUM(CASE WHEN Machine_failure = 0 AND (TWF + HDF + PWF + OSF + RNF) > 0 THEN 1 ELSE 0 END) AS machine_failure_0_with_type
FROM ai4i2020;
