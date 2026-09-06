-- ============================================================
-- ADVANCED QUESTIONS
-- Concepts: Subqueries, CTEs, Window Functions, Views, Stored Procedures
-- ============================================================

USE ecommerce_analytics;

-- 1. Rank products by total revenue within each category using RANK()
-- Business Question: What are the top revenue-generating products in each category?
WITH product_revenue AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT 
    product_id,
    product_name,
    category,
    total_revenue,
    RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS revenue_rank
FROM product_revenue
ORDER BY category, revenue_rank
LIMIT 50;


-- 2. Find customers who spent more than the average customer spend (subquery)
-- Business Question: Who are our above-average spenders?
SELECT 
    c.customer_id,
    c.customer_name,
    c.state AS country,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.customer_name, c.state
HAVING total_spent > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(oi2.quantity * oi2.unit_price) AS customer_total
        FROM customers c2
        JOIN orders o2 ON c2.customer_id = o2.customer_id
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        WHERE o2.status = 'delivered'
        GROUP BY c2.customer_id
    ) AS avg_calc
)
ORDER BY total_spent DESC
LIMIT 20;


-- 3. Identify repeat customers (customers with more than 2 orders)
-- Business Question: Who are our loyal / repeat customers?
SELECT 
    c.customer_id,
    c.customer_name,
    c.state AS country,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.customer_name, c.state
HAVING COUNT(DISTINCT o.order_id) > 2
ORDER BY total_orders DESC, lifetime_value DESC
LIMIT 20;


-- 4. Create a view called monthly_sales_summary
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;

-- Test the view
SELECT * FROM monthly_sales_summary;


-- 5. Stored procedure get_customer_history(customer_id)
DELIMITER //

CREATE PROCEDURE get_customer_history(IN p_customer_id INT)
BEGIN
    SELECT 
        o.order_id,
        o.order_date,
        o.status,
        p.product_name,
        p.category,
        oi.quantity,
        oi.unit_price,
        ROUND(oi.quantity * oi.unit_price, 2) AS line_total,
        pay.payment_type,
        pay.amount AS payment_amount
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN payments pay ON o.order_id = pay.order_id
    WHERE o.customer_id = p_customer_id
    ORDER BY o.order_date DESC, o.order_id, p.product_name;
END //

DELIMITER ;

-- Example: CALL get_customer_history(17850);


-- BONUS: Month-over-month revenue trend with CTE + LAG
WITH monthly_rev AS (
    SELECT 
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS mom_change,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) 
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100, 
        1
    ) AS mom_growth_pct
FROM monthly_rev
ORDER BY month;