/*
 第 4 天 - 可复用 SQL 视图
 项目：AI4I 2020 预测性维护
 
 用途：
 为后续反复使用的故障分析口径创建视图。
 请先运行 sql/02_check_import.sql，确认 Workbench 导入的表数据无误后，再执行本文件。
 */
USE predictive_maintenance2020;
CREATE OR REPLACE VIEW v_type_failure_rate AS
SELECT Type,
    COUNT(*) AS total_cnt,
    SUM(Machine_failure) AS fail_cnt,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020
GROUP BY Type;
CREATE OR REPLACE VIEW v_wear_group_failure_rate AS
SELECT CASE
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
CREATE OR REPLACE VIEW v_numeric_mean_by_failure AS
SELECT Machine_failure,
    ROUND(AVG(Air_temperature), 3) AS avg_air_temperature,
    ROUND(AVG(Process_temperature), 3) AS avg_process_temperature,
    ROUND(AVG(Rotational_speed), 3) AS avg_rotational_speed,
    ROUND(AVG(Torque), 3) AS avg_torque,
    ROUND(AVG(Tool_wear), 3) AS avg_tool_wear
FROM ai4i2020
GROUP BY Machine_failure;
CREATE OR REPLACE VIEW v_failure_type_counts AS
SELECT 'TWF' AS failure_type,
    SUM(TWF) AS fail_cnt
FROM ai4i2020
UNION ALL
SELECT 'HDF' AS failure_type,
    SUM(HDF) AS fail_cnt
FROM ai4i2020
UNION ALL
SELECT 'PWF' AS failure_type,
    SUM(PWF) AS fail_cnt
FROM ai4i2020
UNION ALL
SELECT 'OSF' AS failure_type,
    SUM(OSF) AS fail_cnt
FROM ai4i2020
UNION ALL
SELECT 'RNF' AS failure_type,
    SUM(RNF) AS fail_cnt
FROM ai4i2020;
USE predictive_maintenance2020;
SHOW FULL TABLES
FROM predictive_maintenance2020
WHERE TABLE_TYPE = 'VIEW';
SELECT *
FROM predictive_maintenance2020.v_type_failure_rate;