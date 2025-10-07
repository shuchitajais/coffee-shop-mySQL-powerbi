📊 Project Overview

This project analyzes Coffee Shop Sales Data using MySQL and visualizes the insights through an interactive Power BI Dashboard.

The goal was to track and measure key business performance metrics — Total Sales, Total Orders, and Quantity Sold — and study their Month-on-Month (MoM) growth trends.
It also provides insights into store performance, daily and hourly sales trends, and weekday vs weekend patterns, helping identify sales drivers and operational bottlenecks.

🎯 Key Features
🧮 KPI Analysis

Total Sales, Orders, and Quantity Sold for each month.

Month-on-Month Difference and Growth % in sales, orders, and quantity.

Identify monthly trends and performance variations.

📅 Calendar Heat Map

Dynamic calendar visualization for any selected month.

Color-coded daily sales with tooltips showing Sales, Orders, and Quantity.

📈 Daily Sales Trend

Line chart displaying daily sales with an average line indicator.

Highlights days exceeding or falling below average sales.

🏬 Sales by Store Location

Store-wise sales comparison with Month-on-Month growth.

Helps identify top and low-performing locations.

🕒 Sales by Day and Hour

Hourly sales heat map showing busy hours and off-peak times.

Insights into sales distribution across weekdays and weekends.

☕ Product Insights

Category-wise and Top 10 Product analysis based on sales volume.

Helps track best-selling categories and items.

🧰 Tools & Technologies Used
Tool	Purpose
MySQL	Data cleaning, transformation, and KPI calculations using SQL queries.
Power BI	Interactive dashboard design and visualization of KPIs and trends.
Excel / CSV	Initial data preparation and validation.
GitHub	Version control and project documentation.
🧑‍💻 SQL Functionalities Used

STR_TO_DATE, ROUND, SUM, COUNT, AVG, LAG, MONTH, DAY, DAYOFWEEK,
HOUR, CASE, GROUP BY, ORDER BY, WINDOW FUNCTIONS, JOINS, SUBQUERIES,
ALTER TABLE, UPDATE TABLE, CHANGE COLUMN, etc.

⚙️ Process Workflow

Data Import & Cleaning – Fixed column types, removed encoding errors.

Data Transformation – Converted date/time formats and ensured data consistency.

SQL Querying – Derived KPIs and metrics for business requirements.

Visualization – Created Power BI dashboard with slicers and dynamic visuals.

Documentation – Stored SQL scripts and Power BI file for reproducibility.
