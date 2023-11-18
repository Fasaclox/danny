--DANNYS DINNER --
--CASE STUDY 1--
--QUESTIONS AND ANSWERS--
--1. What is the total amount each customer spent at the restaurant?

SELECT 
	S.customer_id AS Customer, 
	SUM( M.price ) AS Total_Amount_Spent
FROM 
	sales AS S INNER JOIN menu AS M 
	ON S.product_id=M.product_id

GROUP BY customer_id
ORDER BY Total_Amount_Spent DESC


--2.How many days has each customer visited the restaurant?

SELECT
	customer_id AS Customer,
	COUNT (DISTINCT(order_date)) AS Number_of_Visits
FROM sales
GROUP BY customer_id
ORDER BY Number_of_Visits DESC

--3. What was the first item from the menu purchased by each customer?

WITH CTE_CustomerPurchase AS (
SELECT 
	customer_id,
	order_date,
	product_name,
	Rank() Over (Partition by customer_id Order by order_date ) as DateRank 
FROM 
	sales as s inner join menu as m 
	on s.product_id=m.product_id
)
SELECT 
	customer_id,
	product_name
FROM 
	CTE_CustomerPurchase
WHERE DateRank =1


--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1
	product_name,
	count(s.product_id) as TotalPurchase
FROM 
	sales as s inner join menu as m 
	on s.product_id=m.product_id
GROUP BY 
	product_name
ORDER BY 
	TotalPurchase DESC

--5. Which item was the most popular for each customer?
WITH CTE_CustomerPurchase AS (
SELECT 
	customer_id,
	product_name,
	count(product_name) as TotalPurchase,
	rank() Over (Partition by customer_id order by count(product_name) desc)  as ProductRank
FROM 
	sales as s inner join menu as m 
	on s.product_id=m.product_id
GROUP BY 
	product_name,
	customer_id
)

SELECT 
	customer_id,
	product_name
FROM 
	CTE_CustomerPurchase
WHERE 
	ProductRank = 1

---6. Which item was purchased first by the customer after they became a member?
WITH CTE_MemberPurchase AS (

SELECT 
	S.customer_id,
	product_name,
	join_date,
	order_date,
	RANK() OVER (PARTITION BY S.Customer_id ORDER BY order_date) AS PurchaseRank
FROM Sales AS S 
	INNER JOIN Menu AS M ON S.product_id=M.product_id
	INNER JOIN members AS Mem ON S.customer_id=Mem.customer_id
WHERE 
	order_date >=join_date 

)   
SELECT 
	customer_id,
	product_name
FROM 
	CTE_MemberPurchase
WHERE 
	PurchaseRank = 1 

---7. Which item was purchased just before the customer became a member?
WITH CTE_MemberPurchase AS (

SELECT 
	S.customer_id,
	product_name,
	join_date,
	order_date,
	RANK() OVER (PARTITION BY S.Customer_id ORDER BY order_date) AS PurchaseRank
FROM Sales AS S 
	INNER JOIN Menu AS M ON S.product_id=M.product_id
	INNER JOIN members AS Mem ON S.customer_id=Mem.customer_id
WHERE 
	order_date <join_date 

)   
SELECT
	customer_id,
	product_name
FROM 
	CTE_MemberPurchase
WHERE 
	PurchaseRank = 1 

--8 What is the total items and amount spent for each member before they became a member?

SELECT 
	S.customer_id,
	COUNT(S.product_id) AS TotalProduct,
	SUM(M.price) AS TotalAmount
FROM Sales AS S 
	INNER JOIN Menu AS M ON S.product_id=M.product_id
	INNER JOIN members AS Mem ON S.customer_id=Mem.customer_id
WHERE 
	order_date < join_date
GROUP BY
	S.customer_id

---9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	customer_id,
	SUM(
			CASE product_name	
				WHEN 'sushi' THEN price * 10 * 2  
				ELSE price * 10 
				END) AS TotalPoints
FROM 
	sales AS S 
	INNER JOIN	menu AS M
	ON S.product_id = M.product_id
GROUP BY 
	customer_id
ORDER BY TotalPoints DESC

--- 10 In the first week after a customer joins the program (including their join date)
---they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT
    S.customer_id,
    SUM(
        CASE
            WHEN S.order_date BETWEEN Mem.join_date AND 
			DATEADD(day, 6, Mem.join_date) THEN price * 10 * 2 
            WHEN product_name = 'sushi' THEN price * 10 * 2  
            ELSE price * 10 
        END
    ) AS TotalPoints
FROM 
    sales AS S 
    INNER JOIN menu AS M ON S.product_id = M.product_id
    INNER JOIN members AS Mem ON S.customer_id = Mem.customer_id
WHERE 
    YEAR(S.order_date) = 2021 AND MONTH(S.order_date) = 1
GROUP BY 
    S.customer_id
ORDER BY 
	TotalPoints DESC



