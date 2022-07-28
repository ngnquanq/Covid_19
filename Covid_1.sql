select *
from Covid19Project..CovidDeaths$
where continent is not null
order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
from Covid19Project..CovidDeaths$
order by 1,2

--Looking as Total Cases vs Total Deaths
--Show likelihood of dying if you contract covid in your country
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage
from Covid19Project..CovidDeaths$
where Location like '%Vietnam%'
order by 1,2

--Looking as Total Cases vs Populations
--Show what percentage of Vietnamese people caught covid
Select Location, Date, total_cases, population, (total_cases/population)*100 as Percentage
from Covid19Project..CovidDeaths$
where Location like '%Vietnam%'
order by 1,2

--Looking as Total Cases vs Populations
--Show what percentage of world's people caught covid
Select Location, Date, total_cases, population, (total_cases/population)*100 as Percentage
from Covid19Project..CovidDeaths$
order by 1,2

--Looking at Countries with Highest Infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from Covid19Project..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc

--Break things down by continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Covid19Project..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount asc

--Showing the country with the highest deathcount 
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Covid19Project..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--Showing the continent with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Covid19Project..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
Select Date, sum(new_cases) as total, SUM(cast(new_deaths as int)) as death, (1/(sum(new_cases)/SUM(cast(new_deaths as int))))*100 as deathpercentage
from Covid19Project..CovidDeaths$
where continent is not Null
group by date
order by 1,2
--Total of all over the world
Select sum(new_cases) as total, SUM(cast(new_deaths as int)) as death, (1/(sum(new_cases)/SUM(cast(new_deaths as int))))*100 as deathpercentage
from Covid19Project..CovidDeaths$
where continent is not Null
order by 1,2






--Looking at Total population vs Vaccinations


select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid19Project..CovidDeaths$ dea
join Covid19Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use with CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
--Vietnam RollingPeopleVaccinated vs population
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, (sum(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date)) as RollingPeopleVaccinated
from Covid19Project..CovidDeaths$ dea
join Covid19Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%China%'
)
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac





--Temp table


Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
--Vietnam RollingPeopleVaccinated vs population
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, (sum(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date)) as RollingPeopleVaccinated
from Covid19Project..CovidDeaths$ dea
join Covid19Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%China%'

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated




--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as 
--Vietnam RollingPeopleVaccinated vs population
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, (sum(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date)) as RollingPeopleVaccinated
from Covid19Project..CovidDeaths$ dea
join Covid19Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%China%'

