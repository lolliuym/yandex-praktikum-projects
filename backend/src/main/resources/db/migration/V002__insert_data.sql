-- Вставка продуктов
INSERT INTO product (name, picture_url, price) VALUES
('Сливочная', 'https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/6.jpg', 320),
('Особая', 'https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/5.jpg', 179),
('Молочная', 'https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/4.jpg', 225),
('Нюренбергская', 'https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/3.jpg', 315),
('Мюнхенская', 'https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/2.jpg', 330),
('Русская', 'https://res.cloudinary.com/sugrobov/image/upload/v1623323635/repos/sausages/1.jpg', 189);

-- Обновляем sequence для product
-- SELECT setval('products_id_seq', (SELECT MAX(id) FROM product));

-- Вставка заказов
INSERT INTO orders (id, status, date_created) VALUES
(1, 'shipped', '2025-03-24'),
(2, 'shipped', '2025-01-04'),
(3, 'shipped', '2025-02-26'),
(4, 'shipped', '2025-03-22'),
(5, 'shipped', '2025-01-27'),
(6, 'shipped', '2025-03-24'),
(7, 'shipped', '2025-02-16'),
(8, 'shipped', '2025-01-06'),
(9, 'cancelled', '2025-03-26'),
(10, 'shipped', '2025-02-14'),
(11, 'pending', '2025-01-27'),
(12, 'cancelled', '2025-03-22'),
(13, 'shipped', '2025-02-25'),
(14, 'cancelled', '2025-02-21'),
(15, 'pending', '2025-02-15'),
(16, 'shipped', '2025-01-27'),
(17, 'cancelled', '2024-12-31'),
(18, 'pending', '2025-01-07'),
(19, 'cancelled', '2025-01-28'),
(20, 'pending', '2025-02-17'),
(21, 'cancelled', '2025-01-17'),
(22, 'pending', '2025-01-20'),
(23, 'pending', '2025-03-25'),
(24, 'pending', '2025-02-18'),
(25, 'pending', '2025-02-04'),
(26, 'shipped', '2025-01-19'),
(27, 'pending', '2025-02-27'),
(28, 'pending', '2025-03-04'),
(29, 'pending', '2025-01-26'),
(30, 'cancelled', '2025-01-22'),
(31, 'shipped', '2025-03-06'),
(32, 'cancelled', '2025-01-01');

-- Обновляем sequence для orders
-- SELECT setval('orders_id_seq', (SELECT MAX(id) FROM orders));

-- Вставка связей заказов и продуктов
INSERT INTO order_product (quantity, order_id, product_id) VALUES
(28, 1, 5),
(46, 2, 3),
(41, 3, 5),
(46, 4, 2),
(40, 5, 1),
(43, 6, 5),
(33, 7, 1),
(24, 8, 6),
(32, 9, 4),
(49, 10, 3),
(25, 11, 4),
(45, 12, 3),
(17, 13, 5),
(36, 14, 4),
(45, 15, 2),
(20, 16, 4),
(42, 17, 3),
(38, 18, 1),
(12, 19, 5),
(24, 20, 3),
(39, 21, 1),
(32, 22, 3),
(45, 23, 5),
(47, 24, 1),
(2, 25, 3),
(19, 26, 6),
(36, 27, 3),
(13, 28, 4),
(4, 29, 2),
(18, 30, 2),
(5, 31, 1),
(9, 32, 4);