/*

SQl queries used for Covid Exploration Tableau Project

*/



-- 1. 
-- Total cases against total deaths worldwide
SELECT	SUM(new_cases) AS total_cases,
		SUM(new_deaths) AS total_deaths, 
		NULLIF(SUM(new_deaths), 0) / NULLIF(SUM(new_cases), 0) * 100 AS death_percentage
FROM PortfolioProject..['CovidDeaths']
WHERE	continent IS NOT NULL 
ORDER BY 1,2

-- 2. 
-- Certain locations taken out for data consistency
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

-- 3.
-- Countries with highest infection rate compared to population
SELECT	location,
		population, 
		MAX(total_cases) AS highest_infection_count, 
		MAX((total_cases/population))*100 AS pop_infected_percentage
FROM PortfolioProject..['CovidDeaths']
GROUP BY location, population
ORDER BY pop_infected_percentage DESC

-- 4.
-- Countries with highest infection rate compared to population over time
SELECT	location,
		population, 
		date,
		MAX(total_cases) AS highest_infection_count, 
		MAX((total_cases/population))*100 AS pop_infected_percentage
FROM PortfolioProject..['CovidDeaths']
GROUP BY location, population, date
ORDER BY pop_infected_percentage DESC