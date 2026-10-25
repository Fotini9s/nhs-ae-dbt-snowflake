# My A&E data pipeline: a recap I can follow on my own

A study guide for the project in the `ae_project` folder. It explains what was built, why, and how to redo it without help.

---

## 1. The big picture

**Goal:** take NHS England's monthly A&E data, load it into a data warehouse, clean it, join it, test it, analyse it and show it in a dashboard.

Think of a kitchen:

| Stage | Kitchen idea | In this project |
|---|---|---|
| Raw | Ingredients as delivered | `RAW_AE_ACTIVITY`, `RAW_AE_PERFORMANCE` (tables in Snowflake, all text) |
| Staging | Ingredients washed and prepped | `stg_ae_activity`, `stg_ae_performance` (dbt views) |
| Mart | The finished dish | `mart_ae_monthly` (dbt view joining the two) |
| Tests | Taste check | `unique` and `not_null` on `Period` |
| Analysis | Serving suggestions | Six SQL queries in `analyses/` |
| Dashboard | Presentation | Power BI file |

**Tools:** Snowflake (warehouse), SQL (the language), dbt Core (runs saved SQL in the right order), VS Code (where files are edited), Command Prompt (where dbt commands are typed), Power BI (charts).

---

## 2. The steps, in order

### Step 0. The source
NHS England publishes an Excel workbook, "A&E Attendances and Emergency Admissions", monthly time series. Two tabs were used:

- **Activity**: attendances and emergency admissions, Aug 2010 onward.
- **Performance**: attendances seen within / over 4 hours, plus four % columns, Nov 2010 onward.

The Booking tab was not used.

### Step 1. Prepare two CSV files
Each tab was saved as a CSV (`ae_activity_raw.csv`, `ae_performance_raw.csv`). Column headers had to be cleaned: **no spaces or symbols, and no duplicate names**. Snowflake refused the load until that was fixed.

### Step 2. Load into Snowflake
In Snowsight, the CSVs were uploaded into the database `AE_PROJECT`, schema `PUBLIC`, as two tables. Every column was loaded as **text (VARCHAR)** because the values contain commas (`1,111,295`), percentage signs and dashes. Raw tables are loaded as they arrive, and converted afterwards.

Result: `RAW_AE_ACTIVITY` (193 rows), `RAW_AE_PERFORMANCE` (190 rows).

