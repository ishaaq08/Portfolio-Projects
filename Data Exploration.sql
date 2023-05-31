
select *
from PortProj2..CovidDeaths$
where continent is not null
order by 3,4;

--select *
--from PortProj2..CovidVaccinations$
--order by 3,4;

-- Select data that we are going to be using 

select location, date, total_cases	, new_cases, total_deaths, population
from PortProj2..CovidDeaths$
order by 1,2;


-- Looking at the total cases vs total deaths
-- Shows the likelihood of dying if you contract COVID in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortProj2..CovidDeaths$
order by 1,2;


-- Looking at the total cases vs the population 
-- Shows what percentage got covid

select location, date, total_cases, population, (total_cases/population)*100 as 'Percent of Population Infected'
from PortProj2..CovidDeaths$
where location like '%states%'
order by location;


-- Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as 'Highest Infection Count', MAx((total_cases/population))*100 as 'Percent of Population Infected'
from PortProj2..CovidDeaths$
-- where location like '%states%'
group by population, location
order by 'Percent of Population Infected' desc


-- Showing countries with the highest death count per population 

select location, max(cast(total_deaths as int)) as 'Total Death Count'
from PortProj2..CovidDeaths$
where continent is not null
group by location
order by 'Total Death Count' desc;

-- Showing the continents with the highest death count 
-- LET'S BREAK THINGS DOWn BY CONTINENT 

select location, max(cast(total_deaths as int)) as 'Total Death Count'
from PortProj2..CovidDeaths$
where continent is null
group by location
order by 'Total Death Count' desc;

-- TESTING 

select date, new_deaths, total_deaths, total_cases
from PortProj2..CovidDeaths$;


select sum(cast(new_deaths as int)) as NewDeaths, sum(cast(total_deaths as int)) as TotalDeaths
from PortProj2..CovidDeaths$
--where continent is not null

-- Total Number of Deaths in Each Country 
-- Also confirming new_deaths calculation 

select location, max(cast(total_deaths as int)) as 'Total Deaths', sum(cast(new_deaths as int)) as 'Aggregate of New Deaths'
from PortProj2..CovidDeaths$
where continent is not null
group by location
order by 'Total Deaths' desc;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortProj2..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- Total amount of people in the world that have been vaccinated
-- sum of populations 
-- sum of vaccinations 

select dea.location, max(population) as Population, sum(cast(new_vaccinations as int)) as TotalVac, 
sum(cast(new_vaccinations as int))/max(population)*100 as PercentageVaccinated
from PortProj2..CovidDeaths$ as dea
join PortProj2..CovidVaccinations$ as vac
on vac.location = dea.location 
and vac.date = dea.date
where dea.continent is not null
group by dea.location
order by PercentageVaccinated desc;

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortProj2..CovidDeaths$ dea
Join PortProj2..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- CTE 
-- CTE and Temp table are 2 means to achieve the same result 
-- Essentially it allows us to use the resulting table in calculations


with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortProj2..CovidDeaths$ dea
Join PortProj2..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP Table 
-- See previous comment for more information

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortProj2..CovidDeaths$ dea
Join PortProj2..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated;


-- VIEW

use PortProj2

go

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortProj2..CovidDeaths$ dea
Join PortProj2..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
-- order by 2,3

go

select * 
from PercentPopulationVaccinated

