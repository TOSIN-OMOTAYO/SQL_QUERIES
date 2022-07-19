--select * from Sales_order;
--select * from Customers;
--select * from Products;

--Fetch all the small shipped orders from August 2003 till the end of year 2003.
select * from Sales_order
where deal_size = 'Small' 
and order_date between CONVERT(date,'01-08-2003', 103) and CONVERT(datetime,'31-12-2003', 103)

--Find only those orders which do not belong to customers from USA and are still in process
select c.*
from Sales_order s
join Customers c on s.customer = c.customer_id
where  status = 'in process' and country != 'USA'

--Find all orders for Planes, Ships and Trains which are neither Shipped nor In Process nor processed.
select * 
from Products p
left join Sales_order s on p.product_code = s.Product
where p.PRODUCT_LINE in ( 'planes','ships', 'trains')
and s.status not in ('shipped', 'processed', 'in process')


--Find customers whose phone number has either parenthesis "()" or a plus sign "+".
select customer_name from Customers
where phone like '%[(,),+]%'

--Find customers whose phone number does not have any space.
SELECT * FROM CUSTOMERS WHERE phone not like '% %'

 --Find orders which sold the product for price higher than its original price.

select *
from Sales_order s
join products p on s.product = p.product_code
where s.price_each > p.price;

-- Segregate order sales for each quarter. Display the data with highest sales quarter on top.
--(In each quarter how much sales amount was generated)
select sum(sales)T, case when qtr_id = 1 then 'Jan - Mar'
			when qtr_id = 2 then 'Apr - Jun'
			when qtr_id = 3 then 'Jul - Sep'
			when qtr_id = 4 then 'Oct - Dec'
		else 'No match'
		end as quarter
from sales_order
group by qtr_id
order by T desc;


--Identify how many cars, Motorcycles, trains and ships are available. Treat all type of cars as just "Cars". Display only vehicles which are less than 10 in number.
       
With A as(
select count(Product_line)no_of_vehicles, case when product_line like '%Cars'
				 then 'Cars'
			else product_line
		end as product_line
from Products
group by product_line)

select product_line,sum(no_of_vehicles)T
from A
where product_line in ( 'Cars','Motorcycles','trains', 'ships')
and no_of_vehicles < 10
group by product_line
order by T

--Find the countries which have purchased more than 10 motorcycles.
select PRODUCT_LINE,country, count(country)Number from Sales_order s
join Customers c on s.customer = c.customer_id
join Products p ON S.Product = P.product_code
where PRODUCT_LINE ='Motorcycles' 
group by PRODUCT_LINE,country
having count(country) >10

--Find total no of orders per each day. Sort data based on highest orders.
select order_date, count(1) as no_of_orders
from sales_order
group by order_date
order by no_of_orders desc;

--Find the most profitable orders. Most profitable orders are those
--whose sale price exceeded the average sale price for each city and whose deal size was not small.
    -- Using WITH clause
    with avg_sales_per_city
    	as (select city, avg(sales) avg_sales
    		from Sales_order s
    		join customers c on c.customer_id=s.customer
    		group by city)
    select c.city, x.avg_sales, s.order_number, s.quantity_ordered, s.sales
    from Sales_order s
    join customers c on c.customer_id=s.customer
    join avg_sales_per_city x on x.city=c.city
    where s.sales >= x.avg_sales
    and s.deal_size <> 'Small';

   

























