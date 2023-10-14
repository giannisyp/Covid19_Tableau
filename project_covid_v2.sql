-- Select everything to see if its ok from the two tables

SELECT * 
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null
order by 3,4


SELECT * 
FROM Portfolio_Project..Covid_Vaccinations
order by 3,4

-- Select the data that we are going to be using

SELECT Location, date , total_cases, new_cases, total_deaths, population
From Portfolio_Project..Covid_Deaths
order by 1,2

-- Looking at the Total Cases Vs Total Deaths 
-- Shows the likelihookd of dying if you contract covid in greece (or your country by changing the location)

SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From Portfolio_Project..Covid_Deaths
WHERE location like 'Greece'
and continent is not null
order by 1,2

-- Looking at Total Cases Vs Population 
-- The percentage of population that got Covid

SELECT Location, date, population, total_cases,(total_cases/population)*100 as PercentageOfSickPeople
From Portfolio_Project..Covid_Deaths
WHERE location like 'Greece'
order by 1,2

-- Looking at Countries with highest Infection Rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..Covid_Deaths
Group by Location, population
order by PercentPopulationInfected Desc

-- Showing the countries with the highest death count per population

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null
Group by Location
order by TotalDeathCount Desc

-- Let's break things down by continent

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not  null
Group by continent
order by TotalDeathCount Desc

-- Global numbers of new cases and how covid spread every day 

SELECT date, SUM(new_cases) 
FROM Portfolio_Project..Covid_Deaths
where continent is not null
Group by date
order by 1,2

-- Global numbers of deaths every day 

SELECT date, SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths  ,NULLIF(SUM(new_deaths),0)/ NULLIF(SUM(new_cases),0) * 100 as DeathPercentage
FROM Portfolio_Project..Covid_Deaths
where continent is not null
Group by date
order by 1,2

-- Global total Cases vs total deaths plus percent of death

SELECT SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths  ,NULLIF(SUM(new_deaths),0)/ NULLIF(SUM(new_cases),0) * 100 as DeathPercentage
FROM Portfolio_Project..Covid_Deaths
where continent is not null
--Group by date
order by 1,2


-- VACCINATIONS


-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as  Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)* 100
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- USE CTE


With PopvsVac (continent,location,date,population,new_vaccinations, Rolling_People_Vaccinated)
as (
SELECT dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as  Rolling_People_Vaccinated
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)

SELECT * , (Rolling_People_Vaccinated/population)*100 as Percent_of_people_vaccinated
FROM PopvsVac


-- Check for Greece Vaccinations over time


With PopvsVac (continent,location,date,population,new_vaccinations, Rolling_People_Vaccinated)
as (
SELECT dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as  Rolling_People_Vaccinated
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
and dea.location like 'Greece'
)

SELECT * , (Rolling_People_Vaccinated/population)*100 as percent_of_people_vaccinated
FROM PopvsVac



-- Temp Table


DROP TABLE IF exists #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
Rolling_People_Vaccinated numeric
)

Insert into #percent_population_vaccinated
SELECT dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as  Rolling_People_Vaccinated
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT * , (Rolling_People_Vaccinated/population)*100 as Percent_of_people_vaccinated
FROM #percent_population_vaccinated


-- Creating View to store data for later visualizations

USE Portfolio_Project
GO
CREATE VIEW Percent_of_people_vaccinated as 
SELECT dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as  Rolling_People_Vaccinated
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null