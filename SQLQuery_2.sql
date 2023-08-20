-- Select the data needed for analysis
-- Continent is NULL in some cases were the location is only the continent

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths23
WHERE continent is NOT NULL
ORDER BY 1, 2

-- Total cases vs total deaths
-- Provides percent chance of death overall and for the US

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercent
FROM CovidDeaths23
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentUS
FROM CovidDeaths23
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Total cases vs population
-- Provides percent of population that contracted covid

SELECT location, date, population, total_cases, (total_cases / population)*100 as CasesPercent
FROM CovidDeaths23
WHERE continent is NOT NULL
ORDER BY 1,2

SELECT location, date, population, total_cases, (total_cases / population)*100 as CasesPercent
FROM CovidDeaths23
WHERE location LIKE '%states%'
AND continent is NOT NULL
ORDER BY 1,2

-- Countries with the highest covid infection rate compared to the population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases / population)*100 as PercentPopulationInfected
FROM CovidDeaths23
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with the highest death count compared to the population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths23
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Breakdown by continent

SELECT continent, MAX(total_deaths) AS TotalDeathCountContinent
FROM CovidDeaths23
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCountContinent DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CONVERT(DECIMAL(18,2), new_deaths))/SUM(CONVERT(DECIMAL(18,2), new_cases)) *100 AS DeathPercentage
FROM CovidDeaths23
-- WHERE location LIKE '%states%'
WHERE continent is NOT NULL
ORDER BY 1,2

-- Total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths23 as dea
JOIN CovidVax23 as vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent is NOT NULL
ORDER BY 2, 3 DESC


-- USE CTE

WITH PopVsVax (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths23 as dea
JOIN CovidVax23 as vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent is NOT NULL
-- ORDER BY 2, 3 DESC
)
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopVsVax


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths23 as dea
JOIN CovidVax23 as vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent is NOT NULL
-- ORDER BY 2, 3 DESC

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated

-- Creating view to store data for vizualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths23 as dea
JOIN CovidVax23 as vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent is NOT NULL
-- ORDER BY 2, 3 DESC

SELECT *
FROM PercentPopulationVaccinated