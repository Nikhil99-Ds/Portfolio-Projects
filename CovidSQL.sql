Select * from PortfolioProject.dbo.CovidDeaths
Where continent is not NULL 
order by 3,4

-- Select * from PortfolioProject..CovidVaccinations order by 3,4

-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not NULL
order by 1,2


-- Looking at Total_Cases VS Total_Deaths      /*Like how many deaths do they have for entire cases*/
-- Shows Likelihood of dying if you contract COVID in this country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location in ('India' , 'United States')
and continent is not NULL
order by 1,2


-- Looking at Total_Cases VS Population
-- Shows what percentage of Population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as CasesPopln_Percentage
from PortfolioProject..CovidDeaths
Where location in ('India' , 'United States')
order by 1,2


-- Looking at Countries with Highest Infection rates compared to Population
Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Infected_Popln_Percentage
from PortfolioProject..CovidDeaths
-- Where location in ('India','United States')
Group By location, population
order by Infected_Popln_Percentage DESC


-- Showing the Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as Death_Popln_Count
from PortfolioProject..CovidDeaths
-- Where location in ('India','United States')
Where continent is not NULL
Group By location
order by Death_Popln_Count DESC


-- Now just Break Down Data by CONTINENT
-- Showing Continents  with the Highest DeathCounts per Population
Select continent, MAX(cast(total_deaths as int)) as Death_Popln_Count
from PortfolioProject..CovidDeaths
-- Where location in ('India','United States')
Where continent is not NULL
Group By continent
order by Death_Popln_Count DESC


-- Global Numbers  By DATE
Select date, SUM(new_cases) as Ntotal_cases, SUM(cast(new_deaths as int)) as Ntotal_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercenatge_OVRLL
from PortfolioProject..CovidDeaths
-- Where location in ('India' , 'United States')
Where continent is not NULL
Group By Date
order by 1,2


-- JUST Global Numbers
Select SUM(new_cases) as Ntotal_cases, SUM(cast(new_deaths as int)) as Ntotal_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercenatge_OVRLL
from PortfolioProject..CovidDeaths
-- Where location in ('India' , 'United States')
Where continent is not NULL
-- Group By Date
order by 1,2



--- Looking at Total Population VS Vaccinations
--- Using CovidVaccinations Table   and Joining table COVDeaths and COVVaccintn
Select * 
from PortfolioProject..CovidDeaths as CDeaths
Join PortfolioProject..CovidVaccinations as CVaccinations
	On CDeaths.location = CVaccinations.location
	and CDeaths.date = CVaccinations.date


--- New Vaccinations VS Total Population
Select CDeaths.continent, CDeaths.location, CDeaths.date, CDeaths.population, CVaccinations.new_vaccinations
, SUM(cast(CVaccinations.new_vaccinations as int)) OVER (Partition By CDeaths.location Order By CDeaths.location, CDeaths.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as CDeaths
Join PortfolioProject..CovidVaccinations as CVaccinations
	On CDeaths.location = CVaccinations.location
	and CDeaths.date = CVaccinations.date
Where CDeaths.continent is not NULL
Order by 2,3 


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select CDeaths.continent, CDeaths.location, CDeaths.date, CDeaths.population, CVaccinations.new_vaccinations
, SUM(CONVERT(int,CVaccinations.new_vaccinations)) OVER (Partition by CDeaths.Location Order by CDeaths.location, CDeaths.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as CDeaths
Join PortfolioProject..CovidVaccinations as CVaccinations
	On CDeaths.location = CVaccinations.location
	and CDeaths.date = CVaccinations.date
where CDeaths.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--- TEMP TABLE

-- Using Temp Table to perform Calculation on Partition By in previous query

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


INSERT into #PercentPopulationVaccinated
Select CDeaths.continent, CDeaths.location, CDeaths.date, CDeaths.population, CVaccinations.new_vaccinations
, SUM(CONVERT(int,CVaccinations.new_vaccinations)) OVER (Partition by CDeaths.Location Order by CDeaths.location, CDeaths.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as CDeaths
Join PortfolioProject..CovidVaccinations as CVaccinations
	On CDeaths.location = CVaccinations.location
	and CDeaths.date = CVaccinations.date
where CDeaths.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select CDeaths.continent, CDeaths.location, CDeaths.date, CDeaths.population, CVaccinations.new_vaccinations
, SUM(CONVERT(int,CVaccinations.new_vaccinations)) OVER (Partition by CDeaths.Location Order by CDeaths.location, CDeaths.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as CDeaths
Join PortfolioProject..CovidVaccinations as CVaccinations
	On CDeaths.location = CVaccinations.location
	and CDeaths.date = CVaccinations.date
where CDeaths.continent is not null 
-- order by 2,3

Select * 
from PercentPopulationVaccinated
