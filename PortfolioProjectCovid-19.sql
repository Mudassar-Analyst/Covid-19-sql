--Select * from PortfolioProject..CovidDeaths ORDER BY 3,4;
--Select * from PortfolioProject..CovidVaccinations ORDER BY 3,4;
Select * from PortfolioProject..CovidDeaths
--where continent is not NULL
 ORDER BY 1,2;





--Looking at the Total Cases vs Total Deaths
--shows likelihood of dying if you diagnosed covid in your country
Select Location, date, total_cases, total_deaths,
--(CONVERT(int, total_deaths) / (CONVERT(int, total_cases)))*100.0 as DeathPercentage 
(CAST(total_deaths as int)/CAST(total_cases as int))/100.0 as deathPercentage
from
PortfolioProject..CovidDeaths
Where location = 'Pakistan'
ORDER BY 1,2






--Looking at the Total Cases vs Population
--Shows what the percentage of population got covid
select location,date,population,total_cases,
(CONVERT(float,total_cases)/(CONVERT(float,population)))*100.0 as CovidPercentage
FROM
PortfolioProject..CovidDeaths
where location Like '%stan%' 
order by 1,2;

--Looking at countries with highest infection rate compared to population
select Location,Population,MAX(total_cases) as HighestInfectionCount,
MAX(CONVERT(float,total_cases)/(CONVERT(float,population))*100.0) as PercentPopulationInfected 
from PortfolioProject..CovidDeaths 
Group by location,population
order by PercentPopulationInfected desc;

--this gives the same answer as above Convert function gives, So no need to put convert function while
--using aggreage MAX() function
select Location,Population,MAX(total_cases) as HighestInfectionCount,
MAX(total_cases/population)*100.0 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths 
Group by location,population
order by PercentPopulationInfected desc;


--showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as INT)) as HighestDeathCount 
from PortfolioProject.dbo.CovidDeaths
where continent is not NULL
GROUP BY location
ORDER by HighestDeathCount desc;



 --Let's break things down by continent(Where continent is not NULL)
 Select continent,MAX(CAST(total_deaths as int)) as HighestDeathCount
 from PortfolioProject.dbo.CovidDeaths
 where continent is NOT NULL
 group by continent;


 
 --Let's break things down by continent(Where continent is NULL but all locations fields included in Conslusion)
 Select Location,MAX(CAST(total_deaths as int)) as HighestDeathCount
 from PortfolioProject.dbo.CovidDeaths
 where continent is  NULL
 group by Location
 Order BY HighestDeathCount desc;


 --Global Numbers
 Select date,SUM(new_cases) as total_cases,SUM(CAST(new_deaths as float)) as total_deaths, 
 SUM(CAST(new_deaths as float)) /NULLIF(SUM(new_cases),0)*100.0
 as DeathPercentage
 from PortfolioProject.dbo.CovidDeaths
 Where continent is NOT NULL
 group by date
  ORDER BY 1,2;

   --Global Numbers without including Date
 Select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as float)) as total_deaths, 
 SUM(CAST(new_deaths as float)) /NULLIF(SUM(new_cases),0)*100.0
 as DeathPercentage
 from PortfolioProject.dbo.CovidDeaths
 Where continent is NOT NULL
   ORDER BY 1,2;
   --Looking at Total Populations vs New Vaccinations
   Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
   SUM(CONVERT(bigint ,vac.new_vaccinations)) 
   OVER(partition by dea.location ORDER by dea.location,dea.date) as RollingPeopleVaccinated
   from
   PortfolioProject.dbo.CovidDeaths dea 
   join
   PortfolioProject..CovidVaccinations vac
   ON dea.date = vac.date
   AND
   dea.location = vac.location
   where dea.continent is not NULL
   ORDER by 2,3;

--CTE(Common Table Expression) creation to use the RollingPeopleVaccinated Column 

    With PopvsVac(Continent,Location,Date,Population,New_Vaccination,RollingPeopleVaccinated)
	as 
	  ( Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
   SUM(CONVERT(bigint ,vac.new_vaccinations)) 
   OVER(partition by dea.location ORDER by dea.location,dea.date) as RollingPeopleVaccinated
   from
   PortfolioProject.dbo.CovidDeaths dea 
   join
   PortfolioProject..CovidVaccinations vac
   ON dea.date = vac.date
   AND
   dea.location = vac.location
   where dea.continent is not NULL
   --ORDER by 2,3
   )

   Select * ,(RollingPeopleVaccinated/Population)/100
   from PopvsVac;


   --TEMP_Tables
   DROP TABLE if exists #PercentPopulationVaccinated   
create TABLE #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date DateTime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
 Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
   SUM(CONVERT(bigint ,vac.new_vaccinations)) 
   OVER(partition by dea.location ORDER by dea.location,dea.date) as RollingPeopleVaccinated
   from
   PortfolioProject.dbo.CovidDeaths dea 
   join
   PortfolioProject..CovidVaccinations vac
   ON dea.date = vac.date
   AND
   dea.location = vac.location
   --where dea.continent is not NULL
   --ORDER by 2,3;

     Select * ,(RollingPeopleVaccinated/Population)/100
   from #PercentPopulationVaccinated;


   --Create View to store the data for later Visualization
   Create View PercentPopulationVaccinated as
   Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
   SUM(CONVERT(bigint ,vac.new_vaccinations)) 
   OVER(partition by dea.location ORDER by dea.location,dea.date) as RollingPeopleVaccinated
   from
   PortfolioProject.dbo.CovidDeaths dea 
   join
   PortfolioProject..CovidVaccinations vac
   ON dea.date = vac.date
   AND
   dea.location = vac.location
   where dea.continent is not NULL
   --ORDER by 2,3;
   select * from PercentPopulationVaccinated;


--Table 1
 --Global Numbers without including Date
 Select SUM(new_cases) as Total_Cases,SUM(CAST(new_deaths as float)) as Total_Deaths, 
 SUM(CAST(new_deaths as float)) /NULLIF(SUM(new_cases),0)*100.0
 as DeathPercentage
 from PortfolioProject.dbo.CovidDeaths
 Where continent is NOT NULL
   ORDER BY 1,2;
 
 
 --Table 2
SELECT Location,SUM(CAST(new_deaths as int)) as TotalDeathCount 
from
PortfolioProject..CovidDeaths
WHERE continent is NULL AND location NOT in ('World','European Union','International','Low income','Lower middle income','Upper middle income','High income')
GROUP BY location
ORDER BY totalDeathCount;

--Table 3
select Location,Population,MAX(total_cases) as HighestInfectionCount,
MAX(total_cases/population)*100.0 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths 
Group by location,population
order by PercentPopulationInfected desc;

--Table 4
select Location,Population,date,MAX(total_cases) as HighestInfectionCount,
MAX(total_cases/population)*100.0 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths 
Group by location,population,date
order by PercentPopulationInfected desc;







 
