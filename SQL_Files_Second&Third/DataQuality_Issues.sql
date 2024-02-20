-- User Table: Identify rows with missing values in last_login, state, or Signupsource fields
SELECT *
FROM User
WHERE last_login IS NULL OR state IS NULL OR Signupsource IS NULL;

-- Brand Table: Identify rows with missing values in brand_code
SELECT *
FROM Brand
WHERE brand_code IS NULL;

-- Brand Table: Identify rows with missing values in top_brand indicator
SELECT *
FROM Brand
WHERE top_brand IS NULL;

-- Category Table: Identify rows with missing values in category_code
SELECT *
FROM Category
WHERE category_code IS NULL;

-- Category Table: Identify rows with missing values in category_name
SELECT *
FROM Category
WHERE category_name IS NULL;

-- Category Table: Identify rows with missing values in category_code or category_name
SELECT *
FROM Category
WHERE category_code IS NULL OR category_name IS NULL;

-- Receipt Table: Identify rows with missing values in critical fields
SELECT *
FROM Receipt
WHERE bonuspoints_earned IS NULL
   OR bonuspoints_earnedreason IS NULL
   OR finished_date IS NULL
   OR pointsawarded_date IS NULL
   OR total_spent IS NULL
   OR purchaseditem_count IS NULL
   OR points_earned IS NULL
   OR purchase_date IS NULL;


-- Detecting Duplicates:
-- This query identifies duplicate entries in the Receipt table based on the receipt_id field.
SELECT receipt_id, COUNT(*)
FROM Receipt
GROUP BY receipt_id
HAVING COUNT(*) > 1;

-- Checking for Inconsistent Data Types:
-- This query checks if the purchase_date field contains inconsistent data types, such as non-date values.
SELECT *
FROM Receipt
WHERE NOT ISDATE(purchase_date);

-- Identifying Outliers in Numeric Fields:
-- This query identifies receipts with negative values in numeric fields like total_spent, purchaseditem_count, or points_earned.
SELECT *
FROM Receipt
WHERE total_spent < 0 OR purchaseditem_count < 0 OR points_earned < 0;
