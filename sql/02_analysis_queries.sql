-- Olist Customer Retention Analysis
-- Cohort retention
-- Groups customers into monthly cohorts based on their first
-- purchase, then tracks how many customers from each cohort
-- are still active in each subsequent month.

WITH first_purchase AS (
    -- Each customer's first purchase month = their cohort
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(MIN(o.order_purchase_timestamp), '%Y-%m-01') AS cohort_month
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),

orders_by_month AS (
    -- Every order a customer made, tagged with the month it happened
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS order_month
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
),

cohort_activity AS (
    -- Month index: 0 = cohort month itself, 1 = one month later, etc.
    SELECT
        fp.cohort_month,
        obm.customer_unique_id,
        TIMESTAMPDIFF(MONTH, fp.cohort_month, obm.order_month) AS month_index
    FROM orders_by_month obm
    JOIN first_purchase fp ON obm.customer_unique_id = fp.customer_unique_id
),

cohort_size AS (
    -- Total customers in each cohort (month_index = 0)
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS total_customers
    FROM cohort_activity
    WHERE month_index = 0
    GROUP BY cohort_month
),

cohort_counts AS (
    -- Active customers per cohort per month_index
    SELECT
        cohort_month,
        month_index,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM cohort_activity
    GROUP BY cohort_month, month_index
)

SELECT
    cc.cohort_month,
    cc.month_index,
    cc.active_customers,
    cs.total_customers,
    ROUND(cc.active_customers / cs.total_customers * 100, 1) AS retention_pct
FROM cohort_counts cc
JOIN cohort_size cs ON cc.cohort_month = cs.cohort_month
ORDER BY cc.cohort_month, cc.month_index;

-- Time between first and second purchase
-- For customers who made a repeat purchase, calculates how many
-- days on average passed between their 1st and 2nd order, and
-- how many customers actually reached a 2nd order at all.

WITH order_ranks AS (
    SELECT
        c.customer_unique_id,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS purchase_rank
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
),

first_second AS (
    SELECT
        customer_unique_id,
        MAX(CASE WHEN purchase_rank = 1 THEN order_purchase_timestamp END) AS first_purchase,
        MAX(CASE WHEN purchase_rank = 2 THEN order_purchase_timestamp END) AS second_purchase
    FROM order_ranks
    GROUP BY customer_unique_id
)

SELECT
    ROUND(AVG(TIMESTAMPDIFF(DAY, first_purchase, second_purchase)), 1) AS avg_days_between_purchases,
    COUNT(*) AS total_repeat_customers
FROM first_second
WHERE second_purchase IS NOT NULL;

-- Delivery speed & review score vs. repeat purchase
-- Compares average review score and delivery delay (actual vs.
-- estimated delivery date) between repeat customers and
-- one-time customers, to check whether delivery experience
-- relates to whether a customer comes back.

WITH order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),

delivery_reviews AS (
    SELECT
        c.customer_unique_id,
        AVG(r.review_score) AS avg_review_score,
        AVG(TIMESTAMPDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date)) AS avg_delivery_delay_days
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
    WHERE o.order_delivered_customer_date IS NOT NULL
    GROUP BY c.customer_unique_id
)

SELECT
    CASE WHEN oc.total_orders > 1 THEN 'Repeat Customer' ELSE 'One-time Customer' END AS customer_type,
    ROUND(AVG(dr.avg_review_score), 2) AS avg_review_score,
    ROUND(AVG(dr.avg_delivery_delay_days), 1) AS avg_delivery_delay_days,
    COUNT(*) AS num_customers
FROM order_counts oc
JOIN delivery_reviews dr ON oc.customer_unique_id = dr.customer_unique_id
GROUP BY customer_type;
