select *
from PortfolioProject1..CovidDeaths$
where continent is not null
order by 3,4

--Select data we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths$
order by 1,2


-- Looking at total cases vs total deaths
--Shows likelihood of dying to covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at country with hightst infection rate

Select Location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths$
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--Showing countries with the highest death count

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--Breaking it down by continent

--Showing continents with highest death count


Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

Select Sum(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations
--Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopluationVaccinated
Create Table #PercentPopluationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopluationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopluationVaccinated



--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3