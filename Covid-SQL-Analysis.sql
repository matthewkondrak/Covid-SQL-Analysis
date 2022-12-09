-- Initial look at the data in CovidDeaths
SELECT *
FROM `CovidDeaths`
WHERE continent is not null
order by 3,4

-- Another look at the data
Select location, date, total_cases, new_cases, total_deaths, population
From `CovidDeaths`
Where continent is not null
order by 3,4


-- looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From `CovidDeaths`
Where location like '%states%'
and Where continent is not null
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid
Select location, date, population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
From `CovidDeaths`
-- Where location like '%states%'
Where continent is not null
order by 1,2


--  Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From `CovidDeaths`
-- Where location like '%states%'
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- showing the countries with the highest death couth per population
Select location, MAX(total_deaths) as TotalDeathCount 
From `CovidDeaths`
-- Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


-- breakings things down by continent
-- showing the continents with the highest death count per population
Select continent, MAX(total_deaths) as TotalDeathCount 
From `CovidDeaths`
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- global numbers of covid
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From `CovidDeaths`
where continent is not null
group by date
order by 1,2


-- joining coviddeaths and covidvaccinations tables
Select *
From `CovidDeaths` dea
Join `CovidVaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date


-- looking at total population vs vaccinations	
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100)
From `CovidDeaths` dea
Join `CovidVaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


-- Using Common Table Expression
-- Finding percentage of rolling population vaccinated
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100)
From `CovidDeaths` dea
Join `CovidVaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Creating TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
	`continent` varchar(255),
	`Location` varchar(255),
	`Date` datetime,
	`Popualtion` numeric,
	`New_vaccinations` numeric,
	`RollingPeopleVaccinated` numeric
)

Insert into 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100)
From `CovidDeaths` dea
Join `CovidVaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100)
From `CovidDeaths` dea
Join `CovidVaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3

Select *
From PercentPopulationVaccinated
