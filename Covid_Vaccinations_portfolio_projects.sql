select * from PortfolioProject..CovidDeaths
order by 3,4

--select * from PortfolioProject..CovidVaccination
--order by 3,4

select location,date, total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2


select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--Shows what % of population got covid

select location,date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by population,location
order by PercentPopulationInfected desc

--Showing the countries with Highest Death Counts per Population

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

----Lets break things down by continent

select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

---Continent with Highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


---Global numbers

select date, sum(new_cases) as total_cases, sum(CAST(new_deaths as int)) as total_deaths,
sum(CAST(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-----Total population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join 
PortfolioProject..CovidVaccination vac on 
dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
	order by 2,3


--With CTE 

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join 
PortfolioProject..CovidVaccination vac on 
dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
	--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac

---Temporary table

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join 
PortfolioProject..CovidVaccination vac on 
dea.location = vac.location
and dea.date= vac.date
--where dea.continent is not null
	--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


-- Create View to store data for late visualization

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea join 
PortfolioProject..CovidVaccination vac on 
dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
	--order by 2,3











