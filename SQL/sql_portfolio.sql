
--Identify the top 10 highest paying data analyst roles that are working remotely
--remove the nulls

SELECT 
   name as company_name,
   salary_year_avg,
   job_title,
   job_id,
   job_location,
   job_schedule_type,
   job_posted_date
FROM job_postings_fact as job
LEFT JOIN company_dim AS com
   ON com.company_id = job.company_id
WHERE job_location = 'Anywhere' AND job_title_short = 'Data Analyst' AND salary_year_avg is not null
ORDER BY salary_year_avg DESC
limit 10

--use the data from above
--add specific skills required for this roles


SELECT skill_job.skill_id,skills,sub_1.*
FROM (
   SELECT 
   name as company_name,
   salary_year_avg,
   job_title,
   job_id
FROM job_postings_fact as job
LEFT JOIN company_dim AS com
   ON com.company_id = job.company_id
WHERE job_location = 'Anywhere' AND job_title_short = 'Data Analyst' AND salary_year_avg is not null
ORDER BY salary_year_avg DESC
limit 10
) As sub_1
JOIN skills_job_dim as skill_job
   ON sub_1.job_id = skill_job.job_id
JOIN skills_dim as skill_name
   ON skill_job.skill_id = skill_name.skill_id
ORDER BY salary_year_avg DESC

--Insights
--SQL is leading with a count of 8
--Python with a count of 7
--Tableu is also highly saught after, with a count of 6 
--skills like excel,snowflake,r,power bi varies on the company and demand




