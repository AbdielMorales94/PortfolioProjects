SELECT*
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4


--SELECT*
--FROM Portfolio_Project..CovidVaccines
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
order  by location, date

--Looking at Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in your Country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE location = 'Mexico' AND continent IS NOT NULL
order  by location, date DESC

--Looking at Total Cases vs Population
--Shows what percentage of Population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM Portfolio_Project..CovidDeaths
WHERE location = 'Mexico' AND continent IS NOT NULL
order  by location, date DESC

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Portfolio_Project..CovidDeaths
--WHERE location = 'Mexico'
WHERE continent IS NOT NULL
Group by location, population
order  by PercentPopulationInfected DESC

--Showing countries with highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
--WHERE location = 'Mexico'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing the Continents with the highest Death Count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
--WHERE location = 'Mexico'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccination
-- CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
  OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null	
--ORDER BY location, date
)

Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
  OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
    ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent is not null	
--ORDER BY location, date


Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
  OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null	
--ORDER BY location, date

SELECT*
FROM PercentPopulationVaccinated