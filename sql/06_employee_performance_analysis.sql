-- Employee performance analysis

USE northwind;

-- Total employees
SELECT
    COUNT(*) AS total_employees
FROM employees;

-- Employees who handled valid sales orders
SELECT
    COUNT(DISTINCT e.id) AS employees_with_sales
FROM employees e
JOIN orders o
    ON e.id = o.employee_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0;

-- Employee revenue performance
SELECT
    e.id AS employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(DISTINCT o.id) AS total_orders,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue,
    ROUND(SUM(od.quantity * od.unit_price) / COUNT(DISTINCT o.id), 2) AS average_order_value
FROM employees e
JOIN orders o
    ON e.id = o.employee_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY e.id, employee_name
ORDER BY total_revenue DESC;

-- Top employees by number of valid orders
SELECT
    e.id AS employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(DISTINCT o.id) AS total_orders
FROM employees e
JOIN orders o
    ON e.id = o.employee_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY e.id, employee_name
ORDER BY total_orders DESC;

-- Employee performance by order status
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    os.status_name,
    COUNT(DISTINCT o.id) AS total_orders,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue
FROM employees e
JOIN orders o
    ON e.id = o.employee_id
JOIN order_details od
    ON o.id = od.order_id
LEFT JOIN orders_status os
    ON o.status_id = os.id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY employee_name, os.status_name
ORDER BY employee_name, total_revenue DESC;

-- Employee performance category
SELECT
    e.id AS employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(DISTINCT o.id) AS total_orders,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue,
    CASE
        WHEN SUM(od.quantity * od.unit_price) >= 15000 THEN 'Top Performer'
        WHEN SUM(od.quantity * od.unit_price) >= 5000 THEN 'Moderate Performer'
        ELSE 'Low Performer'
    END AS employee_performance_category
FROM employees e
JOIN orders o
    ON e.id = o.employee_id
JOIN order_details od
    ON o.id = od.order_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY e.id, employee_name
ORDER BY total_revenue DESC;
