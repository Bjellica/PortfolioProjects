/* Targets:
- Provide a list of Healthy Individuals & Low Absenteeism for our healthy bonus program - Total Budget $1000
- Calculate a Wage Increase or annual compensation for Non-smokers for
  - Insurance Budget of $983,221 for all Non-smokers
- Create a Dashboard for HR to understand Absenteeism at work based on approved wireframe. */

--create a join table
select * from Absenteeism_at_work ab
left join compensation com
on ab.ID = com.ID
left join Reasons re
on ab.Reason_for_absence = re.Number;

--find the healthiest employees for the bonus
select * from Absenteeism_at_work 
where Social_drinker = 0 and Social_smoker = 0
and Body_mass_index <25 and
Absenteeism_time_in_hours < (select AVG(Absenteeism_time_in_hours) from Absenteeism_at_work)

--compensation rate increase for non-smokers / budget $983,221 so .68 increase per hour / $1,414 per year
select COUNT(*) as Total_nonsmokers from Absenteeism_at_work
where Social_smoker = 0

--optimize the join table query (further use for creating BI Dashboard)
select
ab.ID, re.Reason,
Month_of_absence,
Body_mass_index,
CASE WHEN Body_mass_index < 18.5 then 'Underweight'
     WHEN Body_mass_index between 18.5 and 25 then 'Healthy Wight'
	 WHEN Body_mass_index between 25 and 30 then 'Overweight'
	 WHEN Body_mass_index > 30 then 'Obese'
	 ELSE 'Unknown' END as BMI_Category,
CASE WHEN Month_of_absence IN (12,1,2) Then 'Winter'
     WHEN Month_of_absence IN (3,4,5) Then 'Spring'
	 WHEN Month_of_absence IN (6,7,8) Then 'Summer'
	 WHEN Month_of_absence IN (9,10,11) Then 'Fall'
	 ELSE 'Unknown' END as Season,
Seasons,
Month_of_absence,
Day_of_the_week,
Transportation_expense,
Education,
Son,
Social_drinker,
Social_smoker,
Pet,
Disciplinary_failure,
Age,
Work_load_Average_day,
Absenteeism_time_in_hours
from Absenteeism_at_work ab
left join compensation com
on ab.ID = com.ID
left join Reasons re
on ab.Reason_for_absence = re.Number;

--total absenteeism for each reason
select DISTINCT(re.Reason),
COUNT(ab.ID) OVER (PARTITION BY re.Reason) as Total_for_Reason
from Absenteeism_at_work ab
left join Reasons re
on ab.Reason_for_absence = re.Number
Group by re.Reason, ab.ID
Order by Total_for_Reason DESC