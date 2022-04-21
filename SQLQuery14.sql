SELECT *
FROM CovidProject..covidDeaths
WHERE continent is not null
ORDER BY 3,4;


---SELECT *
---FROM [CovidProject].[dbo].[Deaths]
---ORDER BY 1,2

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..covidDeaths
WHERE continent is  not null
ORDER BY 1,2

---Exploring Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject..covidDeaths
WHERE location like '%Nigeria%'
and continent is not null
ORDER BY 1,2

---Total cases vs Population
---Percentage of population infected
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidProject..covidDeaths
WHERE location like '%Nigeria%'
and continent is not null
ORDER BY 1,2

---Countries with highest infection rate
SELECT location, population, MAX(total_cases) as HighestinfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidProject..covidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY location, Population
ORDER BY PercentPopulationInfected desc

---Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidProject..covidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

---Breaking things down by continent
---Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidProject..covidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

---Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null 
--Group By date
ORDER BY 1,2

---Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.Date) as 
FROM CovidProject..covidDeaths dea
join CovidProject..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

---Using CTE to perform calculation on partition by 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidProject..CovidDeaths dea
Join covidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


---Using Temp Table to perform calculation on partition by 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidProject..CovidDeaths dea
Join covidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidProject..CovidDeaths dea
Join covidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 