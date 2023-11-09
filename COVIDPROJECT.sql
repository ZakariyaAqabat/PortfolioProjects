Select*
From PortfolioProject..CovidDeaths
Where continent is not Null
order by 3,4

--Select*
--From PortfolioProject..CovidVaccination
--order by 3,4

Select location, date,total_cases,new_cases,total_cases,population,total_deaths
From PortfolioProject..CovidDeaths
order by 1,2

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%germany%'
order by 1,2

--looking at Total cases vs population

Select Location, date, total_cases, population, (CONVERT(float, total_cases) / population)*100 as PrecentPopulationInfection
From PortfolioProject..CovidDeaths
Where location like '%germany%'
order by 1,2

--looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighInfectionCount, (MAX(total_cases/ population))*100 as PrecentPopulationInfection
From PortfolioProject..CovidDeaths
Where continent is not Null
group by Location, population
order by PrecentPopulationInfection desc

--looking at countries with highest death count compared to population

Select Location, MAX(cast(total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not Null
group by Location
order by TotalDeathCount desc

-- Breaking it down by continent


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not Null
group by continent
order by TotalDeathCount desc

--Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,COALESCE(SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0),0)*100 as DeathPrecentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac(Continent,location, Date , Population, new_vaccinations,RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

