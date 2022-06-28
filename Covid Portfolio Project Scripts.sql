-- Confirm that data import was successful
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
Order By 3,4

-- Select the data to be used

Select location, date, total_cases, new_cases, total_cases, population
From PortfolioProject..CovidDeaths
Order By 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Nigeria'
and continent is not null
Order By 1,2 

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date,  population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
-- Where location = 'Nigeria'
Order By 1,2


-- Looking at Highest Infection Count compared to Population per Country

Select location,  population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
-- Where location = 'Nigeria'
Group By Location, Population
Order By PercentagePopulationInfected desc


-- Showing the Highest Death Count compared to Population per Country
Select location, MAX(Cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
-- Where location = 'Nigeria'
Where continent is not null
Group By Location
Order By HighestDeathCount desc


-- Let's break things down by continent

-- Showing the highest death count compared to population per Continent

Select continent, MAX(Cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
-- Where location = 'Nigeria'
Where continent is not null
Group By continent
Order By HighestDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, (SUM(Cast(new_deaths as int))/SUM(new_cases)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location = 'Nigeria'
Where continent is not null
--Group By date
Order By 1,2 




-- Looking at total population vs new vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- Looking at total population vs new vaccinations, increasing on a rolling per population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingSumofPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
-- Creating a CTE inorder to make use of RollingSumofPeopleVaccinated column that was created above
-- Looking at Percentage of RollingSumofPeopleVaccinated vs Population

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingSumofPeopleVaccinated)
as  
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingSumofPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)

Select *, (RollingSumofPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinatedvsPopulation
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingSumofPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingSumofPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *, (RollingSumofPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinatedvsPopulation
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingSumofPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

-- Query our PercentPopulationVaccinated View
Select *
From PercentPopulationVaccinated


-- MORE VIEWS

-- Creating a view to showing the Highest Death Count compared to Population per Country
Create View HighestDeathCountPerLocation as
Select location, MAX(Cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
-- Where location = 'Nigeria'
Where continent is not null
Group By Location
-- Order By HighestDeathCount desc

-- Query our HighestDeathCountPerLocation View
Select *
From HighestDeathCountPerLocation



Create View HighestDeathCountPerContinent as
Select continent, MAX(Cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
-- Where location = 'Nigeria'
Where continent is not null
Group By continent
-- Order By HighestDeathCount desc

-- Query the HighestDeathCountPerContinent View
Select *
From HighestDeathCountPerContinent