SELECT *
FROM layoffs;

# STEP 1!
# create a duplicate table first

CREATE TABLE layoffs_cuts
LIKE layoffs;

INSERT layoffs_cuts
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_cuts;

# due to the fact that there is no id number for this dataset, dropping duplicates would need partition first to assign row numbers to them and then dropping duplicates through CTE

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_cuts;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_cuts
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

# only one company came up, so to doublecheck, check the company to make sure the values are truly duplicate
SELECT *
From layoffs_cuts
WHERE company = 'Oyster';

# IN SQL workbench, you cant update the partition statement to delete the duplicates, so go to the tables and copy to the clipboard the create statement
# then add the row_num column to it as an INT

CREATE TABLE `layoffs_cuts2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_cuts2;

INSERT INTO layoffs_cuts2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_cuts;

DELETE
FROM layoffs_cuts2
WHERE row_num > 1;

SELECT *
FROM layoffs_cuts2;

#STEP 2!
#Standardizing data -- This is basicaslly removing extra spaces and other cleanups.

SELECT company, TRIM(company)
FROM layoffs_cuts2;

UPDATE layoffs_cuts2
SET company = TRIM(company);

SELECT DISTINCT(Industry)
FROM layoffs_cuts2
ORDER BY 1;

SELECT DISTINCT(Location)
FROM layoffs_cuts2
ORDER BY 1;

SELECT DISTINCT(Country)
FROM layoffs_cuts2
ORDER BY 1;

# United States has an error as there is one with a full stop at the end so you have to group it all
# you can easily use TRIM Trailing which takes out an item at the end of the words that are not needed.

SELECT *
FROM layoffs_cuts2
WHERE country LIKE 'United States%'
ORDER BY 1;

SELECT DISTINCT(Country), TRIM(TRAILING '.' FROM Country)
FROM layoffs_cuts2
ORDER BY 1;

UPDATE layoffs_cuts2
SET country = TRIM(TRAILING '.' FROM Country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_cuts2;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_cuts2;

UPDATE layoffs_cuts2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

# after doing this, you would need to alter the entire date column from a text format into a date format
ALTER TABLE layoffs_cuts2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_cuts2;

#STEP 3 
# dropping null and blank values

SELECT *
FROM layoffs_cuts2
WHERE industry is NULL
OR industry = '';

SELECT *
FROM layoffs_cuts2
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;


DELETE
FROM layoffs_cuts2
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;


SELECT *
FROM layoffs_cuts2;

# this is used to drop a column from the table
ALTER TABLE layoffs_cuts2
DROP COLUMN row_num;

