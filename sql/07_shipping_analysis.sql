-- Shipping analysis

USE northwind;

-- Total shippers
SELECT
    COUNT(*) AS total_shippers
FROM shippers;

-- Orders handled by each shipper
SELECT
    s.id AS shipper_id,
    s.company AS shipper_name,
    COUNT(DISTINCT o.id) AS total_orders
FROM shippers s
JOIN orders o
    ON s.id = o.shipper_id
GROUP BY s.id, s.company
ORDER BY total_orders DESC;

-- Revenue handled by each shipper
SELECT
    s.id AS shipper_id,
    s.company AS shipper_name,
    COUNT(DISTINCT o.id) AS total_valid_orders,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue
FROM shippers s
JOIN orders o
    ON s.id = o.shipper_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY s.id, s.company
ORDER BY total_revenue DESC;

-- Orders without assigned shipper
SELECT
    o.id AS order_id,
    o.order_date,
    o.shipped_date,
    os.status_name
FROM orders o
LEFT JOIN orders_status os
    ON o.status_id = os.id
WHERE o.shipper_id IS NULL;

-- Orders not yet shipped
SELECT
    o.id AS order_id,
    o.order_date,
    o.shipped_date,
    os.status_name
FROM orders o
LEFT JOIN orders_status os
    ON o.status_id = os.id
WHERE o.shipped_date IS NULL;

-- Average shipping time for shipped orders
SELECT
    ROUND(AVG(DATEDIFF(o.shipped_date, o.order_date)), 2) AS average_shipping_days
FROM orders o
WHERE o.shipped_date IS NOT NULL
  AND o.order_date IS NOT NULL;

-- Shipping time by shipper
SELECT
    s.company AS shipper_name,
    COUNT(o.id) AS shipped_orders,
    ROUND(AVG(DATEDIFF(o.shipped_date, o.order_date)), 2) AS average_shipping_days
FROM shippers s
JOIN orders o
    ON s.id = o.shipper_id
WHERE o.shipped_date IS NOT NULL
  AND o.order_date IS NOT NULL
GROUP BY s.company
ORDER BY average_shipping_days;

-- Shipper performance category
-- The average below is weighted by valid order lines. Use the preceding query
-- for an average where each shipped order contributes once.
SELECT
    s.id AS shipper_id,
    s.company AS shipper_name,
    COUNT(DISTINCT o.id) AS total_valid_orders,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue,
    ROUND(AVG(DATEDIFF(o.shipped_date, o.order_date)), 2) AS average_shipping_days,
    CASE
        WHEN SUM(od.quantity * od.unit_price) >= 25000
             AND AVG(DATEDIFF(o.shipped_date, o.order_date)) <= 1 THEN 'Best Performing Shipper'
        WHEN SUM(od.quantity * od.unit_price) >= 10000 THEN 'Moderate Performing Shipper'
        ELSE 'Low Performing Shipper'
    END AS shipper_performance_category
FROM shippers s
JOIN orders o
    ON s.id = o.shipper_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
  AND o.shipped_date IS NOT NULL
GROUP BY s.id, s.company
ORDER BY total_revenue DESC;
