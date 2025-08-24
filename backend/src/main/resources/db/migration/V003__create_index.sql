-- Индексы для продуктов
CREATE INDEX   idx_product_name ON product(name);
CREATE INDEX   idx_product_price ON product(price);

-- Индексы для заказов
CREATE INDEX   idx_orders_status ON orders(status);
CREATE INDEX   idx_orders_date_created ON orders(date_created);
CREATE INDEX   idx_orders_status_date ON orders(status, date_created);

-- Индексы для связей заказ-продукт
CREATE INDEX  idx_order_product_order_id ON order_product(order_id);
CREATE INDEX  idx_order_product_product_id ON order_product(product_id);
CREATE INDEX  idx_order_product_quantity ON order_product(quantity);