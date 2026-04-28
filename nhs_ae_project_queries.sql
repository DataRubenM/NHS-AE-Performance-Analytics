-- ============================================================
-- NHS A&E PERFORMANCE ANALYTICS PROJECT
-- Author: Ruben Martin Lopez
-- Database: nhs_ae_project
-- Server: SOLMIR\SQLEXPRESS01
-- Description: Full SQL script for NHS A&E analytics project
--              covering database setup, data import, date 
--              conversion and analysis queries.
-- ============================================================


-- ============================================================
-- SECTION 1: DATABASE SETUP
-- ============================================================

-- Create the database
CREATE DATABASE nhs_ae_project;
GO

USE nhs_ae_project;
GO


-- ============================================================
-- SECTION 2: CREATE TABLES
-- ============================================================

-- Monthly A&E attendance and admissions data (Aug 2010 - Feb 2026)
CREATE TABLE ae_monthly (
  period                            VARCHAR(10),
  type1_attendances                 INT,
  type2_attendances                 INT,
  type3_attendances                 INT,
  total_attendances                 INT,
  emergency_admissions_type1        INT,
  emergency_admissions_type2        INT,
  emergency_admissions_type3_4      INT,
  total_emergency_admissions_via_ae INT,
  other_emergency_admissions        INT,
  total_emergency_admissions        INT,
  patients_over_4hrs                INT,
  patients_over_12hrs               DECIMAL(10,1)
);
GO

-- Quarterly A&E attendance and performance data (Apr 2004 - present)
CREATE TABLE ae_quarterly (
  year              VARCHAR(10),
  quarter           VARCHAR(30),
  type1_attendances INT,
  type2_attendances INT,
  type3_attendances INT,
  total_attendances INT,
  type1_under_4hrs  INT,
  type2_under_4hrs  INT,
  type3_under_4hrs  INT,
  total_under_4hrs  INT,
  type1_over_4hrs   INT,
  type2_over_4hrs   INT,
  type3_over_4hrs   INT
);
GO

-- Monthly 4-hour performance percentages by department type
CREATE TABLE ae_performance (
  period                VARCHAR(10),
  type1_under_4hrs      INT,
  type2_under_4hrs      INT,
  type3_under_4hrs      INT,
  total_under_4hrs      INT,
  type1_over_4hrs       INT,
  type2_over_4hrs       INT,
  type3_over_4hrs       INT,
  total_over_4hrs       INT,
  pct_within_4hrs_all   DECIMAL(5,1),
  pct_within_4hrs_type1 DECIMAL(5,1),
  pct_within_4hrs_type2 DECIMAL(5,1),
  pct_within_4hrs_type3 DECIMAL(5,1)
);
GO


-- ============================================================
-- SECTION 3: IMPORT DATA (BULK INSERT)
-- ============================================================

-- Import monthly data
BULK INSERT ae_monthly
FROM 'C:\Users\Admin\OneDrive\Desktop\DATA SETS\Cleaned Data\files\ae_monthly_clean.csv'
WITH (
    FORMAT       = 'CSV',
    FIRSTROW     = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    TABLOCK
);
GO

-- Import quarterly data
BULK INSERT ae_quarterly
FROM 'C:\Users\Admin\OneDrive\Desktop\DATA SETS\Cleaned Data\files\ae_quarterly_clean.csv'
WITH (
    FORMAT       = 'CSV',
    FIRSTROW     = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    TABLOCK
);
GO

-- Import performance data
BULK INSERT ae_performance
FROM 'C:\Users\Admin\OneDrive\Desktop\DATA SETS\Cleaned Data\files\ae_performance_clean.csv'
WITH (
    FORMAT       = 'CSV',
    FIRSTROW     = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    TABLOCK
);
GO


-- ============================================================
-- SECTION 4: VERIFY ROW COUNTS
-- ============================================================

-- Expected: ae_monthly = 187, ae_quarterly = 22, ae_performance = 184
SELECT 'ae_monthly'    AS table_name, COUNT(*) AS rows FROM ae_monthly
UNION ALL
SELECT 'ae_quarterly',               COUNT(*) FROM ae_quarterly
UNION ALL
SELECT 'ae_performance',             COUNT(*) FROM ae_performance;


-- ============================================================
-- SECTION 5: DATE CONVERSION
-- ============================================================

-- Add proper DATE column to ae_monthly (converts 'Aug-10' to 2010-08-01)
ALTER TABLE ae_monthly
ADD period_date DATE;
GO

UPDATE ae_monthly
SET period_date = CAST('01-' + period AS DATE);
GO

-- Add proper DATE column to ae_performance
ALTER TABLE ae_performance
ADD period_date DATE;
GO

UPDATE ae_performance
SET period_date = CAST('01-' + period AS DATE);
GO

