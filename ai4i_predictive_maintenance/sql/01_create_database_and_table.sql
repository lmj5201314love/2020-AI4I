/*
 第 4 天 - MySQL 表结构资产
 项目：AI4I 2020 预测性维护
 
 用途：
 1. 将数据库和数据表结构纳入项目版本管理。
 2. 记录在 Workbench 成功导入后，如何从 MySQL 中提取真实建表语句。
 3. 为已导入的 `ai4i2020` 表保留一份可复现、可审计的参考结构。
 
 重要说明：
 - 当前数据已经通过 MySQL Workbench 导入完成。
 - 本文件用于保存结构和复查流程，不用于手动重新导入 CSV。
 - 最可信的表结构应以当前 MySQL 表执行 SHOW CREATE TABLE 后返回的结果为准。
 */
CREATE DATABASE IF NOT EXISTS predictive_maintenance2020 DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_0900_ai_ci;
USE predictive_maintenance2020;
/*
 确认导入表已经存在后，再运行下面这条语句。
 将返回的 CREATE TABLE 语句复制到“来自 MySQL 的实际 DDL”小节下方。
 */
SHOW CREATE TABLE predictive_maintenance2020.ai4i2020;
/*
 来自 MySQL 的实际 DDL
 运行上面的语句后，将 SHOW CREATE TABLE 的原始输出完整粘贴到这里。
 */
CREATE TABLE `ai4i2020` (
  `编号ID` int DEFAULT NULL,
  `Product_ID` varchar(20) DEFAULT NULL,
  `Type` varchar(5) DEFAULT NULL,
  `Air_temperature` double DEFAULT NULL,
  `Process_temperature` double DEFAULT NULL,
  `Rotational_speed` int DEFAULT NULL,
  `Torque` double DEFAULT NULL,
  `Tool_wear` int DEFAULT NULL,
  `Machine_failure` int DEFAULT NULL,
  `TWF` int DEFAULT NULL,
  `HDF` int DEFAULT NULL,
  `PWF` int DEFAULT NULL,
  `OSF` int DEFAULT NULL,
  `RNF` int DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
/*
 把真实 DDL 保存在项目中，便于后续复现导入结果并追踪表结构变化。
 */
/*
 参考 DDL：根据当前在 MySQL Workbench 中观察到的已导入表整理。
 如果 SHOW CREATE TABLE 返回的字段类型、长度、字符集或索引定义与这里不同，
 应优先采用 SHOW CREATE TABLE 的结果。
 */
CREATE TABLE IF NOT EXISTS predictive_maintenance2020.ai4i2020 (
  `编号ID` INT NOT NULL,
  Product_ID VARCHAR(20),
  Type CHAR(1),
  Air_temperature DOUBLE,
  Process_temperature DOUBLE,
  Rotational_speed INT,
  Torque DOUBLE,
  Tool_wear INT,
  Machine_failure TINYINT,
  TWF TINYINT,
  HDF TINYINT,
  PWF TINYINT,
  OSF TINYINT,
  RNF TINYINT,
  PRIMARY KEY (`编号ID`),
  INDEX idx_type (Type),
  INDEX idx_machine_failure (Machine_failure),
  INDEX idx_tool_wear (Tool_wear)
);
