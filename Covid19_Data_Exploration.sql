-- ==========================================================
-- COVID-19 DATA EXPLORATION PROJECT
-- Author: Belal Abdelrhman
-- ==========================================================

-- ==========================================================
-- STEP 1: Explore Raw Data
-- ==========================================================
USE [Portfolio Project];

SELECT * FROM CovidDeaths;
SELECT * FROM CovidVaccinations;


-- ==========================================================
-- STEP 2: Select Data to Start With
-- ==========================================================
SELECT d.Location, d.date, d.total_cases, d.new_cases, d.total_deaths, d.population
FROM CovidDeaths d
WHERE d.continent IS NOT NULL 
ORDER BY 1,2; -- Order by Location first, then Date


-- ==========================================================
-- STEP 3: Total Cases vs Total Deaths 
-- (Shows likelihood of dying if you contract covid in your country)
-- ==========================================================
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS death_percentage
FROM CovidDeaths
WHERE location like '%egypt%'
ORDER BY 1,2;


-- ==========================================================
-- STEP 4: Total Cases vs Population 
-- (Shows what percentage of population infected with Covid)
-- ==========================================================
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS population_infected_percentage
FROM CovidDeaths
WHERE location like '%egypt%'
ORDER BY location, date;


-- ==========================================================
-- STEP 5: Countries with Highest Infection Rate compared to Population
-- ==========================================================
SELECT Location, population, MAX(total_cases) AS highest_infection_count , MAX((total_cases/population))*100 AS percent_population_infected
FROM CovidDeaths
--WHERE location like '%egypt%'
GROUP BY Location, population
ORDER BY percent_population_infected DESC;


-- ==========================================================
-- STEP 6: Countries with Highest Death Count per Population
-- ==========================================================
select Location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%egypt%'
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- ==========================================================
-- STEP 7: Continents with the Highest Death Count per Population
-- ==========================================================
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--WHERE location like '%egypt%'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- ==========================================================
-- STEP 8: Global Numbers
-- ==========================================================
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%EGYPT%'
WHERE continent IS NOT NULL
--Group By date
ORDER BY 1,2

-- ==========================================================
-- STEP 9: Total Population vs Vaccinations 
-- (Shows Percentage of Population that has received at least one Covid Vaccine)
-- ==========================================================
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- ==========================================================
-- STEP 10: Using CTE to perform Calculation on Partition By in previous query
-- ==========================================================
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;


-- ==========================================================
-- STEP 11: Using Temp Table to perform Calculation on Partition By in previous query
-- ==========================================================
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;


-- ==========================================================
-- STEP 12: Creating View to store data for later visualizations
-- ==========================================================
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

SELECT * FROM PercentPopulationVaccinated;
