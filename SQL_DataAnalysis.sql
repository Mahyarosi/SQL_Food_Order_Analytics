SELECT * 
FROM swiggy_data;

-- Data validation & cleaning
-- Null check
SELECT
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restuarant_name,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
    SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price_inr,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy_data;

-- Blank or empty strings
SELECT *
FROM swiggy_data
WHERE
    State = '' 
    OR City = '' 
    OR Location = '' 
    OR Restaurant_Name = '' 
    OR Category = '' 
    OR Dish_Name = '';

-- Duplicate detection
SELECT
    State, City, Order_Date, Restaurant_Name, Location, Category,
    Dish_Name, Price_INR, Rating, Rating_Count,
    COUNT(*) AS CNT
FROM swiggy_data
GROUP BY
    State, City, Order_Date, Restaurant_Name, Location, Category,
    Dish_Name, Price_INR, Rating, Rating_Count
HAVING COUNT(*) > 1;

-- Delete duplication
WITH CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY
                State, City, Order_Date, Restaurant_Name, Location, Category,
                Dish_Name, Price_INR, Rating, Rating_Count
            ORDER BY (SELECT NULL)
        ) AS rn
    FROM swiggy_data
)
DELETE FROM CTE WHERE rn > 1;

-- Creating schema
-- Dimension tables
-- Date table
CREATE TABLE dim_date (
    Date_Id INT IDENTITY(1, 1) PRIMARY KEY,
    Full_Date DATE,
    Year INT,
    Month INT,
    Month_Name VARCHAR(50),
    Quarter INT,
    Day INT,
    Week INT
);

CREATE TABLE dim_location (
    Location_Id INT IDENTITY(1, 1) PRIMARY KEY,
    State VARCHAR(100),
    City VARCHAR(100),
    Location VARCHAR(200)
);

CREATE TABLE dim_restaurant (
    Restaurant_Id INT IDENTITY(1, 1) PRIMARY KEY,
    Restaurant_Name VARCHAR(200)
);

CREATE TABLE dim_category (
    Category_Id INT IDENTITY(1, 1) PRIMARY KEY,
    Category VARCHAR(200)
);

CREATE TABLE dim_dish (
    Dish_Id INT IDENTITY(1, 1) PRIMARY KEY,
    Dish_Name VARCHAR(200)
);

-- Fact Table
CREATE TABLE fact_swiggy_orders (
    Order_Id INT IDENTITY(1, 1) PRIMARY KEY,
    Date_Id INT,
    Price_INR DECIMAL(10, 2),
    Rating DECIMAL(4, 2),
    Rating_Count INT,
    Location_Id INT,
    Restaurant_Id INT,
    Category_Id INT,
    Dish_Id INT,
    FOREIGN KEY (Date_Id) REFERENCES dim_date(Date_Id),
    FOREIGN KEY (Location_Id) REFERENCES dim_location(Location_Id),
    FOREIGN KEY (Restaurant_Id) REFERENCES dim_restaurant(Restaurant_Id),
    FOREIGN KEY (Category_Id) REFERENCES dim_category(Category_Id),
    FOREIGN KEY (Dish_Id) REFERENCES dim_dish(Dish_Id)
);

-- Insert data in tables
-- dim_date
INSERT INTO dim_date (Full_Date, Year, Month, Month_Name, Quarter, Day, Week)
SELECT DISTINCT
    Order_Date,
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH, Order_Date),
    DATEPART(Quarter, Order_Date),
    DAY(Order_Date),
    DATEPART(WEEK, Order_Date)
FROM swiggy_data
WHERE Order_Date IS NOT NULL;

-- dim_location
INSERT INTO dim_location (State, City, Location)
SELECT DISTINCT
    State,
    City,
    Location
FROM swiggy_data;

-- dim_restaurant
INSERT INTO dim_restaurant (Restaurant_Name)
SELECT DISTINCT
    Restaurant_Name
FROM swiggy_data;

-- dim_category
INSERT INTO dim_category (Category)
SELECT DISTINCT
    Category
FROM swiggy_data;

