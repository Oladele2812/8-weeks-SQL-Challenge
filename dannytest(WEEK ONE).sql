use dannys_diner;
-- QUESTION 1: what is the total amount spent by esch customer

select customer_id,sum(price) as total_amount_spent
from sales as s
join menu as m
on s.product_id=m.product_id
group by customer_id
order by total_amount_spent desc;
;
-- QUESTION 2: how ,many days has each custoner visited the bar
SELECT customer_id, count(distinct order_date) as number_of_days_visited
FROM sales 
GROUP BY customer_id
ORDER BY number_of_days_visited desc;

-- QUESTION 3: what is the first item purchased by each customer?
select customer_id,product_name
from(
SELECT customer_id,product_name, row_number() over(partition by customer_id order by order_date asc) as rn 
from sales as s
join menu as m
on s.product_id = m.product_id
) as subquery
where subquery.rn=1;

-- QUESTION 4: What is the most purchased item on the menu and how ,any times was it purchased
select m.product_name,count(*) as number_of_time_purchased
from sales as s 
join menu as m
on s.product_id=m.product_id
group by m.product_name
order by number_of_time_purchased desc
limit 1;
-- Question 5:which item was the most popular for each customer?
select customer_id,product_name,c
from 
(select customer_id,product_name,count(*) as c,rank() over(partition by customer_id order by count(*) desc) as rn
from sales as s
join menu as m
on s.product_id=m.product_id
group by customer_id,product_name
order by c desc
) as subquery
where subquery.rn=1
order by customer_id
;  
-- QUESTION 6:which item was purchased first by a customer after they became a member?
select customer_id,product_name,order_date
from(
select s.customer_id,product_name,rank() over(partition by customer_id order by order_date) as rn,order_date
from sales as s
join menu as m
on s.product_id=m.product_id
join members as me
on s.customer_id=me.customer_id
where order_date >= me.join_date)
as sub
where sub.rn =1
;
-- QUESTION 7: which item was purchased just when before they customer became a memeber?
select customer_id,product_name,order_date
from(
select s.customer_id,product_name,rank() over(partition by customer_id order by order_date) as rn,order_date
from sales as s
join menu as m
on s.product_id=m.product_id
join members as me
on s.customer_id=me.customer_id
where order_date < me.join_date)
as sub
where sub.rn =1
;
-- QUESTION 8: What is the total items amount spent by a csutomer just before th customer became a memeber?
select customer_id,count(product_name) total_product_purchased,sum(price) as total_amount_spent
from(
select s.customer_id,product_name,rank() over(partition by customer_id order by order_date) as rn,order_date,price
from sales as s
join menu as m
on s.product_id=m.product_id
join members as me
on s.customer_id=me.customer_id
where order_date < me.join_date)
as sub
where sub.rn =1
group by customer_id
;
-- QUESTION 9: if easch $1 spent by each customer eqautes 10points and sushi has 2x point multiplier,how many point does each customer has?
SELECT customer_id,sum(Points) as Total_points
FROM 
(SELECT customer_id,s.product_id,product_name,price, 
CASE WHEN product_name='sushi' THEN price*20
ELSE price*10
END AS Points
 FROM dannys_diner.sales as s
join menu as m
on s.product_id=m.product_id
) as sub
GROUP BY customer_id
ORDER BY customer_id;

/* QUESTION 10:In the first week after a customer joined the program(including their joined date) they earn 2x points on all items not just sushi 
how many points do customer A and B have at the end of January*/
SELECT 
  m.customer_id,
  SUM(CASE WHEN s.order_date BETWEEN m.join_date AND DATE_ADD(m.join_date, INTERVAL 7 DAY) THEN 2*price ELSE price END) AS total_points
FROM 
  Sales s
  INNER JOIN menu mnu ON s.product_id = mnu.product_id
  INNER JOIN members m ON s.customer_id = m.customer_id
WHERE 
  m.customer_id IN ('A', 'B')
   AND s.order_date <= '2021-01-31'
GROUP BY 
  m.customer_id


