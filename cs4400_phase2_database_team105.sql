-- CS4400: Introduction to Database Systems (Fall 2022)
-- Phase II: Create Table & Insert Statements [v0] Monday, September 5, 2022 @ 7:50pm (Local/EDT)

-- Team 105
-- Jyothi Guruprasad (jguruprasad3)
-- Palak Aggarwal (paggarwal39)
-- Varsha Srinivasan (vsrinivasan75)

-- ----------
-- SQL SCRIPT
-- ----------

DROP DATABASE IF EXISTS restaurant_supply;
CREATE DATABASE IF NOT EXISTS restaurant_supply;
USE restaurant_supply;

-- Table structure for 'user'
DROP TABLE IF EXISTS user;
CREATE TABLE user (
    username CHAR(20) NOT NULL UNIQUE,
    first_name CHAR(20) NOT NULL,
    last_name CHAR(20) NOT NULL,
    birthdate DATE NOT NULL,
    address CHAR(100) NOT NULL,
    PRIMARY KEY (username)
);
INSERT INTO user
VALUES 
	('agarcia7', 'Alejandro', 'Garcia', '1966-10-29', '710 Living Water Drive'),
	('awilson5', 'Aaron', 'Wilson', '1963-11-11', '220 Peachtree Street'),
	('bsummers4', 'Brie', 'Summers', '1976-02-09', '5105 Dragon Star Circle'),
    ('cjordan5', 'Clark', 'Jordan', '1966-06-05', '77 Infinite Stars Road'),
    ('ckann5', 'Carrot', 'Kann', '1972-09-01', '64 Knights Square Trail'),
    ('csoares8', 'Claire', 'Soares', '1965-09-03', '706 Living Stone Way'),
    ('echarles19', 'Ella', 'Charles', '1974-05-06', '22 Peachtree Street'),
    ('eross10', 'Erica', 'Ross', '1975-04-02', '22 Peachtree Street'),
    ('fprefontaine6', 'Ford', 'Prefontaine', '1961-01-28', '10 Hitch Hikers Lane'),
    ('hstark16', 'Harmon', 'Stark', '1971-10-27', '53 Tanker Top Lane'),
    ('jstone5', 'Jared', 'Stone', '1961-01-06', '101 Five Finger Way'),
    ('lrodriguez5', 'Lina', 'Rodriguez', '1975-04-02', '360 Corkscrew Circle'),
    ('mrobot1', 'Mister', 'Robot', '1988-11-02', '10 Autonomy Trace'),
	('mrobot2', 'Mister', 'Robot', '1988-11-02', '10 Clone Me Circle'),
	('rlopez6', 'Radish', 'Lopez', '1999-09-03', '8 Queens Route'),
    ('sprince6', 'Sarah', 'Prince', '1968-06-15', '22 Peachtree Street'),
    ('tmccall5', 'Trey', 'McCall', '1973-03-19', '360 Corkscrew Circle');

-- Table structure for 'employee'
DROP TABLE IF EXISTS employee;
CREATE TABLE employee (
    username CHAR(20) NOT NULL UNIQUE,
    taxID CHAR(20) NOT NULL UNIQUE,
    experience CHAR(20) NOT NULL,
    salary INT NOT NULL,
    hired DATE NOT NULL,
    PRIMARY KEY (username)
);
INSERT INTO employee
VALUES
	('agarcia7','999-99-9999', 24, 41000, '2019-03-17'),
    ('awilson5','111-11-1111', 9, 46000, '2020-03-15'),
    ('bsummers4','000-00-0000', 17, 35000, '2018-12-06'),
    ('ckann5','640-81-2357', 27, 46000, '2019-08-03'),
	('echarles19','777-77-7777', 3, 27000, '2021-01-02'),
    ('eross10','444-44-4444', 10, 61000, '2020-04-17'),
    ('fprefontaine6','121-21-2121', 5, 20000, '2020-04-19'),
    ('hstark16','555-55-5555', 20, 59000, '2018-07-23'),
    ('mrobot1','101-01-0101', 8, 38000, '2015-05-27'),
    ('mrobot2', '010-10-1010', 8, 38000, '2015-05-27'),
    ('rlopez6','123-58-1321', 51, 64000, '2017-02-05'),
    ('tmccall5', '333-33-3333', 29, 33000, '2018-10-17');

