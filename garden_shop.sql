USE ECOMMERCE_ANALYSIS;

select * from customers;

select distinct count(*) as no_of_custs from customers ;


select city,count(*) as no_of_custs from customers group by city having no_of_custs>1;


WITH REGISTRATIONS AS(
SELECT year(SIGNUP_DATE)  AS YEAR_REGISTERED,
count(*) AS NO_OF_CUSTS
 FROM CUSTOMERS
 GROUP BY YEAR_REGISTERED ORDER BY YEAR_REGISTERED

)
SELECT * FROM REGISTRATIONS 
WHERE NO_OF_CUSTS=
(SELECT MAX(NO_OF_CUSTS) FROM REGISTRATIONS);

SELECT
CASE
WHEN IS_ACTIVE=1 THEN 'ACTIVE'
WHEN IS_ACTIVE=0 THEN 'INACTIVE'
END AS ACTIVATION_STATUS,
COUNT(CUSTOMER_ID) AS NUMBER_OF_CUSTOMERS,
COUNT(CUSTOMER_ID) /(SELECT COUNT(*) FROM CUSTOMERS) *100 AS PERCENTAGE
FROM CUSTOMERS GROUP BY IS_ACTIVE;


SELECT C.CUSTOMER_ID,C.FIRST_NAME ,COUNT(O.ORDER_ID) AS NUMBER_OF_ORDERS
FROM CUSTOMERS C
JOIN ORDERS O ON C.CUSTOMER_ID =O.CUSTOMER_ID
GROUP BY O.CUSTOMER_ID ,C.FIRST_NAME;

SELECT 
C.CUSTOMER_ID ,C.FIRST_NAME
FROM CUSTOMERS C
LEFT JOIN ORDERS O ON C.CUSTOMER_ID =O.CUSTOMER_ID
WHERE O.CUSTOMER_ID IS NULL;

WITH NOORDERS AS(
SELECT C.CUSTOMER_ID AS ID,COUNT(O.ORDER_ID) AS NUMBER_OF_ORDERS
FROM CUSTOMERS C
JOIN ORDERS O ON C.CUSTOMER_ID =O.CUSTOMER_ID
GROUP BY O.CUSTOMER_ID 
)
SELECT ID,NUMBER_OF_ORDERS FROM NOORDERS
WHERE NUMBER_OF_ORDERS=(SELECT MAX(NUMBER_OF_ORDERS) FROM NOORDERS ) ;


SELECT P.PRODUCT_ID,P.PRODUCT_NAME,sum(ot.quantity) AS TOTAL_ORDERS
FROM PRODUCTS P
JOIN ORDER_ITEMS OT
ON P.PRODUCT_ID = OT.PRODUCT_ID 
group by P.PRODUCT_ID,P.PRODUCT_NAME
ORDER BY TOTAL_ORDERS DESC;

SELECT P.PRODUCT_ID,P.PRODUCT_NAME,sum(OT.QUANTITY*OT.UNIT_PRICE) AS TOTAL_REVENUE
FROM PRODUCTS P
JOIN ORDER_ITEMS OT
ON P.PRODUCT_ID = OT.PRODUCT_ID 
group by P.PRODUCT_ID,P.PRODUCT_NAME;


SELECT 
    rank() OVER(
        ORDER BY SUM(OT.QUANTITY * OT.UNIT_PRICE) DESC 
    ) AS rankk,
    P.PRODUCT_ID,
    P.PRODUCT_NAME,
    SUM(OT.QUANTITY * OT.UNIT_PRICE) AS TOTAL_REVENUE
FROM PRODUCTS P
JOIN ORDER_ITEMS OT
    ON P.PRODUCT_ID = OT.PRODUCT_ID
GROUP BY P.PRODUCT_ID, P.PRODUCT_NAME;

select product_id,product_name,quantity_on_hand,reorder_level 
from products 
where quantity_on_hand <reorder_level;


select product_id,product_name,quantity_on_hand from products 
where quantity_on_hand =0;

select product_id,product_name,quantity_on_hand,discontinued from products 
where discontinued=1;

select category_id,count(*) as total_orders from products group by category_id;


with lowstock as
(select product_id,product_name,quantity_on_hand,reorder_level 
from products 
where quantity_on_hand <reorder_level),

zerostock as(
select product_id,product_name,quantity_on_hand from products 
where quantity_on_hand =0),

discontinued as(
select product_id,product_name,quantity_on_hand,discontinued from products 
where discontinued=1)

SELECT
    (SELECT COUNT(*) FROM lowstock) AS lowstock,
    (SELECT COUNT(*) FROM zerostock) AS zerostock,
    (SELECT COUNT(*) FROM discontinued) AS discontinued;
    
    
select count(*) as total_orders from orders;

select sum( quantity*unit_price) as total_revenue 
from order_items ot 
join orders o on ot.order_id=o.order_id 
where status!='cancelled';

select sum(quantity) as total_products_sold from order_items;

select status,count(status) as total_orders from orders group by status;

select sum( quantity*unit_price) as total_revenue ,
sum(quantity) as total_shipped_quantity
from order_items ot 
join orders o on ot.order_id=o.order_id 
where status='shipped';

select c.customer_id ,C.FIRST_NAME AS Name,
COALESCE(SUM(OT.QUANTITY * OT.UNIT_PRICE), 0) AS TOTAL_SPENT
from customers c
left join orders o 
on C.CUSTOMER_ID = O.CUSTOMER_ID
AND O.STATUS = 'Shipped'
LEFT JOIN ORDER_ITEMS OT
    ON O.ORDER_ID = OT.ORDER_ID
