SELECT *
FROM dbo.CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM dbo.CovidVaccinations$
--ORDER BY 3,4

--Select the data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM dbo.CovidDeaths
ORDER BY 1,2

--Looking at the Total Cases VS. Total Deaths 
--Shows the likelihood of dying if you contract COVID in your country
SELECT location
,date
,total_cases
,total_deaths
,(total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total Cases VS Population
--Shows what percentage of the population has gotten COVID
SELECT location
,date
,population
,total_cases
,(total_cases/population)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location
,population
,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
SELECT location
,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
--Where location like %state%
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent
,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
--Where location like %state%
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



-- Showing the Continents with the Highest Death Count
SELECT continent
,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
--Where location like %state%
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS
SELECT date
,SUM(new_cases) as total_cases
,SUM(cast(new_deaths as int)) as total_deaths
,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null 
GROUP by date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations 


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.DATE)
AS RollingPeopleVaccinated
FROM PortfolioC19..CovidDeaths dea
JOIN PortfolioC19..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.DATE)
AS RollingPeopleVaccinated
FROM PortfolioC19..CovidDeaths dea
JOIN PortfolioC19..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.DATE)
AS RollingPeopleVaccinated
FROM PortfolioC19..CovidDeaths dea
JOIN PortfolioC19..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.DATE)
AS RollingPeopleVaccinated
FROM PortfolioC19..CovidDeaths dea
JOIN PortfolioC19..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

CREATE VIEW GlobalNumbers AS
SELECT date
,SUM(new_cases) as total_cases
,SUM(cast(new_deaths as int)) as total_deaths
,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null 
GROUP by date

CREATE VIEW DeathCount AS
SELECT location
,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
--Where location like %state%
WHERE continent is not null
GROUP BY location
--ORDER BY TotalDeathCount desc

CREATE VIEW PercentInfected AS
SELECT location
,population
,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM dbo.CovidDeaths
GROUP BY location, population
--ORDER BY PercentPopulationInfected desc

CREATE VIEW TotalDeath AS
--Showing Countries with Highest Death Count per Population
SELECT location
,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
--Where location like %state%
WHERE continent is not null
GROUP BY location
--ORDER BY TotalDeathCount desc