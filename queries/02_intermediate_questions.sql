-- ============================================================
-- INTERMEDIATE QUESTIONS
-- Concepts: JOINs, GROUP BY, HAVING, Aggregates
-- ============================================================

USE ecommerce_analytics;

-- 1. What is the total revenue generated so far?
-- Business Question: What is the overall revenue of the platform?
SELECT 
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'delivered';


-- 2. Which product category has sold the most units?
-- Business Question: Which category is our best seller by volume?
SELECT 
    p.category,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS category_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
GROUP BY p.category
ORDER BY total_units_sold DESC;


-- 3. List the top 5 customers by total amount spent
-- Business Question: Who are our most valuable customers (high spenders)?
SELECT 
    c.customer_id,
    c.customer_name,
    c.state AS country,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spent,
    COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.customer_name, c.state
ORDER BY total_spent DESC
LIMIT 5;


-- 4. Which sellers have generated more than a set revenue threshold? (HAVING)
-- Business Question: Which sellers are high performers (e.g. > £5,000 revenue)?
SELECT 
    s.seller_id,
    s.seller_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS seller_revenue
FROM sellers s
JOIN products p ON s.seller_id = p.seller_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
GROUP BY s.seller_id, s.seller_name
HAVING seller_revenue > 5000
ORDER BY seller_revenue DESC;


-- 5. What is the average order value per country?
-- Business Question: Which countries have higher average order values?
SELECT 
    c.state AS country,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN (
    SELECT order_id, SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
) ot ON o.order_id = ot.order_id
WHERE o.status = 'delivered'
GROUP BY c.state
ORDER BY avg_order_value DESC;


-- 6. How many orders did each payment type handle, and what's the average payment value per type?
-- Business Question: Which payment methods are most popular and valuable?
SELECT 
    payment_type,
    COUNT(*) AS number_of_orders,
    ROUND(AVG(amount), 2) AS avg_payment_value,
    ROUND(SUM(amount), 2) AS total_amount
FROM payments
WHERE status = 'completed'
GROUP BY payment_type
ORDER BY number_of_orders DESC;