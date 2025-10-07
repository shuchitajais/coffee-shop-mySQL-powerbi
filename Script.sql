-- data cleaning
SELECT * FROM coffee_shop_sales;
SET SQL_SAFE_UPDATES = 0;
UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;
DESCRIBE coffee_shop_sales;
UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;
SELECT * FROM coffee_shop_sales;
ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;
ALTER TABLE coffee_shop_sales
MODIFY COLUMN unit_price DOUBLE;
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_qty INT;
ALTER TABLE coffee_shop_sales
MODIFY COLUMN product_id INT;
ALTER TABLE coffee_shop_sales
MODIFY COLUMN store_id INT;

DESCRIBE coffee_shop_sales;

-- KPI Requirements
-- Total sales for each month
SELECT ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales 
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5; -- march month 
SELECT * FROM coffee_shop_sales LIMIT 100000;

-- month on month increase or decrease in sales
WITH monthly AS (
  SELECT
    YEAR(transaction_date) AS yr,
    MONTH(transaction_date) AS mo,
    ROUND(SUM(unit_price * transaction_qty),0) AS total_sales
  FROM coffee_shop_sales
  GROUP BY YEAR(transaction_date), MONTH(transaction_date)
)
SELECT
  mo AS month,
  total_sales,
  total_sales - LAG(total_sales) OVER (PARTITION BY yr ORDER BY mo) AS mom_difference,   -- absolute change
  ROUND(
    (total_sales - LAG(total_sales) OVER (PARTITION BY yr ORDER BY mo))
    / NULLIF(LAG(total_sales) OVER (PARTITION BY yr ORDER BY mo), 0) * 100, 2
  ) AS mom_increase_percentage,                                                                     -- percent change
  CASE
    WHEN LAG(total_sales) OVER (PARTITION BY yr ORDER BY mo) IS NULL THEN 'N/A'
    WHEN total_sales > LAG(total_sales) OVER (PARTITION BY yr ORDER BY mo) THEN 'Increase'
    WHEN total_sales < LAG(total_sales) OVER (PARTITION BY yr ORDER BY mo) THEN 'Decrease'
    ELSE 'No change'
  END AS direction                                                                         -- increase / decrease label
FROM monthly
ORDER BY mo;

-- total number of orders
SELECT
  MONTH(transaction_date)     AS month,
  MONTHNAME(transaction_date) AS month_name,
  COUNT(*)                    AS total_orders
FROM coffee_shop_sales
GROUP BY MONTH(transaction_date), MONTHNAME(transaction_date)
ORDER BY MONTH(transaction_date);

-- mom inc or dec in number of order
WITH monthly_orders AS (
SELECT 
MONTH(transaction_date) AS month,
    COUNT(*) AS total_orders
  FROM coffee_shop_sales
  GROUP BY MONTH(transaction_date)
  )
  SELECT
  MONTH,total_orders, total_orders - LAG(total_orders) OVER (ORDER BY month) AS mom_difference,   -- absolute change
ROUND(
(total_orders - LAG(total_orders) OVER (ORDER BY month)) /
    NULLIF(LAG(total_orders) OVER (ORDER BY month), 0) * 100, 2
    ) AS mom_increase_percentage,                                             -- percentage change
    CASE
    WHEN LAG(total_orders) OVER (ORDER BY month) IS NULL THEN 'N/A'
  WHEN total_orders > LAG(total_orders) OVER (ORDER BY month) THEN 'Increase'
    WHEN total_orders < LAG(total_orders) OVER (ORDER BY month) THEN 'Decrease'
    ELSE 'No Change'
  END AS direction                                                                  -- increase/decrease label
FROM monthly_orders
ORDER BY month;

-- TOTAL QUANTITY SOLD
SELECT 
  MONTH(transaction_date) AS month,                   -- Month number (1 = Jan, 2 = Feb, etc.)
  MONTHNAME(transaction_date) AS month_name,          -- Month name (Jan, Feb, etc.)
  SUM(transaction_qty) AS total_quantity_sold         -- Total quantity sold in that month
FROM coffee_shop_sales
GROUP BY MONTH(transaction_date), MONTHNAME(transaction_date)
ORDER BY MONTH(transaction_date);

