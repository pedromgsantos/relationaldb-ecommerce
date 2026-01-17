-- -----------------------------------------------------
-- Group members
-- -----------------------------------------------------
-- Pedro Santos - Student number: 20250399
-- Miguel Correia - Student number: 20250381
-- Pedro Fernandes - Student number: 20250418
-- Tiago Duarte - Student number: 20250360
-- -----------------------------------------------------


-- -----------------------------------------------------
-- Schema nova_spotech
-- -----------------------------------------------------
CREATE DATABASE IF NOT EXISTS nova_spotech;
USE nova_spotech;
-- -----------------------------------------------------


-- -----------------------------------------------------
-- Reset
-- -----------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Product_Review;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Order_Item;
DROP TABLE IF EXISTS `Order`;
DROP TABLE IF EXISTS Cart_Item;
DROP TABLE IF EXISTS Cart;
DROP TABLE IF EXISTS Wishlist_Item;
DROP TABLE IF EXISTS Wishlist;
DROP TABLE IF EXISTS Payment_Method;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Supplier;
DROP TABLE IF EXISTS log;
DROP TABLE IF EXISTS `User`;
DROP TABLE IF EXISTS Address;

SET FOREIGN_KEY_CHECKS = 1;
-- -----------------------------------------------------


-- -----------------------------------------------------
-- Tables
-- ------------------------~-----------------------------

-- Table: Address
CREATE TABLE Address (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    street VARCHAR(255) NOT NULL,
    number VARCHAR(10) NOT NULL,
    postal_code VARCHAR(12) NOT NULL,
    city VARCHAR(20) NOT NULL,
    district VARCHAR(20) NOT NULL,
    country VARCHAR(20) DEFAULT 'Portugal' NOT NULL
);

-- Table: User
CREATE TABLE `User` (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    address_id INT NOT NULL, 
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, 
    phone VARCHAR(20) UNIQUE NOT NULL,
    birth_date DATE NOT NULL,
    FOREIGN KEY (address_id) REFERENCES Address(address_id) ON DELETE RESTRICT
);

-- Table: Supplier
CREATE TABLE Supplier (
    supplier_id TINYINT PRIMARY KEY AUTO_INCREMENT,
    address_id INT NOT NULL, 
    company_name VARCHAR(50) NOT NULL,
    tax_id VARCHAR(20) UNIQUE NOT NULL,
    phone VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    website VARCHAR(255) UNIQUE,
    FOREIGN KEY (address_id) REFERENCES Address(address_id) ON DELETE RESTRICT
);

-- Table: Category
CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

-- Table: Product
CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    short_description VARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE RESTRICT
);

-- Table: Inventory
CREATE TABLE Inventory (
    product_id INT NOT NULL,
    supplier_id TINYINT NOT NULL,
    quantity INT DEFAULT 0,
    last_update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id) ON DELETE CASCADE
);

-- Table: Cart
CREATE TABLE Cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id) ON DELETE CASCADE
);

-- Table: Cart_Item (linking table)
CREATE TABLE Cart_Item (
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (cart_id, product_id),
    FOREIGN KEY (cart_id) REFERENCES Cart(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE
);

-- Table: Wishlist
CREATE TABLE Wishlist (
    wishlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(100) DEFAULT 'My List',
    description TEXT,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id) ON DELETE CASCADE
);

-- Table: Wishlist_Item
CREATE TABLE Wishlist_Item (
    wishlist_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (wishlist_id, product_id),
    FOREIGN KEY (wishlist_id) REFERENCES Wishlist(wishlist_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE
);

-- Table: Order
CREATE TABLE `Order` (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    shipping_address_id INT NOT NULL,
	status ENUM('CREATED','PAID','CANCELLED','SHIPPED','DELIVERED') NOT NULL DEFAULT 'CREATED',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id) ON DELETE SET NULL,
    FOREIGN KEY (shipping_address_id) REFERENCES Address(address_id) ON DELETE RESTRICT
);

-- Table: Order_Item (linking table). Ideally, we wouldn't store unit_price to avoid redundancy, but we must preserve the historical price at the time of purchase since Product prices may change over time.
CREATE TABLE Order_Item (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    supplier_id TINYINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    vat_rate DECIMAL(4,2) NOT NULL DEFAULT 0.23,
    PRIMARY KEY (order_id, product_id, supplier_id),
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE RESTRICT,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id) ON DELETE RESTRICT
);

-- Table: Payment_Method
CREATE TABLE Payment_Method (
    payment_method_id TINYINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type ENUM('credit_card', 'debit_card', 'mbway', 'paypal', 'bank_transfer') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id) ON DELETE CASCADE
);

