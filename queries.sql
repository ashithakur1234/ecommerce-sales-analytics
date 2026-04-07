USE superstore_db;
-- 1. BUSINESS KPIs (Total Revenue, Profit, Margin)
SELECT 
    ROUND(SUM(CAST(sales AS DECIMAL(10,2))), 2)     AS total_revenue,
    ROUND(SUM(CAST(profit AS DECIMAL(10,2))), 2)    AS total_profit,
    COUNT(DISTINCT order_id)                        AS total_orders,
    COUNT(DISTINCT customer_id)                     AS total_customers,
    ROUND((SUM(CAST(profit AS DECIMAL(10,2))) / SUM(CAST(sales AS DECIMAL(10,2)))) * 100, 2) AS profit_margin
FROM clean_superstore;  

-- 2. YEARLY PERFORMANCE
SELECT 
    year,
    ROUND(SUM(CAST(sales AS DECIMAL(10,2))), 2)   AS total_sales,
    ROUND(SUM(CAST(profit AS DECIMAL(10,2))), 2)  AS total_profit,
    COUNT(DISTINCT order_id)                      AS total_orders
FROM clean_superstore
GROUP BY year
ORDER BY year;  

-- 3. CATEGORY & LOSS ANALYSIS
-- Which category makes most revenue?
SELECT 
    category, 
    ROUND(SUM(CAST(sales AS DECIMAL(10,2))), 2)   AS total_sales,
    ROUND(SUM(CAST(profit AS DECIMAL(10,2))), 2)  AS total_profit,
    ROUND((SUM(CAST(profit AS DECIMAL(10,2)))/SUM(CAST(sales AS DECIMAL(10,2)))) * 100, 2) AS profit_margin
FROM clean_superstore
GROUP BY category
ORDER BY total_sales DESC;  

-- Products that are actually losing money (Top 10 Losses)
SELECT 
    product_name,
    category,
    ROUND(SUM(CAST(profit AS DECIMAL(10,2))), 2) AS total_loss
FROM clean_superstore
GROUP BY product_name, category
HAVING total_loss < 0
ORDER BY total_loss ASC
LIMIT 10;  

-- 4. REGIONAL & STATE INSIGHTS
SELECT 
    region, 
    state,
    ROUND(SUM(CAST(sales AS DECIMAL(10,2))), 2)   AS total_sales,
    ROUND(SUM(CAST(profit AS DECIMAL(10,2))), 2)  AS total_profit
FROM clean_superstore
GROUP BY region, state
ORDER BY total_sales DESC
LIMIT 15;  

-- 5. DISCOUNT IMPACT
SELECT 
    CASE 
        WHEN CAST(discount AS DECIMAL(10,2)) = 0 THEN 'No Discount'
        WHEN CAST(discount AS DECIMAL(10,2)) <= 0.2 THEN 'Low (0-20%)'
        WHEN CAST(discount AS DECIMAL(10,2)) <= 0.5 THEN 'Medium (20-50%)'
        ELSE 'High (50%+)'
    END AS discount_bracket,
    COUNT(*) AS total_orders,
    ROUND(AVG(CAST(profit AS DECIMAL(10,2))), 2) AS avg_profit_per_order
FROM clean_superstore
GROUP BY discount_bracket
ORDER BY avg_profit_per_order DESC;  

-- 6. ADVANCED: MONTH OVER MONTH GROWTH
SELECT 
    year, 
    month, 
    ROUND(SUM(CAST(sales AS DECIMAL(10,2))), 2) AS monthly_sales,
    ROUND(LAG(SUM(CAST(sales AS DECIMAL(10,2)))) OVER (ORDER BY year, month), 2) AS prev_month_sales,
    ROUND(SUM(CAST(sales AS DECIMAL(10,2))) - LAG(SUM(CAST(sales AS DECIMAL(10,2)))) OVER (ORDER BY year, month), 2) AS diff_from_last_month
FROM clean_superstore
GROUP BY year, month
ORDER BY year, month;   

-- 7. the Sub-Categories where we are LOSING the most money

SELECT 
    category, 
    `sub-category`,  -- Changed to backticks and hyphen
    ROUND(SUM(CAST(profit AS DECIMAL(10,2))), 2) AS total_profit,
    ROUND(AVG(CAST(discount AS DECIMAL(10,2))) * 100, 2) AS avg_discount_pct
FROM clean_superstore
GROUP BY category, `sub-category`
HAVING total_profit < 0
ORDER BY total_profit ASC;  