-- Table structure for 'pilot'
DROP TABLE IF EXISTS pilot;
CREATE TABLE pilot (
    username CHAR(20) NOT NULL UNIQUE,
    experience CHAR(20) NOT NULL,
    license_type INT NOT NULL,
    PRIMARY KEY (username)
);
INSERT INTO pilot 
VALUES
	('agarcia7', 38, 610623),
	('awilson5', 41, 314159),
    ('bsummers4', 35, 411911),
	('csoares8', 7, 343563),
    ('echarles19', 10, 236001),
    ('fprefontaine6', 2, 657483),
    ('lrodriguez5', 67, 287182),
    ('mrobot1', 18, 101010),
	('rlopez6', 58, 235711),
    ('tmccall5', 10, 181633);

-- Table structure for 'ingredient'
DROP TABLE IF EXISTS ingredient;
CREATE TABLE ingredient (
    barcode CHAR(20) NOT NULL UNIQUE,
    iname CHAR(20) NOT NULL,
    weight INT NOT NULL,
    PRIMARY KEY (barcode)
);
INSERT INTO ingredient
VALUES
	('bv_4U5L7M', 'balsamic vinegar', 4),
    ('clc_4T9U25X', 'caviar',  5),
    ('ap_9T25E36L', 'foie gras', 4),
    ('pr_3C6A9R', 'prosciutto', 6),
    ('ss_2D4E6L', 'saffron', 3),
    ('hs_5E7L23M', 'truffles', 3);

-- Table structure for 'location'
DROP TABLE IF EXISTS location;
CREATE TABLE location (
    label CHAR(20) NOT NULL UNIQUE,
    x_coord DECIMAL NOT NULL,
    y_coord DECIMAL NOT NULL,
    space INT DEFAULT NULL,
    PRIMARY KEY (label)
);
INSERT INTO location 
VALUES 
	('plaza', -4, -3, 10), 
    ('buckhead', 7, 10, 8), 
    ('avalon', 2, 15, Null), 
    ('mercedes', -8, 5, Null), 
    ('midtown', 2, 1, 7), 
    ('southside', 1, -16, 5);

-- Table structure for 'service'
DROP TABLE IF EXISTS service;
CREATE TABLE service (
    id CHAR(20) NOT NULL UNIQUE,
    service_name CHAR(20) NOT NULL,
    manager_username CHAR(20) NOT NULL,
    home_base CHAR(20) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (manager_username)
        REFERENCES employee (username),
    FOREIGN KEY (home_base)
        REFERENCES location (label)
);
INSERT INTO service
VALUES
	('hf', 'Herban Feast', 'hstark16', 'southside'),
    ('osf', 'On Safari Foods', 'eross10', 'southside'),
    ('rr', 'Ravishing Radish', 'echarles19', 'avalon');

-- Table structure for 'drone'
CREATE TABLE drone (
    tag INT NOT NULL,
    fuel INT NOT NULL,
    capacity INT NOT NULL,
    sales INT NOT NULL,
    pilot_username CHAR(20) DEFAULT NULL,
    swarm_tag INT DEFAULT NULL,
    service_id CHAR(5) NOT NULL,
    loc_label CHAR(20) NOT NULL,
    CONSTRAINT PRIMARY KEY (tag , service_id),
    FOREIGN KEY (service_id)
        REFERENCES service (id),
    FOREIGN KEY (pilot_username)
        REFERENCES pilot (username),
    FOREIGN KEY (loc_label)
        REFERENCES location (label),
    FOREIGN KEY (swarm_tag)
        REFERENCES drone (tag)
);
INSERT INTO drone
VALUES
	(1, 100, 6, 0,'fprefontaine6', null, 'hf', 'southside'),
	(5, 27, 7, 100,'fprefontaine6', null, 'hf', 'southside'),
	(8, 100, 8, 0,'bsummers4', null, 'hf', 'southside'),
	(11, 25, 10, 0, null , 5, 'hf', 'southside'),
	(16, 17, 5, 40, 'fprefontaine6', null, 'hf', 'southside'),
	(1, 100, 9, 0, 'awilson5', null, 'osf', 'southside'),
	(2, 75, 7, 0, null , 1, 'osf', 'southside'),
	(3, 100, 5, 50, 'agarcia7', null, 'rr', 'avalon'),
	(7, 53, 5, 100, 'agarcia7' , null, 'rr', 'avalon'),
	(8, 100, 6, 0, 'agarcia7' , null, 'rr', 'avalon'),
	(11, 90, 6, 0, null , 8, 'rr', 'avalon');

