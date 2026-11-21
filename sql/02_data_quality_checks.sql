-- Data quality checks

USE northwind;

-- Check missing customer values
SELECT *
FROM customers
WHERE company IS NULL
   OR first_name IS NULL
   OR last_name IS NULL
   OR city IS NULL
   OR country_region IS NULL;

-- Count missing customer values by column
SELECT
    SUM(company IS NULL) AS missing_company,
    SUM(first_name IS NULL) AS missing_first_name,
    SUM(last_name IS NULL) AS missing_last_name,
    SUM(city IS NULL) AS missing_city,
    SUM(country_region IS NULL) AS missing_country
FROM customers;

-- Check missing important order values
SELECT *
FROM orders
WHERE customer_id IS NULL
   OR employee_id IS NULL
   OR order_date IS NULL
   OR shipper_id IS NULL;

-- Inspect incomplete orders
SELECT
    id AS order_id,
    customer_id,
    employee_id,
    order_date,
    shipped_date,
    shipper_id,
    status_id
FROM orders
WHERE customer_id IS NULL
   OR employee_id IS NULL
   OR order_date IS NULL
   OR shipper_id IS NULL;

-- Check orders with no shipped date
SELECT *
FROM orders
WHERE shipped_date IS NULL;

-- Check unshipped orders with status
SELECT
    o.id AS order_id,
    o.order_date,
    o.shipped_date,
    o.status_id,
    os.status_name
FROM orders o
LEFT JOIN orders_status os
    ON o.status_id = os.id
WHERE o.shipped_date IS NULL;

-- Check missing values in order_details
SELECT *
FROM order_details
WHERE order_id IS NULL
   OR product_id IS NULL
   OR quantity IS NULL
   OR unit_price IS NULL;

-- Check invalid quantity or unit price
SELECT *
FROM order_details
WHERE quantity <= 0
   OR unit_price <= 0;

-- Inspect invalid order details
SELECT
    od.id,
    od.order_id,
    od.product_id,
    p.product_name,
    od.quantity,
    od.unit_price,
    od.discount,
    od.status_id
FROM order_details od
LEFT JOIN products p
    ON od.product_id = p.id
WHERE od.quantity <= 0
   OR od.unit_price <= 0;

-- Check missing product fields and invalid prices
SELECT *
FROM products
WHERE product_name IS NULL
   OR standard_cost IS NULL
   OR list_price IS NULL;

SELECT *
FROM products
WHERE standard_cost < 0
   OR list_price < 0;

-- Check duplicate customers and products
SELECT
    company,
    first_name,
    last_name,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY company, first_name, last_name
HAVING COUNT(*) > 1;

SELECT
    product_name,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_name
HAVING COUNT(*) > 1;

-- Check date consistency
SELECT
    id AS order_id,
    order_date,
    shipped_date
FROM orders
WHERE shipped_date < order_date;

-- Check orders without order details
SELECT
    o.id AS order_id,
    o.customer_id,
    o.order_date
FROM orders o
LEFT JOIN order_details od
    ON o.id = od.order_id
WHERE od.order_id IS NULL;

-- Check products never ordered
SELECT
    p.id AS product_id,
    p.product_name
FROM products p
LEFT JOIN order_details od
    ON p.id = od.product_id
WHERE od.product_id IS NULL;

-- Check customers with no orders
SELECT
    c.id AS customer_id,
    c.company,
    c.first_name,
    c.last_name
FROM customers c
LEFT JOIN orders o
    ON c.id = o.customer_id
WHERE o.customer_id IS NULL;

-- Check qualifying sales without a matching employee record.
SELECT
    COUNT(*) AS unmatched_sales_lines,
    COALESCE(ROUND(SUM(od.quantity * od.unit_price), 2), 0) AS unmatched_gross_sales
FROM order_details AS od
JOIN orders AS o ON od.order_id = o.id
LEFT JOIN employees AS e ON o.employee_id = e.id
WHERE od.quantity > 0
  AND od.unit_price > 0
  AND e.id IS NULL;
