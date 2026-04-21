/*
Day 4 - MySQL schema asset
Project: AI4I 2020 Predictive Maintenance

Purpose:
1. Keep the database and table definition under version control.
2. Record how to extract the actual table DDL from MySQL after a successful import.
3. Provide a reproducible reference schema for the imported table.

Important:
- The current data has already been imported through MySQL Workbench.
- Do not use this file to re-import the CSV manually.
- The real source of truth should be the output of SHOW CREATE TABLE from the current MySQL table.
*/

CREATE DATABASE IF NOT EXISTS predictive_maintenance2020
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE predictive_maintenance2020;

/*
Run this after confirming the imported table exists.
Copy the returned CREATE TABLE statement below the "Actual DDL from MySQL" section.
*/
SHOW CREATE TABLE predictive_maintenance2020.ai4i2020;

/*
Actual DDL from MySQL
Paste the exact SHOW CREATE TABLE output here after running the statement above.
Keeping the real DDL here makes the project reproducible and auditable.
*/

/*
Reference DDL based on the current imported table observed in MySQL Workbench.
If SHOW CREATE TABLE returns a different type, length, charset, or index definition,
prefer the SHOW CREATE TABLE result.
*/
CREATE TABLE IF NOT EXISTS predictive_maintenance2020.ai4i2020 (
    UDI INT NOT NULL,
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
    PRIMARY KEY (UDI),
    INDEX idx_type (Type),
    INDEX idx_machine_failure (Machine_failure),
    INDEX idx_tool_wear (Tool_wear)
);
