Select * from PortfolioProjects..Covid_deaths order by 3, 4
--Select * from PortfolioProjects..Covid_vaccinations order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProjects..Covid_deaths
order by 1,2

-- total cases VS total deaths

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as mortality_rate
From PortfolioProjects..Covid_deaths
Where location like '%states%'
Order by 1,2

-- Looking at total cases vs population

Select Location, date, total_cases, population, (total_cases/population)*100 as infection_rate
From PortfolioProjects..Covid_deaths
Where location like '%states%'
Order by 1,2

-- Looking at the countries with highest infection rate compared to popultaion


Select Location, MAX(total_cases) as highestinfectioncount, population, MAX(total_cases/population)*100 as infection_rate
From PortfolioProjects..Covid_deaths
group by location, population
Order by infection_rate desc

-- Showing countries with highest Death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..Covid_deaths
where continent is not NULL
group by location
Order by TotalDeathCount desc

-- Let's break down according to continent
-- Showing the continent with highest death counts
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..Covid_deaths
where continent is NULL
group by location
Order by TotalDeathCount desc

-- Breaking into Global Numbers

Select date, SUM(new_cases) totalcases, SUM(cast(New_deaths as int)) totaldeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as mortality_rate
From PortfolioProjects..Covid_deaths
Where continent is not null 
group by date
Order by 1,2

-- Looking at total population VS vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations ,
SUM(CONVERT(BIGINT,v.new_vaccinations)) over (PARTITION by D.location order by d.location,d.date) as total_vaccinationsdone
from PortfolioProjects..Covid_deaths d 
join PortfolioProjects..Covid_vaccinations v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
order by 2, 3 


-- USE CTE

with popvsvac(Continent, location, date, population, new_vaccinations, total_vaccinationsdone)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations ,
SUM(CONVERT(BIGINT,v.new_vaccinations)) over (PARTITION by D.location order by d.location,d.date) as total_vaccinationsdone
from PortfolioProjects..Covid_deaths d 
join PortfolioProjects..Covid_vaccinations v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
--order by 2, 3 
)
Select *, (total_vaccinationsdone/population)*100 
from popvsvac

-- TEMP Table
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vaccinationsdone numeric
)

Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations ,
SUM(CONVERT(BIGINT,v.new_vaccinations)) over (PARTITION by D.location order by d.location,d.date) as total_vaccinationsdone
from PortfolioProjects..Covid_deaths d 
join PortfolioProjects..Covid_vaccinations v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
--order by 2, 3 

select *, (total_vaccinationsdone/population)*100
from #PercentPopulationVaccinated


-- creating view to data store for later viz..

 create view percentpopulationvaccinated as 
 select d.continent, d.location, d.date, d.population, v.new_vaccinations ,
SUM(CONVERT(BIGINT,v.new_vaccinations)) over (PARTITION by D.location order by d.location,d.date) as total_vaccinationsdone
from PortfolioProjects..Covid_deaths d 
join PortfolioProjects..Covid_vaccinations v
on d.location = v.location 
and d.date = v.date
where d.continent is not null


