SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

------

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Shows what percentage who contracted dies of covid

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
and continent is not null 
order by 5 DESC

-- Shows what percentage contracted covid

Select Location, date, total_cases,population, (total_cases/population)*100 as TPR
From PortfolioProject..CovidDeaths
Where location like '%india%'
and continent is not null 
order by 5 DESC

-- Highest infection rate

Select Location, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null 
group by location,population
order by PercentPopulationInfected DESC

-- Showing countries with highest death count

Select Location, MAX(cast(total_deaths as int)) AS HighestDeathCount
From PortfolioProject..CovidDeaths
where continent is not null 
group by location,population
order by HighestDeathCount DESC

-- By continent

Select continent, MAX(cast(total_deaths as int)) AS HighestDeathCount
From PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by HighestDeathCount DESC

-- more accurate continent

Select location, MAX(cast(total_deaths as int)) AS HighestDeathCount
From PortfolioProject..CovidDeaths
where continent is null 
group by location
order by HighestDeathCount DESC

-- global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%india%'
where continent is not null 
--Group By date
order by 1,2

-- join

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- rolling people vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USING CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

DROP TABLE  if exists #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(continent nvarchar(255), location nvarchar(255),Date datetime,
population numeric, new_vaccinations numeric, rollingpeoplevaccinated numeric)

INSERT INTO #PERCENTPOPULATIONVACCINATED
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PERCENTPOPULATIONVACCINATED


-- creating views to store data for later


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


DROP view PercentPopulationVaccinated