-- Table: Payment
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_method_id TINYINT,
    status ENUM('pending', 'approved', 'failed', 'refunded') DEFAULT 'pending',
    transaction_id VARCHAR(20) UNIQUE, 
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES Payment_Method(payment_method_id) ON DELETE SET NULL
);

-- Table: Product_Review
CREATE TABLE Product_Review (
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(50),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, product_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE SET NULL
);

-- Log table
CREATE TABLE log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT NULL,
    event VARCHAR(30) NOT NULL,
    message VARCHAR(255) NOT NULL,
    entity VARCHAR(30) NULL,
    entity_id INT NULL,
    old_value VARCHAR(255) NULL,
    new_value VARCHAR(255) NULL,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id) ON DELETE SET NULL
);

-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------

-- Log product price changes
DELIMITER $$

DROP TRIGGER IF EXISTS trg_product_price_update_log $$
CREATE TRIGGER trg_product_price_update_log
AFTER UPDATE ON Product
FOR EACH ROW
BEGIN
    IF NOT (OLD.price <=> NEW.price) THEN
        INSERT INTO log (user_id, event, message, entity, entity_id, old_value, new_value)
        VALUES (
            NULL,
            'PRICE_CHANGED',
            CONCAT('Product price changed. product_id=', NEW.product_id),
            'Product',
            NEW.product_id,
            CAST(OLD.price AS CHAR),
            CAST(NEW.price AS CHAR)
        );
    END IF;
END $$

DELIMITER ;

-- Update stock before an order item is inserted + log stock movement
DELIMITER $$

DROP TRIGGER IF EXISTS trg_order_item_update_inventory $$
CREATE TRIGGER trg_order_item_update_inventory
BEFORE INSERT ON Order_Item
FOR EACH ROW
BEGIN
    DECLARE v_old_qty INT;
    DECLARE v_new_qty INT;

    SELECT quantity INTO v_old_qty
    FROM Inventory
    WHERE product_id = NEW.product_id
      AND supplier_id = NEW.supplier_id;

    IF v_old_qty IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Inventory row not found for this product and supplier.';
    END IF;

    IF v_old_qty < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Not enough stock available for this product and supplier.';
    END IF;

    UPDATE Inventory
    SET quantity = quantity - NEW.quantity
    WHERE product_id = NEW.product_id
      AND supplier_id = NEW.supplier_id;

    SET v_new_qty = v_old_qty - NEW.quantity;

    INSERT INTO log (user_id, event, message, entity, entity_id, old_value, new_value)
    VALUES (
        NULL,
        'STOCK_MOVEMENT',
        CONCAT('Stock decreased due to sale. product_id=', NEW.product_id,
               ', supplier_id=', NEW.supplier_id,
               ', qty_sold=', NEW.quantity),
        'Inventory',
        NULL,
        CONCAT('qty=', v_old_qty),
        CONCAT('qty=', v_new_qty)
    );
END$$

DELIMITER ;

-- Prevent Order from being marked as PAID without a CONFIRMED payment + log (UPDATE requirement)
DELIMITER $$

DROP TRIGGER IF EXISTS trg_order_paid_requires_confirmed_payment $$
CREATE TRIGGER trg_order_paid_requires_confirmed_payment
BEFORE UPDATE ON `Order`
FOR EACH ROW
BEGIN
    DECLARE v_confirmed_payments INT DEFAULT 0;

    IF OLD.status <> 'PAID' AND NEW.status = 'PAID' THEN

        SELECT COUNT(*)
          INTO v_confirmed_payments
        FROM Payment p
        WHERE p.order_id = NEW.order_id
          AND p.status = 'approved';

        IF v_confirmed_payments = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Order cannot be marked as PAID unless there is an approved payment.';
        END IF;

        INSERT INTO log (user_id, event, message, entity, entity_id, old_value, new_value)
        VALUES (
            NEW.user_id,
            'ORDER_STATUS',
            CONCAT('Order status changed to PAID. order_id=', NEW.order_id),
            'Order',
            NEW.order_id,
            OLD.status,
            NEW.status
        );
    END IF;
END$$

DELIMITER ;

-- Log new user registration
DELIMITER $$

CREATE TRIGGER trg_new_user_insert_log
AFTER INSERT ON `User`
FOR EACH ROW
BEGIN
    INSERT INTO log (user_id, event, message, entity, entity_id)
    VALUES (
        NEW.user_id,
        'NEW_USER',
        CONCAT('New user registered: ', NEW.name, ' (', NEW.email, ')'),
        'User',
        NEW.user_id
    );
