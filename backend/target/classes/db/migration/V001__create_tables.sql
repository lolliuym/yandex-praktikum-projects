-- V001__create_tables.sql
-- Create product table (singular name as in your schema)
CREATE TABLE   product (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    picture_url VARCHAR(255),
    price DOUBLE PRECISION
);

-- Create orders table
CREATE TABLE   orders (
    id BIGSERIAL PRIMARY KEY,
    status VARCHAR(255),
    date_created DATE DEFAULT CURRENT_DATE
);

-- Create order_product junction table
CREATE TABLE   order_product (
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_order_product_order FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT fk_order_product_product FOREIGN KEY (product_id) REFERENCES product(id)
);

-- Create existing indexes
CREATE INDEX  order_product_order_id_idx ON order_product(order_id);
CREATE INDEX   orders_status_date_idx ON orders(status, date_created);