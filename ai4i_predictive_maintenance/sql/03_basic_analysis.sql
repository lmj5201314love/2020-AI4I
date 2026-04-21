/*
Day 4 - Basic SQL analysis
Project: AI4I 2020 Predictive Maintenance

Purpose:
Keep reusable SQL analysis queries in the project after the MySQL import has been validated.
This file is for analysis, not for table creation or CSV import.
*/

USE predictive_maintenance2020;

-- Overall failure rate.
SELECT
    COUNT(*) AS total_cnt,
    SUM(Machine_failure) AS fail_cnt,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020;

-- Product type sample size and failure rate.
SELECT
    Type,
    COUNT(*) AS total_cnt,
    SUM(Machine_failure) AS fail_cnt,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020
GROUP BY Type
ORDER BY fail_rate_pct DESC;

-- Numeric feature means by failure label.
SELECT
    Machine_failure,
    ROUND(AVG(Air_temperature), 3) AS avg_air_temperature,
    ROUND(AVG(Process_temperature), 3) AS avg_process_temperature,
    ROUND(AVG(Rotational_speed), 3) AS avg_rotational_speed,
    ROUND(AVG(Torque), 3) AS avg_torque,
    ROUND(AVG(Tool_wear), 3) AS avg_tool_wear
FROM ai4i2020
GROUP BY Machine_failure
ORDER BY Machine_failure;

-- Failure rate by tool wear group.
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

-- Specific failure type counts.
SELECT 'TWF' AS failure_type, SUM(TWF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'HDF' AS failure_type, SUM(HDF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'PWF' AS failure_type, SUM(PWF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'OSF' AS failure_type, SUM(OSF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'RNF' AS failure_type, SUM(RNF) AS fail_cnt FROM ai4i2020;
