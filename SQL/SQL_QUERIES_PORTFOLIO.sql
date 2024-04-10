SELECT 
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 as percentage
FROM `CovidDeath.DeathTable`
WHERE location like '%States%'
ORDER BY 1,2


--PERCENTAGE OF INFECTED
SELECT  
  location,
  date,
  total_cases,
  population,
  (total_cases/population) * 100 as percentageOfInfected
FROM `CovidDeath.DeathTable`
WHERE location = 'Philippines'
ORDER BY 1,2


--POPULATION INFECTION RATE

SELECT 
  location,
  population,
  MAX(total_cases) as HighestInfectionCount,
  MAX((total_cases/population)) * 100 as percentageOfPopulationInfected
FROM `CovidDeath.DeathTable`
GROUP BY location,population
ORDER BY percentageOfPopulationInfected desc



SELECT *
FROM `CovidDeath.DeathTable`
ORDER BY 3,4




-- PERCENTAGE OF DEATH PER COUNTRY
SELECT 
  location,
  MAX(cast(total_deaths as int)) as HighestTotalDeath,
FROM `CovidDeath.DeathTable`
--because in the data set there is null continents and what should be in the continent is placed in location
WHERE continent is not null
GROUP BY location
ORDER BY HighestTotalDeath desc

--BY CONTINENT


--show continents with highest death per population
SELECT 
  continent,
  MAX(cast(total_deaths as int)) as HighestTotalDeath,
FROM `CovidDeath.DeathTable`
--because in the data set there is null continents and what should be in the continent is placed in location
WHERE continent is not null
GROUP BY continent
ORDER BY HighestTotalDeath desc

--global numbers
SELECT 
  SUM(new_cases) as total_case, SUM(new_deaths) as NewDeath, (SUM(new_deaths)/SUM(new_cases))* 100 as percentage
  --total_deaths,(total_deaths/total_cases)*100 as percentage
FROM `CovidDeath.DeathTable`
WHERE continent is not null

--GROUP BY date
ORDER BY 1,2
--this does rolling count using partition

SELECT 
  ded.continent,
  ded.location,
  ded.date, 
  population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (partition by ded.location ORDER BY ded.location, ded.date) AS total_vaccination,
 
FROM `CovidVaccine.VaccineTable` AS vac
Join `CovidDeath.DeathTable` AS ded
ON vac.location = ded.location AND vac.date = ded.date
WHERE ded.continent is not null 
ORDER BY 2,3

--using CTE
WITH PopVsVac AS (
  SELECT 
    ded.continent,
    ded.location,
    ded.date, 
    population,
    vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (partition by ded.location ORDER BY ded.date,ded.location) AS total_vaccination
FROM `CovidVaccine.VaccineTable` AS vac
Join `CovidDeath.DeathTable` AS ded
ON vac.location = ded.location AND vac.date = ded.date
WHERE ded.continent is not null 
)
select *,(total_vaccination/population) * 100 AS PERCENTAGE FROM PopVsVac


--USING temp_table

CREATE TABLE #TempTable
(
  continent string,
  location string,
  date datetime,
  population int64,
  total_vaccination int64
)

INSERT INTO #TempTable
SELECT 
    ded.continent,
    ded.location,
    ded.date, 
    population,
    vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (partition by ded.location ORDER BY ded.date,ded.location) AS total_vaccination
FROM `CovidVaccine.VaccineTable` AS vac
Join `CovidDeath.DeathTable` AS ded
ON vac.location = ded.location AND vac.date = ded.date
WHERE ded.continent is not null 

select *,(total_vaccination/population) * 100 AS PERCENTAGE FROM #TempTable


--CREATE VISUALS
CREATE VIEW CovidVaccine.PercentPopulationVaccinated AS 
  SELECT 
  ded.continent,
  ded.location,
  ded.date, 
  population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (partition by ded.location ORDER BY ded.location, ded.date) AS total_vaccination
 
FROM `CovidVaccine.VaccineTable` AS vac
Join `CovidDeath.DeathTable` AS ded
ON vac.location = ded.location AND vac.date = ded.date
WHERE ded.continent is not null 
--ORDER BY 2,3
