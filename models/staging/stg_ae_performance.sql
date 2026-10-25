
/*Cleans the Performance table (commas removed, text turned into numbers and dates) 
& percentages are stored on a 0 to 100 scale*/
SELECT
   TO_DATE(Period, 'MON-YY') AS Period,
   TRY_TO_NUMBER(REPLACE(Type_1_Departments_Major_AE, ',', '')) as Type_1_within_4hrs,
   TRY_TO_NUMBER(REPLACE(Type_2_Departments_Single_Specialty, ',', '')) as Type_2_within_4hrs,
   TRY_TO_NUMBER(REPLACE(Type_3_Departments_Other_AE_Minor_Injury_Unit, ',', '')) as Type_3_within_4hrs,
   TRY_TO_NUMBER(REPLACE(Total_Attendances_less_than_4_hours, ',', '')) as Total_within_4hrs,
   TRY_TO_NUMBER(REPLACE(Type_1_Departments_Major_AE_, ',', '')) as Type_1_over_4hrs,
   TRY_TO_NUMBER(REPLACE(Type_2_Departments_Single_Specialty_, ',', '')) as Type_2_over_4hrs,
   TRY_TO_NUMBER(REPLACE(Type_3_Departments_Other_AE_Minor_Injury_Unit_, ',', '')) as Type_3_over_4hrs,
   TRY_TO_NUMBER(REPLACE(Total_Attendances_over_4_hours, ',', '')) as Total_over_4hrs,

   TRY_TO_NUMBER(REPLACE(Percentage_in_4_hours_or_less_all, '%', ''), 5, 2) as Percentage_in_4_hours_or_less_all,
   TRY_TO_NUMBER(REPLACE(Percentage_in_4_hours_or_less_type_1, '%', ''), 5, 2) as Percentage_in_4_hours_or_less_type_1,
   TRY_TO_NUMBER(REPLACE(Percentage_in_4_hours_or_less_type_2, '%', ''), 5, 2) as Percentage_in_4_hours_or_less_type_2,
   TRY_TO_NUMBER(REPLACE(Percentage_in_4_hours_or_less_type_3, '%', ''), 5, 2) as Percentage_in_4_hours_or_less_type_3
FROM AE_PROJECT.PUBLIC.RAW_AE_PERFORMANCE