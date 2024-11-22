select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * from PortfolioProject..CovidVaccinations
order by 3,4

select location, sum(cast(new_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like 'India'
where continent is null
and location not in ('world', 'European Union', 'International')
group by location
order by totaldeathcount desc

select location, date, total_cases,new_cases,total_deaths,population 
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'India'
order by 1,2

--Looking at Total Cases vs Poplulation
--Shows what percentage of populaiton got covid

select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'India'
order by 1,2

--Looking at Countries highest infection rate vs populaiton by date

select location, date, max(total_cases) as highestinfectioncount, population, MAX((total_cases/population))*100 as Percentagepopulaitoninfected
from PortfolioProject..CovidDeaths
--where location like 'India'
group by population, location, date
order by Percentagepopulaitoninfected desc

--Looking at Countries highest infection rate vs populaiton

select location, max(total_cases) as highestinfectioncount, population, MAX((total_cases/population))*100 as Percentagepopulaitoninfected
from PortfolioProject..CovidDeaths
--where location like 'India'
group by population, location
order by Percentagepopulaitoninfected desc

--Showing Countries with Highest death count per population

select location, max(cast(total_deaths as Int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like 'India'
group by population, location
order by TotalDeathCount desc

--Looking from continent perspective

select continent , max(cast(total_deaths as Int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like 'India'
group by continent
order by TotalDeathCount desc

-- Global numbers

select sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location like 'India'
--group by continent
order by 1,2

-- Total population got vaccinated

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 -- Using CTE
with popvac (Continent,location,date,popluation,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select * , (rollingpeoplevaccinated/popluation)*100
 from popvac


 --temp table 

--drop table #Percentagepopulationvaccinated

create table #Percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
+
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #Percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
-- where dea.continent is not null
 --order by 2,3

 
 select *, (rollingpeoplevaccinated/population)*100 
 from #Percentagepopulationvaccinated


 -- Creating View

create view Percentagepopulationvaccinated as

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 --order by 2,3


 select * from Percentagepopulationvaccinated