END $$

DELIMITER ;

-- Log critical user data changes
DELIMITER $$

DROP TRIGGER IF EXISTS trg_user_update_log $$
CREATE TRIGGER trg_user_update_log
AFTER UPDATE ON `User`
FOR EACH ROW
BEGIN
    IF NOT (OLD.email <=> NEW.email) THEN
        INSERT INTO log (user_id, event, message, entity, entity_id, old_value, new_value)
        VALUES (NEW.user_id, 'USER_UPDATED', 'User email changed.', 'User', NEW.user_id, OLD.email, NEW.email);
    END IF;

    IF NOT (OLD.phone <=> NEW.phone) THEN
        INSERT INTO log (user_id, event, message, entity, entity_id, old_value, new_value)
        VALUES (NEW.user_id, 'USER_UPDATED', 'User phone changed.', 'User', NEW.user_id, OLD.phone, NEW.phone);
    END IF;

    IF NOT (OLD.address_id <=> NEW.address_id) THEN
        INSERT INTO log (user_id, event, message, entity, entity_id, old_value, new_value)
        VALUES (
            NEW.user_id,
            'USER_UPDATED',
            'User address changed.',
            'User',
            NEW.user_id,
            CONCAT('address_id=', OLD.address_id),
            CONCAT('address_id=', NEW.address_id)
        );
    END IF;

    IF NOT (OLD.password <=> NEW.password) THEN
        INSERT INTO log (user_id, event, message, entity, entity_id)
        VALUES (NEW.user_id, 'USER_UPDATED', 'User password changed.', 'User', NEW.user_id);
    END IF;
END $$

DELIMITER ;

-- Log payment status changes (fraud / audit)
DELIMITER $$

DROP TRIGGER IF EXISTS trg_payment_status_update_log $$
CREATE TRIGGER trg_payment_status_update_log
AFTER UPDATE ON Payment
FOR EACH ROW
BEGIN
    IF NOT (OLD.status <=> NEW.status) THEN
        INSERT INTO log (user_id, event, message, entity, entity_id, old_value, new_value)
        VALUES (
            NULL,
            'PAYMENT_STATUS',
            CONCAT('Payment status changed. payment_id=', NEW.payment_id, ', order_id=', NEW.order_id),
            'Payment',
            NEW.payment_id,
            OLD.status,
            NEW.status
        );
    END IF;
END $$

DELIMITER ;

-- -----------------------------------------------------
-- Inserts
-- -----------------------------------------------------

-- Addresses (several European countries)
INSERT INTO Address (street, number, postal_code, city, district, country) VALUES
('Rua Augusta',            '10',  '1100-048', 'Lisboa',    'Lisboa',         'Portugal'),
('Gran Via',               '25',  '28013',    'Madrid',    'Madrid',         'Spain'),
('Alexanderplatz',         '3',   '10178',    'Berlin',    'Berlin',         'Germany'),
('Baker Street',           '221B','NW1 6XE',  'London',    'Greater London', 'United Kingdom'),
('Bahnhofstrasse',         '15',  '8001',     'Zurich',    'Zurich',         'Switzerland'),
-- Alternative shipping addresses
('Rua de Santa Catarina',  '100', '4000-002', 'Porto',     'Porto',          'Portugal'),
('Carrer de Mallorca',     '200', '08013',    'Barcelona', 'Catalonia',      'Spain'),
('Oranienburger Strasse',  '18',  '10178',    'Berlin',    'Berlin',         'Germany'),
('Oxford Street',          '90',  'W1D 1BS',  'London',    'Greater London', 'United Kingdom'),
('Avenida da Liberdade',   '150', '1250-096', 'Lisboa',    'Lisboa',         'Portugal'),
-- Supplier addresses
('Zona Industrial Norte',  '100', '4470-000', 'Maia',      'Porto',          'Portugal'),
('Industriestrasse',       '50',  '80331',    'Munich',    'Bavaria',        'Germany'),
('Via Roma',               '12',  '00100',    'Rome',      'Lazio',          'Italy'),
('Rue de Rivoli',          '45',  '75001',    'Paris',     'Île-de-France',  'France');