-- Verify date conversion
SELECT TOP 5 period, period_date FROM ae_monthly;
SELECT TOP 5 period, period_date FROM ae_performance;


-- ============================================================
-- SECTION 6: ANALYSIS QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- Query 1: Quick data sense check
-- View top 5 rows from all three tables
-- ------------------------------------------------------------
SELECT TOP 5 * FROM ae_monthly;
SELECT TOP 5 * FROM ae_performance;
SELECT TOP 5 * FROM ae_quarterly;


-- ------------------------------------------------------------
-- Query 2: Monthly 4-hour performance rate
-- Shows % of patients seen within 4 hours each month
-- ------------------------------------------------------------
SELECT 
  period_date,
  total_attendances,
  patients_over_4hrs,
  ROUND(100.0 * (total_attendances - patients_over_4hrs) / total_attendances, 1) AS pct_seen_within_4hrs
FROM ae_monthly
ORDER BY period_date;


-- ------------------------------------------------------------
-- Query 3: Year on year comparison
-- Monthly breakdown by year to compare seasonal trends
-- ------------------------------------------------------------
SELECT 
  DATENAME(MONTH, period_date) AS month,
  YEAR(period_date)            AS year,
  total_attendances,
  patients_over_4hrs,
  ROUND(100.0 * (total_attendances - patients_over_4hrs) / total_attendances, 1) AS pct_within_4hrs
FROM ae_monthly
ORDER BY year, MONTH(period_date);


-- ------------------------------------------------------------
-- Query 4: Annual totals
-- Total attendances and breaches summarised by year
-- ------------------------------------------------------------
SELECT 
  YEAR(period_date)                                                              AS year,
  SUM(total_attendances)                                                         AS total_attendances,
  SUM(patients_over_4hrs)                                                        AS total_over_4hrs,
  ROUND(100.0 * SUM(patients_over_4hrs) / SUM(total_attendances), 1)            AS pct_breaching
FROM ae_monthly
GROUP BY YEAR(period_date)
ORDER BY year;


-- ------------------------------------------------------------
-- Query 5: COVID impact 2019 to 2021
-- Shows attendance drop during March-May 2020 lockdown
-- ------------------------------------------------------------
SELECT 
  YEAR(period_date)            AS year,
  DATENAME(MONTH, period_date) AS month,
  total_attendances,
  patients_over_4hrs,
  ROUND(100.0 * (total_attendances - patients_over_4hrs) / total_attendances, 1) AS pct_within_4hrs
FROM ae_monthly
WHERE YEAR(period_date) BETWEEN 2019 AND 2021
ORDER BY period_date;


-- ------------------------------------------------------------
-- Query 6: 10 worst months for 4-hour performance
-- Identifies the lowest performing months on record
-- ------------------------------------------------------------
SELECT TOP 10
  period_date,
  pct_within_4hrs_all,
  pct_within_4hrs_type1
FROM ae_performance
ORDER BY pct_within_4hrs_all ASC;


-- ------------------------------------------------------------
-- Query 7: 10 best months for 4-hour performance
-- Identifies the highest performing months on record
-- ------------------------------------------------------------
SELECT TOP 10
  period_date,
  pct_within_4hrs_all,
  pct_within_4hrs_type1
FROM ae_performance
ORDER BY pct_within_4hrs_all DESC;


-- ------------------------------------------------------------
-- Query 8: 12-hour waits trend
-- Tracks patients waiting over 12 hours as % of 4hr breaches
-- ------------------------------------------------------------
SELECT 
  period_date,
  patients_over_4hrs,
  patients_over_12hrs,
  ROUND(100.0 * patients_over_12hrs / patients_over_4hrs, 1) AS pct_12hr_of_4hr_breaches
FROM ae_monthly
WHERE patients_over_12hrs IS NOT NULL
ORDER BY period_date;


-- ------------------------------------------------------------
-- Query 9: Performance by department type
-- Compares Type 1 (major A&E) vs Type 2 vs Type 3 performance
-- ------------------------------------------------------------
SELECT 
  period_date,
  pct_within_4hrs_all,
  pct_within_4hrs_type1,
  pct_within_4hrs_type2,
  pct_within_4hrs_type3
FROM ae_performance
ORDER BY period_date;


-- ------------------------------------------------------------
-- Query 10: Emergency admissions trend
-- Tracks total emergency admissions over time
-- ------------------------------------------------------------
SELECT 
  period_date,
  total_emergency_admissions,
  total_emergency_admissions_via_ae,
  other_emergency_admissions,
  ROUND(100.0 * total_emergency_admissions_via_ae / total_emergency_admissions, 1) AS pct_via_ae
FROM ae_monthly
ORDER BY period_date;
