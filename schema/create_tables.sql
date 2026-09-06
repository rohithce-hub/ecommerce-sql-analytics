-- E-Commerce Sales & Customer Analytics Schema
-- Adapted for UCI Online Retail Dataset (normalized)
-- Source: https://archive.ics.uci.edu/ml/datasets/online+retail
-- MySQL

CREATE DATABASE IF NOT EXISTS ecommerce_analytics;
USE ecommerce_analytics;

-- 1. Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    city VARCHAR(50),
    state VARCHAR(50),          -- used for Country in this dataset
    signup_date DATE
);

-- 2. Sellers (synthetic, for completeness with original guide)
CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    join_date DATE
);

-- 3. Products  (product_id is StockCode - alphanumeric)
CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    seller_id INT,
    stock_quantity INT DEFAULT 0,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-- 4. Orders  (order_id is InvoiceNo)
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'delivered',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 5. Order Items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 6. Payments (synthetic payment methods added)
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id VARCHAR(20) NOT NULL,
    payment_type VARCHAR(30) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE,
    status VARCHAR(20) DEFAULT 'completed',
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Indexes
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_customers_country ON customers(state);