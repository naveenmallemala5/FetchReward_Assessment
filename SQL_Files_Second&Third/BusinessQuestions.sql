-- Business Question 1: Top 5 brands by receipts scanned for the most recent month
WITH most_recent_month AS (
    -- Subquery to determine the most recent month
    SELECT recent_year, MAX(MONTH(date_scanned)) AS recent_month
    FROM FR_RECEIPT
    WHERE recent_year = (SELECT MAX(YEAR(date_scanned)) FROM FR_RECEIPT)
    GROUP BY recent_year
),
receipts_scanned_per_brand AS (
    -- Subquery to count receipts scanned per brand in the most recent month
    SELECT
        brand_name,
        COUNT(DISTINCT receipt_id) AS receipts_scanned
    FROM FR_RECEIPT
    JOIN most_recent_month ON YEAR(date_scanned) = recent_year
                            AND MONTH(date_scanned) = recent_month
    JOIN FR_RECEIPT_ITEM ON receipt_id = receipt_id
    JOIN FR_ITEM_BRAND ON itembrand_id = itembrand_id
    JOIN FR_BRAND ON brand_id = brand_id
    GROUP BY brand_name
)
-- Query to select the top 5 brands by receipts scanned
SELECT 
    brand_name
FROM (
    SELECT 
        brand_name,
        ROW_NUMBER() OVER (ORDER BY receipts_scanned DESC) AS rank
    FROM receipts_scanned_per_brand
)
WHERE rank <= 5;

-- Business Question 2: Comparison of top 5 brands by receipts scanned for recent and previous months
WITH most_recent_month AS (
    -- Subquery to determine the most recent month
    SELECT recent_year, MAX(MONTH(date_scanned)) AS recent_month
    FROM FR_RECEIPT
    WHERE recent_year = (SELECT MAX(YEAR(date_scanned)) FROM FR_RECEIPT)
    GROUP BY recent_year
),
receipts_scanned_per_brand AS (
    -- Subquery to count receipts scanned per brand in the most recent month
    -- (Same as in Query 1)
),
top_5_brand_recent_month AS (
    -- Subquery to select the top 5 brands by receipts scanned for the recent month
    -- (Same as in Query 1)
),
prev_month AS (
    -- Subquery to determine the previous month
    -- (Similar to most_recent_month, but for the previous month)
),
receipts_scanned_per_brand_prev_month AS (
    -- Subquery to count receipts scanned per brand in the previous month
    -- (Similar to receipts_scanned_per_brand, but for the previous month)
),
brand_ranks_prev_month AS (
    -- Subquery to rank brands by receipts scanned in the previous month
    -- (Similar to top_5_brand_recent_month, but for the previous month)
)
-- Query to compare rankings of top 5 brands for recent and previous months
SELECT
    brand_name,
    recent.rank AS recent_rank,
    prev.rank AS prev_rank
FROM top_5_brand_recent_month recent 
JOIN brand_ranks_prev_month prev ON recent.brand_name = prev.brand_name;

-- Business Question 3: Average spend from receipts with 'Accepted' or 'Rejected' status
SELECT
    rewards_receiptstatus,
    AVG(total_spent) AS avg_total_spent
FROM FR_RECEIPT
GROUP BY rewards_receiptstatus;

-- Business Question 4: Total number of items purchased from receipts with 'Accepted' or 'Rejected' status
SELECT
    rewards_receiptstatus,
    SUM(purchaseditem_count) AS total_purchased_items
FROM FR_RECEIPT
GROUP BY rewards_receiptstatus;

-- Business Question 5: Brand with the most spend among users created within the past 6 months
SELECT
    brand_name
FROM (
    SELECT
        brand_id,
        brand_name,
        total_spent,
        ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS rank
    FROM (
        SELECT
            brand_id,
            brand_name,
            SUM(item_count * item_price) AS total_spent 
        FROM FR_USER
        JOIN FR_RECEIPT ON user_id = user_id
        JOIN FR_RECEIPT_ITEM ON receipt_id = receipt_id
        JOIN FR_ITEM_BRAND ON itembrand_id = itembrand_id
        JOIN FR_BRAND ON brand_id = brand_id
        JOIN FR_ITEM ON item_id = item_id
        WHERE created_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
        AND created_date <= CURDATE()
        GROUP BY brand_id, brand_name
    ) AS total_spent_per_brand
) AS ranked_brands
WHERE rank = 1;

-- Business Question 6: Brand with the most transactions among users created within the past 6 months
SELECT
    brand_name
FROM (
    SELECT
        brand_id,
        brand_name,
        total_spent,
        ROW_NUMBER() OVER (ORDER BY transaction_count DESC) AS rank
    FROM (
        SELECT
            brand_id,
            brand_name,
            COUNT(DISTINCT receipt_id) AS transaction_count
        FROM FR_USER
        JOIN FR_RECEIPT ON user_id = user_id
        JOIN FR_RECEIPT_ITEM ON receipt_id = receipt_id
        JOIN FR_ITEM_BRAND ON itembrand_id = itembrand_id
        JOIN FR_BRAND ON brand_id = brand_id
        JOIN FR_ITEM ON item_id = item_id
        WHERE created_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
        AND created_date <= CURDATE()
        GROUP BY brand_id, brand_name
    ) AS transaction_count_per_brand
) AS ranked_brands
WHERE rank = 1;
