CREATE VIEW v_CustomerNames AS
SELECT firstName AS 'FN',lastName AS 'LN' FROM customer
order BY 'LN','FN';



CREATE VIEW v_customers AS 
SELECT customer.ID AS "customer_number",customer.firstName AS "first_name",customer.lastName AS "last_name",customer.address1 AS "street1",customer.address2 AS "street2",city.city AS "city",city.state AS "state",city.zip AS "zip_code",email 
FROM customer JOIN city
ON customer.zip=city.zip;


CREATE VIEW v_ProductBuyers AS 
SELECT product.ID AS 'productID',product.name AS 'productName',
GROUP_CONCAT(DISTINCT CONCAT(customer.ID," ",customer.firstName," ",customer.lastName) SEPARATOR ',') AS 'customers'
FROM product 
LEFT JOIN orderline
ON product.ID=orderline.productID
LEFT JOIN `order`
ON orderline.orderID=`order`.ID
LEFT JOIN customer
ON `order`.customerID=customer.ID
GROUP BY product.ID,product.name;


CREATE VIEW v_CustomerPurchases AS
SELECT customer.ID,customer.firstName,customer.lastName,
GROUP_CONCAT(DISTINCT CONCAT(product.ID," ",product.name) ORDER BY product.ID SEPARATOR '|') AS 'products'
FROM customer
LEFT JOIN `order`
ON customer.ID = `order`.customerID
LEFT JOIN orderline
ON `order`.ID = orderline.orderID
LEFT JOIN product 
ON orderline.productID = product.ID
GROUP BY customer.ID,customer.firstName,customer.lastName;

/*SELECT customer.ID,customer.firstName,customer.lastName,
GROUP_CONCAT(DISTINCT CONCAT(product.ID," ",product.name) ORDER BY product.ID SEPARATOR '|') AS 'products'
FROM customer
LEFT JOIN `order`
ON customer.ID = `order`.customerID
LEFT JOIN orderline
ON `order`.ID = orderline.orderID
LEFT JOIN product 
ON orderline.productID = product.ID
where product.ID = NULL
GROUP BY customer.ID,customer.firstName,customer.lastName;*/ 


CREATE TABLE mv_ProductBuyers AS 
SELECT * FROM v_ProductBuyers;

CREATE TABLE mv_CustomerPurchases AS
SELECT * FROM v_CustomerPurchases;






/*DROP view v_customerNames;
DROP view v_customers;*/
