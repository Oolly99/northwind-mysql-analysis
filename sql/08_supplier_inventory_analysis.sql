-- Supplier inventory analysis

USE northwind;

-- Total suppliers
SELECT
    COUNT(*) AS total_suppliers
FROM suppliers;

-- Total purchase orders
SELECT
    COUNT(*) AS total_purchase_orders
FROM purchase_orders;

-- Purchase orders by supplier
SELECT
    s.id AS supplier_id,
    s.company AS supplier_name,
    COUNT(po.id) AS total_purchase_orders
FROM suppliers s
LEFT JOIN purchase_orders po
    ON s.id = po.supplier_id
GROUP BY s.id, s.company
ORDER BY total_purchase_orders DESC;

-- Purchase order value by supplier
SELECT
    s.id AS supplier_id,
    s.company AS supplier_name,
    COUNT(DISTINCT po.id) AS total_purchase_orders,
    ROUND(SUM(pod.quantity * pod.unit_cost), 2) AS total_purchase_value
FROM suppliers s
JOIN purchase_orders po
    ON s.id = po.supplier_id
JOIN purchase_order_details pod
    ON po.id = pod.purchase_order_id
GROUP BY s.id, s.company
ORDER BY total_purchase_value DESC;

-- Products purchased from suppliers
SELECT
    s.company AS supplier_name,
    p.product_name,
    SUM(pod.quantity) AS total_quantity_purchased,
    ROUND(SUM(pod.quantity * pod.unit_cost), 2) AS total_purchase_value
FROM suppliers s
JOIN purchase_orders po
    ON s.id = po.supplier_id
JOIN purchase_order_details pod
    ON po.id = pod.purchase_order_id
JOIN products p
    ON pod.product_id = p.id
GROUP BY s.company, p.product_name
ORDER BY total_purchase_value DESC;

-- Inventory transaction types
SELECT *
FROM inventory_transaction_types;

-- Inventory movement by product
SELECT
    p.id AS product_id,
    p.product_name,
    COUNT(it.id) AS total_inventory_transactions,
    COALESCE(SUM(it.quantity), 0) AS total_inventory_quantity
FROM products p
LEFT JOIN inventory_transactions it
    ON p.id = it.product_id
GROUP BY p.id, p.product_name
ORDER BY total_inventory_quantity DESC;

-- Inventory transactions by type
SELECT
    itt.type_name AS transaction_type,
    COUNT(it.id) AS total_transactions,
    SUM(it.quantity) AS total_quantity
FROM inventory_transactions it
JOIN inventory_transaction_types itt
    ON it.transaction_type = itt.id
GROUP BY itt.type_name
ORDER BY total_transactions DESC;

-- Supplier performance category
SELECT
    s.id AS supplier_id,
    s.company AS supplier_name,
    COUNT(DISTINCT po.id) AS total_purchase_orders,
    ROUND(COALESCE(SUM(pod.quantity * pod.unit_cost), 0), 2) AS total_purchase_value,
    CASE
        WHEN COALESCE(SUM(pod.quantity * pod.unit_cost), 0) >= 30000 THEN 'Strategic Supplier'
        WHEN COALESCE(SUM(pod.quantity * pod.unit_cost), 0) >= 5000 THEN 'Key Supplier'
        WHEN COALESCE(SUM(pod.quantity * pod.unit_cost), 0) > 0 THEN 'Low Value Supplier'
        ELSE 'Inactive Supplier'
    END AS supplier_category
FROM suppliers s
LEFT JOIN purchase_orders po
    ON s.id = po.supplier_id
LEFT JOIN purchase_order_details pod
    ON po.id = pod.purchase_order_id
GROUP BY s.id, s.company
ORDER BY total_purchase_value DESC;
