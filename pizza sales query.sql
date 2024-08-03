-- Q1: Retrieve the total number of orders placed.

select count(orders.order_id) as total_orders
from orders;

-- Q2: Calculate the total revenue generated from pizza sales.

select 
ROUND(SUM(order_details.quantity* pizzas.price),2) as total_sales
from pizzas
JOIN order_details ON (pizzas.pizza_id = order_details.pizza_id);

-- Q3: Identify the highest-priced pizza.

select pizza_types.name,pizzas.price
from pizza_types
JOIN pizzas ON (pizzas.pizza_type_id = pizza_types.pizza_type_id)
order by pizzas.price desc
limit 1;

-- Q4: Identify the most common pizza size ordered.

select pizzas.size, count(order_details.order_details_id) as order_quantity
from pizzas
JOIN order_details ON ( pizzas.pizza_id = order_details.pizza_id)
group by pizzas.size 
order by order_quantity desc;

-- Q5: List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name, sum(order_details.quantity) as quantity
from pizza_types
JOIN pizzas ON (pizza_types.pizza_type_id = pizzas.pizza_type_id)
JOIN order_details ON (order_details.pizza_id = pizzas.pizza_id)
group by pizza_types.name 
order by quantity desc
limit 5;

-- Q6: Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, sum(order_details.quantity) as quantity 
from pizza_types
join pizzas ON (pizza_types.pizza_type_id = pizzas.pizza_type_id)
join order_details ON (pizzas.pizza_id = order_details.pizza_id)
group by pizza_types.category
order by quantity desc;

-- Q7: Determine the distribution of orders by hour of the day.

select extract(hour from order_time)as hour, count(order_id) as order_count
from orders
group by extract(hour from order_time);

-- Q8: Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name) 
from pizza_types
group by category;

-- Q9: Group the orders by date and calculate the average number of pizzas ordered per day.\

SELECT ROUND(AVG(quantity),0) as average_pizza_ordered
FROM 
(SELECT orders.order_date , SUM(order_details.quantity) as Quantity
FROM orders 
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS order_quantity;


-- Q.10 Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, SUM(pizzas.price * order_details.quantity) as revenue 
from pizza_types
JOIN pizzas ON (pizza_types.pizza_type_id = pizzas.pizza_type_id)
JOIN order_details ON (pizzas.pizza_id = order_details.pizza_id)
group by pizza_types.name
order by revenue desc 
limit 3;

-- Q.11 Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category, 
round(SUM(pizzas.price * order_details.quantity) / (select round(SUM(pizzas.price * order_details.quantity),2) as total_sales 
from order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id)*100,2) as revenue
from pizza_types
JOIN pizzas ON (pizzas.pizza_type_id = pizza_types.pizza_type_id)
JOIN order_details ON (pizzas.pizza_id = order_details.pizza_id)
group by pizza_types.category
order by revenue desc;

-- Q.12 Analyze the cumulative revenue generated over time.
select order_date,sum(revenue) over (order by order_date) as total_revenue
from 
(select orders.order_date,round(sum(pizzas.price * order_details.quantity),2) as revenue
from orders 
join order_details ON (orders.order_id = order_details.order_id)
join pizzas ON (pizzas.pizza_id = order_details.pizza_id)
group by orders.order_date) as sales;

-- Q.13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with temp_table as (select pizza_types.category,pizza_types.name,round(sum(pizzas.price * order_details.quantity),2) as revenue, 
rank()over(partition by category order by sum(pizzas.price * order_details.quantity) desc) as p
from pizza_types
JOIN pizzas on (pizza_types.pizza_type_id = pizzas.pizza_type_id)
JOIN order_details on (pizzas.pizza_id = order_details.pizza_id)
group by pizza_types.category,pizza_types.name
order by pizza_types.category,revenue desc)
select category,name, revenue
from temp_table
where p <= 3;






