create database case_study;
USE case_study;
select * from sales_transaction;
select * from product_inventory;
select * from customer_profiles;

#***************************** DATA PREPARATION AND UNDERSTANDING ***************************

# Data Cleaning

ALTER TABLE sales_transaction
RENAME COLUMN `ï»¿TransactionID` TO `TransactionID`;

select * from product_inventory;
ALTER TABLE product_inventory
RENAME COLUMN `ï»¿ProductID` TO `ProductID`;

select * from customer_profiles;
ALTER TABLE customer_profiles
RENAME COLUMN `ï»¿CustomerID` TO `CustomerID`;

select * from sales_transaction;

-- Checking for duplicates --

SELECT TransactionID, count(*)
from sales_transaction
group by TransactionID
having count(*) > 1;

select * from sales_transaction 
where transactionid in (4999,5000)
order by transactionid;

CREATE TABLE sales_transaction1 AS 
SELECT * FROM sales_transaction;
SELECT * FROM sales_transaction1;

delete from sales_transaction 
where transactionid = 4999
limit 1;

delete from sales_transaction 
where transactionid = 5000
limit 1;

SELECT * FROM sales_transaction
WHERE transactionid is null
or CustomerID is null
or ProductID is null
or QuantityPurchased is null
or TransactionDate is null
or Price is null;

select * from sales_transaction;

-- Questions and cobmining tables:

 -- Joining Two tables -- 
SELECT s.ProductID, s.Price AS sales_price, p.Price as official_price
from sales_transaction s
join product_inventory p on s.ProductID = p.ProductID
where s.Price != p.Price;

UPDATE sales_transaction s
join product_inventory p on s.ProductID = p.ProductID
set s.Price = p.Price
where s.Price != p.Price;

set sql_safe_updates = 0;

select count(*) from sales_transaction;
select * from sales_transaction;

describe sales_transaction;

ALTER Table sales_transaction
MODIFY COLUMN TransactionDate DATE;

describe sales_transaction;
describe product_inventory;
describe customer_profiles;

ALTER Table customer_profiles
MODIFY COLUMN JoinDate DATE;

SELECT * FROM sales_transaction
WHERE transactionid is null or transactionid = ''
or CustomerID is null or CustomerID = ''
or ProductID is null or ProductID = ''
or QuantityPurchased is null
or TransactionDate is null
or Price is null;

SELECT * FROM product_inventory;
desc product_inventory;

select ProductID, count(*)
from product_inventory
group by ProductID
having count(*) > 1;

SELECT * FROM product_inventory
WHERE ProductID is null or ProductID = ''
or ProductName is null or ProductName = ''
or Category is null or Category = ''
or StockLevel is null
or Price is null;

-- Checking for zero or negative stock/price --

SELECT * FROM product_inventory
where stocklevel < 0
or price <= 0;

select count(distinct ProductID) FROM product_inventory;

SELECT * FROM customer_profiles;
desc customer_profiles;

select CustomerID, count(*)
from customer_profiles
group by CustomerID
having count(*) > 1;

SELECT * FROM customer_profiles
WHERE CustomerID is null or CustomerID = ''
or Age is null or Age = ''
or Gender is null or Gender = ''
or Location is null or Location = ''
or JoinDate is null;

update customer_profiles
set Location = 'NA'
where Location is NULL;

desc customer_profiles;

SELECt distinct Gender from customer_profiles;

SELECT * FROM customer_profiles
WHERE Age < 10 or Age > 100;

SELECT AVG(Age) from customer_profiles
where CustomerID <> 668;

Delete from Customer_profiles where customerid = 668;

SELECT * FROM customer_profiles
where joindate > curdate();

drop table customer_profiles;

SELECT * FROM customer_profiles;

Alter table customer_profiles
add column joindate_parsed date;

update customer_profiles
set joindate_parsed = str_to_date(joindate, '%d/%m/%y')
where joindate is not null;

ALTER TABLE customer_profiles
DROP COLUMN join_parsed;

ALTER TABLE  customer_profiles 
RENAME COLUMN joindate_parsed TO joindate;

-- Changing date to correct format %d/%m/%y -- 

SELECT * FROM sales_transaction;
Alter table sales_transaction
add column TransactionDateparsed date;

update sales_transaction
set TransactionDateparsed = str_to_date(TransactionDate, '%d/%m/%y')
where TransactionDate is not null;

ALTER TABLE sales_transaction
RENAME COLUMN TransactionDateparsed TO Transaction_Date;

-- Questions solved according to the dataset --

-- Q1. Which product sells most or least?

SELECT * FROM Sales_transaction; -- st
SELECT * FROM product_inventory; -- pi

SELECT pi.ProductID, pi.ProductName, pi.Category, SUM(st.QuantityPurchased) as Total_quantity_sold,
ROUND(SUM(st.QuantityPurchased * st.Price), 2) as Total_Revenue
from Sales_transaction st
JOIN 
product_inventory pi
on st.ProductID = pi.ProductID
group by pi.ProductID, pi.ProductName, pi.Category
order by Total_quantity_sold desc;

