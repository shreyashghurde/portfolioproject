



                                    ---files for the projects
select*
from portfolioproject.dbo.CovidDeaths$
order by 3,4

select*
from portfolioproject.dbo.CovidVaccinations$
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject.dbo.CovidDeaths$
order by 1,2


--looking at total cases vs total death 
--rough Estimate of data of dying if you contract covid in india
select location,date,total_cases,total_deaths,(total_deaths/total_cases*100) as death_percentage
from portfolioproject.dbo.CovidDeaths$
where location like '%india%' 
order by 1,2

--looking at total cases vs populations
--shows that percentage of population by covid in india
select location,date,population,total_cases,(total_cases/population*100) as percentage
from portfolioproject.dbo.CovidDeaths$
where location like '%india%' 
order by 1,2


--looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as maximum_cases,MAX((total_cases/population*100)) as infectionpercentage 
from portfolioproject.dbo.CovidDeaths$
--where location like '%india%' 
group by population,location
order by  infectionpercentage desc


--countries with highest death_count per population 
 select location,MAX(cast(total_deaths as int)) as highdeath_count,MAX((total_deaths/population*100)) as death_percentage,MAX((total_cases/population*100)) as infectionpercentage 
from portfolioproject.dbo.CovidDeaths$
----where location like '%india%' 
group by location
order by highdeath_count desc


--ACCORDING TO CONTINENT 
 select continent, MAX(cast(total_deaths as int)) as highdeath_count,MAX((total_deaths/population*100)) as death_percentage
from portfolioproject.dbo.CovidDeaths$
----where location like '%india%' 
where continent is not null
group by continent
order by highdeath_count desc
  

--global numbers 


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From portfolioproject.dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--looking at total population vs vaccination

select dth.continent,dth.location,dth.date, dth.population,vct.new_vaccinations ,
SUM(cast (vct.new_vaccinations as int))over (partition by dth.location order by dth.location,dth.date) as rolling_people_vaccination
from portfolioproject.dbo.CovidDeaths$ as dth
join portfolioproject.dbo.CovidVaccinations$ vct
on dth.location=vct.location and
dth.date=vct.date
where dth.continent is not null 
 --and dth.location like '%india%'
 -- --group by dth.continent,dth.date
order by 2,3


--USE CTE
  with PopvsVac(continent ,location,date,population,new_vaccinations,rolling_people_vaccination)
  as
(
select dth.continent,dth.location,dth.date, dth.population,vct.new_vaccinations ,
SUM(cast (vct.new_vaccinations as int))over (partition by dth.location order by dth.location,dth.date) as rolling_people_vaccination
from portfolioproject.dbo.CovidDeaths$ as dth
join portfolioproject.dbo.CovidVaccinations$ vct
on dth.location=vct.location and
dth.date=vct.date
where dth.continent is not null 
 --and dth.location like '%india%'
 -- --group by dth.continent,dth.date
--order by 2,3
)
select (rolling_people_vaccination/population)*100
from PopvsVac


--using Temptable 

DROP Table if exists #percentpoppulationvaccinated
create table #percentpoppulationvaccinated
(continent nvarchar(255),location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,
rolling_people_vaccination numeric)

insert into #percentpoppulationvaccinated
select dth.continent,dth.location,dth.date, dth.population,vct.new_vaccinations ,
SUM(cast (vct.new_vaccinations as int))over (partition by dth.location order by dth.location,dth.date) as rolling_people_vaccination
from portfolioproject.dbo.CovidDeaths$ as dth
join portfolioproject.dbo.CovidVaccinations$ vct
on dth.location=vct.location and
dth.date=vct.date
where dth.continent is not null 
 --and dth.location like '%india%'
 -- --group by dth.continent,dth.date
--order by 2,3
select (rolling_people_vaccination/population)*100
from #percentpoppulationvaccinated


--creating view to store data in visualization 


Create View percentpoppulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioproject.dbo.CovidDeaths$ dea
Join portfolioproject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 















 