---task queries

--Task 1: Retrieve the total number of orders placed.

SELECT 
	COUNT(ORDER_ID) AS TOTAL_ORDERS
FROM ORDERS

--Task 2: Calculate the total revenue generated from pizza sales.

SELECT
	SUM(OD.QUANTITY * PIZZAS.PRICE) AS TOTAL_REVENUE
FROM ORDER_DETAILS AS OD
JOIN PIZZAS ON OD.PIZZA_ID = PIZZAS. PIZZA_ID

--Task 3: Identify the highest-priced pizza.

SELECT
	PT.PIZZA_NAME,
	PIZZAS.PRICE
FROM PIZZAS
JOIN PIZZA_TYPES AS PT ON PIZZAS.PIZZA_TYPE_ID = PT.PIZZA_TYPE_ID
ORDER BY 2 DESC
LIMIT 1;

--Task 4: Identify the most common pizza size ordered.

SELECT
	P.SIZE,
	SUM(OD.QUANTITY) AS TOTAL_QUANTITY_ORDERED
FROM PIZZAS AS P
	JOIN ORDER_DETAILS AS OD ON P.PIZZA_ID = OD.PIZZA_ID
GROUP BY 1
ORDER BY 2 DESC;

--Task 5: List the top 5 most ordered pizza types along with their quantities..

SELECT
	PT.PIZZA_NAME,
	SUM(QUANTITY) AS ORDER_QUANTITY
FROM ORDER_DETAILS AS OD
	JOIN PIZZAS ON OD.PIZZA_ID = PIZZAS.PIZZA_ID
	JOIN PIZZA_TYPES AS PT ON PIZZAS.PIZZA_TYPE_ID = PT.PIZZA_TYPE_ID
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--Task 6: Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT
	PT.CATEGORY ,
	SUM (OD.QUANTITY) AS TOTAL_QUANTITY
FROM ORDER_DETAILS AS OD
	JOIN PIZZAS ON OD.PIZZA_ID = PIZZAS. PIZZA_ID
	JOIN PIZZA_TYPES AS PT ON PIZZAS.PIZZA_TYPE_ID = PT.PIZZA_TYPE_ID
GROUP BY 1
ORDER BY 2

--Task 7: Determine the distribution of orders by hour of the day.

SELECT
	EXTRACT(
		HOUR
		FROM
			TIME
	) AS HOUR_OF_DAY,
	COUNT(ORDER_ID) AS ORDER_COUNT
FROM
	ORDERS
GROUP BY
	1
ORDER BY 1;

--Task 8: Join relevant tables to find the category-wise distribution of pizzas.

SELECT
	CATEGORY,
	COUNT(PIZZA_NAME) AS PIZZA
FROM
	PIZZA_TYPES
GROUP BY
	CATEGORY;


--Task 9: Group the orders by date and calculate the average number of pizzas ordered per day.

WITH
	ORDER_BY_DATE AS (
		SELECT
			ORDERS.DATE,
			SUM(OD.QUANTITY) AS ORDER_COUNT
		FROM
			ORDERS
			JOIN ORDER_DETAILS AS OD ON ORDERS.ORDER_ID = OD.ORDER_ID
		GROUP BY
			DATE
		ORDER BY
			DATE
	)
SELECT
	ROUND(AVG(ORDER_COUNT)) AS AVG_ORDER_PER_DAY
FROM
	ORDER_BY_DATE


--Task 10: Determine the top 3 most ordered pizza types based on revenue.

SELECT
	PT.PIZZA_NAME,
	SUM(OD.QUANTITY * PIZZAS.PRICE) AS REVENUE
FROM
	ORDER_DETAILS AS OD
	JOIN PIZZAS ON OD.PIZZA_ID = PIZZAS.PIZZA_ID
	JOIN PIZZA_TYPES AS PT ON PIZZAS.PIZZA_TYPE_ID = PT.PIZZA_TYPE_ID
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT
	3;

--Task 11: Calculate the percentage contribution of each pizza type to total revenue.

WITH
	TOTALREVENUE AS (
		SELECT
			SUM(OD.QUANTITY * P.PRICE) AS TOTAL_REVENUE
		FROM
			ORDER_DETAILS AS OD
			JOIN PIZZAS P ON OD.PIZZA_ID = P.PIZZA_ID
	),
	CATEGORYREVENUE AS (
		SELECT
			PT.CATEGORY,
			SUM(OD.QUANTITY * P.PRICE) AS CATEGORY_REVENUE
		FROM
			PIZZA_TYPES PT
			JOIN PIZZAS P ON PT.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
			JOIN ORDER_DETAILS OD ON P.PIZZA_ID = OD.PIZZA_ID
		GROUP BY
			PT.CATEGORY
	)
SELECT
	CR.CATEGORY,
	ROUND(
		(CR.CATEGORY_REVENUE * 100.0 / TR.TOTAL_REVENUE),
		2
	) AS PERCENTAGE_REVENUE
FROM
	CATEGORYREVENUE CR
	CROSS JOIN TOTALREVENUE TR
ORDER BY
	PERCENTAGE_REVENUE DESC;

--Task 12: Analyze the cumulative revenue generated over time.
WITH
	REVENUE_BY_DATE AS (
		SELECT
			ORDERS.DATE,
			SUM(OD.QUANTITY * PIZZAS.PRICE) AS REVENUE
		FROM
			ORDERS
			JOIN ORDER_DETAILS AS OD ON ORDERS.ORDER_ID = OD.ORDER_ID
			JOIN PIZZAS ON OD.PIZZA_ID = PIZZAS.PIZZA_ID
		GROUP BY
			1
		ORDER BY
			1
	)
SELECT
	RD.DATE,
	SUM(REVENUE) OVER (
		ORDER BY
			DATE
	) AS CUM_REVENUE
FROM
	REVENUE_BY_DATE AS RD;

--Task 13: Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH
	CATEGORYREVENUE AS (
		SELECT
			PT.CATEGORY,
			PT.PIZZA_NAME,
			SUM(OD.QUANTITY * P.PRICE) AS REVENUE,
			ROW_NUMBER() OVER (
				PARTITION BY
					PT.CATEGORY
				ORDER BY
					SUM(OD.QUANTITY * P.PRICE) DESC
			) AS RN
		FROM
			PIZZA_TYPES PT
			JOIN PIZZAS P ON PT.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
			JOIN ORDER_DETAILS OD ON P.PIZZA_ID = OD.PIZZA_ID
		GROUP BY
			PT.CATEGORY,
			PT.PIZZA_NAME
	)
SELECT
	CATEGORY,
	PIZZA_NAME,
	REVENUE
FROM
	CATEGORYREVENUE
WHERE
	RN <= 3
ORDER BY
	CATEGORY,
	REVENUE DESC;

--- END ---


