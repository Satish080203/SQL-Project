create database portfolioproject;
use portfolioproject;
select * from coviddeaths;
select * from covidvaccinations;
select location,date,total_cases,new_cases,total_deaths,population from coviddeaths order by 1,2 ;
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage from coviddeaths where location="Afghanistan"  order by 1,2;
select location,date,total_cases,population,(total_cases/population)*100 as percentofpopulation from coviddeaths where location="Afghanistan"  order by 1,2;
select location,population,max(total_cases) as highestcount,max((total_deaths/population))*100 as percentageofpopulationinfected from coviddeaths group by location,population  order by percentageofpopulationinfected desc;
select location, max(total_deaths ) as totaldeathcount from coviddeaths group by location order by totaldeathcount desc;
select * from coviddeaths where continent is not null;
select continent,max(total_deaths) as totaldeathcount from coviddeaths where continent is not null group by continent order by totaldeathcount desc;
select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,sum(new_deaths)/sum(new_cases)*100 as deathpercentage from coviddeaths where continent is not null order by 1,2;
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations from coviddeaths as dea join covidvaccinations as vac on dea.location=vac.location and dea.date=vac.date where dea.continent is not null order by 1,2;
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated  from coviddeaths as dea join covidvaccinations as vac on dea.location=vac.location and dea.date=vac.date where dea.continent is not null order by 1,2;
with popvsvac (continent,location,date,population,new_vaccination,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated  from coviddeaths as dea join covidvaccinations as vac on dea.location=vac.location and dea.date=vac.date where dea.continent is not null 
)
select * ,(rollingpeoplevaccinated/population)*100 from popvsvac;

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
);

insert into PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated  from coviddeaths as dea join covidvaccinations as vac on dea.location=vac.location and dea.date=vac.date where dea.continent is not null;

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;