-- Users
INSERT INTO `User` (address_id, name, email, password, phone, birth_date) VALUES
(1,  'João Silva',     'joao.silva@example.com',     'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '910000001', '1990-03-15'),
(2,  'María García',   'maria.garcia@example.com',   '9e5b8b1d3b4b5f8e8f9e3c7b8b9e6d5c4b3a2f1e0d9c8b7a6f5e4d3c2b1a0f9e8', '610000002', '1992-07-21'),
(3,  'Hans Müller',    'hans.mueller@example.com',   '8d5e957f297893487bd98fa830fa6413df9d0e8c6f8e7d6c5b4a3f2e1d0c9b8a', '490000003', '1988-11-05'),
(4,  'Emily Brown',    'emily.brown@example.com',    '7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d3c2b1a0f9e8d7c6', '740000004', '1995-01-30'),
(5,  'Luca Meier',     'luca.meier@example.com',     '6f5e4d3c2b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5', '410000005', '1985-06-10'),
(10, 'Ana Pereira',    'ana.pereira@example.com',    '5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b', '910000010', '1998-09-14'),
(6,  'Pedro Costa',    'pedro.costa@example.com',    '4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c', '910000011', '1991-12-02'),
(7,  'Sofia Martins',  'sofia.martins@example.com',  '3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d', '910000012', '1993-04-27'),
(8,  'Carlos López',   'carlos.lopez@example.com',   '2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e', '610000013', '1989-08-19'),
(9,  'Giulia Bianchi', 'giulia.bianchi@example.com', '1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f', '390000014', '1996-02-11');

-- Suppliers (Portugal and Germany)
INSERT INTO Supplier (address_id, company_name, tax_id, phone, email, website) VALUES
(11, 'TechSupply Lda',    'PT500000001', '220000001', 'contact@techsupply.pt', 'https://www.techsupply.pt'),
(12, 'EuroOffice GmbH',   'DE500000002', '890000002', 'info@eurooffice.de',    'https://www.eurooffice.de'),
(13, 'RomaTech SRL',      'IT500000003', '060000003', 'sales@romatech.it',     'https://www.romatech.it'),
(14, 'Paris Devices SAS', 'FR500000004', '010000004', 'contact@parisdevices.fr','https://www.parisdevices.fr');

-- Categories
INSERT INTO Category (name, description) VALUES
('Computers & Accessories', 'Mice, keyboards, hubs and computer accessories'),
('Office & Productivity',   'Stands, desks and office gear'),
('Audio & Music',           'Headphones, speakers and audio devices'),
('Smart Home & Lighting',   'Smart bulbs, lamps and home automation'),
('Monitors & Displays',     'Computer monitors and display devices'),
('Networking',              'Routers, switches and network accessories'),
('Storage',                 'External drives, SSDs and storage accessories');

-- Products
INSERT INTO Product (category_id, name, description, short_description, price) VALUES
(1, 'Wireless Mouse',          'Ergonomic wireless mouse',                              '2.4 GHz wireless mouse',             19.99),
(1, 'Mechanical Keyboard',     'Backlit mechanical keyboard',                           'RGB mechanical keyboard',             79.90),
(1, 'USB-C Hub 7-in-1',        'USB-C hub with HDMI and USB 3.0 ports',                 'USB-C hub 7-in-1',                    34.50),
(5, '27-inch Monitor',         '27-inch full HD monitor for work and gaming',           '27" monitor 1080p',                   189.00),
(2, 'Aluminium Laptop Stand',  'Adjustable aluminium laptop stand',                     'Aluminium laptop stand',              39.99),
(4, 'LED Desk Lamp',           'LED desk lamp with brightness control',                 'LED desk lamp',                       24.75),
(3, 'Wireless Headphones',     'Over-ear wireless headphones with noise isolation',     'Wireless headphones',                 59.90),
(6, 'Wi-Fi Router AX1800',     'Dual-band Wi-Fi 6 router for home and office',          'Wi-Fi 6 router',                      89.00),
(7, 'Portable SSD 1TB',        'High-speed portable SSD with USB-C',                    '1TB portable SSD',                    99.90),
(2, 'Ergonomic Desk Mat',      'Large desk mat for keyboard and mouse comfort',         'Extended desk mat',                   14.50),
(4, 'Smart Bulb E27',          'Smart LED bulb with app control',                       'Smart bulb E27',                      12.99),
(6, 'Gigabit Network Switch',  '5-port gigabit unmanaged network switch',               '5-port gigabit switch',               24.90);

-- Inventory
INSERT INTO Inventory (product_id, supplier_id, quantity) VALUES
(1,  1, 100),
(2,  1,  80),
(3,  1, 120),
(4,  2,  50),
(5,  2,  70),
(6,  2, 150),
(7,  3,  60),
(8,  3,  40),
(9,  4,  55),
(10, 1, 200),
(11, 4, 130),
(12, 2,  90);

-- Payment methods
INSERT INTO Payment_Method (user_id, type) VALUES
(1,  'mbway'),
(2,  'credit_card'),
(3,  'paypal'),
(4,  'debit_card'),
(5,  'bank_transfer'),
(6,  'credit_card'),
(7,  'mbway'),
(8,  'paypal'),
(9,  'credit_card'),
(10, 'debit_card');

-- Wishlist + items
INSERT INTO Wishlist (user_id, name, description) VALUES
(1,  'João''s Wishlist',       'Items João would like to buy soon'),
(3,  'Hans Tech List',         'Tech gear Hans is interested in'),
(4,  'Emily Home Office',      'Office products Emily is considering'),
(7,  'Sofia Setup',            'Products for Sofia''s desk setup'),
(9,  'Giulia Smart Home',      'Smart home products to try');

INSERT INTO Wishlist_Item (wishlist_id, product_id) VALUES
(1, 4),
(1, 2),
(2, 3),
(2, 1),
(3, 5),
(3, 6),
(4, 9),
(4, 10),
(5, 11),
(5, 6);

-- Cart + items
INSERT INTO Cart (user_id, creation_date) VALUES
(2, '2025-05-10 10:00:00'),
(4, '2025-05-15 11:30:00'),
(7, '2025-06-02 09:10:00'),
(9, '2025-06-07 18:45:00');

INSERT INTO Cart_Item (cart_id, product_id, quantity) VALUES
(1,  1, 1),
(1,  3, 1),
(2,  4, 1),
(2,  6, 2),
(3,  9, 1),
(3, 10, 1),
(4, 11, 4),
(4,  6, 1);

-- Orders (30 orders, some with multiple items)
-- 2023
INSERT INTO `Order` (user_id, shipping_address_id, order_date) VALUES
(1,  1,  '2023-01-15 10:30:00'),
(2,  2,  '2023-02-03 14:20:00'),
(3,  3,  '2023-02-18 09:10:00'),
(4,  4,  '2023-03-05 16:45:00'),
(5,  5,  '2023-03-21 11:05:00'),
(1,  6,  '2023-04-02 19:30:00'),
(2,  7,  '2023-04-18 08:55:00'),
(3,  3,  '2023-05-01 13:15:00'),
(4,  4,  '2023-05-20 17:40:00'),
(5,  5,  '2023-06-10 10:00:00');

-- 2024
INSERT INTO `Order` (user_id, shipping_address_id, order_date) VALUES
(1,  1,  '2024-01-12 09:25:00'),
(2,  2,  '2024-01-28 15:10:00'),
(3,  3,  '2024-02-09 11:50:00'),
(4,  4,  '2024-02-25 18:05:00'),
(5,  5,  '2024-03-11 12:30:00'),
(1,  6,  '2024-03-29 20:15:00'),
(2,  2,  '2024-04-07 10:40:00'),
(3,  3,  '2024-04-23 16:55:00'),
(4,  4,  '2024-05-05 09:05:00'),
(5,  5,  '2024-05-22 14:35:00');

-- 2025
INSERT INTO `Order` (user_id, shipping_address_id, order_date) VALUES
(1,  1,  '2025-01-08 09:00:00'),
(2,  2,  '2025-01-19 19:20:00'),
(3,  3,  '2025-02-02 11:10:00'),
(4,  4,  '2025-02-20 17:30:00'),
(5,  5,  '2025-03-04 13:45:00'),
(1,  6,  '2025-03-18 08:25:00'),
(2,  2,  '2025-04-01 15:55:00'),
(3,  3,  '2025-04-16 10:05:00'),
(4,  4,  '2025-05-03 16:20:00'),
(5,  5,  '2025-05-21 09:40:00');

-- Order items (some orders with multiple items)
INSERT INTO Order_Item (order_id, product_id, supplier_id, quantity, unit_price) VALUES
-- 2023
(1,  1, 1, 1, 19.99),

(2,  2, 1, 2, 79.90),
(2,  5, 2, 1, 39.99),

(3,  3, 1, 1, 34.50),

(4,  4, 2, 1, 189.00),
(4,  6, 2, 2, 24.75),

(5,  5, 2, 1, 39.99),
(5,  6, 2, 1, 24.75),

(6,  6, 2, 1, 24.75),
(7,  1, 1, 1, 19.99),

(8,  2, 1, 1, 79.90),
(8,  3, 1, 1, 34.50),

(9,  3, 1, 1, 34.50),
(10, 4, 2, 1, 189.00),

-- 2024
(11, 5, 2, 1, 39.99),

(12, 6, 2, 2, 24.75),
(12, 1, 1, 1, 19.99),

(13, 1, 1, 1, 19.99),
(14, 2, 1, 1, 79.90),

(15, 3, 1, 3, 34.50),
(15, 5, 2, 1, 39.99),

(16, 4, 2, 1, 189.00),
(17, 5, 2, 1, 39.99),

(18, 6, 2, 1, 24.75),
(18, 2, 1, 1, 79.90),

(19, 1, 1, 1, 19.99),
(20, 2, 1, 1, 79.90),

-- 2025
(21, 3, 1, 1, 34.50),

(22, 4, 2, 2, 189.00),
(22, 5, 2, 1, 39.99),

(23, 5, 2, 1, 39.99),
(24, 6, 2, 1, 24.75),

(25, 1, 1, 2, 19.99),
(25, 3, 1, 3, 34.50),

(26, 2, 1, 1, 79.90),
(27, 3, 1, 1, 34.50),

(28, 4, 2, 1, 189.00),
(28, 6, 2, 1, 24.75),

(29, 5, 2, 1, 39.99),

(30, 6, 2, 4, 24.75),
(30, 2, 1, 2, 79.90);

-- Payments
INSERT INTO Payment (order_id, payment_method_id, status, transaction_id) VALUES
-- 2023
(1,  1, 'approved', 'TX2023_001'),
(2,  2, 'approved', 'TX2023_002'),
(3,  3, 'approved', 'TX2023_003'),
(4,  4, 'approved', 'TX2023_004'),
(5,  5, 'approved', 'TX2023_005'),
(6,  1, 'approved', 'TX2023_006'),
(7,  2, 'approved', 'TX2023_007'),
(8,  3, 'approved', 'TX2023_008'),
(9,  4, 'approved', 'TX2023_009'),
(10, 5, 'approved', 'TX2023_010'),

-- 2024
(11, 1, 'approved', 'TX2024_011'),
(12, 2, 'approved', 'TX2024_012'),
(13, 3, 'approved', 'TX2024_013'),
(14, 4, 'approved', 'TX2024_014'),
(15, 5, 'approved', 'TX2024_015'),
(16, 1, 'approved', 'TX2024_016'),
(17, 2, 'approved', 'TX2024_017'),
(18, 3, 'approved', 'TX2024_018'),
(19, 4, 'approved', 'TX2024_019'),
(20, 5, 'approved', 'TX2024_020'),

-- 2025
(21, 1, 'approved', 'TX2025_021'),
(22, 2, 'approved', 'TX2025_022'),
(23, 3, 'approved', 'TX2025_023'),
(24, 4, 'approved', 'TX2025_024'),
(25, 5, 'approved', 'TX2025_025'),
(26, 1, 'approved', 'TX2025_026'),
(27, 2, 'approved', 'TX2025_027'),
(28, 3, 'approved', 'TX2025_028'),
(29, 4, 'approved', 'TX2025_029'),
(30, 5, 'approved', 'TX2025_030');

-- Product reviews (verified purchases, UNIQUE(user_id, product_id))
INSERT INTO Product_Review (product_id, user_id, order_id, rating, title, comment, review_date) VALUES
(1, 1,  1, 5, 'Great mouse',        'Very comfortable and responsive.', '2023-01-20 12:00:00'),
(2, 2,  2, 4, 'Solid keyboard',     'Good feel, a bit noisy.',          '2023-02-10 18:30:00'),
(3, 3,  3, 5, 'Useful hub',         'Everything works as expected.',    '2023-02-25 09:00:00'),
(4, 4,  4, 5, 'Excellent monitor',  'Great colors and size.',           '2023-03-15 20:10:00'),
(5, 5,  5, 4, 'Nice stand',         'Stable and well built.',           '2023-03-28 10:45:00'),
(6, 1,  6, 5, 'Perfect lamp',       'Light is very pleasant.',          '2023-04-05 21:00:00'),
(1, 2,  7, 4, 'Good mouse',         'Battery could last longer.',       '2023-04-25 08:30:00'),
(2, 3,  8, 5, 'Love this keyboard', 'Great for typing every day.',      '2023-05-05 14:20:00'),
(3, 4,  9, 4, 'Decent hub',         'Works fine with my laptop.',       '2023-05-25 19:10:00'),
(4, 5, 10, 5, 'Amazing monitor',    'Perfect for gaming and work.',     '2023-06-15 11:15:00'),
(2, 1, 26, 5, 'Fantastic keyboard', 'Very satisfying switches and great build quality.', '2025-03-22 10:05:00'),
(3, 1, 21, 4, 'Handy hub',          'Works well, HDMI is stable, gets slightly warm.',    '2025-01-12 18:40:00'),
(5, 2, 17, 4, 'Sturdy stand',       'Stable base and neat finish.',                       '2024-04-12 08:55:00'),
(6, 2, 12, 5, 'Great desk lamp',    'Perfect brightness control, excellent for study.',  '2024-02-03 21:15:00'),
(9, 3, 28, 5, 'Fast SSD',           'Very fast transfers and compact design.',            '2025-04-30 09:10:00'),
(11,4, 24, 4, 'Nice smart bulb',    'App setup was easy, light is smooth.',               '2025-02-25 18:20:00'),
(8, 5, 22, 4, 'Good router',        'Stable Wi-Fi and easy setup.',                       '2025-01-30 16:20:00');

-- -----------------------------------------------------
-- Invoice
-- -----------------------------------------------------

DROP VIEW IF EXISTS Invoice_Header;
DROP VIEW IF EXISTS Invoice_Details;

CREATE VIEW Invoice_Header AS
SELECT
    o.order_id AS invoice_id,
    o.order_date,
    COALESCE(u.name, 'Deleted user') AS customer_name,
    pm.type AS payment_method,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS subtotal,
    ROUND(SUM(oi.quantity * oi.unit_price * oi.vat_rate), 2) AS vat_amount,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 + oi.vat_rate)), 2) AS total_with_vat
