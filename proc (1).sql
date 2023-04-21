use pos;


ALTER TABLE orderLine
ADD unitPrice DECIMAL(6,2);


ALTER TABLE orderLine
ADD lineTotal DECIMAL(7,2) 
GENERATED ALWAYS AS (orderLine.quantity*orderLine.unitPrice) VIRTUAL;

ALTER TABLE `order`
ADD orderTotal DECIMAL(8,2);

ALTER TABLE customer
DROP COLUMN customer.phone;



ALTER TABLE `order`
DROP CONSTRAINT  order_ibfk_1;

ALTER TABLE `order`
DROP CONSTRAINT  order_ibfk_2;

DROP TABLE `status`;

ALTER TABLE `order`
ADD FOREIGN KEY (customerID) REFERENCES customer(ID);

ALTER TABLE `order`
DROP COLUMN `order`.`status`;


delimiter //
CREATE OR REPLACE PROCEDURE proc_FillUnitPrice()
BEGIN 
UPDATE orderline  
INNER JOIN product ON (orderline.productID = product.ID)
SET orderline.unitPrice = product.currentPrice
WHERE orderline.unitPrice IS NULL;
END  //  
delimiter ;


/*we need to delete this*/
/*CALL proc_FillUnitPrice();*/


delimiter //
CREATE OR REPLACE PROCEDURE proc_FillOrderTotal()
BEGIN 
UPDATE `order`
INNER JOIN (SELECT orderId,SUM(lineTotal) total FROM orderline GROUP BY orderID) tmp 
ON tmp.orderId=`order`.ID
SET `order`.orderTotal = tmp.total;
END //

/*CALL proc_FillOrderTotal();*/

delimiter //
CREATE OR REPLACE PROCEDURE proc_FillMVCustomerPurchase()
BEGIN 

DELETE FROM mv_customerpurchases; 
INSERT INTO mv_customerpurchases 
SELECT * FROM v_CustomerPurchases;
END //



/*CALL proc_FillMVCustomerPurchase();*/

























/*SHOW CREATE TABLE `order`;*/



