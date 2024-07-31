-- Calculate the total amount spent by each customer
WITH total_amounts AS (
    SELECT 
        customer_id,
        SUM(amount) AS total_amount
    FROM 
        oracle_table
    GROUP BY 
        customer_id
),

-- Calculate the cumulative sum of amounts per customer per month
cumulative_sums AS (
    SELECT 
        customer_id,
        value_date,
        amount,

        -- Extract year and month for partitioning
        EXTRACT(YEAR FROM value_date) AS year,
        EXTRACT(MONTH FROM value_date) AS month,

        -- Calculate the cumulative sum of amounts, resetting each month
        SUM(amount) OVER (
            PARTITION BY customer_id, EXTRACT(YEAR FROM value_date), EXTRACT(MONTH FROM value_date) 
            ORDER BY value_date, ROWID
        ) AS cumulative_sum
    FROM 
        oracle_table
)

-- Combine the results of cumulative sums with the total amounts
SELECT 
    cs.customer_id,
    cs.value_date,
    cs.amount,
    cs.cumulative_sum,
    ta.total_amount
FROM 
    cumulative_sums cs
JOIN 
    total_amounts ta
ON 
    cs.customer_id = ta.customer_id
ORDER BY 
    cs.customer_id, 
    cs.value_date;
