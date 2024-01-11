update CovidDeaths
Set total_deaths = Round (( new_deaths_smoothed_per_million)*1000,2)

update CovidDeaths
Set total_deaths = CAST (Round (total_cases/6, 0) as INT);
--select total_deaths from PortfolioProject..CovidDeaths
Select Date, Location, total_cases, total_deaths from PortfolioProject..CovidDeaths
where Location like '%America%'
order by 1,2

update CovidDeaths
Set total_deaths_per_million = ( total_deaths/population)*1000

-- total cases/  total deaths
--shows likelihood of dying if you in contract covid in country
Select Date, Location, total_cases, total_deaths, ((total_deaths/total_cases)*100) as deathspercent from PortfolioProject..CovidDeaths
where total_cases > 0 and Location like '%jap%'
order by 1,2

--total cases vs population


Select Date, Location, total_cases, population, (total_cases/population)*100 as Population_affected  from PortfolioProject..CovidDeaths
where total_cases > 0 and Location like '%north%'
order by 1,2


---highest infected countries wrt population
Select Location,population, Max(total_cases) as highest_infectionrate,  Max((total_cases/population)*100) as Population_percent_affected  from PortfolioProject..CovidDeaths
where total_cases > 0 and Location like '%%'
group by location, population
order by Population_percent_affected DESC


---highest death count per population



Select Location, Max(total_deaths) as highest_deaths  from PortfolioProject..CovidDeaths
where total_cases > 0 and continent is not null --and Location like '%%'
group by location, population
order by highest_deaths DESC


-- by continent
Select continent, Max(cast(total_deaths as int)) as highest_deaths  from PortfolioProject..CovidDeaths
where continent is not null --and Location like '%w%'
group by continent
order by highest_deaths DESC

--showing continent with highest death count
Select continent, Max(cast(total_deaths as int)) as highest_deaths  from PortfolioProject..CovidDeaths
where continent is not null --and Location like '%w%'
group by continent
order by highest_deaths DESC



--global numbers

select  sum(cast(new_cases as int)) as total_newcases, sum(cast(new_deaths as int)) as total_newdeaths, 
sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 as new_deathpercent
from PortfolioProject..CovidDeaths
where continent is not null --and Location like '%w%'
order by 1,2 

update CovidDeaths
Set new_deaths = ( cast(new_Cases*.021 as Int))

select new_deaths from PortfolioProject..CovidDeaths


select  sum(cast(new_cases as int)) as total_newcases, sum(cast(new_deaths as int)) as total_newdeaths, 
sum(cast(new_deaths as int))/sum(new_cases) *100 as new_deathpercent
from PortfolioProject..CovidDeaths
where continent is not null --and Location like '%w%'
order by 1,2 



--join-- population/vaccination


select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac. location 
and dea.date = vac. date
where dea.continent is not null  
order by new_vaccinations DESC

-----------
update CovidVaccinations
set new_vaccinations = CovidDeaths.population * 0.02
from PortfolioProject..CovidVaccinations
join CovidDeaths on CovidVaccinations.location = CovidDeaths.location

update CovidVaccinations
set new_vaccinations = cast( cast(new_vaccinations as float) as int)
select new_vaccinations from PortfolioProject..CovidVaccinations


-----------------total population vs vaccination--CTE--

WITH Popvsvac (continent, location, date, population, new_vaccination, total_vaccinations)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations
    FROM
        PortfolioProject..CovidDeaths dea
    JOIN
        PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
SELECT *
FROM Popvsvac;


----TEMP---
drop table if exists #percentpopvac
create table #percentpopvac
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccination numeric,
rollingvac numeric
)

Insert into #percentpopvac
SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingvac
    FROM
        PortfolioProject..CovidDeaths dea
    JOIN
        PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL


		select *, (rollingvac/population)*100
		from #percentpopvac




