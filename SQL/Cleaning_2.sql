CREATE TABLE trial(
   company VARCHAR(255),
   location VARCHAR(50),
   industry VARCHAR (50),
   total_laid_off int,
   percentage_laid_off numeric,
   date text,
   stage text,
   country VARCHAR(50),
   funds_raised_millions int
)
SELECT * FROM trial

-- Used to remove duplicates 
with cte as (
SELECT *, row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country) AS rn
FROM trial) 
DELETE FROM trial
using cte 
where rn > 1

-- trimmed some of the trailing dots in country col
SELECT distinct country, trim(trailing '.' from country)
FROM trial

UPDATE trial 
set country = trim(trailing '.' from country)

--standardizing industry
SELECT distinct industry
from trial 
order by 1

SELECT distinct industry 
from trial
where industry like 'Crypto%'

UPDATE trial
SET industry = 'Crypto'
WHERE industry like 'Crypto%'




-- change the column data type of date

ALTER TABLE trial
ALTER COLUMN date TYPE date using TO_DATE(date, 'MM-DD-YYYY')


-- tried to populate some of the null values 

select company,location, industry
from trial
WHERE industry is null or industry = ''

SELECT t1.industry, t2.industry 
FROM trial as t1
JOIN trial as t2
on t1.company = t2.company 
WHERE t1.industry IS NULL and t2.industry is not null

SELECT * from trial WHERE company = 'Carvana'


UPDATE trial t1
SET industry = t2.industry
FROM trial t2
WHERE t1.company = t2.company
AND t1.industry IS NULL
AND t2.industry IS NOT NULL;






