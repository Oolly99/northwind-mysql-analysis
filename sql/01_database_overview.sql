-- Database overview

-- Select the database
USE northwind;

-- Show all tables
SHOW TABLES;

-- Count records in key tables
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_details', COUNT(*) FROM order_details
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'shippers', COUNT(*) FROM shippers
UNION ALL
SELECT 'invoices', COUNT(*) FROM invoices;

-- View table structures
DESCRIBE customers;
DESCRIBE employees;
DESCRIBE orders;
DESCRIBE order_details;
DESCRIBE products;
DESCRIBE suppliers;
DESCRIBE shippers;
DESCRIBE invoices;

-- Preview sample records
SELECT * FROM customers LIMIT 5;
SELECT * FROM employees LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_details LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM suppliers LIMIT 5;
SELECT * FROM shippers LIMIT 5;
SELECT * FROM invoices LIMIT 5;

-- Check foreign key relationships
SELECT
    table_name,
    column_name,
    referenced_table_name,
    referenced_column_name
FROM information_schema.key_column_usage
WHERE table_schema = 'northwind'
  AND referenced_table_name IS NOT NULL;
