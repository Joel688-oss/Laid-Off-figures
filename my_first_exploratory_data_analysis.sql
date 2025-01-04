SELECT *
FROM layoffs_cuts2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_cuts2;

SELECT *
FROM layoffs_cuts2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_cuts2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_cuts2
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM layoffs_cuts2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_cuts2
GROUP BY country
ORDER BY 2 DESC;
# 2 in this code means order by the second column which is the sum of total laid off

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_cuts2;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_cuts2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
# 1 here means order by the first column which is the year column

SELECT stage, SUM(total_laid_off)
FROM layoffs_cuts2
GROUP BY stage
ORDER BY 2 DESC; 

SELECT *
FROM layoffs_cuts2;

SELECT SUBSTRING(`date`, 6,2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_cuts2
GROUP BY `MONTH`;
# under the substring, the 6 there means (in the date column, pick from the 6th item and move 2 places which will give us the month)

SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_cuts2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;
# this substring here gave us the year and month (1 to the 7th place on the substring)

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_cuts2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS Rolling_Total
FROM ROlling_Total;
#the rolling total here is used to check the months and add them all together sequentially 

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_cuts2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;



WITH Company_Year (Company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_cuts2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;
#This CTE has been used to rank the companies based on the number of staffs they laid off in each years

WITH Company_Year (Company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_cuts2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5;
# this double CTE has been used to filter the rankings to show the top 5 on the rankings, you can use it to filter the numbers you want