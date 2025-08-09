# ElevateLabs_Internship_Task-4
Use SQL queries to extract and analyze data from a database.
# Task 4 — SQL for Data Analysis

## Overview
This project performs data analysis on a sample E-commerce database using PostgreSQL and pgAdmin.  
It covers basic SQL operations, joins, aggregations, subqueries, views, indexes, and query optimization.

## Database Details
- **Database name:** ecommerce_db
- **Tables:** users, categories, products, orders, order_items
- **Data source:** Synthetic dataset (CSV files) created for demonstration

## Queries Performed
1. Count rows in all tables  
2. Recent 10 orders  
3. Orders by specific user  
4. Total revenue  
5. Average revenue per user  
6. Monthly revenue  
7. Top 10 products by revenue  
8. Orders with user info (JOIN)  
9. Products with zero sales  
10. Customers with above-average spend  
11. Orders above/below average value  
12. Categories with revenue > 10000  
13. View for monthly revenue  
14. Index creation  
15. Explain analyze for optimization  
16. Repeat purchase rate

## How to Run
1. Create the tables in PostgreSQL (schema provided in queries.sql).
2. Import the CSV data using pgAdmin's Import feature.
3. Run queries in pgAdmin Query Tool individually to view results.
