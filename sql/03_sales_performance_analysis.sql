-- Sales performance analysis

USE northwind;

-- Total revenue from valid sales records
SELECT
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue
FROM order_details od
WHERE od.quantity > 0
  AND od.unit_price > 0;

-- Total number of valid orders
SELECT
    COUNT(DISTINCT o.id) AS total_valid_orders
FROM orders o
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0;

-- Average order value
SELECT
    ROUND(SUM(order_revenue), 2) AS total_revenue,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(order_revenue), 2) AS average_order_value
FROM (
    SELECT
        o.id AS order_id,
        SUM(od.quantity * od.unit_price) AS order_revenue
    FROM orders o
    JOIN order_details od
        ON o.id = od.order_id
    WHERE od.quantity > 0
      AND od.unit_price > 0
    GROUP BY o.id
) AS order_summary;

-- Revenue by order
SELECT
    o.id AS order_id,
    o.order_date,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS order_revenue
FROM orders o
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY o.id, o.order_date
ORDER BY order_revenue DESC;

-- Monthly revenue trend
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS monthly_revenue
FROM orders o
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;

-- Highest revenue month
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS monthly_revenue
FROM orders o
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY monthly_revenue DESC
LIMIT 1;

-- Revenue by order status
SELECT
    os.status_name,
    COUNT(DISTINCT o.id) AS total_orders,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue
FROM orders o
JOIN order_details od
    ON o.id = od.order_id
LEFT JOIN orders_status os
    ON o.status_id = os.id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY os.status_name
ORDER BY total_revenue DESC;

-- Revenue by year
SELECT
    YEAR(o.order_date) AS sales_year,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS yearly_revenue
FROM orders o
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY YEAR(o.order_date)
ORDER BY sales_year;

-- March revenue breakdown
SELECT
    o.id AS order_id,
    o.order_date,
    os.status_name,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS order_revenue
FROM orders o
JOIN order_details od
    ON o.id = od.order_id
LEFT JOIN orders_status os
    ON o.status_id = os.id
WHERE od.quantity > 0
  AND od.unit_price > 0
  AND DATE_FORMAT(o.order_date, '%Y-%m') = '2006-03'
GROUP BY o.id, o.order_date, os.status_name
ORDER BY order_revenue DESC;

-- Percentage contribution of top two March orders
WITH march_orders AS (
    SELECT o.id AS order_id, SUM(od.quantity * od.unit_price) AS gross_sales
    FROM orders o
    JOIN order_details od ON o.id = od.order_id
    WHERE od.quantity > 0
      AND od.unit_price > 0
      AND o.order_date >= '2006-03-01'
      AND o.order_date < '2006-04-01'
    GROUP BY o.id
),
ranked_orders AS (
    SELECT gross_sales, ROW_NUMBER() OVER (ORDER BY gross_sales DESC, order_id) AS order_rank
    FROM march_orders
)
SELECT ROUND(
    100.0 * SUM(CASE WHEN order_rank <= 2 THEN gross_sales ELSE 0 END)
    / NULLIF(SUM(gross_sales), 0), 2
) AS top_two_march_orders_percentage
FROM ranked_orders;