FROM `Order` o
LEFT JOIN `User` u ON o.user_id = u.user_id
JOIN Order_Item oi ON o.order_id = oi.order_id
LEFT JOIN Payment p ON p.order_id = o.order_id
LEFT JOIN Payment_Method pm ON pm.payment_method_id = p.payment_method_id
GROUP BY o.order_id, o.order_date, customer_name, pm.type;

CREATE VIEW Invoice_Details AS
SELECT
    o.order_id AS invoice_id,
    p.product_id,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price,
    oi.vat_rate,
    ROUND(oi.quantity * oi.unit_price, 2) AS line_total
FROM `Order` o
JOIN Order_Item oi ON o.order_id = oi.order_id
JOIN Product p ON oi.product_id = p.product_id;

SELECT * FROM Invoice_Header WHERE invoice_id = 2;
SELECT * FROM Invoice_Details WHERE invoice_id = 1;

-- ----------------------------------------------------------------------------
-- Queries for the CEO questions
-- ----------------------------------------------------------------------------

-- 1. Customers with the highest lifetime purchase value
SELECT u.name,
       u.email,
       a.country,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(oi.unit_price * oi.quantity) AS lifetime_value
FROM `User` u
JOIN `Order` o ON u.user_id = o.user_id
JOIN Address a ON u.address_id = a.address_id
JOIN Order_Item oi ON o.order_id = oi.order_id
JOIN Payment pay ON pay.order_id = o.order_id
WHERE pay.status = 'approved'
GROUP BY u.user_id, u.name, u.email, a.country
ORDER BY lifetime_value DESC;