-- dim_dish
INSERT INTO dim_dish (Dish_Name)
SELECT DISTINCT
    Dish_Name
FROM swiggy_data;

-- fact table
INSERT INTO fact_swiggy_orders (
    Date_Id,
    Price_INR,
    Rating,
    Rating_Count,
    Location_Id,
    Restaurant_Id,
    Category_Id,
    Dish_Id
)
SELECT
    dd.Date_Id,
    s.Price_INR,
    s.Rating,
    s.Rating_Count,
    dl.Location_Id,
    dr.Restaurant_Id,
    dc.Category_Id,
    dsh.Dish_Id
FROM swiggy_data s
JOIN dim_date dd ON dd.Full_Date = s.Order_Date
JOIN dim_location dl ON dl.State = s.State AND dl.City = s.City AND dl.Location = s.Location
JOIN dim_restaurant dr ON dr.Restaurant_Name = s.Restaurant_Name
JOIN dim_category dc ON dc.Category = s.Category
JOIN dim_dish dsh ON dsh.Dish_Name = s.Dish_Name;

SELECT *
FROM fact_swiggy_orders f
JOIN dim_date d ON f.Date_Id = d.Date_Id
JOIN dim_location l ON f.Location_Id = l.Location_Id
JOIN dim_category c ON f.Category_Id = c.Category_Id
JOIN dim_restaurant r ON f.Restaurant_Id = r.Restaurant_Id
JOIN dim_dish di ON f.Date_Id = di.Dish_Id;

-- KPIs
-- Total orders
SELECT COUNT(*) AS Total_Orders
FROM fact_swiggy_orders;

-- Total revenue
SELECT
    FORMAT(SUM(CONVERT(FLOAT, Price_INR)) / 1000000, 'N2') + 'INR Million' AS Total_Revenue
FROM fact_swiggy_orders;

-- Average Rating
SELECT
    AVG(Rating) AS Avg_Rating
FROM fact_swiggy_orders;

-- Deep-Dive business analysis
-- Monthly order trends
SELECT
    d.Year,
    d.Month,
    d.Month_Name,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.Date_Id = d.Date_Id
GROUP BY
    d.Year,
    d.Month,
    d.Month_Name;

-- Orders by day of week (MON–SUN)
SELECT
    DATENAME(WEEKDAY, d.Full_Date) AS day_name,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.Date_Id = d.Date_Id
GROUP BY
    DATENAME(WEEKDAY, d.Full_Date),
    DATEPART(WEEKDAY, d.Full_Date)
ORDER BY DATEPART(WEEKDAY, d.Full_Date);

-- Top 10 cities by order volume
SELECT TOP 10
    l.City,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_location l ON l.Location_Id = f.Location_Id
GROUP BY l.City
ORDER BY COUNT(*) DESC;

-- Revenue contribution by states
SELECT
    l.State,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_location l ON l.Location_Id = f.Location_Id
GROUP BY l.State
ORDER BY COUNT(*) DESC;

-- Top restaurants by orders
SELECT
    r.Restaurant_Name,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_restaurant r ON r.Restaurant_Id = f.Restaurant_Id
GROUP BY r.Restaurant_Name
ORDER BY COUNT(*) DESC;

-- Top categories by order volume
SELECT
    c.Category,
    COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_category c ON f.Category_Id = f.Category_Id
ORDER BY Total_Orders DESC;

-- Total Orders by Price Range
SELECT
    CASE
        WHEN TRY_CAST(price_inr AS FLOAT) < 100 THEN 'Under 100'
        WHEN TRY_CAST(price_inr AS FLOAT) BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN TRY_CAST(price_inr AS FLOAT) BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN TRY_CAST(price_inr AS FLOAT) BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+'
    END AS price_range,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders
GROUP BY
    CASE
        WHEN TRY_CAST(price_inr AS FLOAT) < 100 THEN 'Under 100'
        WHEN TRY_CAST(price_inr AS FLOAT) BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN TRY_CAST(price_inr AS FLOAT) BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN TRY_CAST(price_inr AS FLOAT) BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+'
    END
ORDER BY total_orders DESC;