### Step 3. Set up dbt
1. Python was installed; `pip install dbt-core dbt-snowflake` installed dbt.
2. A project folder was made: `Documents\ae_project`.
3. `dbt_project.yml` (in the project folder) tells dbt the project's name and where its folders are.
4. `profiles.yml` (in `C:\Users\<you>\.dbt\`) holds the Snowflake connection details, including the password. It lives **outside** the project folder so the password never gets uploaded anywhere. **Never share or commit this file.**
5. `dbt debug` checks the connection. "Connection test: OK" means it works. The Git warning can be ignored.

### Step 4. Staging models (`models/staging/`)
Each staging model cleans **one** raw table. Every `.sql` file is a single `select`; dbt turns it into a view.

What the SQL does:

- `TO_DATE(Period, 'MON-YY')` turns text like `Aug-10` into a real date (2010-08-01).
- `REPLACE(col, ',', '')` removes commas from numbers.
- `TRY_TO_NUMBER(...)` converts text to a number, and returns blank (NULL) instead of an error when it can't.
- For the four percentage columns: `REPLACE(col, '%', '')` then `TRY_TO_NUMBER(..., 5, 2)`. The `5, 2` keeps two decimal places (without it, 97.20 would round to 97). It must **not** be used on count columns, because anything above 999.99 would silently become NULL.
- `COALESCE(x, 0)` means "use x, and if it is blank use 0". It was applied to the 12-hour-waits column, which has blanks.
- In the Performance model, columns were renamed (`Type_1_within_4hrs`, `Type_1_over_4hrs`, ...) because the original names repeated and were confusing.

Percentages are stored on a 0 to 100 scale (97.2 means 97.2%).

### Step 5. Checks before joining
Duplicate-month check: `SELECT Period, COUNT(*) ... GROUP BY Period HAVING COUNT(*) > 1`. Zero rows came back for both tables, so each month appears once.

### Step 6. The mart (`models/marts/mart_ae_monthly.sql`)
- Joins the two staging models on `Period`, with a **FULL OUTER JOIN**, which keeps every month from either side. Performance starts three months later than Activity, so those first months have blank percentages.
- `COALESCE(a.Period, p.Period) AS Period` takes the month from Activity, and from Performance if Activity is blank.
- Columns are prefixed `a.` and `p.` so SQL knows which table each comes from (`a` and `p` are aliases).
- The staging tables are referred to with `{{ ref('stg_ae_activity') }}` and `{{ ref('stg_ae_performance') }}`. `ref()` tells dbt "this depends on that model", so dbt builds staging first, then the mart, and the lineage diagram draws arrows.
- Only the Activity counts and the four percentages were kept. The within/over 4-hour counts from Performance were left out to avoid duplicating the Activity attendances.

### Step 7. Tests (`models/marts/schema.yml`)
```yaml
version: 2

models:
  - name: mart_ae_monthly
    columns:
      - name: Period
        tests:
          - unique
          - not_null
```
`dbt test` runs them. `PASS=2` means both passed. YAML uses spaces for indentation, never tabs.

### Step 8. Analysis queries (`analyses/seasonality_and_rankings.sql`)
Six queries on the mart:

1. Worst 5 months (`WHERE ... IS NOT NULL`, `ORDER BY ... ASC`, `LIMIT 5`)
2. Average 4-hour performance by month of year (`GROUP BY MONTH(Period)`)
3. Average monthly attendances by month of year
4. Attendances per day (`DAY(LAST_DAY(Period))` gives days in the month)
5. Average 4-hour performance per year (`GROUP BY YEAR(Period)`)
6. Emergency admissions via A&E as % of attendances, per year

Key idea: any column in the `SELECT` that isn't wrapped in `AVG`, `SUM` etc. must also be in the `GROUP BY`.

### Step 9. Power BI dashboard
- Connected to Snowflake (**Import** mode, so the data is stored in the file and keeps working after the trial ends), choosing `MART_AE_MONTHLY`.
- Charts: monthly line chart; yearly and month-of-year column charts; worst-5 table (Top N filter, Bottom 5); attendances by month; attendances per day; admissions share by year.
- The last two needed calculated columns (DAX): `Days in month = DAY(EOMONTH([PERIOD], 0))`, `Attendances per day = DIVIDE([TOTAL_ATTENDANCES], [Days in month])`, `Admissions share = 100 * DIVIDE([TOTAL_EMERGENCY_ADMISSIONS_VIA_AE], [TOTAL_ATTENDANCES])`.
- Date fields must be set to the plain date (not Date Hierarchy) on line charts, and numbers set to Average, not Sum.

### Step 10. Lineage diagram
`dbt docs generate` then `dbt docs serve` opens a web page; the blue icon at the bottom right shows how models connect. Ctrl + C stops it.

---

## 3. Command cheat sheet (Command Prompt, inside `ae_project`)

| Command | What it does |
|---|---|
| `cd` (alone) | Shows the folder you are in |
| `cd foldername` / `cd ..` | Go into a folder / go up one |
| `dir` | Lists the files in the folder |
| `dbt debug` | Checks the Snowflake connection |
| `dbt run` | Builds all models as views in Snowflake |
| `dbt test` | Runs the tests |
| `dbt docs generate` + `dbt docs serve` | Builds and opens the documentation and lineage page |
| Ctrl + C | Stops a running command |

`dbt` commands only work from **inside** the `ae_project` folder.

---

## 4. What the data showed

- 4-hour performance fell from about 97% (2010) to about 75% (2026). The lowest month was December 2022 (65.2%). The five worst months were Oct to Dec 2022 and Nov to Dec 2023.
- Across all years, December has the lowest average and May the highest. The trend over time is a bigger effect than the season.
- 2020 shows a spike in performance (fewer attendances during the pandemic, an interpretation rather than something the data proves).
- Per day, January is the quietest month and June the busiest. February's low monthly total is mostly because it is a shorter month.
- Emergency admissions via A&E were about 17 to 19% of attendances in most years, peaking at about 22.9% in 2020.

Caveats: 2010 and 2026 are partial years. Yearly figures are simple averages of monthly percentages, not weighted by patient numbers. Source notes say Nov 2010 to May 2015 is estimated from weekly data, May 2019 to May 2023 four-hour performance excludes 14 trusts in the CRS trial, and Aug 2020 onward includes booked appointments.

---

## 5. Views vs tables, `ref()` vs `source()`

- **Table:** stores a copy of the data. **View:** stores only the query, and runs it each time it is read. dbt makes views by default.
- **`ref('model')`:** "this depends on another dbt model". dbt builds in the right order and draws the lineage.
- **`source('name', 'table')`:** "this is a raw table I load myself, outside dbt". It lets the lineage start at the raw data and allows tests on it.
- This project uses `ref()`, but the raw tables are not yet declared as sources (they were loaded manually through Snowsight). That is a known limitation and the next improvement.

---

## 6. How to rebuild it alone

1. Open a Snowflake account (the free trial lasts 30 days). Note the **account identifier**.
2. Create the database `AE_PROJECT` with schema `PUBLIC`.
3. Load the two raw CSVs as tables named `RAW_AE_ACTIVITY` and `RAW_AE_PERFORMANCE` (all columns as text).
4. Edit `C:\Users\<you>\.dbt\profiles.yml` with the new account identifier, username and password. Type the password yourself; never paste it anywhere.
5. In Command Prompt, inside `ae_project`: `dbt debug`, then `dbt run`, then `dbt test`.
6. In Power BI, open the `.pbix` file. To refresh it, point it at the new account (Home, then Transform data, then Data source settings); otherwise rebuild the connection with Get data, then Snowflake.

---

## 7. Mini glossary

- **Warehouse (Snowflake):** the engine that runs your queries.
- **Schema / database:** folders that hold your tables and views.
- **NULL:** blank, no value.
- **Alias:** a nickname for a table or column (`a`, `p`, `AS name`).
- **Aggregate:** a function that squashes many rows into one (`AVG`, `SUM`, `COUNT`).
- **GROUP BY:** bundles rows before an aggregate is applied.
- **Percentage points:** the difference between two percentages (22.9% to 16.7% is a drop of about 6 points, not 6%).