-- 2. Top 5 best-selling products
SELECT p.name,
       COUNT(DISTINCT oi.order_id) AS total_orders,
       SUM(oi.quantity) AS units_sold,
       SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM Product p
JOIN Order_Item oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY units_sold DESC, total_revenue DESC
LIMIT 5;


-- 3. Best rated products
SELECT p.name,
       AVG(pr.rating) as avg_rating,
       COUNT(*) as num_reviews
FROM Product p
JOIN Product_Review pr ON p.product_id = pr.product_id
GROUP BY p.product_id, p.name, p.price
HAVING num_reviews > 0
ORDER BY avg_rating DESC, num_reviews DESC;

-- 4. Frequently bought together (top 10 product pairs)
SELECT p1.name AS product_1,
       p2.name AS product_2,
       COUNT(DISTINCT oi1.order_id) AS times_bought_together
FROM Order_Item oi1
JOIN Order_Item oi2
  ON oi1.order_id = oi2.order_id
 AND oi1.product_id < oi2.product_id
JOIN Product p1 ON oi1.product_id = p1.product_id
JOIN Product p2 ON oi2.product_id = p2.product_id
GROUP BY p1.product_id, p1.name, p2.product_id, p2.name
ORDER BY times_bought_together DESC
LIMIT 10;