-- End Q1. -- 

-- Q2 HOW OFTEN CUSTOMERS PURCHASE?

SELECT * FROM Sales_transaction; -- st
SELECT * FROM customer_profiles; -- cp

SELECT cp.CustomerID, cp.Gender, cp.Location,
COUNT(st.TransactionID) as Total_orders,
case
when COUNT(st.TransactionID) = 0 then 'No Order'
when COUNT(st.TransactionID) between 1 and 10 then 'Low Order'
when COUNT(st.TransactionID) between 11 and 30 then 'Medium Order'
ELSE 'High Order'
END AS Customer_Segment
from customer_profiles cp  
LEFT JOIN 
Sales_transaction st
on cp.CustomerID = st.CustomerID
group by 
cp.CustomerID, cp.Gender, cp.Location;

-- End Q2. -- 

-- Q3. Which product is performing well? 

SELECT * FROM Sales_transaction; -- st
SELECT * FROM product_inventory; -- pi

SELECT pi.Category,
COUNT(Distinct st.TransactionID) as Number_of_Transaction,
SUM(st.QuantityPurchased) as Total_units_sold,
ROUND(SUM(st.QuantityPurchased * st.Price), 2) as Total_Sales
from Sales_transaction st
JOIN product_inventory pi
on st.ProductID = pi.ProductID
group by pi.Category
order by Total_Sales desc;

-- End Q3. -- 

-- Q4. How sales are performing M-O-M identify peak and low sales month?  ( monthly revenue)

SELECT * FROM Sales_transaction; -- st
SELECT * FROM product_inventory; -- pi

Select Date_format(Transaction_Date, '%Y-%m') as YearMonth,
SUM(QuantityPurchased * price) as MonthlyRevenue
from Sales_transaction
Group by YearMonth
Order by YearMonth;

-- End Q4. -- 

-- Q5. what are the total sales for each category?

SELECT * FROM Sales_transaction; -- st
SELECT * FROM product_inventory; -- pi
SELECT * FROM customer_profiles; -- cp

Select pi.category as Categories,
SUM(st.QuantityPurchased * st.Price) as MonthlySales 
From product_inventory pi 
Join Sales_transaction st
on pi.ProductID = st.ProductID
GROUP BY pi.category
ORDER BY SUM(st.QuantityPurchased * st.Price) DESC;

-- End Q5. -- 

-- Q6. What is the avg purchase value per trancastion for each?

SELECT * FROM Sales_transaction; -- st
SELECT * FROM product_inventory; -- pi
SELECT * FROM customer_profiles; -- cp

Select pi.category as Categories,
AVG(st.QuantityPurchased * st.Price) as AverageTransactionPrice
From product_inventory pi 
join sales_transaction st 
on st.Productid=pi.productid
group by pi.Category
order by AverageTransactionPrice desc;

-- End Q6. -- 

-- Q7. Identify top 5 customers who spent the most overall?

SELECT * FROM Sales_transaction; -- st
SELECT * FROM product_inventory; -- pi
SELECT * FROM customer_profiles; -- cp

Select cp.CustomerID,  
SUM(st.QUANTITYPURCHASED * st.PRICE) AS Total_Purchase
FROM customer_profiles cp 
JOIN Sales_transaction st
ON cp.CUSTOMERID = st.CUSTOMERID
GROUP BY cp.CUSTOMERID
ORDER BY TOTAL_PURCHASE DESC
LIMIT 5;

-- End Q7. -- 

-- Q8. Duration b/w first and last purchase as an indicator of customer loyalty?

SELECT * FROM Sales_transaction; -- st
SELECT * FROM product_inventory; -- pi
SELECT * FROM customer_profiles; -- cp

Select CustomerID,
MIN(Transaction_Date) as First_Purchase,
MAX(Transaction_Date) as Last_Purchase,
Datediff(MAX(Transaction_Date), MIN(Transaction_Date)) as Duration_Day
FROM Sales_transaction
GROUP BY CustomerID;

-- End Q8. -- 

-- Q9. Describe the duration b/w purchase of the customer? 

Select CustomerID,
MIN(Transaction_Date) as First_Purchase,
MAX(Transaction_Date) as Last_Purchase,
(MAX(Transaction_Date) - MIN(Transaction_Date)) as DaysBetweenPurchase
FROM Sales_transaction
GROUP BY CustomerID
Having (MAX(Transaction_Date) - MIN(Transaction_Date)) > 0
Order by DaysBetweenPurchase desc;

-- End Q9. -- 

-- Q10. Repeat the purchase pattern, total no of purchases made by each customer against each product id to understand 

SELECT * FROM Sales_transaction; -- st
SELECT * FROM product_inventory; -- pi
SELECT * FROM customer_profiles; -- cp

Select CustomerID, ProductID,
COUNT(*) AS TOTAL_NUM_TRANSCATION
from Sales_transaction
GROUP BY CustomerID, ProductID
Having TOTAL_NUM_TRANSCATION > 1 
Order by TOTAL_NUM_TRANSCATION desc, CustomerID;

-- End Q10. -- 


















































































