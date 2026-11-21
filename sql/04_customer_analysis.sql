-- Customer analysis

USE northwind;

-- Total customers
SELECT
    COUNT(*) AS total_customers
FROM customers;

-- Customers with valid orders
SELECT
    COUNT(DISTINCT c.id) AS customers_with_orders
FROM customers c
JOIN orders o
    ON c.id = o.customer_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0;

-- Customers with no orders
SELECT
    c.id AS customer_id,
    c.company,
    c.first_name,
    c.last_name,
    c.city,
    c.country_region
FROM customers c
LEFT JOIN orders o
    ON c.id = o.customer_id
WHERE o.customer_id IS NULL
ORDER BY c.company;

-- All customers by revenue
SELECT
    c.id AS customer_id,
    c.company,
    c.first_name,
    c.last_name,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.id = o.customer_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY c.id, c.company, c.first_name, c.last_name
ORDER BY total_revenue DESC;

-- Top 5 customers by revenue
SELECT
    c.id AS customer_id,
    c.company,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.id = o.customer_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY c.id, c.company, customer_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Customers by number of valid orders
SELECT
    c.id AS customer_id,
    c.company,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT o.id) AS total_orders
FROM customers c
JOIN orders o
    ON c.id = o.customer_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY c.id, c.company, customer_name
ORDER BY total_orders DESC;

-- Customer revenue, order count, and average order value
SELECT
    c.id AS customer_id,
    c.company,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT o.id) AS total_orders,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue,
    ROUND(SUM(od.quantity * od.unit_price) / COUNT(DISTINCT o.id), 2) AS average_order_value
FROM customers c
JOIN orders o
    ON c.id = o.customer_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY c.id, c.company, customer_name
ORDER BY total_revenue DESC;

-- Revenue by country/region
SELECT
    c.country_region,
    COUNT(DISTINCT c.id) AS total_customers,
    COUNT(DISTINCT o.id) AS total_orders,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.id = o.customer_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY c.country_region
ORDER BY total_revenue DESC;

-- Average revenue per active customer
SELECT
    ROUND(SUM(customer_revenue), 2) AS total_revenue,
    COUNT(customer_id) AS active_customers,
    ROUND(AVG(customer_revenue), 2) AS average_revenue_per_customer
FROM (
    SELECT
        c.id AS customer_id,
        SUM(od.quantity * od.unit_price) AS customer_revenue
    FROM customers c
    JOIN orders o
        ON c.id = o.customer_id
    JOIN order_details od
        ON o.id = od.order_id
    WHERE od.quantity > 0
      AND od.unit_price > 0
    GROUP BY c.id
) AS customer_summary;

-- Top customer revenue percentage
WITH customer_sales AS (
    SELECT c.id, SUM(od.quantity * od.unit_price) AS gross_sales
    FROM order_details od
    JOIN orders o ON od.order_id = o.id
    JOIN customers c ON o.customer_id = c.id
    WHERE od.quantity > 0
      AND od.unit_price > 0
    GROUP BY c.id
)
SELECT ROUND(100.0 * MAX(gross_sales) / NULLIF((
    SELECT SUM(quantity * unit_price)
    FROM order_details
    WHERE quantity > 0 AND unit_price > 0
), 0), 2) AS top_customer_revenue_percentage
FROM customer_sales;

-- Customer segmentation
SELECT
    c.id AS customer_id,
    c.company,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT o.id) AS total_orders,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue,
    CASE
        WHEN SUM(od.quantity * od.unit_price) >= 10000 THEN 'High Value Customer'
        WHEN SUM(od.quantity * od.unit_price) >= 3000 THEN 'Medium Value Customer'
        ELSE 'Low Value Customer'
    END AS customer_segment
FROM customers c
JOIN orders o
    ON c.id = o.customer_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY c.id, c.company, customer_name
ORDER BY total_revenue DESC;
