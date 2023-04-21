select json_object("Name",CONCAT(customer.firstName," ",customer.lastName),"cust_email",email,
"Orders",(json_arrayagg(JSON_OBJECT(
   "datePlaced",datePlaced,
   "products",(select json_arrayagg(json_object("Product Name",p.name, "Quantity", ol.quantity,"Unit Price", ol.unitPrice))
   from `order` ord join 
   orderLine ol on ord.id = ol.orderID join 
   product p on ol.productID=p.ID  
   where ord.id=od.id),"orderTotal",od.orderTotal)))
, "NumOrders", COUNT(DISTINCT od.ID),"moneySpent",sum(od.orderTotal)) 
from customer join `order` od on customer.ID = od.customerID
group by customer.id
into outfile "last_milestone.json"
;