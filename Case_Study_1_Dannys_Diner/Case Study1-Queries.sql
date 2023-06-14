/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

	SELECT
		S.customer_id,
		SUM(ME.price) total_amount
	FROM dannys_diner.sales S
	JOIN dannys_diner.menu ME
		ON S.product_id = ME.product_id
	GROUP BY 1
	ORDER BY 2 DESC;
	
-- 2. How many days has each customer visited the restaurant?

	SELECT
		customer_id,
		COUNT(DISTINCT order_date) num_days
	FROM dannys_diner.sales
	GROUP BY 1
	ORDER BY 2 DESC;

-- 3. What was the first item from the menu purchased by each customer?

	WITH first_time AS(
		SELECT
			customer_id,
			MIN(order_date) first_date
		FROM dannys_diner.sales
		GROUP BY 1)

	SELECT
		S.customer_id,
		M.product_name
	FROM dannys_diner.sales S
	JOIN dannys_diner.menu M
		ON S.product_id = M.product_id
	JOIN first_time F
		ON S.customer_id = F.customer_id
		AND S.order_date = F.first_date
	ORDER BY 1;
         
         
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

	SELECT
		M.product_name,
		COUNT(S.product_id) num_times
	FROM dannys_diner.menu M
	JOIN dannys_diner.sales S
		ON M.product_id = S.product_id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 1;


-- 5. Which item was the most popular for each customer?

	WITH products_order AS
		(SELECT
			S.customer_id,
			M.product_name,
			COUNT(S.product_id) num_times
		FROM dannys_diner.sales S
		JOIN dannys_diner.menu M
			ON S.product_id = M.product_id
		GROUP BY 1, 2),

	customer_order AS
		(SELECT 
			customer_id,
			MAX(num_times) num_times
		FROM products_order
		GROUP BY 1)

	SELECT 
		P.customer_id,
		P.product_name
	FROM products_order P
	JOIN customer_order C
		ON P.customer_id = C.customer_id
		AND P.num_times = C.num_times
	ORDER BY 1;

-- 6. Which item was purchased first by the customer after they became a member?

	WITH orders_after_member AS
		(SELECT
			S.customer_id,
			ME.product_name,
			S.order_date
		FROM dannys_diner.sales S
		JOIN dannys_diner.menu ME
			ON S.product_id = ME.product_id
		JOIN dannys_diner.members MM
			ON S.customer_id = MM.customer_id
			AND S.order_date > MM.join_date
		ORDER BY 1),

	customer_and_order AS
		(SELECT 
			customer_id,
			MIN(order_date) first_date
		FROM orders_after_member
		GROUP BY 1)

	SELECT
		O.customer_id,
		O.product_name	
	FROM orders_after_member O
	JOIN customer_and_order C
		ON O.customer_id = C.customer_id
		AND O.order_date = C.first_date;


-- 7. Which item was purchased just before the customer became a member?

	WITH orders_before_member AS
		(SELECT
			S.customer_id,
			ME.product_name,
			S.order_date
		FROM dannys_diner.sales S
		JOIN dannys_diner.menu ME
			ON S.product_id = ME.product_id
		JOIN dannys_diner.members MM
			ON S.customer_id = MM.customer_id
			AND S.order_date < MM.join_date
		ORDER BY 1),

	customer_and_order AS
		(SELECT 
			customer_id,
			MAX(order_date) last_date
		FROM orders_before_member
		GROUP BY 1)

	SELECT
		O.customer_id,
		O.product_name	
	FROM orders_before_member O
	JOIN customer_and_order C
		ON O.customer_id = C.customer_id
		AND O.order_date = C.last_date;
    
    
-- 8. What is the total items and amount spent for each member before they became a member?

	SELECT
		S.customer_id,
		COUNT(S.customer_id) num_items,
		SUM(ME.price) total_amount
	FROM dannys_diner.sales S
	JOIN dannys_diner.menu ME
		ON S.product_id = ME.product_id
	JOIN dannys_diner.members MM
		ON S.customer_id = MM.customer_id
		AND S.order_date < MM.join_date
	GROUP BY 1 ;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

	WITH products_points AS
		(SELECT
			product_id,
			product_name,
			price,
			CASE
				WHEN product_name = 'sushi' THEN price * 20
				ELSE price * 10
			 END AS points
		 FROM dannys_diner.menu)

	SELECT
		S.customer_id,
		SUM(PP.points) total_points
	FROM dannys_diner.sales S
	JOIN products_points PP
		ON S.product_id = PP.product_id
	GROUP BY 1
	ORDER BY 1;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
	--how many points do customer A and B have at the end of January?

	WITH jan_points AS
		(SELECT
			S.customer_id,
			S.order_date,
			M.product_name,
			M.price,
			CASE
				WHEN M.product_name = 'sushi' THEN price * 20 
				WHEN S.order_date >= MM.join_date
				AND S.order_date <= MM.join_date + INTERVAL '7 days' THEN price * 20
			  ELSE price * 10
			 END AS points
		FROM dannys_diner.menu M
		JOIN dannys_diner.sales S
			ON M.product_id = S.product_id
			AND (S.customer_id = 'A' OR S.customer_id = 'B')
			AND S.order_date <= '2021-01-31'
		JOIN dannys_diner.members MM
			ON S.customer_id = MM.customer_id
		ORDER BY 1, 2)

	SELECT
		customer_id,
		SUM(points) total_points
	FROM jan_points
	GROUP BY 1 ;


-- 11. The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join 
	-- the underlying tables using SQL.

	SELECT
		S.customer_id,
		S.order_date,
		M.product_name,
		M.price,
		CASE
			WHEN S.order_date >= MM.join_date THEN 'Y'
			ELSE 'N'
		END AS member
	FROM dannys_diner.sales S
	JOIN dannys_diner.menu M
		ON S.product_id = M.product_id
	LEFT JOIN dannys_diner.members MM
		ON S.customer_id = MM.customer_id
	ORDER BY 1, 2;


-- 12. Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking 
	-- for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

	SELECT
		S.customer_id,
		S.order_date,
		M.product_name,
		M.price,
		CASE
			WHEN S.order_date >= MM.join_date THEN 'Y'
			ELSE 'N'
		END AS member,
		CASE
			WHEN S.order_date >= MM.join_date THEN
				DENSE_RANK() OVER (PARTITION BY S.customer_id ORDER BY 
								   CASE WHEN S.order_date >= MM.join_date THEN S.order_date END) 
		END AS ranking
	FROM dannys_diner.sales S
	JOIN dannys_diner.menu M
		ON S.product_id = M.product_id
	LEFT JOIN dannys_diner.members MM
		ON S.customer_id = MM.customer_id
	ORDER BY 1, 2;