-- Table structure for 'restaurant'
DROP TABLE IF EXISTS restaurant;
CREATE TABLE restaurant (
    name CHAR(20) NOT NULL UNIQUE,
    rating INT NOT NULL,
    spent DECIMAL NOT NULL,
    loc_label CHAR(20) NOT NULL,
    PRIMARY KEY (name),
    FOREIGN KEY (loc_label)
        REFERENCES location (label)
);
INSERT INTO restaurant 
VALUES 
	('Bishoku', 5, 10, 'plaza'), 
    ('Casi Cielo', 5, 30, 'plaza'), 
    ('Ecco', 3, 0, 'buckhead'), 
    ('Fogo de Chao', 4, 30, 'buckhead'), 
    ('Hearth', 4, 0, 'avalon'), 
    ('Il Giallo', 4, 10, 'mercedes'), 
    ('Lure', 5, 20, 'midtown'), 
    ('Micks', 2, 0, 'southside'), 
    ('South City Kitchen', 5, 30, 'midtown'), 
    ('Tre Vele', 4, 10, 'plaza');

-- Table structure for 'contain'
DROP TABLE IF EXISTS contain;
CREATE TABLE contain (
    ing_barcode CHAR(20) NOT NULL,
    drone_tag INT DEFAULT NULL,
    quantity INT DEFAULT NULL,
    price CHAR(20),
    FOREIGN KEY (ing_barcode)
        REFERENCES ingredient (barcode),
    FOREIGN KEY (drone_tag)
        REFERENCES drone (tag)
);
INSERT INTO contain VALUES 
	('clc_4T9U25X', 3, 2, 28),
	('clc_4T9U25X', 5, 1, 30),
	('pr_3C6A9R', 1, 5, 20),
	('pr_3C6A9R', 8, 4, 18),
	('ss_2D4E6L', 1, 3, 23),
	('ss_2D4E6L', 11, 3, 19),
	('ss_2D4E6L', 1, 6, 27),
	('hs_5E7L23M', 2, 7, 14),
	('hs_5E7L23M', 3, 2, 15),
	('hs_5E7L23M', 5, 4, 17);

-- Table structure for 'works_for'
DROP TABLE IF EXISTS works_for;
CREATE TABLE works_for (
    worker_username CHAR(20) NOT NULL,
    service_id CHAR(20) NOT NULL,
    FOREIGN KEY (worker_username)
        REFERENCES employee (username),
    FOREIGN KEY (service_id)
        REFERENCES service (id)
);
INSERT INTO works_for VALUES 
	('ckann5','osf'),
	('eross10', 'osf'),
	('hstark16','hf'),
	('mrobot2','rr');

-- Table structure for 'fund'
DROP TABLE IF EXISTS fund;
CREATE TABLE fund (
    restaurant_name CHAR(20) NOT NULL,
    owner_username CHAR(20) NOT NULL,
    invested INT NOT NULL,
    dt_made DATE NOT NULL,
    FOREIGN KEY (owner_username)
        REFERENCES user (username),
    FOREIGN KEY (restaurant_name)
        REFERENCES restaurant (name)
);
INSERT INTO fund VALUES 
	('Ecco', 'jstone5', 20, '2022-10-25'),
	('Il Giallo', 'sprince6', 10, '2022-03-06'),
	('Lure', 'jstone5', 30, '2022-09-08'), 
    ('South City Kitchen', 'jstone5', 5, '2022-07-25');
