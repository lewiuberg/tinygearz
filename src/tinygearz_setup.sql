/* ************************************************************************* */
/* *************************** TinyGearz Database ************************** */
/* ************************************************************************* */

/* To not repeat the comments, only the first encounter will be commented on.*/
/* Most things are self-explanatory since every attribute definition is on   */
/* one line. No limitations on characters per line has been defined.         */

/****************************** Initialisation *******************************/

/* Disabeling foreign keys, to be able to drop tables.                       */
PRAGMA foreign_keys = OFF;

/* This file is only supposed to be used while doing the initial setup,      */
/* therefore it drops any existing tables during the implementation process. */
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS salesperson;
DROP TABLE IF EXISTS mechanic;
DROP TABLE IF EXISTS service_ticket;
DROP TABLE IF EXISTS service_ticket_mechanic;
DROP TABLE IF EXISTS brand_certification;
DROP TABLE IF EXISTS watch;
DROP TABLE IF EXISTS model;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS used_part;

/* Enabeling foreign keys. */
PRAGMA foreign_keys = ON;

/*************************** Database definition *****************************/

/* Creating all tables according to the specifications of the EARD.          */

CREATE TABLE customer (
    /* Defining an atutoincrementing primary key */
    customer_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    /* Limiting input possibilities. */
    first_name TEXT(30) NOT NULL CHECK(first_name NOT GLOB '*[^a-zæøåA-ZÆØÅ ]*'), 
    middle_name TEXT(30) CHECK(middle_name NOT GLOB '*[^a-zæøåA-ZÆØÅ ]*'),
    last_name TEXT(30) NOT NULL CHECK(last_name NOT GLOB '*[^a-zæøåA-ZÆØÅ ]*'),
    streetname TEXT(50) NOT NULL CHECK(streetname NOT GLOB '*[^a-zæøåA-ZÆØÅ ]*'),
    building_number TEXT(5) NOT NULL CHECK(building_number NOT GLOB '*[^a-z0-9 ]*'),
    /* Defining the exact length of input */
    postal_code INTEGER(4) NOT NULL CHECK (LENGTH(postal_code) = 4),
    city TEXT(30) NOT NULL CHECK(first_name NOT GLOB '*[^a-zæøåA-ZÆØÅ ]*'),
    phone_number INTEGER(8) NOT NULL CHECK (LENGTH(phone_number) = 8),
    e_mail TEXT(75)
);

CREATE TABLE employee (
    employee_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    first_name TEXT(30) NOT NULL CHECK(first_name NOT GLOB '*[^a-zæøåA-ZÆØÅ ]*'),
    middle_name TEXT(30) CHECK(middle_name NOT GLOB '*[^a-zæøåA-ZÆØÅ ]*'),
    last_name TEXT(30) NOT NULL CHECK(last_name NOT GLOB '*[^a-zæøåA-ZÆØÅ ]*'),
    streetname TEXT(50) NOT NULL CHECK(streetname NOT GLOB '*[^a-zæøåA-ZÆØÅ ]*'),
    building_number TEXT(5) NOT NULL CHECK(building_number NOT GLOB '*[^a-z0-9 ]*'),
    postal_code INTEGER(4) NOT NULL CHECK (LENGTH(postal_code) = 4),
    city TEXT(30) NOT NULL CHECK(first_name NOT GLOB '*[^a-zæøåA-ZÆØÅ ]*'),
    phone_number INTEGER(8) NOT NULL CHECK (LENGTH(phone_number) = 8),
    e_mail TEXT(75),
    /* If there is not an input to this attribute on a new new, */
    /* the value will be set to the default value. */
    salary REAL(4, 2) DEFAULT 225.00
);

