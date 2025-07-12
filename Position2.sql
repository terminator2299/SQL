-- Create the sellers table
CREATE TABLE sellers (
    seller_id INT,
    country_name VARCHAR(255),
    revenue DECIMAL(10, 2)
);

-- Insert sample data
INSERT INTO sellers (seller_id, country_name, revenue)
VALUES
    (1, 'USA', 1000.00),
    (2, 'USA', 2000.00),
    (3, 'USA', 3000.00),
    (1, 'UK', 1000.00),
    (1, 'USA', 1800.00),
    (1, 'UK', 1000.00),
    (2, 'UK', 1000.00),
    (4, 'USA', 1800.00),
    (4, 'USA', 1000.00),
    (5, 'USA', 1000.00),
    (6, 'USA', 1009800.00),
    (7, 'USA', 1700.00),
    (9, 'USA', 1000.00),
    (9, 'UK', 1000.00);

-- CORRECTED QUERY: Top 2 sellers per country based on total revenue
WITH seller_totals AS (
    SELECT 
        seller_id,
        country_name,
        SUM(revenue) as total_revenue
    FROM sellers
    GROUP BY seller_id, country_name
),
ranked_sellers AS (
    SELECT 
        seller_id,
        country_name,
        total_revenue,
        DENSE_RANK() OVER (PARTITION BY country_name ORDER BY total_revenue DESC) as rank_num
    FROM seller_totals
)
SELECT 
    seller_id,
    country_name,
    total_revenue
FROM ranked_sellers
WHERE rank_num <= 2
ORDER BY country_name, rank_num;

-- Query 2: Find 2nd Oldest Person

-- Create the Person table
CREATE TABLE Person (
    person_id INT,
    name VARCHAR(10),
    age_gap INT
);


-- Insert sample data
INSERT INTO Person (person_id, name, age_gap)
VALUES 
    (1, 'A', 0),
    (2, 'B', 3),
    (3, 'C', 5),
    (4, 'D', 2),
    (5, 'E', 4);

-- CORRECTED QUERY: Find 2nd oldest person
WITH cumulative_ages AS (
    SELECT 
        person_id,
        name,
        age_gap,
        -- Calculate actual age: start with 15 + cumulative sum of age_gap
        15 + SUM(age_gap) OVER (ORDER BY person_id) as actual_age
    FROM Person
),
age_ranks AS (
    SELECT 
        person_id,
        name,
        actual_age,
        DENSE_RANK() OVER (ORDER BY actual_age DESC) as age_rank
    FROM cumulative_ages
)
SELECT 
    person_id,
    name,
    actual_age
FROM age_ranks
WHERE age_rank = 2;

 -- Alternative Approach for QUERY-1
-- If you want exactly 2 sellers per country (not handling ties):
WITH seller_totals AS (
    SELECT 
        seller_id,
        country_name,
        SUM(revenue) as total_revenue
    FROM sellers
    GROUP BY seller_id, country_name
),
ranked_sellers AS (
    SELECT 
        seller_id,
        country_name,
        total_revenue,
        ROW_NUMBER() OVER (PARTITION BY country_name ORDER BY total_revenue DESC) as row_num
    FROM seller_totals
)
SELECT 
    seller_id,
    country_name,
    total_revenue
FROM ranked_sellers
WHERE row_num <= 2
ORDER BY country_name, row_num;