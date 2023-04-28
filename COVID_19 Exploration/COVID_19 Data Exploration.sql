/*
Exploring COVID-19 data
Skills used: Joins, CTE's, temp tables, windows functions, aggregate functions, creating views,  data type conversion
*/



SELECT * 
FROM PortfolioProject..['CovidDeaths']
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..['CovidVaccinations']
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select data we are using
SELECT	location, 
		date, 
		total_cases, 
		new_cases, 
		total_deaths, 
		population 
FROM PortfolioProject..['CovidDeaths'] 
ORDER BY 1,2

-- Total cases against total deaths in UK
-- Shows death rate against total cases at a specific date
SELECT	location,
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..['CovidDeaths']
WHERE location LIKE '%kingdom%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Total cases against population in UK
-- Shows % of population infected with Covid
SELECT	location, 
		date, 
		population, 
		total_cases, 
		(total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..['CovidDeaths']
WHERE location LIKE '%kingdom%'
ORDER BY 1,2

-- Countries with highest infection rate compared to population
SELECT	location,
		population, 
		MAX(total_cases) AS highest_infection_count, 
		MAX((total_cases/population))*100 AS pop_infected_percentage
FROM PortfolioProject..['CovidDeaths']
GROUP BY location, population
ORDER BY pop_infected_percentage DESC

-- Countries with highest death count per population
SELECT	location,
		MAX(total_deaths) AS total_death_count
FROM PortfolioProject..['CovidDeaths']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC




-- BREAKING THINGS DOWN BY CONTINENT
-- Showing continents with the highest total death count per population
SELECT	continent,
		SUM(new_deaths) AS total_death_count
FROM PortfolioProject..['CovidDeaths']
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

-- GLOBAL NUMBERS
-- Total cases against total deaths worldwide
SELECT	SUM(new_cases) AS total_cases,
		SUM(new_deaths) AS total_deaths, 
		NULLIF(SUM(new_deaths), 0) / NULLIF(SUM(new_cases), 0) * 100 AS death_percentage
FROM PortfolioProject..['CovidDeaths']
WHERE	continent IS NOT NULL 
		AND new_cases IS NOT NULL 
		AND new_deaths IS NOT NULL
ORDER BY 1,2

-- Total deaths in each continent
SELECT	location, 
		SUM(new_deaths) AS total_death_count
FROM PortfolioProject..['CovidDeaths']
WHERE continent IS NULL 
AND location NOT IN ('World',
					'European Union', 
					'International', 
					'High income', 
					'Upper middle income', 
					'Lower middle income', 
					'Low income')
GROUP BY location
ORDER BY total_death_count desc

-- Total population against vaccinations
SELECT	cd.continent, 
		cd.location, 
		cd.date, 
		cd.population, 
		cv.new_vaccinations, 
		SUM (CAST(cv.new_vaccinations AS BIGINT)) 
			OVER (
				PARTITION BY cd.location 
				ORDER BY cd.location, 
						 cd.date
				) AS rolling_sum_vaccinated
--, (rolling_sum_vaccinated/population)*100
FROM PortfolioProject..['CovidDeaths'] cd
JOIN PortfolioProject..['CovidVaccinations'] cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform calculation on partition by in previous query
-- Shows % of population who are fully vaccinated
WITH PopulationVaccinated 
(
continent, 
location,
date, 
population, 
people_fully_vaccinated, 
rolling_sum_vaccinated
) 
AS 
(
SELECT	cd.continent,
		cd.location, 
		cd.date, 
		cd.population, 
		cv.people_fully_vaccinated, 
		SUM (CAST(cv.people_fully_vaccinated AS BIGINT)) 
			OVER (
				PARTITION BY cd.location 
				ORDER BY cd.location, 
						 cd.date
				) AS rolling_sum_vaccinated
FROM PortfolioProject..['CovidDeaths'] cd
JOIN PortfolioProject..['CovidVaccinations'] cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, 
	(rolling_sum_vaccinated/population)*100 AS percentage_population_vaccinated
FROM PopulationVaccinated
--ORDER BY date DESC, percentage_population_vaccinated DESC

-- Using Temp table to perform calculation on partition by in previous query
DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_sum_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT	cd.continent, 
		cd.location, 
		cd.date, 
		cd.population,
		cv.people_fully_vaccinated, 
		SUM(CAST(cv.people_fully_vaccinated AS BIGINT)) 
		OVER (
			PARTITION BY cd.location 
			ORDER BY cd.location, 
					 cd.date
			) AS rolling_sum_vaccinated
FROM PortfolioProject..['CovidDeaths'] cd
JOIN PortfolioProject..['CovidVaccinations'] cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *, 
	(rolling_sum_vaccinated/population)*100 AS population_percentage_vaccinated
FROM #PercentPopulationVaccinated







-- Creating Views to store data for later visualisations
CREATE VIEW PercentagePopulationVaccinated AS
SELECT	cd.continent, 
		cd.location, 
		cd.date, 
		cd.population, 
		cv.new_vaccinations, 
		SUM(CAST(cv.new_vaccinations AS BIGINT)) 
			OVER (
				PARTITION BY cd.location 
				ORDER BY cd.location, 
						 cd.date
				) AS rolling_sum_vaccinated
FROM PortfolioProject..['CovidDeaths'] cd
JOIN PortfolioProject..['CovidVaccinations'] cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

CREATE VIEW UnitedKingdomDeathRate AS
SELECT	location, 
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..['CovidDeaths']
WHERE location LIKE '%kingdom%'
AND continent IS NOT NULL

CREATE VIEW UnitedKingdomInfectedRate AS
SELECT	location,
		date, 
		population,
		total_cases, 
		(total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..['CovidDeaths']
WHERE location LIKE '%kingdom%'