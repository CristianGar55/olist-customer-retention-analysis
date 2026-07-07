-- Olist Customer Retention Analysis
-- Database setup and data import

CREATE DATABASE IF NOT EXISTS olist_ecommerce;
USE olist_ecommerce;

CREATE TABLE olist_customers_dataset (
    customer_id                VARCHAR(50) PRIMARY KEY,
    customer_unique_id         VARCHAR(50),
    customer_zip_code_prefix   VARCHAR(10),
    customer_city              VARCHAR(100),
    customer_state             VARCHAR(10)
);

CREATE TABLE olist_orders_dataset (
    order_id                       VARCHAR(50) PRIMARY KEY,
    customer_id                    VARCHAR(50),
    order_status                   VARCHAR(20),
    order_purchase_timestamp       DATETIME,
    order_approved_at              DATETIME,
    order_delivered_carrier_date   DATETIME,
    order_delivered_customer_date  DATETIME,
    order_estimated_delivery_date  DATETIME
);

CREATE TABLE olist_order_items_dataset (
    order_id             VARCHAR(50),
    order_item_id        INT,
    product_id           VARCHAR(50),
    seller_id            VARCHAR(50),
    shipping_limit_date  DATETIME,
    price                DECIMAL(10,2),
    freight_value        DECIMAL(10,2)
);

CREATE TABLE olist_order_payments_dataset (
    order_id              VARCHAR(50),
    payment_sequential    INT,
    payment_type          VARCHAR(30),
    payment_installments  INT,
    payment_value         DECIMAL(10,2)
);

CREATE TABLE olist_order_reviews_dataset (
    review_id               VARCHAR(50),
    order_id                VARCHAR(50),
    review_score            INT,
    review_comment_title    VARCHAR(255),
    review_comment_message  TEXT,
    review_creation_date    DATETIME,
    review_answer_timestamp DATETIME
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Cristian/Downloads/archive/olist_customers_dataset.csv'
INTO TABLE olist_customers_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Cristian/Downloads/archive/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Cristian/Downloads/archive/olist_order_items_dataset.csv'
INTO TABLE olist_order_items_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Cristian/Downloads/archive/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Cristian/Downloads/archive/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Sanity check: confirm row counts look reasonable

SELECT 'customers'  AS table_name, COUNT(*) AS row_count FROM olist_customers_dataset
UNION ALL
SELECT 'orders',         COUNT(*) FROM olist_orders_dataset
UNION ALL
SELECT 'order_items',    COUNT(*) FROM olist_order_items_dataset
UNION ALL
SELECT 'order_payments', COUNT(*) FROM olist_order_payments_dataset
UNION ALL
SELECT 'order_reviews',  COUNT(*) FROM olist_order_reviews_dataset;
