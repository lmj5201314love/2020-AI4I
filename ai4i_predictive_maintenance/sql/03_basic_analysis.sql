/*
Day 5 - SQL 业务分析
项目：AI4I 2020 预测性维护

用途：
本文件用于沉淀固定口径的 SQL 业务分析查询，让 MySQL 不只是保存数据，
而是真正参与设备故障分析。Day 5 的重点是用 SQL 复现并扩展
Day 2 / Day 3 中已经观察到的业务现象。

当前数据对象：
- 数据库：predictive_maintenance2020
- 数据表：ai4i2020

说明：
- 今天不重新导入 CSV。
- 今天不重构表字段命名。
- 当前查询优先使用已经存在的真实字段名。
- 如果后续要做字段命名标准化，可以单独安排为数据工程优化任务。
*/

USE predictive_maintenance2020;

-- 1. 整体故障率：确认 SQL 侧与 pandas 侧口径一致，预期故障率约为 3.39%。
SELECT
    COUNT(*) AS total_cnt,
    SUM(Machine_failure) AS fail_cnt,
    ROUND(SUM(Machine_failure) / COUNT(*), 4) AS fail_rate,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020;

-- 2. 各产品类型故障率：比较 Type 内部故障风险，而不是只比较故障数量。
SELECT
    Type,
    COUNT(*) AS total_cnt,
    SUM(Machine_failure) AS fail_cnt,
    ROUND(SUM(Machine_failure) / COUNT(*), 4) AS fail_rate,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020
GROUP BY Type
ORDER BY fail_rate DESC;

