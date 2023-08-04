Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccines
--Order by 3,4

--Select the data that we are using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your county

Select location, 
date, 
total_cases, 
total_deaths, 
cast(total_deaths as float) / cast(total_cases as float)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, 
date, 
total_cases, 
population, 
cast(total_cases as float) / cast(population as float)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at countries with highest infection Rate compared to population

Select 
location,  
max(total_cases) as HighestInfectionCount,
population
,Max(cast(total_cases as float)/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

-- Let's Break things down by contitnent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,case when sum(new_cases) !=0 then Sum(cast(new_deaths as int))/sum(new_cases)*100 else 0 end as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,case when sum(new_cases) !=0 then Sum(cast(new_deaths as int))/sum(new_cases)*100 else 0 end as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations

--USE CTE, created to make another column

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	on dea.location = vac.location 
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated