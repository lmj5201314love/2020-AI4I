/*
 第 4 天 - 导入结果校验
 项目：AI4I 2020 预测性维护
 
 用途：
 校验已经通过 MySQL Workbench 导入完成的 MySQL 数据表。
 连接 MySQL 后，建议在 VSCode 中运行本脚本，作为后续 SQL 分析前的复查步骤。
 
 预期数据库和数据表：
 - 数据库：predictive_maintenance2020
 - 数据表：ai4i2020
 
 来自 pandas 数据质量检查的参考结果：
 - 总行数：10000
 - Machine_failure：0 = 9661，1 = 339
 - Type：L = 6000，M = 2997，H = 1003
 - 各故障原因计数：TWF = 46，HDF = 115，PWF = 95，OSF = 98，RNF = 19
 */
USE predictive_maintenance2020;
-- 1. 确认目标表存在。
SHOW TABLES LIKE 'ai4i2020';
-- 2. 确认表结构和字段名。
DESCRIBE ai4i2020;
-- 3. 检查总行数。预期：10000。
SELECT COUNT(*) AS total_rows
FROM ai4i2020;
-- 4. 按 UDI 预览前 10 条设备运行记录。
SELECT *
FROM ai4i2020
ORDER BY '编号ID'
LIMIT 10;
-- 5. 检查产品类型分布。预期：L=6000，M=2997，H=1003。
SELECT Type,
    COUNT(*) AS total_cnt,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*)
            FROM ai4i2020
        ),
        2
    ) AS sample_pct
FROM ai4i2020
GROUP BY Type
ORDER BY total_cnt DESC;
-- 6. 检查总故障标签分布。预期：0=9661，1=339。
SELECT Machine_failure,
    COUNT(*) AS total_cnt,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*)
            FROM ai4i2020
        ),
        2
    ) AS sample_pct
FROM ai4i2020
GROUP BY Machine_failure
ORDER BY Machine_failure;
-- 7. 检查各类具体故障原因标记的计数。
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
-- 8. 回看第 3 天 EDA：按产品类型计算故障率。
-- 由于不同 Type 的样本量不均衡，比较各类型内部故障率比只比较原始故障数量更有意义。
SELECT Type,
    COUNT(*) AS total_cnt,
    SUM(Machine_failure) AS fail_cnt,
    ROUND(AVG(Machine_failure) * 100, 2) AS fail_rate_pct
FROM ai4i2020
GROUP BY Type
ORDER BY fail_rate_pct DESC;
-- 9. 回看第 3 天 EDA：按刀具磨损分箱计算故障率。
-- 分箱边界沿用笔记本中第一轮 EDA 的设置，便于与图表分析结果对齐。
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
GROUP BY wear_group
ORDER BY CASE
        wear_group
        WHEN '0-50' THEN 1
        WHEN '51-100' THEN 2
        WHEN '101-150' THEN 3
        WHEN '151-200' THEN 4
        WHEN '201-300' THEN 5
        ELSE 6
    END;
-- 10. 对总故障标签与具体故障原因标记做轻量一致性检查。
SELECT SUM(
        CASE
            WHEN (TWF + HDF + PWF + OSF + RNF) > 0 THEN 1
            ELSE 0
        END
    ) AS rows_with_any_failure_type,
    SUM(
        CASE
            WHEN (TWF + HDF + PWF + OSF + RNF) > 1 THEN 1
            ELSE 0
        END
    ) AS rows_with_multiple_failure_types,
    SUM(
        CASE
            WHEN Machine_failure = 1
            AND (TWF + HDF + PWF + OSF + RNF) = 0 THEN 1
            ELSE 0
        END
    ) AS machine_failure_1_without_type,
    SUM(
        CASE
            WHEN Machine_failure = 0
            AND (TWF + HDF + PWF + OSF + RNF) > 0 THEN 1
            ELSE 0
        END
    ) AS machine_failure_0_with_type
FROM ai4i2020;