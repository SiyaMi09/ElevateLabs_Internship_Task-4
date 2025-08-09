DROP TABLE IF EXISTS order_items, orders, products, categories, users CASCADE;


CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name TEXT,
    email TEXT,
    created_at DATE
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name TEXT
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name TEXT,
    category_id INT REFERENCES categories(category_id),
    price NUMERIC(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    order_date DATE,
    total_amount NUMERIC(10,2),
    status TEXT
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    unit_price NUMERIC(10,2)
);


SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM categories;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;


-- 1. Count rows
SELECT 'users' AS table_name, COUNT(*) AS rows FROM users
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;

-- 2. Recent 10 orders
SELECT * FROM orders
ORDER BY order_date DESC
LIMIT 10;

-- 3. Orders by a specific user
SELECT * FROM orders
WHERE user_id = 1
ORDER BY order_date DESC;

-- 4. Total revenue
SELECT SUM(total_amount) AS total_revenue FROM orders;

-- 5. Average revenue per user
SELECT AVG(user_revenue) AS arpu
FROM (
    SELECT user_id, SUM(total_amount) AS user_revenue
    FROM orders
    GROUP BY user_id
) sub;

-- 6. Monthly revenue
SELECT to_char(order_date, 'YYYY-MM') AS month, SUM(total_amount) AS revenue
FROM orders
GROUP BY month
ORDER BY month;

-- 7. Top 10 products by revenue
SELECT p.product_id, p.name,
       SUM(oi.quantity * oi.unit_price) AS revenue,
       SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name
ORDER BY revenue DESC
LIMIT 10;

-- 8. Orders with user info
SELECT o.order_id, o.order_date, o.total_amount, u.name, u.email
FROM orders o
JOIN users u ON o.user_id = u.user_id
ORDER BY o.order_date DESC
LIMIT 20;

-- 9. Products with zero sales
SELECT p.product_id, p.name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- 10. Customers with above-average spend
WITH user_spend AS (
    SELECT user_id, SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY user_id
)
SELECT user_id, total_spent
FROM user_spend
WHERE total_spent > (SELECT AVG(total_spent) FROM user_spend)
ORDER BY total_spent DESC;

-- 11. Orders above/below average value
SELECT o.order_id, o.total_amount,
  CASE WHEN o.total_amount > (SELECT AVG(total_amount) FROM orders)
       THEN 'above_avg' ELSE 'below_avg' END AS flag
FROM orders o
LIMIT 50;

-- 12. Categories with revenue > 10000
SELECT c.category_id, c.category_name,
       SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY c.category_id, c.category_name
HAVING SUM(oi.quantity * oi.unit_price) > 10000
ORDER BY category_revenue DESC;

-- 13. View for monthly revenue
CREATE OR REPLACE VIEW monthly_revenue AS
SELECT to_char(order_date, 'YYYY-MM') AS month, SUM(total_amount) AS revenue
FROM orders
GROUP BY month;

SELECT * FROM monthly_revenue ORDER BY month;

-- 14. Indexes
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_oi_order ON order_items(order_id);
CREATE INDEX idx_oi_product ON order_items(product_id);

-- 15. Explain plan for top products
EXPLAIN ANALYZE
SELECT p.product_id, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY revenue DESC
LIMIT 5;

-- 16. Repeat purchase rate
SELECT
  (SELECT COUNT(DISTINCT user_id) FROM orders WHERE user_id IN (
     SELECT user_id FROM orders GROUP BY user_id HAVING COUNT(*) > 1
  ))::NUMERIC /
  (SELECT COUNT(DISTINCT user_id) FROM orders) AS repeat_rate;