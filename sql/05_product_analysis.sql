-- Product analysis

USE northwind;

-- Total products
SELECT
    COUNT(*) AS total_products
FROM products;

-- Products with at least one valid sale
SELECT
    COUNT(DISTINCT p.id) AS products_sold
FROM products p
JOIN order_details od
    ON p.id = od.product_id
WHERE od.quantity > 0
  AND od.unit_price > 0;

-- Products never ordered
SELECT
    p.id AS product_id,
    p.product_name,
    p.list_price
FROM products p
LEFT JOIN order_details od
    ON p.id = od.product_id
WHERE od.product_id IS NULL
ORDER BY p.product_name;

-- Top products by revenue
SELECT
    p.id AS product_id,
    p.product_name,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue
FROM products p
JOIN order_details od
    ON p.id = od.product_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY p.id, p.product_name
ORDER BY total_revenue DESC;

-- Top products by quantity sold
SELECT
    p.id AS product_id,
    p.product_name,
    SUM(od.quantity) AS total_quantity_sold
FROM products p
JOIN order_details od
    ON p.id = od.product_id
WHERE od.quantity > 0
  AND od.unit_price > 0
GROUP BY p.id, p.product_name
ORDER BY total_quantity_sold DESC;

-- Coffee revenue percentage contribution
SELECT ROUND(
    100.0 * SUM(CASE WHEN p.product_name = 'Northwind Traders Coffee'
                    THEN od.quantity * od.unit_price ELSE 0 END)
    / NULLIF(SUM(od.quantity * od.unit_price), 0), 2
) AS coffee_revenue_percentage
FROM order_details od
LEFT JOIN products p ON od.product_id = p.id
WHERE od.quantity > 0
  AND od.unit_price > 0;

-- Product performance category
SELECT
    p.id AS product_id,
    p.product_name,
    COALESCE(SUM(od.quantity), 0) AS total_quantity_sold,
    ROUND(COALESCE(SUM(od.quantity * od.unit_price), 0), 2) AS total_revenue,
    CASE
        WHEN COALESCE(SUM(od.quantity * od.unit_price), 0) >= 10000 THEN 'High Performing Product'
        WHEN COALESCE(SUM(od.quantity * od.unit_price), 0) >= 3000 THEN 'Medium Performing Product'
        WHEN COALESCE(SUM(od.quantity * od.unit_price), 0) > 0 THEN 'Low Performing Product'
        ELSE 'Unsold Product'
    END AS product_performance_category
FROM products p
LEFT JOIN order_details od
    ON p.id = od.product_id
   AND od.quantity > 0
   AND od.unit_price > 0
GROUP BY p.id, p.product_name
ORDER BY total_revenue DESC;
