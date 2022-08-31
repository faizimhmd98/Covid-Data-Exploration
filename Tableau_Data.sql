create database Portfolioproject;
use Portfolioproject;

select * from Portfolioproject.dbo.['CovidDeaths$'] 
where continent is not null
order by  3,4;
select * from Portfolioproject.dbo.['CovidVaccinations$'] order by  3,4;

select location , date, total_cases,new_cases,total_deaths,population from Portfolioproject.dbo.['CovidDeaths$'] order by  1,2;

--Total Cases VS Total Deaths

select location , date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRatio
from Portfolioproject.dbo.['CovidDeaths$'] 
where location like '%india%'
order by  1,2;

--Country with the highest infection rate 

select location ,population, max(total_cases) as HighestInfectionCount,max(total_deaths/total_cases)*100 as PopulationPercentInfected
from Portfolioproject.dbo.['CovidDeaths$'] 
group by location, population
order by  PopulationPercentInfected desc

-- Countries with the highest death per population
select location ,max (cast(total_deaths as int))  as TotalDeathCount
from Portfolioproject.dbo.['CovidDeaths$'] 
where continent is not null
group by location
order by  TotalDeathCount desc

--By Continent
select location ,max (cast(total_deaths as int))  as TotalDeathCount
from Portfolioproject.dbo.['CovidDeaths$'] 
where continent is null
group by location
order by  TotalDeathCount desc

--Continents wiht the highest death count per population
select location ,max (cast(total_deaths as int))  as TotalDeathCount
from Portfolioproject.dbo.['CovidDeaths$'] 
where continent is not null
group by location
order by  TotalDeathCount desc

--death percentage on global numbers
select sum(new_cases)as TotalCases,sum(cast(new_deaths as int))as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolioproject.dbo.['CovidDeaths$'] 
where continent is not null
--group by date
order by 1,2;

--Vaccinations
select * from Portfolioproject..['CovidDeaths$'] dea
join Portfolioproject..['CovidVaccinations$'] vac
on dea.location = vac.location and dea.date = vac.date;

--Total population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from Portfolioproject..['CovidDeaths$'] dea
join Portfolioproject..['CovidVaccinations$'] vac
on dea.location = vac.location and dea.date = vac.date
where (dea.continent is not null )
order by 1,2;


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint))over(partition by dea.Location order by dea.location,dea.Date)as CumulativePeopleVaccinated
from Portfolioproject..['CovidDeaths$'] dea
join Portfolioproject..['CovidVaccinations$'] vac
on dea.location = vac.location and dea.date = vac.date
where (dea.continent is not null  )
order by 2,3;


--USE CTE

with PopvsVac ( Continent,Location,Date,Population,CumulativePeopleVaccinated,new_vaccinations)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint))over(partition by dea.Location order by dea.location,dea.Date)as CumulativePeopleVaccinated
from Portfolioproject..['CovidDeaths$'] dea
join Portfolioproject..['CovidVaccinations$'] vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null  
--order by 2,3;
)
select* from PopvsVac;

with PopvsVac ( Continent,Location,Date,Population,CumulativePeopleVaccinated,new_vaccinations)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint))over(partition by dea.Location order by dea.location,dea.Date)as CumulativePeopleVaccinated
from Portfolioproject..['CovidDeaths$'] dea
join Portfolioproject..['CovidVaccinations$'] vac
on dea.location = vac.location and dea.date = vac.date
where (dea.continent is not null  )
--order by 2,3;
)
select*,(CumulativePeopleVaccinated/Population)*100
from PopvsVac;

--Temp Table

drop table if exists #PercentPopVaccinated
create table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacciantions numeric,
CumulativePeopleVaccinated numeric
)
insert into #PercentPopVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint))over(partition by dea.Location order by dea.location,dea.Date)as CumulativePeopleVaccinated
from Portfolioproject..['CovidDeaths$'] dea
join Portfolioproject..['CovidVaccinations$'] vac
on dea.location = vac.location and dea.date = vac.date
--where (dea.continent is not null  )
--order by 2,3;
select*,(CumulativePeopleVaccinated/Population)*100
from #PercentPopVaccinated;

--View for visualization

create view PercentPopVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint))over(partition by dea.Location order by dea.location,dea.Date)as CumulativePeopleVaccinated
from Portfolioproject..['CovidDeaths$'] dea
join Portfolioproject..['CovidVaccinations$'] vac
on dea.location = vac.location and dea.date = vac.date
where (dea.continent is not null  )