# NHS A&E Performance Analytics Dashboard

![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![NHS England](https://img.shields.io/badge/Data-NHS_England-005EB8?style=for-the-badge)

## 📊 Project Overview

An end-to-end data analytics portfolio project analysing **15 years of NHS A&E performance data** (August 2010 – February 2026) using real publicly available NHS England statistics.

The project covers the full analytics workflow — from raw data cleaning and SQL database design through to an interactive Power BI dashboard — demonstrating the skills required for a Business Analyst or Data Analyst role in an NHS or healthcare environment.

---

## 🎯 Key Insights

- 📉 **NHS A&E performance has been in decline since 2015** — the 95% four-hour target has not been consistently met since 2013
- 🦠 **COVID-19 caused a 26.8% drop in A&E attendances in 2020** — from a monthly average of 2.14M in 2019 to 1.56M in 2020
- 🚨 **12-hour waits have exploded post-2020** — from near zero before the pandemic to tens of thousands per month by 2022
- 🏥 **Major A&E departments are the biggest pressure point** — Type 1 performance has dropped from 98% in 2011 to around 60% by 2026
- 📈 **Emergency admissions continue to grow** — with nearly 1 in 5 A&E attendances (18.4%) resulting in an emergency admission

---

## 🖥️ Dashboard Pages

### Page 1 — Overview
High-level summary of NHS A&E performance across the full 2010–2026 period including total attendances, 4-hour performance trend and the 95% NHS standard target line.

![Overview](screenshots/page1_overview.jpg)

---

### Page 2 — Performance Deep Dive
Detailed breakdown of 4-hour and 12-hour breach trends, attendance volumes by department type (Major A&E, Single Specialty, Minor Injuries Unit) and performance by department type.

![Performance Deep Dive](screenshots/page2_performance.jpg)

---

### Page 3 — COVID Impact
Focused analysis of the 2019–2021 period showing the dramatic attendance drop during lockdown, performance changes during COVID and the sharp rise in 12-hour waits through 2021.

![COVID Impact](screenshots/page3_covid.jpg)

---

### Page 4 — Emergency Admissions
Analysis of emergency admission trends, admissions via A&E vs other routes and the admission rate as a percentage of total attendances over time.

![Emergency Admissions](screenshots/page4_admissions.jpg)

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Python (pandas)** | Data cleaning and CSV preparation |
| **SQL Server (SSMS)** | Database design, data import and analysis queries |
| **Power BI Desktop** | Interactive dashboard and data visualisation |
| **T-SQL** | Data transformation, date conversion and analytical queries |
| **DAX** | Calculated measures and conditional formatting in Power BI |

---

## 📁 Project Structure

```
NHS-AE-Performance-Analytics/
│
├── README.md
│
├── sql/
│   └── nhs_ae_project_queries.sql      # Full SQL script — setup, import and analysis
│
├── data/
│   ├── ae_monthly_clean.csv            # Monthly A&E data (187 rows, Aug 2010–Feb 2026)
│   ├── ae_quarterly_clean.csv          # Quarterly A&E data (22 rows, 2004–2026)
│   └── ae_performance_clean.csv        # Monthly 4hr performance % (184 rows)
│
├── dashboard/
│   └── NHS_AE_Performance_Analytics_RubenMartinLopez.pbix
│
├── docs/
│   └── NHS_AE_Project_Brief_Updated.docx
│
└── screenshots/
    ├── page1_overview.jpg
    ├── page2_performance.jpg
    ├── page3_covid.jpg
    └── page4_admissions.jpg
```

---

## 🗄️ Database Structure

Three tables were created in SQL Server (`nhs_ae_project` database):

| Table | Rows | Description |
|-------|------|-------------|
| `ae_monthly` | 187 | Monthly attendances, admissions and breach data |
| `ae_quarterly` | 22 | Quarterly attendance and performance by department type |
| `ae_performance` | 184 | Monthly 4-hour performance % by Type 1, 2 and 3 |

### Key SQL Techniques Used
- `BULK INSERT` for CSV data loading
- `ALTER TABLE` and `CAST` for date column conversion
- `DATENAME()`, `YEAR()`, `MONTH()` for date-based analysis
- `GROUP BY` with `SUM()` and `ROUND()` for aggregations
- `sp_rename` for column renaming
- `CREATE VIEW` for unpivoting department type data
- `UNION ALL` for combining department-level data

---

## 📐 DAX Measures

Key measures created in Power BI:

```dax
-- 4-hour performance rate
Pct Within 4hrs =
ROUND(
  DIVIDE(
    SUM(ae_monthly[total_attendances]) - SUM(ae_monthly[patients_over_4hrs]),
    SUM(ae_monthly[total_attendances])
  ) * 100,
1)

-- COVID attendance drop
COVID Attendance Drop % =
ROUND(
  DIVIDE(
    [Avg Attendance 2020] - [Avg Attendance 2019],
    [Avg Attendance 2019]
  ),
3)

-- Conditional colour (red if below 95% target)
Performance Colour =
IF([Pct Within 4hrs] >= 95, "#1D6A3A", "#DA291C")

-- Admission rate
Admissions to Attendances Ratio =
ROUND(
  100 * DIVIDE(
    SUM(ae_monthly[total_emergency_admissions_via_ae]),
    SUM(ae_monthly[total_attendances])
  ),
1)
```

---

## 📂 Data Source

**NHS England — A&E Attendances and Emergency Admissions Statistics**

- Source: [NHS England Statistics](https://www.england.nhs.uk/statistics/statistical-work-areas/ae-waiting-times-and-activity/)
- Data is publicly available under the [Open Government Licence](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)
- Two datasets used:
  - Monthly A&E Time Series (August 2010 – February 2026)
  - Quarterly Annual Time Series (April 2004 – present)

---

## 👤 About

**Ruben Martin Lopez**
Business Analyst / Data Analyst — London, UK

7+ years experience across healthcare (NHS histology, HSL), commercial BI (Alexander Maclean) and business analysis (Reynolds & Parker Solutions).

**Key Skills:** SQL · Power BI · Tableau · Python · Excel · Agile

**Certifications:**
- BCS Foundation Certificate in Business Analysis v4.1 (March 2026)
- Data Analyst Associate
- MSc Molecular & Cellular Biology

🔗 [LinkedIn](https://www.linkedin.com/in/ruben-martin-lopez-599533240) | 💼 [Upwork](https://www.upwork.com/freelancers/~01bcd439bd20e08328?mp_source=share)

---

*This project was built as a personal portfolio piece to demonstrate end-to-end data analytics skills using real NHS public data.*
