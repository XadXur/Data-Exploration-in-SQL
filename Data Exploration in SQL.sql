--Data Exploration in SQL:

Select *
From CovidDeaths$
Order by 3,4

--Select *
--From CovidVaccinations$
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
order by 1,2


-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
order by 1,2


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
WHERE Location Like '%states%'
order by 1,2


--Wildcard characters are used with the LIKE operator. 
--The LIKE operator is used in a WHERE clause to 
--search for a specified pattern in a column.

--looking at total cases vs population
--shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
From CovidDeaths$
WHERE Location Like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
PercentPopulationInfected
From CovidDeaths$
--WHERE Location Like '%states%'
Group By Location, Population
order by PercentPopulationInfected Desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--WHERE Location Like '%states%'
Where continent is not null
Group By Location
order by TotalDeathCount Desc

--lets use CAST to convert data from string to int, 
--so we can get the correct result

--n CovidDeaths file in location there are some 
--errors where locations shows Asia and continent shows Null
--so we will use Where Continent is not Null in 
--order to remove that)

--LETS BREAK THINGS DOWN BY CONTINENT 

Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--WHERE Location Like '%states%'
Where continent is not null
Group By Continent
order by TotalDeathCount Desc

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--WHERE Location Like '%states%'
Where continent is null
Group By Location
order by TotalDeathCount Desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/
SUM(new_cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null
Group by date
Order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/
SUM(new_cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null
--Group by date
Order by 1,2


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidDeaths$ as dea
Join CovidVaccinations$ as vac
--From CovidVaccinations$ as vac
--Join CovidDeaths$ dea
On dea.location = vac.location
and dea.date = vac.date
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.location)
From CovidDeaths$ as dea
Join CovidVaccinations$ as vac
--From CovidVaccinations$ as vac
--Join CovidDeaths$ dea
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From CovidDeaths$ as dea
Join CovidVaccinations$ as vac
--From CovidVaccinations$ as vac
--Join CovidDeaths$ dea
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--CTEs

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From CovidDeaths$ as dea
Join CovidVaccinations$ as vac
--From CovidVaccinations$ as vac
--Join CovidDeaths$ dea
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists  #PercentPopulationVaccinated
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
, SUM (CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From CovidDeaths$ as dea
Join CovidVaccinations$ as vac
--From CovidVaccinations$ as vac
--Join CovidDeaths$ dea
On dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations.

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From CovidDeaths$ as dea
Join CovidVaccinations$ as vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated