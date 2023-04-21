use pos;

call proc_FillUnitPrice();
call proc_FillOrderTotal();
call proc_FillMVCustomerPurchase();

CREATE OR REPLACE TABLE priceChangeLog(
    ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    oldPrice DECIMAL(6,2),
    newPrice DECIMAL(6,2),
    changeTimestamp TIMESTAMP,
    productid INT,
    FOREIGN KEY(productid) REFERENCES product(ID)
);

DELIMITER //

CREATE OR REPLACE TRIGGER productPriceChanger
BEFORE UPDATE ON product
FOR EACH ROW 
BEGIN 
IF (NEW.currentPrice != OLD.currentPrice)
THEN 
INSERT INTO priceChangeLog(oldPrice,newPrice,productid)
VALUES (OLD.currentPrice,NEW.currentPrice,OLD.ID);
END IF;
END //
DELIMITER ; 

/*-------------------1 complete-------------------------------------------*/
/*for update*/
DELIMITER //
CREATE OR REPLACE TRIGGER setOrderLineUnitPrice
BEFORE UPDATE ON orderLine
FOR EACH ROW 
BEGIN 
SET new.unitPrice = (select currentPrice from product where product.ID = new.productID );
IF (NEW.quantity is NULL) THEN SET NEW.quantity = 1;
END IF ;
END //
DELIMITER ; 

/*for insert*/
DELIMITER //
CREATE OR REPLACE TRIGGER setOrderLineUnitPrice1
BEFORE insert ON orderLine
FOR EACH ROW 
BEGIN 

/*UPDATE orderLine*/
SET new.unitPrice = (select currentPrice from product where product.ID = new.productID );
IF (NEW.quantity is NULL) THEN SET NEW.quantity = 1;
END IF ;
END //
DELIMITER ; 





/*-----------5 start-----------------------------*/

DELIMITER //
CREATE OR REPLACE TRIGGER updateOrderTotal1 AFTER UPDATE ON orderline
FOR EACH ROW
BEGIN
UPDATE `order`
SET orderTotal = (SELECT SUM(lineTotal) FROM orderline WHERE orderID = NEW.orderID)
WHERE ID = NEW.orderID;

/*last question trigger*/

if (new.quantity-old.quantity)>(select qtyOnHand from product where ID=new.productID)
THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ENOUGH IS ENOUGH';
ELSE
UPDATE product set product.qtyOnHand=product.qtyOnHand+OLD.quantity-NEW.quantity
WHERE product.ID = NEW.productID;
END IF;
END //
DELIMITER ;




DELIMITER //
CREATE OR REPLACE TRIGGER updateOrderTotal2 AFTER INSERT ON orderline
FOR EACH ROW
BEGIN
UPDATE `order`
SET orderTotal = (SELECT SUM(lineTotal) FROM orderline WHERE orderID = NEW.orderID)
WHERE ID = NEW.orderID;
/*last question trigger*/
if (new.quantity)>(select qtyOnHand from product where ID=new.productID)
THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ENOUGH IS ENOUGH';
ELSE
UPDATE product set product.qtyOnHand=product.qtyOnHand-NEW.quantity
WHERE product.ID = NEW.productID;
END IF;
END //
DELIMITER ;




DELIMITER //
CREATE OR REPLACE TRIGGER updateOrderTotal3 AFTER DELETE ON orderline
FOR EACH ROW
BEGIN
UPDATE `order`
SET orderTotal = (SELECT SUM(lineTotal) FROM orderline WHERE orderID = OLD.orderID)
WHERE ID = OLD.orderID;
/*last question triggers*/
UPDATE product set product.qtyOnHand=product.qtyOnHand+OLD.quantity
WHERE product.ID = OLD.productID;
END //
DELIMITER ;




/*-----------6th start--------------*/

Delimiter //
CREATE OR REPLACE TRIGGER updateMV_CustomerPurchases AFTER UPDATE ON orderline
FOR EACH ROW
BEGIN
UPDATE mv_CustomerPurchases
INNER JOIN (SELECT * FROM v_customerpurchases WHERE ID = (SELECT customerID FROM `order` WHERE ID = NEW.orderID )) AS abc
ON mv_CustomerPurchases.id = abc.id
SET mv_CustomerPurchases.ID=abc.ID,mv_CustomerPurchases.firstName=abc.firstName,mv_CustomerPurchases.lastName=abc.lastName,mv_CustomerPurchases.products = abc.products
WHERE mv_CustomerPurchases.ID = (SELECT customerID FROM `order` WHERE ID = NEW.orderID );

UPDATE mv_ProductBuyers
INNER JOIN (SELECT * FROM v_ProductBuyers WHERE productID = (SELECT ID FROM product WHERE ID = NEW.productID )) AS abc
ON mv_ProductBuyers.productID = abc.productID
SET mv_ProductBuyers.productID = abc.productID,mv_ProductBuyers.productName = abc.productName,mv_ProductBuyers.customers = abc.customers
WHERE mv_ProductBuyers.productID = (SELECT ID FROM product WHERE ID = NEW.productID );

UPDATE mv_ProductBuyers
INNER JOIN (SELECT * FROM v_ProductBuyers WHERE productID = (SELECT ID FROM product WHERE ID = NEW.productID )) AS abc
ON mv_ProductBuyers.productID = abc.productID
SET mv_ProductBuyers.productID = abc.productID,mv_ProductBuyers.productName = abc.productName,mv_ProductBuyers.customers = abc.customers
WHERE mv_ProductBuyers.productID = (SELECT ID FROM product WHERE ID = OLD.productID );
END //
delimiter ; 




Delimiter //
CREATE OR REPLACE TRIGGER insertMV_CustomerPurchases AFTER INSERT ON orderline
FOR EACH ROW
BEGIN
UPDATE mv_CustomerPurchases
INNER JOIN (SELECT * FROM v_CustomerPurchases WHERE ID = (SELECT customerID FROM `order` WHERE ID = NEW.orderID )) AS abc
ON mv_CustomerPurchases.id = abc.id
SET mv_CustomerPurchases.ID=abc.ID,mv_CustomerPurchases.firstName=abc.firstName,mv_CustomerPurchases.lastName=abc.lastName,mv_CustomerPurchases.products = abc.products
WHERE mv_CustomerPurchases.ID = (SELECT customerID FROM `order` WHERE ID = NEW.orderID );



UPDATE mv_ProductBuyers
INNER JOIN (SELECT * FROM v_ProductBuyers WHERE productID = (SELECT ID FROM product WHERE ID = NEW.productID )) AS abc
ON mv_ProductBuyers.productID = abc.productID
SET mv_ProductBuyers.productID = abc.productID,mv_ProductBuyers.productName = abc.productName,mv_ProductBuyers.customers = abc.customers
WHERE mv_ProductBuyers.productID = (SELECT ID FROM product WHERE ID = NEW.productID );

END //
delimiter ; 





Delimiter //
CREATE OR REPLACE TRIGGER deleteMV_CustomerPurchases AFTER DELETE ON orderline
FOR EACH ROW
BEGIN
UPDATE mv_CustomerPurchases
INNER JOIN (SELECT * FROM v_CustomerPurchases WHERE ID = (SELECT customerID FROM `order` WHERE ID = OLD.orderID )) AS abc
ON mv_CustomerPurchases.id = abc.id
SET mv_CustomerPurchases.ID=abc.ID,mv_CustomerPurchases.firstName=abc.firstName,mv_CustomerPurchases.lastName=abc.lastName,mv_CustomerPurchases.products = abc.products
WHERE mv_CustomerPurchases.ID = (SELECT customerID FROM `order` WHERE ID = OLD.orderID );


UPDATE mv_ProductBuyers
INNER JOIN (SELECT * FROM v_ProductBuyers WHERE productID = (SELECT ID FROM product WHERE ID = OLD.productID )) AS abc
ON mv_ProductBuyers.productID = abc.productID
SET mv_ProductBuyers.productID = abc.productID,mv_ProductBuyers.productName = abc.productName,mv_ProductBuyers.customers = abc.customers
WHERE mv_ProductBuyers.productID = (SELECT ID FROM product WHERE ID = OLD.productID );

END //
delimiter ; 

/*---------7th question in previous triggers---------------------------*/



