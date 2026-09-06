-- ============================================================
-- BEGINNER QUESTIONS
-- Concepts: SELECT, WHERE, ORDER BY, LIMIT
-- Dataset: UCI Online Retail (normalized sample)
-- ============================================================

USE ecommerce_analytics;

-- 1. List all customers from a specific country (e.g. Germany)
-- Business Question: Which customers are located in Germany?
SELECT customer_id, customer_name, city, state AS country, signup_date
FROM customers
WHERE state = 'Germany'
ORDER BY signup_date
LIMIT 20;


-- 2. Show all orders placed in a specific period (e.g. December 2010)
-- Business Question: What orders were placed in Dec 2010 (peak season)?
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE order_date BETWEEN '2010-12-01' AND '2010-12-31'
ORDER BY order_date DESC
LIMIT 30;


-- 3. Find the 10 most expensive products
-- Business Question: What are our premium products?
SELECT product_id, product_name, category, price, stock_quantity
FROM products
ORDER BY price DESC
LIMIT 10;


-- 4. List all orders with status = 'delivered'
-- Business Question: How many successfully completed orders do we have?
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE status = 'delivered'
ORDER BY order_date DESC
LIMIT 20;


-- 5. Find customers who signed up (first order) in 2011
-- Business Question: Who are the customers whose first purchase was in 2011?
SELECT customer_id, customer_name, state AS country, signup_date
FROM customers
WHERE YEAR(signup_date) = 2011
ORDER BY signup_date
LIMIT 20;