group by c.CUSTOMER_ID,C.FIRST_NAME 
ORDER BY TOTAL_SPENT DESC;

select c.customer_id ,C.FIRST_NAME AS Name,
COALESCE(SUM(OT.QUANTITY * OT.UNIT_PRICE), 0) AS TOTAL_SPENT
from customers c
left join orders o 
on C.CUSTOMER_ID = O.CUSTOMER_ID
AND O.STATUS = 'Shipped'
LEFT JOIN ORDER_ITEMS OT
    ON O.ORDER_ID = OT.ORDER_ID
group by c.CUSTOMER_ID,C.FIRST_NAME 
ORDER BY TOTAL_SPENT DESC
limit 5;

select O.customer_id ,C.FIRST_NAME AS Name,sum(ot.quantity*ot.unit_price) as total_spent
from order_items ot
join orders o 
on o.order_id=ot.order_id
and status="shipped"
JOIN CUSTOMERS C
ON C.CUSTOMER_ID = O.CUSTOMER_ID
group by O.CUSTOMER_ID,C.FIRST_NAME
HAVING TOTAL_SPENT>100
ORDER BY TOTAL_SPENT DESC;

SELECT
    C.CATEGORY_NAME,
    COALESCE(SUM(SO.QUANTITY), 0) AS TOTAL_QUANTITY_SOLD
FROM CATEGORIES C
LEFT JOIN PRODUCTS P
    ON C.CATEGORY_ID = P.CATEGORY_ID
LEFT JOIN (
    SELECT OT.PRODUCT_ID, OT.QUANTITY
    FROM ORDER_ITEMS OT
    JOIN ORDERS O
        ON OT.ORDER_ID = O.ORDER_ID
    WHERE O.STATUS = 'Shipped'
) SO
    ON P.PRODUCT_ID = SO.PRODUCT_ID
GROUP BY C.CATEGORY_NAME;

SELECT
    C.CATEGORY_NAME,
    COALESCE(SUM(SO.QUANTITY * SO.UNIT_PRICE), 0) AS TOTAL_REVENUE
FROM CATEGORIES C
LEFT JOIN PRODUCTS P
    ON C.CATEGORY_ID = P.CATEGORY_ID
LEFT JOIN (
    SELECT OT.PRODUCT_ID, OT.QUANTITY, OT.UNIT_PRICE
    FROM ORDER_ITEMS OT
    JOIN ORDERS O
        ON OT.ORDER_ID = O.ORDER_ID
    WHERE O.STATUS = 'Shipped'
) SO
    ON P.PRODUCT_ID = SO.PRODUCT_ID
GROUP BY C.CATEGORY_NAME;

SELECT
    C.CATEGORY_NAME,
    COALESCE(SUM(SO.QUANTITY * SO.UNIT_PRICE), 0) AS TOTAL_REVENUE
FROM CATEGORIES C
LEFT JOIN PRODUCTS P
    ON C.CATEGORY_ID = P.CATEGORY_ID
LEFT JOIN (
    SELECT OT.PRODUCT_ID, OT.QUANTITY, OT.UNIT_PRICE
    FROM ORDER_ITEMS OT
    JOIN ORDERS O
        ON OT.ORDER_ID = O.ORDER_ID
    WHERE O.STATUS = 'Shipped'
) SO
    ON P.PRODUCT_ID = SO.PRODUCT_ID
GROUP BY C.CATEGORY_NAME
ORDER BY TOTAL_REVENUE DESC
LIMIT 1;

WITH category_revenue AS (
    SELECT
        C.CATEGORY_NAME,
        COALESCE(SUM(SO.QUANTITY * SO.UNIT_PRICE), 0) AS TOTAL_REVENUE
    FROM CATEGORIES C
    LEFT JOIN PRODUCTS P
        ON C.CATEGORY_ID = P.CATEGORY_ID
    LEFT JOIN (
        SELECT OT.PRODUCT_ID, OT.QUANTITY, OT.UNIT_PRICE
        FROM ORDER_ITEMS OT
        JOIN ORDERS O
            ON OT.ORDER_ID = O.ORDER_ID
        WHERE O.STATUS = 'Shipped'
    ) SO
        ON P.PRODUCT_ID = SO.PRODUCT_ID
    GROUP BY C.CATEGORY_NAME
)

SELECT
    CATEGORY_NAME,
    TOTAL_REVENUE,
    RANK() OVER(ORDER BY TOTAL_REVENUE DESC) AS REVENUE_RANK
FROM category_revenue
ORDER BY REVENUE_RANK;

select s.supplier_id,s.supplier_name,count(product_id) as total_products
from suppliers s
left join products p
on s.supplier_id=p.supplier_id
group by s.supplier_id,s.supplier_name;



select s.supplier_id,s.supplier_name,coalesce(sum(p.cost*p.quantity_on_hand),0) as inventory_value
from suppliers s
left join products p
on s.supplier_id=p.supplier_id
group by s.supplier_id,s.supplier_name;

with supplied as(
select s.supplier_id,s.supplier_name,count(*) as total_products
from suppliers s
left join products p
on s.supplier_id=p.supplier_id
group by s.supplier_id,s.supplier_name
)
select * from supplied where total_products= (select max(total_products) from supplied);

select s.supplier_id,s.supplier_name,count(product_id) as total_products
from suppliers s
left join products p
on s.supplier_id=p.supplier_id
group by s.supplier_id,s.supplier_name
having total_products=0;


