
ALTER TABLE orders_details
RENAME TO order_details;

# What is the total number of orders placed?
select count(order_id) as Total_Orders from orders;

#What is the Total number of pizzas sold?
SELECT SUM(order_details.quantity) as Total_Pizzas_Sold FROM order_details; 

#What is the total revenue generated from pizza sales?
SELECT sum(p.price*od.quantity) AS Total_Sales
FROM pizzas p
JOIN order_details od 
ON p.pizza_id = od.pizza_id;

#What is the Average Pizzas per order?
SELECT SUM(quantity) / COUNT(DISTINCT order_id) AS Average_Pizzas_per_order
FROM order_details;


#What is the Average Order Value per order?
SELECT SUM(p.price * od.quantity) / Count(DISTINCT o.order_id)  AS Average_Order_Value 
FROM pizzas p
JOIN order_details od
ON p.pizza_id = od.pizza_id
JOIN orders o 
ON o.order_id = od.order_id;

#What is the Daily Trend of Orders?
SELECT DAYNAME(order_date) AS order_day, COUNT(DISTINCT order_id) AS Total_orders  
FROM orders
GROUP BY DAYNAME(order_date), DAYOFWEEK(order_date)
ORDER BY DAYOFWEEK(order_date);

#What is the Monthly Trend of Orders?
SELECT MONTHNAME(order_date) AS order_month, COUNT(DISTINCT order_id) AS Total_orders  
FROM orders
GROUP BY MONTHNAME(order_date), MONTH(order_date)
ORDER BY MONTH(order_date) ASC;



#Which one is the Highest priced pizza?
SELECT pt.name, p.price 
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC 
LIMIT 1;

#Which one is the most common Pizza size order?
SELECT p.size, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC
LIMIT 1;	

#List the top five most ordered pizza types along with their quantities.
SELECT pt.name, sum(od.quantity) as Pizzas_Ordered
FROM pizzas p
JOIN order_details od 
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id 
GROUP BY pt.name ORDER BY Pizzas_Ordered DESC
LIMIT 5;


#Find the Total Quantity of each Pizza Category Ordered. 
SELECT pt.category, SUM(od.quantity) as Total_Quantity
FROM pizzas p 
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY Total_Quantity DESC;


#Determine the distribution of the orders by hour of the day
SELECT HOUR(order_time) as Hour, COUNT(order_id) as Order_Count 
FROM orders 
GROUP BY HOUR(order_time);

 #Find the category wise distribution of Pizzas.
 SELECT  category, COUNT(pizza_type_id) as Pizza_Count
 FROM  pizza_types
 GROUP BY category;
 
 #Group the orders by date and calculate the average number of pizzas ordered per day.
 SELECT round(AVG(quantity),0) as Average_Pizzas_Per_Day
 FROM (select orders. order_date, SUM(order_details.quantity) as quantity 
 FROM orders 
 JOIN order_details ON orders.order_id = order_details.order_id 
 GROUP BY orders.order_date) as order_quantity;
 
 #What are the top 3 most ordered pizza types based on revenue?
 SELECT pt.name, pt.pizza_type_id, SUM(od.quantity * p.price) as Revenue
 FROM pizzas p 
 JOIN order_details od
 ON p.pizza_id = od.pizza_id 
 JOIN pizza_types pt
 ON p.pizza_type_id = pt.pizza_type_id
 GROUP BY pt.name, pt.pizza_type_id 
 ORDER BY Revenue DESC
 LIMIT 3;
 
#What is the percentage contribution of each pizza category to total revenue?
SELECT pizza_types.category, round(sum(order_details.quantity*pizzas.price) / 
	(SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_sales 
		FROM order_details
		JOIN pizzas 
		ON pizzas.pizza_id = order_details.pizza_id) *100,2) as revenue
FROM pizza_types 
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category 
ORDER BY revenue DESC;   
 
 
#Analyze the cumulative revenue generated over time
SELECT order_date, 
SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM 
(SELECT orders.order_date,
SUM(order_details.quantity * pizzas.price) AS revenue
FROM order_details 
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS sales;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category
SELECT name, revenue 
FROM
(SELECT category, name, revenue,
RANK() OVER(partition by category order by revenue desc) AS rn
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM((order_details.quantity) * pizzas.price) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE rn <= 3;


SELECT @@hostname;