-- 3. 各故障类型数量：观察 TWF/HDF/PWF/OSF/RNF 这几类具体故障原因的稀疏程度。
SELECT 'TWF' AS failure_type, SUM(TWF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'HDF' AS failure_type, SUM(HDF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'PWF' AS failure_type, SUM(PWF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'OSF' AS failure_type, SUM(OSF) AS fail_cnt FROM ai4i2020
UNION ALL
SELECT 'RNF' AS failure_type, SUM(RNF) AS fail_cnt FROM ai4i2020
ORDER BY fail_cnt DESC;

-- 4. 不同刀具磨损区间故障率：呼应 Day 3 中“高磨损组故障率明显更高”的发现。
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
    ROUND(SUM(Machine_failure) / COUNT(*), 4) AS fail_rate,
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

-- 5. 不同扭矩区间故障率：观察高扭矩是否对应更高故障风险，呼应 Day 3 中故障组平均扭矩更高的现象。
SELECT
    CASE
        WHEN Torque < 30 THEN '<30'
        WHEN Torque >= 30 AND Torque < 40 THEN '30-40'
        WHEN Torque >= 40 AND Torque < 50 THEN '40-50'
        WHEN Torque >= 50 AND Torque < 60 THEN '50-60'
        WHEN Torque >= 60 THEN '>=60'
        ELSE 'unknown'
    END AS torque_group,
    COUNT(*) AS total_cnt,
    SUM(Machine_failure) AS fail_cnt,
    ROUND(SUM(Machine_failure) / COUNT(*), 4) AS fail_rate,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020
GROUP BY torque_group
ORDER BY
    CASE torque_group
        WHEN '<30' THEN 1
        WHEN '30-40' THEN 2
        WHEN '40-50' THEN 3
        WHEN '50-60' THEN 4
        WHEN '>=60' THEN 5
        ELSE 6
    END;

-- 6. 不同转速区间故障率：观察低转速区间是否有更高故障风险，呼应 Day 3 中故障组平均转速更低的现象。
SELECT
    CASE
        WHEN Rotational_speed < 1300 THEN '<1300'
        WHEN Rotational_speed >= 1300 AND Rotational_speed < 1500 THEN '1300-1500'
        WHEN Rotational_speed >= 1500 AND Rotational_speed < 1700 THEN '1500-1700'
        WHEN Rotational_speed >= 1700 AND Rotational_speed < 1900 THEN '1700-1900'
        WHEN Rotational_speed >= 1900 THEN '>=1900'
        ELSE 'unknown'
    END AS speed_group,
    COUNT(*) AS total_cnt,
    SUM(Machine_failure) AS fail_cnt,
    ROUND(SUM(Machine_failure) / COUNT(*), 4) AS fail_rate,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020
GROUP BY speed_group
ORDER BY
    CASE speed_group
        WHEN '<1300' THEN 1
        WHEN '1300-1500' THEN 2
        WHEN '1500-1700' THEN 3
        WHEN '1700-1900' THEN 4
        WHEN '>=1900' THEN 5
        ELSE 6
    END;

-- 7. 故障样本与正常样本的均值对比：用 SQL 固化 Day 3 的均值对比口径。
SELECT
    Machine_failure,
    COUNT(*) AS total_cnt,
    ROUND(AVG(Air_temperature), 3) AS avg_air_temperature,
    ROUND(AVG(Process_temperature), 3) AS avg_process_temperature,
    ROUND(AVG(Rotational_speed), 3) AS avg_rotational_speed,
    ROUND(AVG(Torque), 3) AS avg_torque,
    ROUND(AVG(Tool_wear), 3) AS avg_tool_wear
FROM ai4i2020
GROUP BY Machine_failure
ORDER BY Machine_failure;

-- 8. 高风险组合分析：同时按产品类型和刀具磨损区间看故障率，寻找更具体的风险组合。
SELECT
    Type,
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
    ROUND(SUM(Machine_failure) / COUNT(*), 4) AS fail_rate,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020
GROUP BY Type, wear_group
HAVING total_cnt >= 30
ORDER BY fail_rate DESC, total_cnt DESC;

-- 9. 高负载状态组合分析：按扭矩区间和转速区间交叉观察故障率，用于识别“高扭矩 + 低转速”等运行状态风险。
SELECT
    CASE
        WHEN Torque < 30 THEN '<30'
        WHEN Torque >= 30 AND Torque < 40 THEN '30-40'
        WHEN Torque >= 40 AND Torque < 50 THEN '40-50'
        WHEN Torque >= 50 AND Torque < 60 THEN '50-60'
        WHEN Torque >= 60 THEN '>=60'
        ELSE 'unknown'
    END AS torque_group,
    CASE
        WHEN Rotational_speed < 1300 THEN '<1300'
        WHEN Rotational_speed >= 1300 AND Rotational_speed < 1500 THEN '1300-1500'
        WHEN Rotational_speed >= 1500 AND Rotational_speed < 1700 THEN '1500-1700'
        WHEN Rotational_speed >= 1700 AND Rotational_speed < 1900 THEN '1700-1900'
        WHEN Rotational_speed >= 1900 THEN '>=1900'
        ELSE 'unknown'
    END AS speed_group,
    COUNT(*) AS total_cnt,
    SUM(Machine_failure) AS fail_cnt,
    ROUND(SUM(Machine_failure) / COUNT(*), 4) AS fail_rate,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020
GROUP BY torque_group, speed_group
HAVING total_cnt >= 30
ORDER BY fail_rate DESC, total_cnt DESC;

-- 10. 具体故障原因与总故障标签的一致性检查：作为 SQL 侧的数据解释边界提醒。
SELECT
    SUM(CASE WHEN (TWF + HDF + PWF + OSF + RNF) > 0 THEN 1 ELSE 0 END) AS rows_with_any_failure_type,
    SUM(CASE WHEN (TWF + HDF + PWF + OSF + RNF) > 1 THEN 1 ELSE 0 END) AS rows_with_multiple_failure_types,
    SUM(CASE WHEN Machine_failure = 1 AND (TWF + HDF + PWF + OSF + RNF) = 0 THEN 1 ELSE 0 END) AS machine_failure_1_without_type,
    SUM(CASE WHEN Machine_failure = 0 AND (TWF + HDF + PWF + OSF + RNF) > 0 THEN 1 ELSE 0 END) AS machine_failure_0_with_type
FROM ai4i2020;