-- 5. Year-over-year growth
SELECT YEAR(o.order_date) AS year,
       COUNT(DISTINCT o.order_id) AS num_orders,
       SUM(oi.unit_price * oi.quantity) AS annual_revenue,
       ROUND(
         SUM(oi.unit_price * oi.quantity) / COUNT(DISTINCT o.user_id),
         2
       ) AS revenue_per_customer
FROM `Order` o
JOIN Order_Item oi ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_date)
ORDER BY year;

-- ----------------------------------------------------------------------------
-- Testing Triggers
-- ----------------------------------------------------------------------------

-- In a fresh run, the next order_id is expected to be 31

-- Create a new order without any payment
INSERT INTO `Order` (user_id, shipping_address_id, order_date)
VALUES (1, 1, '2025-06-01 10:00:00');

-- Insert an order item
INSERT INTO Order_Item (order_id, product_id, supplier_id, quantity, unit_price)
VALUES (31, 1, 1, 1, 19.99);

-- Try to mark the order as PAID (should fail: no approved payment). This commented to not interrupt the flow
-- UPDATE `Order` SET status = 'PAID' WHERE order_id = 31;

-- Add an approved payment
INSERT INTO Payment (order_id, payment_method_id, status, transaction_id, payment_date)
VALUES (31, 1, 'approved', 'TX_TEST_31', NOW());

