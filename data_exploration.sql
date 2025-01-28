-- Exploratory Data Analysis
SELECT *
FROM layoffs_staging2;

-- Total layoffs by year
SELECT MIN(`date`), MAX(`date`), COUNT(DISTINCT(country))
FROM layoffs_staging2;
/* The dataset covers a period from March 2020 to March 2023, 
providing insights into layoffs over three years and 51 countries. */

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
/*The data reveals that 2022 had the highest number of layoffs overall. 
However, considering that only three months of data are available for 2023, 
the volume of layoffs in 2023 is concerning and indicates a potentially escalating trend.*/

-- Total layoffs by company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Total layoffs by company by year
SELECT YEAR(`date`), company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`), company
ORDER BY 3 DESC;
/* The company with the highest number of layoffs in a single year is Google, 
which laid off 12,000 employees in 2023. Notably, this occurred within just three months of data recorded. 
This is followed by Meta, which laid off 11,000 employees in 2022. 
However, Google's layoffs in only three months surpass Meta's total layoffs for the entire year.*/

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


-- Total layoffs by stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Rolling Total of lay_offs by month
WITH Rolling_Total AS
(
SElECT SUBSTRING(`date`,1,7) AS `month`,SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`,total_off, SUM(total_off) OVER(ORDER BY `month`) as rolling_total
FROM Rolling_Total;

/*Layoffs have steadily increased since the beginning of the dataset, 
with major surges in 2020, late 2022, and early 2023.
By March 2023, the cumulative layoffs reached 383,159, 
with nearly 32% of the total layoffs occurring in just three months (2023).

November 2022 to February 2023 was a period of particularly high layoffs, 
suggesting external economic or sector-specific issues.
*/

-- Ranking by company, industry and year
WITH Company_Year (company, industry, years, total_laid_off) AS
(
SELECT company, industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, industry, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) as ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5
ORDER BY years;

/*In 2020, the pandemic had a significant impact on companies in the travel and transportation sectors, 
with Uber ranking first, followed by Booking and Airbnb. 
In 2021, there was more diversity across industries, indicating broader economic adjustments.
By 2022, major companies, particularly in tech and e-commerce, experienced large layoffs, a trend that continued into 2023.*/
