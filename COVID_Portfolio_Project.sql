--select *
--from PortfolioProfect..CovidDeaths

--select date, new_cases, new_deaths
--from PortfolioProfect..CovidDeaths
--Where continent is not null
--order by 1,2

--select *
--from PortfolioProfect..CovidVaccinations

--select *
--from PortfolioProfect..CovidVaccinations
--order by 3, 4


-- Selecting Data that is going to be used

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying in the specific country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where location like '%ukr%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From CovidDeaths
-- Where location like '%ukr%'
-- and continent is not null
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasesPercentage
From CovidDeaths
-- Where location like '%ukr%'
-- and continent is not null
group by location, population
order by CasesPercentage DESC


-- Showing Continents with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
-- Where location like '%ukr%'
Where continent is null
group by location
order by TotalDeathCount DESC


-- Showing Countries with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
-- Where location like '%ukr%'
Where continent is not null
group by location
order by TotalDeathCount DESC


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
-- Where location like '%ukr%'
Where continent is not null
group by continent
order by TotalDeathCount DESC


-- GLOBAL NUMBERS
-- Total cases, deaths and DeathPercentage worldwide

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
From CovidDeaths
--where location like '%ukr%'
where continent is not null
--group by date
order by 1,2


-- Total cases and deaths worldwide for each date

Select date, SUM(total_cases) as total_cases, SUM(cast(total_deaths as int)) as total_death, SUM(cast(total_deaths as int))/SUM(total_cases) as DeathPercentage
From CovidDeaths
--where location like '%ukr%'
where continent is not null
group by date
order by 1,2

--Select date, location, total_cases, cast(total_deaths as int), cast(total_deaths as int)/total_cases as DeathPercentage
--From PortfolioProfect..CovidDeaths
----where location like '%ukr%'
--where continent is not null
--group by date, location, total_cases, total_deaths
--order by 1,2


-- Total Population vs Vaccinations

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_vaccinations
--, (total_vaccinations/dea.population)*100 as VaccinatedPercentage
--From PortfolioProfect..CovidDeaths dea
--Join PortfolioProfect..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_vaccinations
, (total_vaccinations/dea.population)*100 as VaccinatedPercentage
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, total_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_vaccinations
--, (total_vaccinations/dea.population)*100 as VaccinatedPercentage
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2,3
)
Select *, (total_vaccinations/Population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_vaccinations
--, (total_vaccinations/dea.population)*100 as VaccinatedPercentage
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
order by 2,3

Select *, (total_vaccinations/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_vaccinations
--, (total_vaccinations/dea.population)*100 as VaccinatedPercentage
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 1,2

Select *
from PercentPopulationVaccinated