CREATE TABLE salesperson (
    salesperson_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL UNIQUE,
    /* Referencing an attribute from another table; */
    /* on the many side of a one yo many relationship. */
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE mechanic (
    mechanic_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE brand_certification (
    brand_name TEXT(30) NOT NULL CHECK(brand_name NOT GLOB '*[^a-zæøåA-ZÆØÅ0-9 ]*'),
    mechanic_id INTEGER NOT NULL,
    valid_from TEXT NOT NULL DEFAULT (DATE('now', 'localtime')),
    valid_to TEXT,
    PRIMARY KEY (brand_name, mechanic_id)
);

CREATE TABLE model (
    model_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    model_name TEXT(30) NOT NULL UNIQUE CHECK(model_name NOT GLOB '*[^a-zæøåA-ZÆØÅ0-9 ]*'),
    water_resistance_original INTEGER(3) NOT NULL DEFAULT 0
);

CREATE TABLE watch (
    watch_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER(4) NOT NULL,
    manufacturer TEXT(50) NOT NULL CHECK(manufacturer NOT GLOB '*[^a-zæøåA-ZÆØÅ ]*'),
    model_id INTEGER NOT NULL,
    serial_number TEXT(30) UNIQUE CHECK(serial_number NOT GLOB '*[^a-zæøåA-ZÆØÅ0-9 ]*'),
    colour TEXT(30) NOT NULL CHECK(colour NOT GLOB '*[^a-zæøåA-ZÆØÅ0-9 ]*') DEFAULT 'steel',
    value_estimate INTEGER,
    part_permission INTEGER(1) CHECK(LENGTH(part_permission) = 1 AND part_permission NOT GLOB '*[^0-1 ]*') DEFAULT 0,
    cosmetic_condition_rating INTEGER(1) CHECK(LENGTH(cosmetic_condition_rating) = 1 AND cosmetic_condition_rating NOT GLOB '*[^0-5 ]*') DEFAULT 5,
    cosmetic_description TEXT(1000),
    functioning INTEGER(1) CHECK(LENGTH(functioning) = 1 AND functioning NOT GLOB '*[^0-1 ]*') DEFAULT 0,
    precision REAL(2, 3) DEFAULT 99.99,
    amplitude INTEGER(3) DEFAULT 320,
    beat_error INTEGER(2) DEFAULT 0,
    water_resistance_unit TEXT(8) NOT NULL CHECK(water_resistance_unit NOT GLOB '*[^a-zA-Z ]*') DEFAULT 'metric',
    water_resistance_current INTEGER(3) DEFAULT 0,
    FOREIGN KEY (model_id) REFERENCES model(model_id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE service_ticket (
    service_ticket_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    watch_id INTEGER NOT NULL,
    salesperson_id INTEGER NOT NULL,
    labour_time INTEGER(4) DEFAULT 60,
    labour_rate REAL(4,2) NOT NULL,
    customer_comment TEXT(1000),
    received TEXT NOT NULL DEFAULT (DATE('now', 'localtime')),
    returned TEXT,
    service_comment TEXT(1000),
    FOREIGN KEY (watch_id) REFERENCES watch(watch_id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (salesperson_id) REFERENCES salesperson(salesperson_id) ON UPDATE CASCADE ON DELETE SET NULL
);
/* Linking table used for many-to-many relationships */
CREATE TABLE service_ticket_mechanic (
    service_ticket_id INTEGER NOT NULL,
    mechanic_id INTEGER,
    FOREIGN KEY (service_ticket_id) REFERENCES service_ticket(service_ticket_id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (mechanic_id) REFERENCES mechanic(mechanic_id) ON UPDATE CASCADE ON DELETE SET NULL,
    /* Composite primary key; composed of two forreign keys. */
    PRIMARY KEY (service_ticket_id, mechanic_id)
);

CREATE TABLE inventory (
    part_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    manufacturer TEXT(30) NOT NULL CHECK(manufacturer NOT GLOB '*[^a-zæøåA-ZÆØÅ0-9 ]*'),
    manufacturer_id TEXT(30) NOT NULL CHECK(manufacturer_id NOT GLOB '*[^a-zæøåA-ZÆØÅ0-9 ]*'),
    description TEXT(1000) NOT NULL,
    retail_price REAL(6, 2) NOT NULL,
    selling_price REAL(6, 2) NOT NULL,
    stock_quantity INTEGER(4) NOT NULL DEFAULT 0
);

CREATE TABLE used_part (
    service_ticket_id INTEGER NOT NULL,
    part_id INTEGER NOT NULL,
    quantity_used INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (service_ticket_id) REFERENCES service_ticket(service_ticket_id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (part_id) REFERENCES inventory(part_id) ON UPDATE CASCADE ON DELETE SET NULL,
    PRIMARY KEY (service_ticket_id, part_id)
);

/***************************** Data insertion ********************************/

/* Defining which tables to insert the data into and which attributes that   */
/* are to receive data. Not necessary every attribute in each table;         */
/* If an entry needs to include an attribute that is not included the        */
/* original statement, an additional input statement is needed.              */
/* Here the autoincrementing primary key is excluded for instance.           */

INSERT INTO customer (first_name, middle_name, last_name, streetname, building_number, postal_code, city, phone_number, e_mail) VALUES
('Samuel', 'Lie', 'Hansen', 'Kirkeveien', '18 b', 4848, 'Arendal', 95011946, 'samuelhansen@icloud.com'),
('Marie', 'Lie', 'Hansen', 'Kirkeveien', '18 b', 4848, 'Arendal', 93455856, 'marie@icloud.com'),
('Marit', NULL, 'Stalone', 'Solaasen', 11, 4817, 'His', 47653924, 'ma-ub@texas.no'),
('Morten', 'Nielsen', 'Stalone', 'Solaasen', 11, 4817, 'His', 48348894, 'mmn@texas.no'),
('Jan Georg', NULL, 'Hansen', 'Søndregate', '5 b', 7500, 'Trondheim', 99584579, 'jan@hansen.no');

INSERT INTO employee (first_name, middle_name, last_name, streetname, building_number, postal_code, city, phone_number, e_mail, salary) VALUES
('Johan', NULL, 'Brasøy', 'Bringebaerveien', '57', 4980, 'Gjerstad', 93881196, 'jb@tg.no', 240.00),
('Tommy', NULL, 'Jensen', 'Moskvaveien', 3, 4870, 'Grimstad', 97911637, 'tnj@tg.no', 265.00),
('Egil Frank', NULL, 'Mortenson', 'Birketveit', 128, 4870, 'Vik', 99294120, 'eam@tg.no', 185.00),
('Arvid', NULL, 'Lauvland', 'Skraaleveien', 98, 4900, 'Tvedestrand', 97502394, 'al@tg.no', 265.00),
('Børge', NULL, 'Rosen', 'Skotveien', 30, 4900, 'Tvedestrand', 90943419, 'br@tg.no', 265.00),
('Sahabettin', 'Berkan', 'Gustavsen', 'Dvergsnesfaret', 3, 4639, 'Kristiansand S', 66930107, 'sbg@tg.no', 300.00),
('Hanne', 'Svensen', 'Jensen', 'Dvergsnesfaret', 3, 4639, 'Kristiansand S', 93457633, 'hhg@tg.no', 300.00);

INSERT INTO salesperson (employee_id) VALUES
(6),
(7);

INSERT INTO mechanic (employee_id) VALUES
(1),
(2),
(3),
(4),
(5),
(7);

INSERT INTO brand_certification (brand_name, mechanic_id, valid_from, valid_to) VALUES
/* Specifying the exact date */
('rolex', 1, DATE('2018-06-01'), DATE('2018-06-01', '+1095 days')),
('rolex', 2, DATE('2019-01-01'), DATE('2019-01-01', '+1095 days')),
('rolex', 3, DATE('2019-01-01'), DATE('2019-01-01', '+1095 days')),
('breitling', 1, DATE('2018-10-01'), DATE('2018-10-01', '+1825 days')),
('breitling', 4, DATE('2018-10-01'), DATE('2018-10-01', '+1825 days')),
('breitling', 5, DATE('2019-04-01'), DATE('2019-04-01', '+1825 days')),
('breitling', 6, DATE('2019-04-01'), DATE('2019-04-01', '+1825 days'));

INSERT INTO model (model_name, water_resistance_original) VALUES
('submariner', 100),
('oyster', 100),
('cosmograph', 100),
('navitimer', 100),
('professional emergency', 100),
('transocean', 50);

INSERT INTO watch (customer_id, manufacturer, model_id, serial_number, colour, value_estimate, part_permission, cosmetic_condition_rating, cosmetic_description, functioning, precision, amplitude, beat_error, water_resistance_unit, water_resistance_current) VALUES
(1, 'rolex', 1, 'df6g54d6g46', 'steel', 220000, 1, 5, 'This text is not important', 0, 98.8, 249, .1, 'metric', 95),
(3, 'rolex', 1, 'df6g47d6g47', 'gold', 135000, 1, 4, 'This text is not important', 1, 98.2, 318, .095, 'metric', 50),
(1, 'breitling', 4, 'DDGD5465ddg', 'steel', 180000, 1, 3, 'This text is not important', 1, 98.1, 228, .1, 'metric', 55),
(2, 'breitling', 5, 'AAGD5465r4g', 'gold', 140000, 1, 5, 'This text is not important', 0, 98.6, 319, .1, 'metric', 70),
(4, 'rolex', 2, 'df6g47d6g49', 'gold', 135000, 0, 4, 'This text is not important', 0, 97.9, 317, .09, 'metric', 95),
(5, 'breitling', 6, 'DDGD5465rrg', 'steel', 180000, 1, 4, 'This text is not important', 1, 98.1, 318, .1, 'metric', 55),
(5, 'rolex', 3, 'df6g47da349', 'silver', 180000, 1, 4, 'This text is not important', 1, 99.4, 240, .1, 'metric', 95);

INSERT INTO service_ticket (watch_id, salesperson_id, labour_time, labour_rate, customer_comment, received, returned, service_comment) VALUES
(1, 1, 120, 400.00, 'Please make it work', DATE('2019-04-01'), DATE('2019-04-15'), 'Metal shaving locking spokewheel'),
(2, 2, 60, 400.00, 'Runs slow', DATE('2019-04-02'), DATE('2019-04-07'), 'Weak mainspring'),
/* Specifying the date, based on the current date and manipulating it from there */
(2, 1, 60, 400.00, 'Broken glass', DATE('now', 'localtime', '-6 days'), DATE('now', 'localtime'), "Glass replaced"),
(3, 2, 30, 350.00, 'Runs slow', DATE('now', 'localtime', '-6 days'), DATE('now', 'localtime', '-5 days'), 'Dry lubricant'),
(4, 1, 90, 350.00, 'Please make it work', DATE('now', 'localtime', '-4 days'), DATE('now', 'localtime', '-3 days'), 'Metal shaving locking spokewheel'),
(5, 1, NULL, 400.00, 'Not running', DATE('now', 'localtime', '-6 days'), NULL, NULL),
(6, 1, NULL, 350.00, 'Runs slow', DATE('now', 'localtime', '-2 days'), NULL, 'Weak mainspring'),
(7, 2, 60, 400.00, 'Checkup', DATE('now', 'localtime', '-1 days'), DATE('now', 'localtime'), 'Everything ok. Applied some lubricant'),
(1, 1, 60, 400.00, 'Runs slow', DATE('now', 'localtime'), DATE('now', 'localtime'),'Weak mainspring');

INSERT INTO service_ticket_mechanic (service_ticket_id, mechanic_id) VALUES
(1, 1),
(2, 2),
(3, 1),
(4, 4),
(5, 5),
(6, 3),
(7, 6),
(8, 2),
(9, 2);

INSERT INTO inventory (manufacturer, manufacturer_id, description, retail_price, selling_price, stock_quantity) VALUES
('rolex', 'MA78SUBjk342', 'mainspring for rolex', 100.00, 275.00, 73),
('rolex', 'SCW78GENjk34', 'small screw', 0.95, 5.00, 427),
('rolex', 'SCW78GENjk35', 'glass for submariner', 398.68, 1000.00, 20),
('breitling', '4645655456GG', 'mainspring for breitling', 77.29, 200.00, 57),
('breitling', 'SCW78GENjk34', 'small screw', 0.95, 5.00, 427),
('acme', 'AAA012003B', 'grease 1ml', 4, 9.00, 124),
('breitling', 'GLA78GE4jk35', 'glass for transocean', 295.50, 700.00, 15);

INSERT INTO used_part (service_ticket_id, part_id, quantity_used) VALUES
(2, 1, 1),
(2, 2, 2),
(3, 3, 1),
(3, 2, 3),
(4, 6, 1),
(7, 4, 1),
(7, 5, 2),
(7, 7, 1),
(7, 6, 2),
(8, 6, 1),
(9, 1, 1),
(9, 2, 2);

/******************************* Automating **********************************/

/* Creating trigger to update the inventory when parts get used              */
CREATE TRIGGER using_parts AFTER INSERT ON used_part
BEGIN
UPDATE inventory
/* Finds which value to subtract                                             */
SET stock_quantity = stock_quantity - (SELECT quantity_used
                                       FROM used_part
                                       WHERE rowid = (SELECT MAX(rowid)
                                                      FROM used_part))
/* Finds which row to update                                                 */
WHERE (SELECT part_id
       FROM used_part
       WHERE (rowid = (SELECT MAX(rowid)
                      FROM used_part))) = part_id;
END;