-- Try again (should succeed)
UPDATE `Order`
SET status = 'PAID'
WHERE order_id = 31;

-- Stock trigger test
INSERT INTO `Order` (user_id, shipping_address_id, order_date)
VALUES (2, 2, '2025-06-02 12:00:00');

-- Try to insert more items than available in stock (should fail). This is commented to not interrupt the flow
-- INSERT INTO Order_Item (order_id, product_id, supplier_id, quantity, unit_price) VALUES (32, 1, 1, 999999, 19.99);

-- Check logs
SELECT * FROM log ORDER BY log_id DESC;

-- ----------------------------------------------------------------------------
-- Testing Indexes (EXPLAIN before and after)
-- ----------------------------------------------------------------------------

-- Selected query: Customers with the highest lifetime purchase value
-- 1) EXPLAIN before creating indexes

EXPLAIN FORMAT = TRADITIONAL
SELECT u.name,
       u.email,
       a.country,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(oi.unit_price * oi.quantity) AS lifetime_value
FROM `User` u
JOIN `Order` o ON u.user_id = o.user_id
JOIN Address a ON u.address_id = a.address_id
JOIN Order_Item oi ON o.order_id = oi.order_id
JOIN Payment pay ON pay.order_id = o.order_id
WHERE pay.status = 'approved'
GROUP BY u.user_id, u.name, u.email, a.country
ORDER BY lifetime_value DESC;


-- 2) Create indexes to improve join and filtering performance

CREATE INDEX idx_user_address_id            ON `User`(address_id);

CREATE INDEX idx_order_user_id              ON `Order`(user_id);
CREATE INDEX idx_order_order_date           ON `Order`(order_date);

CREATE INDEX idx_payment_order_id           ON Payment(order_id);
CREATE INDEX idx_payment_status             ON Payment(status);

CREATE INDEX idx_order_item_product_id      ON Order_Item(product_id);
CREATE INDEX idx_order_item_supplier_id     ON Order_Item(supplier_id);


-- 3) EXPLAIN after creating indexes

EXPLAIN FORMAT = TRADITIONAL
SELECT u.name,
       u.email,
       a.country,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(oi.unit_price * oi.quantity) AS lifetime_value
FROM `User` u
JOIN `Order` o ON u.user_id = o.user_id
JOIN Address a ON u.address_id = a.address_id
JOIN Order_Item oi ON o.order_id = oi.order_id
JOIN Payment pay ON pay.order_id = o.order_id
WHERE pay.status = 'approved'
GROUP BY u.user_id, u.name, u.email, a.country
ORDER BY lifetime_value DESC;

-- ---------------------------------------------------------------------------
-- EXPLAIN: Index impact on query performance (this could not go on the video because it was too long)
-- ---------------------------------------------------------------------------
-- Before creating indexes, the execution plan showed full table scans (type ALL),
-- usage of temporary tables and filesort, and join buffers, indicating an
-- inefficient execution of the query.
--
-- After creating indexes on the columns used in JOIN and WHERE clauses,
-- the execution plan improved significantly. Most tables are accessed using
-- ref or eq_ref, the number of processed rows is reduced, and temporary tables
-- and filesort operations are no longer required.
--
-- This demonstrates that proper indexing greatly improves query performance
-- and scalability.
-- ---------------------------------------------------------------------------

-- -----------------------------------------------------
-- End
-- -----------------------------------------------------