--select * from AE_PROJECT.PUBLIC.STG_AE_ACTIVITY limit 10;

--select * from AE_PROJECT.PUBLIC.STG_AE_PERFORMANCE
--order by Period limit 5;

--SELECT Period, count(*) 
--FROM AE_PROJECT.PUBLIC.STG_AE_ACTIVITY 
--GROUP BY Period 
--HAVING COUNT(*) > 1;

--SELECT Period, count(*) 
--FROM AE_PROJECT.PUBLIC.STG_AE_PERFORMANCE 
--GROUP by Period 
--HAVING count(*) > 1;


/*joins the two with a FULL OUTER JOIN on month*/
 -- SELECT
 --   a.Period,
 --   a.Type_1_Departments_Major_AE,
 --   a.Type_2_Departments_Single_Specialty,
 --   a.Type_3_Departments_Other_AE_Minor_Injury_Unit,
 --   a.Total_Attendances,
 --   a.Emergency_Admissions_via_Type_1_AE,
 --   a.Emergency_Admissions_via_Type_2_AE,
 --   a.Emergency_Admissions_via_Type_3_and_4_AE,
 --   a.Total_Emergency_Admissions_via_AE,
 --   a.Other_Emergency_Admissions_Not_via_AE,
 --   a.Total_Emergency_Admissions,
 --   a.Number_of_patients_spending_over_4_hours_from_decision_to_admit_to_admission,
 --   a.Number_of_patients_spending_over_12_hours_from_decision_to_admit_to_admission,
 --   p.Percentage_in_4_hours_or_less_all,
 --   p.Percentage_in_4_hours_or_less_type_1,
 --   p.Percentage_in_4_hours_or_less_type_2,
--    p.Percentage_in_4_hours_or_less_type_3
--FROM AE_PROJECT.PUBLIC.STG_AE_ACTIVITY a
--FULL OUTER JOIN AE_PROJECT.PUBLIC.STG_AE_PERFORMANCE p
 --   on a.Period = p.Period

-- SELECT 
--    Period, 
--    Total_within_4hrs, 
--    FROM AE_PROJECT.PUBLIC.STG_AE_PERFORMANCE
--Order BY Period
--limit 5;

--SELECT *
--FROM AE_PROJECT.PUBLIC.mart_ae_monthly 
--ORDER BY Period
--limit 6

/*mart*/
--SELECT * 
--FROM AE_PROJECT.PUBLIC.mart_ae_monthly 
--ORDER BY Period

/*the worst 5 months*/
SELECT
   Period,
   Percentage_in_4_hours_or_less_all
FROM AE_PROJECT.PUBLIC.mart_ae_monthly
   WHERE Percentage_in_4_hours_or_less_all IS NOT NULL
   ORDER BY Percentage_in_4_hours_or_less_all ASC
   Limit 5


/*Average 4-hour performance by month of year*/
SELECT
   MONTH(Period) AS month_number,
   AVG(Percentage_in_4_hours_or_less_all) AS Percentage_in4h_orless
FROM AE_PROJECT.PUBLIC.mart_ae_monthly
   GROUP BY MONTH(Period)
   ORDER BY MONTH(Period)


/*Average monthly attendances by month of year*/
SELECT
   MONTH(Period) AS month_number,
   AVG(Total_Attendances) AS Total_Attendances
FROM AE_PROJECT.PUBLIC.mart_ae_monthly
   GROUP BY MONTH(Period)
   ORDER BY MONTH(Period)


/*Attendances per day*/
SELECT
   MONTH(Period) AS month_number,
   AVG(Total_Attendances) AS Total_Attendances,
   AVG(Total_Attendances/DAY(LAST_DAY(Period))) AS Attendances_per_day
FROM AE_PROJECT.PUBLIC.mart_ae_monthly
   GROUP BY MONTH(Period)
   ORDER BY MONTH(Period)

/*Average 4-hour performance per year*/
SELECT
   YEAR(Period) AS year,
   AVG(Percentage_in_4_hours_or_less_all) AS Percentage_in4h_orless
FROM AE_PROJECT.PUBLIC.mart_ae_monthly
   GROUP BY YEAR(Period)
   ORDER BY YEAR(Period)


/*Admissions as a percentage of attendances per year*/
SELECT
   YEAR(Period) AS year,
   AVG(Total_Attendances) AS avg_monthly_attendances,
   AVG(100 * Total_Emergency_Admissions_via_AE/Total_Attendances) AS Admissions_as_percentage_of_attendances_per_year
FROM AE_PROJECT.PUBLIC.mart_ae_monthly
   GROUP BY YEAR(Period)
   ORDER BY YEAR(Period)