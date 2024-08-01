select * from coviddeaths 
order by 3,4

select * from covidvacinations 
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population  from coviddeaths
order by 1,2

#Total Cases vs Total Deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like 'Poland'
order by 1,2

#Total Cases vs Population
select Location, date, population, total_cases,(total_cases/population)*100 as TotalCasesPercent
from coviddeaths
where location like 'Poland'
order by TotalCasesPercent desc

#Highest infection vs population
select Location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
PercentPouplationInfected
from coviddeaths
group by location, population 
order by PercentPouplationInfected desc

#Highest Death Count per population
select Location, max(total_deaths) as TotaDeathCount
from coviddeaths
where continent is not null
group by location
order by TotaDeathCount desc;


#Continents with highest death count per population
select continent, max(total_deaths) as TotaDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotaDeathCount desc


#Global total_cases vs dotal_deaths
select SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths , SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from coviddeaths
#where location like 'Poland'
where continent is not null
#group by date
order by 1,2

#Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
from coviddeaths dea
join covidvacinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

#USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
from coviddeaths dea

join covidvacinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null)
select *, (RollingPeopleVaccinated/Population)*100 
from popvsvac


#TEMP TABBLE
drop table if exist PercentPopulationVaccinated

create temporary table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

ALTER TABLE PercentPopulationVaccinated
MODIFY COLUMN new_vaccinations VARCHAR(255)

ALTER TABLE PercentPopulationVaccinated
MODIFY COLUMN RollingPeopleVaccinated BIGINT

insert into PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations ) over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
from coviddeaths dea
join covidvacinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
AND vac.new_vaccinations IS NOT null

select *, (RollingPeopleVaccinated/Population)*100 
from PercentPopulationVaccinated


#Creating view for tableu
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations ) over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
from coviddeaths dea
join covidvacinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
AND vac.new_vaccinations IS NOT null
order by 2,3

select * from PercentPopulationVaccinated
