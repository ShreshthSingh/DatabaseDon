DROP DATABASE IF EXISTS pos;
CREATE DATABASE pos;
USE pos;

create table city ( zip DECIMAL(5,0) unsigned zerofill PRIMARY KEY, 
city VARCHAR(32), state VARCHAR(4));

CREATE TABLE customer ( ID INT PRIMARY KEY, 
firstName VARCHAR(64), 
lastName VARCHAR(32), email VARCHAR(128), 
address1 VARCHAR(128), 
address2 VARCHAR(128), phone VARCHAR(32), 
birthDate DATE, 
zip DECIMAL(5,0) UNSIGNED zerofill,
FOREIGN KEY (zip) REFERENCES city(zip));





create table `status` ( `status` TINYINT PRIMARY KEY, 
description VARCHAR(12));

create table `order` ( ID INT PRIMARY KEY, 
datePlaced DATE, 
dateShipped DATE, 
`status` TINYINT, 
customerID INT,
FOREIGN KEY (`status`) REFERENCES `status`(`status`),
FOREIGN KEY (customerID) REFERENCES customer(ID));


create table product ( ID INT PRIMARY KEY, 
name VARCHAR(128), 
currentPrice DECIMAL(6,2), 
qtyOnHand INT);

create table orderLine ( orderID INT, 
productID INT,
PRIMARY KEY( orderID, productID), 
quantity INT,
FOREIGN KEY (orderID) REFERENCES `order`(ID),
FOREIGN KEY (productID) REFERENCES product(ID));






create table temp_cust(
ID int PRIMARY KEY,
FName varchar(64),
LName varchar(32),
Cty varchar(32),
STT varchar(4),
ZIP decimal(5),
A1 varchar(128),
A2 varchar(128),
EML varchar(128),
BDT VARCHAR(32)
);




LOAD DATA local INFILE 'C:/Users/TAMU Libraries/Documents/project/customers.csv' INTO TABLE temp_cust
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ID, FName, LName, Cty, STT, ZIP, A1, A2, EML, BDT);






CREATE TABLE temp_ord(ID INT PRIMARY KEY,
CID INT);



LOAD DATA LOCAL INFILE 'C:/Users/TAMU Libraries/Documents/project/orders.csv' INTO TABLE temp_ord
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ID, CID);


CREATE TABLE temp_prod(ID INT PRIMARY KEY, 
NAM VARCHAR(128), 
PRC VARCHAR(128), 
QOH INT);


LOAD DATA LOCAL INFILE 'C:/Users/TAMU Libraries/Documents/project/products.csv' INTO TABLE temp_prod
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ID, NAM, PRC, QOH);

CREATE TABLE temp_ol(OID INT, 
PID INT);



LOAD DATA LOCAL INFILE 'C:/Users/TAMU Libraries/Documents/project/orderlines.csv' INTO TABLE temp_ol
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(OID, PID);

INSERT INTO city (zip, city, `state`)
SELECT DISTINCT  temp_cust.ZIP, temp_cust.Cty, temp_cust.STT
FROM temp_cust
GROUP BY temp_cust.ZIP;

INSERT INTO customer (ID, firstName, lastName, email, address1, address2, phone, birthDate, zip)
SELECT DISTINCT temp_cust.ID, temp_cust.FName, temp_cust.LName, temp_cust.EML, temp_cust.A1,
case when temp_cust.A2 = '' then NULL ELSE temp_cust.A2 END,
NULL,
case when temp_cust.BDT = '' then NULL ELSE STR_TO_DATE(temp_cust.BDT, '%m/%d/%Y') END,
temp_cust.ZIP
FROM temp_cust;

INSERT INTO `order` (ID, datePlaced, dateShipped, `status`, customerID)
SELECT temp_ord.ID, 
NULL,
NULL,
NULL,
temp_ord.CID
FROM temp_ord;

UPDATE temp_prod SET PRC = REPLACE(PRC, '$', '');
UPDATE temp_prod SET PRC = REPLACE(PRC, ',', '');

INSERT INTO product (ID, NAME, currentPrice, qtyonHand)
SELECT temp_prod.ID,
temp_prod.NAM,
temp_prod.PRC,
temp_prod.QOH
FROM temp_prod;

INSERT INTO orderLine (orderID, productID, quantity)
SELECT temp_ol.OID, temp_ol.PID,
COUNT(*) FROM temp_ol
GROUP BY temp_ol.OID, temp_ol.PID;

DROP TABLE temp_prod;
DROP TABLE temp_cust;
DROP TABLE temp_ol;
DROP TABLE temp_ord;


