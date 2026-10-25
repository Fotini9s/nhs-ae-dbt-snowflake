/*joins the two tables with a FULL OUTER JOIN on month*/

SELECT
   COALESCE(a.Period, p.Period) AS Period,
   a.Type_1_Departments_Major_AE,
   a.Type_2_Departments_Single_Specialty,
   a.Type_3_Departments_Other_AE_Minor_Injury_Unit,
   a.Total_Attendances,
   a.Emergency_Admissions_via_Type_1_AE,
   a.Emergency_Admissions_via_Type_2_AE,
   a.Emergency_Admissions_via_Type_3_and_4_AE,
   a.Total_Emergency_Admissions_via_AE,
   a.Other_Emergency_Admissions_Not_via_AE,
   a.Total_Emergency_Admissions,
   a.Number_of_patients_spending_over_4_hours_from_decision_to_admit_to_admission,
   a.Number_of_patients_spending_over_12_hours_from_decision_to_admit_to_admission,
   p.Percentage_in_4_hours_or_less_all,
   p.Percentage_in_4_hours_or_less_type_1,
   p.Percentage_in_4_hours_or_less_type_2,
   p.Percentage_in_4_hours_or_less_type_3

FROM {{ ref('stg_ae_activity') }} as a
FULL OUTER JOIN {{ ref('stg_ae_performance') }} as p
on a.Period = p.Period

/*FROM AE_PROJECT.PUBLIC.stg_ae_activity as a
FULL OUTER JOIN AE_PROJECT.PUBLIC.stg_ae_performance as p*/