-- Total Quantity Sold - MoM Difference & Growth for all months
WITH monthly_qty AS (
  SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty), 0) AS total_quantity_sold      -- total quantity sold per month
  FROM coffee_shop_sales
  GROUP BY MONTH(transaction_date)
)
SELECT 
  month,
  total_quantity_sold,
  total_quantity_sold - LAG(total_quantity_sold) OVER (ORDER BY month) AS mom_difference,  -- difference from previous month
  ROUND(
    (total_quantity_sold - LAG(total_quantity_sold) OVER (ORDER BY month)) /
    NULLIF(LAG(total_quantity_sold) OVER (ORDER BY month), 0) * 100, 2
  ) AS mom_growth_pct                                                                      -- percentage growth
FROM monthly_qty
ORDER BY month;

-- Calendar Table – Daily Sales, Quantity, and Total Orders
SELECT
  transaction_date,                                             -- each date
  ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales,   -- total sales per day
  SUM(transaction_qty) AS total_quantity_sold,                  -- total quantity sold per day
  COUNT(transaction_id) AS total_orders                         -- total orders per day
FROM coffee_shop_sales
GROUP BY transaction_date                                       -- group by each date
ORDER BY transaction_date;                                      -- sorted chronologically

-- for specific day
SELECT
  ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales,
  SUM(transaction_qty) AS total_quantity_sold,
  COUNT(transaction_id) AS total_orders
FROM coffee_shop_sales
WHERE transaction_date = '2023-05-18';

-- Sales Trend Over Period (Daily)
SELECT 
  transaction_date,                                      -- each date in the period
  ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales  -- total sales per day
FROM coffee_shop_sales
WHERE transaction_date BETWEEN '2023-05-01' AND '2023-05-31'  -- filter for desired period
GROUP BY transaction_date
ORDER BY transaction_date;

-- Average daily sales for May
SELECT 
  ROUND(AVG(daily_sales), 2) AS average_daily_sales
FROM (
  SELECT 
    SUM(unit_price * transaction_qty) AS daily_sales
  FROM coffee_shop_sales
  WHERE MONTH(transaction_date) = 5
  GROUP BY transaction_date
) AS t;

-- Daily Sales for Selected Month (May)
SELECT 
  transaction_date,                                       -- each day in the month
  ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales  -- total sales per day
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5                         -- filter for May
GROUP BY transaction_date
ORDER BY transaction_date;

-- SALES BY WEEKDAY / WEEKEND (for selected month)
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'   -- 1=Sunday, 7=Saturday
        ELSE 'Weekdays'                                              -- all other days
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales       -- total sales for each category
FROM coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5                                      -- filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;
    
-- SALES BY STORE LOCATION (for selected month)
SELECT store_location,
ROUND(SUM(unit_price* transaction_qty),2) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)= 5
GROUP BY store_location                                              -- group by each store location
ORDER BY total_sales DESC;   

-- SALES BY PRODUCT CATEGORY (for selected month)
SELECT 
    product_category,                                           -- each product category
    ROUND(SUM(unit_price * transaction_qty), 1) AS total_sales  -- total sales per category (1 decimal)
FROM coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5                                 -- filter for May
GROUP BY 
    product_category                                            -- group by category
ORDER BY 
    total_sales DESC;                                           -- highest sales first
    
-- SALES BY DAY | HOUR
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,  -- total sales amount
    SUM(transaction_qty) AS total_quantity,                   -- total items sold
    COUNT(*) AS total_orders                                  -- total number of orders
FROM coffee_shop_sales
WHERE 
    DAYOFWEEK(transaction_date) = 3   -- 3 = Tuesday (1=Sun, 2=Mon, ..., 7=Sat)
    AND HOUR(transaction_time) = 8    -- hour = 8 AM
    AND MONTH(transaction_date) = 5;  -- filter for May

-- sales by hour (for May)
SELECT 
  HOUR(transaction_time) AS hour,
  ROUND(SUM(unit_price * transaction_qty)) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY HOUR(transaction_time)
ORDER BY hour;

-- SALES FROM MONDAY TO SUNDAY FOR THE MONTH OF MAY
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'     -- 2 = Monday
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'    -- 3 = Tuesday
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'  -- 4 = Wednesday
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'   -- 5 = Thursday
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'     -- 6 = Friday
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'   -- 7 = Saturday
        ELSE 'Sunday'                                          -- 1 = Sunday
    END AS day_of_week,
    
    ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales  -- total sales per weekday

FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5                               -- filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');