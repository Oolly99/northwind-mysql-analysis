# Northwind Sales Analysis with MySQL

A MySQL portfolio project by Olaoluwa Bamgbose. I used the Northwind Traders sample database to investigate sales concentration, customer activity, product performance, and data quality. The analysis covers January–June 2006.

## What the data showed

| Finding | Result |
| --- | --- |
| Gross order-line sales | **$68,137.00** across **39 qualifying orders**, or **$1,747.10 per qualifying order** |
| Peak month | **March 2006** recorded **$32,609.25** in gross sales. Two orders accounted for **84.64%** of that month’s sales. |
| Customer concentration | **Company BB and Company G** accounted for **42.90%** of gross sales combined. |
| Product concentration | **Northwind Traders Coffee** generated **$29,900.00** from **650 units**, or **43.88%** of gross sales. |
| Data quality | **14 of 29 customers** had no recorded orders. **8 of 48 orders** had no order details. **2 order lines** had zero quantity. All qualifying sales lines matched an employee record. |

Gross order-line sales sum `quantity × unit_price` for lines with a positive quantity and unit price. The measure excludes discounts, freight, taxes, and cost, and includes qualifying lines from New, Shipped, and Closed orders. A qualifying order is a distinct order ID with at least one qualifying line. No recorded orders refers to this sample period. Shipping-day calculations measure elapsed calendar days from order date to shipment.

## Explore the analysis

| SQL script | What it covers |
| --- | --- |
| [01 · Database overview](sql/01_database_overview.sql) | Tables, record counts, keys, and schema discovery |
| [02 · Data quality](sql/02_data_quality_checks.sql) | Nulls, duplicates, invalid prices and quantities, missing order lines, and employee join coverage |
| [03 · Sales performance](sql/03_sales_performance_analysis.sql) | Gross sales, distinct orders, monthly trends, and March order concentration |
| [04 · Customers](sql/04_customer_analysis.sql) | Activity, customer sales rankings, and segmentation |
| [05 · Products](sql/05_product_analysis.sql) | Units sold, product rankings, and Coffee’s contribution |
| [06 · Employees](sql/06_employee_performance_analysis.sql) | Sales, order counts, and order status by employee |
| [07 · Shipping](sql/07_shipping_analysis.sql) | Shipper volume, shipment timing, and unassigned orders |
| [08 · Suppliers and inventory](sql/08_supplier_inventory_analysis.sql) | Purchase activity, procurement value, and inventory movements |

[View the result CSVs](results) · [Read the original Word query breakdown](docs/Northwind_SQL_Project_Query_Breakdown.docx)

## Run with MySQL

1. Use MySQL 8.0 or newer. Download the [schema](https://github.com/dalers/mywind/blob/0036c3ca2f2a010b77c7880a3b4badf85dbcfc7a/northwind.sql) and [sample data](https://github.com/dalers/mywind/blob/0036c3ca2f2a010b77c7880a3b4badf85dbcfc7a/northwind-data.sql) from the pinned MyWind snapshot.
2. Load the files in that order into a disposable MySQL instance. The upstream schema script drops any existing `northwind` schema before creating it.
3. Run a project query file in MySQL Workbench, or use the command line from this repository’s root:

   ```bash
   mysql -u YOUR_USER -p < sql/03_sales_performance_analysis.sql
   ```

The SQL scripts were extracted from the original write-up. The repository recalculates three percentage findings from the input data and includes an explicit employee join check. The result CSVs were reproduced from the pinned sample using a local SQLite check with equivalent date and string functions. MySQL-specific database metadata commands require MySQL.
