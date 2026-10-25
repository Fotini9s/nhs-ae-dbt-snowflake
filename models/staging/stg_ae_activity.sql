
/* cleans the raw Activity table (commas removed, text turned into numbers and dates) */

SELECT
   TO_DATE(Period, 'MON-YY') AS Period,
   TRY_TO_NUMBER(REPLACE(Type_1_Departments_Major_AE, ',', '')) as Type_1_Departments_Major_AE,
   TRY_TO_NUMBER(REPLACE(Type_2_Departments_Single_Specialty, ',', '')) as Type_2_Departments_Single_Specialty,
   TRY_TO_NUMBER(REPLACE(Type_3_Departments_Other_AE_Minor_Injury_Unit, ',', '')) as Type_3_Departments_Other_AE_Minor_Injury_Unit,
   TRY_TO_NUMBER(REPLACE(Total_Attendances, ',', '')) as Total_Attendances,
   TRY_TO_NUMBER(REPLACE(Emergency_Admissions_via_Type_1_AE, ',', '')) as Emergency_Admissions_via_Type_1_AE,
   TRY_TO_NUMBER(REPLACE(Emergency_Admissions_via_Type_2_AE, ',', '')) as Emergency_Admissions_via_Type_2_AE,
   TRY_TO_NUMBER(REPLACE(Emergency_Admissions_via_Type_3_and_4_AE, ',', '')) as Emergency_Admissions_via_Type_3_and_4_AE,
   TRY_TO_NUMBER(REPLACE(Total_Emergency_Admissions_via_AE, ',', '')) as Total_Emergency_Admissions_via_AE,
   TRY_TO_NUMBER(REPLACE(Other_Emergency_Admissions_Not_via_AE, ',', '')) as Other_Emergency_Admissions_Not_via_AE,
   TRY_TO_NUMBER(REPLACE(Total_Emergency_Admissions, ',', '')) as Total_Emergency_Admissions,
   TRY_TO_NUMBER(REPLACE(Number_of_patients_spending_over_4_hours_from_decision_to_admit_to_admission, ',', '')) as Number_of_patients_spending_over_4_hours_from_decision_to_admit_to_admission,
   COALESCE(TRY_TO_NUMBER(REPLACE(Number_of_patients_spending_over_12_hours_from_decision_to_admit_to_admission, ',', '')), 0) AS Number_of_patients_spending_over_12_hours_from_decision_to_admit_to_admission
FROM AE_PROJECT.PUBLIC.RAW_AE_ACTIVITY