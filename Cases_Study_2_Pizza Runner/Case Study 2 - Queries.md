# 8 Week SQL Challenge by Danny Ma

## Case Study 2 - Pizza Runner

<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" width="600" height="550">

**- Access the challenge and full details about it via this link** [Case Study #2 - Pizza Runner](https://8weeksqlchallenge.com/case-study-2/).

---

### A. Cleaning Stage of the Dataset:

  #### 1- Table 1: runners:
  
  ```sql
    SELECT *
    FROM pizza_runner.runners;
  ```

| runner_id | registration_date        |
| --------- | ------------------------ |
| 1         | 2021-01-01T00:00:00.000Z |
| 2         | 2021-01-03T00:00:00.000Z |
| 3         | 2021-01-08T00:00:00.000Z |
| 4         | 2021-01-15T00:00:00.000Z |


  - According to the results, the runners table dosen't need any cleaning. But we will create a temporary table from it to keep the origin database.

 ```sql
  DROP TABLE IF EXISTS runners_cleaned;
  CREATE TEMP TABLE runners_cleaned AS
    (SELECT *
     FROM pizza_runner.runners);
```
---

 #### 2- Table 2: customer_orders:
  
```sql
   SELECT *
   FROM pizza_runner.customer_orders;
```

| order_id | customer_id | pizza_id | exclusions | extras | order_time               |
| -------- | ----------- | -------- | ---------- | ------ | ------------------------ |
| 1        | 101         | 1        |            |        | 2020-01-01T18:05:02.000Z |
| 2        | 101         | 1        |            |        | 2020-01-01T19:00:52.000Z |
| 3        | 102         | 1        |            |        | 2020-01-02T23:51:23.000Z |
| 3        | 102         | 2        |            |        | 2020-01-02T23:51:23.000Z |
| 4        | 103         | 1        | 4          |        | 2020-01-04T13:23:46.000Z |
| 4        | 103         | 1        | 4          |        | 2020-01-04T13:23:46.000Z |
| 4        | 103         | 2        | 4          |        | 2020-01-04T13:23:46.000Z |
| 5        | 104         | 1        | null       | 1      | 2020-01-08T21:00:29.000Z |
| 6        | 101         | 2        | null       | null   | 2020-01-08T21:03:13.000Z |
| 7        | 105         | 2        | null       | 1      | 2020-01-08T21:20:29.000Z |
| 8        | 102         | 1        | null       | null   | 2020-01-09T23:54:33.000Z |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10T11:22:59.000Z |
| 10       | 104         | 1        | null       | null   | 2020-01-11T18:34:49.000Z |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11T18:34:49.000Z |


  - The customer_orders table has two columns need to be cleaned exclusions and extras where we should handle missing values and datatypes.
  - First step we will create a temporary table from it:

 ```sql
  DROP TABLE IF EXISTS customer_orders_cleaned_1;
  CREATE TEMP TABLE customer_orders_cleaned_1 AS
    (SELECT 
       ROW_NUMBER() OVER(ORDER BY order_id):: INT row_id,
       *
     FROM pizza_runner.customer_orders);
```

- We named it customer_orders_cleaned_1 because it will be the first step of cleaning this table and we add row_id column to make the rows unique and we will use later in the cleaning stage.
- Now we will handle the missing values of the two columns:

1. exclusions column:

    ```sql
	UPDATE customer_orders_cleaned_1
	SET exclusions = NULL
	WHERE exclusions LIKE ' ' OR exclusions LIKE '';

	UPDATE customer_orders_cleaned_1
	SET exclusions = NULL
	WHERE exclusions LIKE 'null';
    ```
  
2. extras column:

  ```sql
	UPDATE customer_orders_cleaned_1
	SET extras = NULL
	WHERE extras LIKE ' ' OR extras LIKE '';

	UPDATE customer_orders_cleaned_1
	SET extras = NULL
	WHERE extras LIKE 'null';
  ```
  
 - In order to optimize the customer_orders_cleaned_1, we need to handle the exclusions and extras columns because they have multiple values in the same cell in some rows
 - So we will create from it three new tables:
 1. **customer_orders_cleaned:** contains the all coulmns except the exclusions and extras columns, it will be the main table of customer orders.
 2. **exclusions_cleaned:** contains two columns the row_id and exclusion_id, connected with customer_orders_cleaned through row_id column and also it will be connected with pizza_toppings_cleaned later.
 3. **extras_cleaned:** contains two columns the row_id and extras_id, connected with customer_orders_cleaned through row_id column and also it will be connected with pizza_toppings_cleaned later.
 

**customer_orders_cleaned:**

```sql
   DROP TABLE IF EXISTS customer_orders_cleaned;
   CREATE TEMP TABLE customer_orders_cleaned AS
	   (SELECT
		row_id,
		order_id,
		customer_id,
		pizza_id,
		order_time
	    FROM customer_orders_cleaned_1);
```
```sql
   SELECT *
   FROM customer_orders_cleaned
   ORDER BY 1;
```

| row_id | order_id | customer_id | pizza_id | order_time               |
| ------ | -------- | ----------- | -------- | ------------------------ |
| 1      | 1        | 101         | 1        | 2020-01-01T18:05:02.000Z |
| 2      | 2        | 101         | 1        | 2020-01-01T19:00:52.000Z |
| 3      | 3        | 102         | 1        | 2020-01-02T23:51:23.000Z |
| 4      | 3        | 102         | 2        | 2020-01-02T23:51:23.000Z |
| 5      | 4        | 103         | 1        | 2020-01-04T13:23:46.000Z |
| 6      | 4        | 103         | 1        | 2020-01-04T13:23:46.000Z |
| 7      | 4        | 103         | 2        | 2020-01-04T13:23:46.000Z |
| 8      | 5        | 104         | 1        | 2020-01-08T21:00:29.000Z |
| 9      | 6        | 101         | 2        | 2020-01-08T21:03:13.000Z |
| 10     | 7        | 105         | 2        | 2020-01-08T21:20:29.000Z |
| 11     | 8        | 102         | 1        | 2020-01-09T23:54:33.000Z |
| 12     | 9        | 103         | 1        | 2020-01-10T11:22:59.000Z |
| 13     | 10       | 104         | 1        | 2020-01-11T18:34:49.000Z |
| 14     | 10       | 104         | 1        | 2020-01-11T18:34:49.000Z |


**exclusions_cleaned:**

```sql
	DROP TABLE IF EXISTS exclusions_cleaned;
	CREATE TEMP TABLE exclusions_cleaned AS
		(SELECT 
			row_id,
			UNNEST(string_to_array(exclusions, ','))::INTEGER exclusions_id
		FROM customer_orders_cleaned_1);
```
```sql
	SELECT *
	FROM exclusions_cleaned
	ORDER BY 1;
```

| row_id | exclusions_id |
| ------ | ------------- |
| 5      | 4             |
| 6      | 4             |
| 7      | 4             |
| 12     | 4             |
| 14     | 2             |
| 14     | 6             |


**extras_cleaned:**

```sql
	DROP TABLE IF EXISTS extras_cleaned;
	CREATE TEMP TABLE extras_cleaned AS
		(SELECT 
			row_id,
			UNNEST(string_to_array(extras, ','))::INTEGER extras_id
		FROM customer_orders_cleaned_1);
```
```sql
	SELECT *
	FROM extras_cleaned
	ORDER BY 1;
```

| row_id | extras_id |
| ------ | --------- |
| 8      | 1         |
| 10     | 1         |
| 12     | 1         |
| 12     | 5         |
| 14     | 1         |
| 14     | 4         |


- Finally we have finished the cutsomer_orders cleaning and we got three tables which we will use in the challenge (customer_orders_cleaned, exclusions_cleaned and extras_cleaned).

---

#### 3- Table 3: runner_orders:

```sql
	SELECT *
	FROM pizza_runner.runner_orders;
```

| order_id | runner_id | pickup_time         | distance | duration   | cancellation            |
| -------- | --------- | ------------------- | -------- | ---------- | ----------------------- |
| 1        | 1         | 2020-01-01 18:15:34 | 20km     | 32 minutes |                         |
| 2        | 1         | 2020-01-01 19:10:54 | 20km     | 27 minutes |                         |
| 3        | 1         | 2020-01-03 00:12:37 | 13.4km   | 20 mins    |                         |
| 4        | 2         | 2020-01-04 13:53:03 | 23.4     | 40         |                         |
| 5        | 3         | 2020-01-08 21:10:57 | 10       | 15         |                         |
| 6        | 3         | null                | null     | null       | Restaurant Cancellation |
| 7        | 2         | 2020-01-08 21:30:45 | 25km     | 25mins     | null                    |
| 8        | 2         | 2020-01-10 00:15:02 | 23.4 km  | 15 minute  | null                    |
| 9        | 2         | null                | null     | null       | Customer Cancellation   |
| 10       | 1         | 2020-01-11 18:50:20 | 10km     | 10minutes  | null                    |

- As we can see, there are four columns need to be cleaned (pickup_time, distance, duration and cancellation), need to changing datatypes, handling missing values and removing unwanted text.
- First step, we will create temporary table from it as usual, name it runner_orders_cleaned.

```sql
DROP TABLE IF EXISTS runner_orders_cleaned;
CREATE TEMP TABLE runner_orders_cleaned AS
	(SELECT *
	FROM pizza_runner.runner_orders);
```

- Now we will start cleaning each column one by one:

**1. pickup_time column:**
- Handling missing values:
```sql
	UPDATE runner_orders_cleaned
	SET pickup_time = NULL
	WHERE pickup_time LIKE 'null';
```

- Changing datatype (from VARCHAR to TIMESTAMP):
```sql
	ALTER TABLE runner_orders_cleaned
	ALTER COLUMN pickup_time TYPE TIMESTAMP WITHOUT TIME ZONE 
	USING pickup_time::TIMESTAMP WITHOUT TIME ZONE;
```

**2. distance column:**
- Handling missing values:
```sql
	UPDATE runner_orders_cleaned
	SET distance = NULL
	WHERE distance LIKE 'null';
```

- Removing unwanted text to reach consistency:
```sql
	UPDATE runner_orders_cleaned
	SET distance = REPLACE(distance, 'km', '');
```

- Changing the datatype of the columns (from VARCHAR to double precision):
```sql
	ALTER TABLE runner_orders_cleaned
	ALTER COLUMN distance TYPE double precision
	USING distance::double precision;
```

- Renaming the column to be more clear about its values:
```sql
	ALTER TABLE runner_orders_cleaned 
	RENAME COLUMN distance TO distance_km;
```

**3. duration column:**
- Handling missing values:
```sql
	UPDATE runner_orders_cleaned
	SET duration = NULL
	WHERE duration LIKE 'null';
```

- Removing unwanted text to reach consistency:
```sql
	UPDATE runner_orders_cleaned
	SET duration = REPLACE(duration, 'minutes', '');

	UPDATE runner_orders_cleaned
	SET duration = REPLACE(duration, 'mins', '');

	UPDATE runner_orders_cleaned
	SET duration = REPLACE(duration, 'minute', '');
```

- Changing the datatype of the columns (from VARCHAR to double precision):
```sql
	ALTER TABLE runner_orders_cleaned
	ALTER COLUMN duration TYPE double precision
	USING duration::double precision;
```

- Renaming the column to be more clear about its values:
```sql
	ALTER TABLE runner_orders_cleaned 
	RENAME COLUMN duration TO duration_minutes;
```

**4. cancellation column:**
- Handling missing values:
```sql
	UPDATE runner_orders_cleaned
	SET cancellation = NULL
	WHERE cancellation = ' ' OR cancellation = '' OR cancellation = 'null';

	UPDATE runner_orders_cleaned
	SET cancellation = 'Not Canceled'
	WHERE cancellation IS NULL;
```

- We have finished all required cleaning steps on the runner_orders table and got the cleaned version of it runner_orders_cleaned

```sql
	SELECT *
	FROM runner_orders_cleaned;
```
| order_id | runner_id | pickup_time              | distance_km | duration_minutes | cancellation            |
| -------- | --------- | ------------------------ | ----------- | ---------------- | ----------------------- |
| 6        | 3         |                          |             |                  | Restaurant Cancellation |
| 9        | 2         |                          |             |                  | Customer Cancellation   |
| 3        | 1         | 2020-01-03T00:12:37.000Z | 13.4        | 20               | Not Canceled            |
| 4        | 2         | 2020-01-04T13:53:03.000Z | 23.4        | 40               | Not Canceled            |
| 5        | 3         | 2020-01-08T21:10:57.000Z | 10          | 15               | Not Canceled            |
| 1        | 1         | 2020-01-01T18:15:34.000Z | 20          | 32               | Not Canceled            |
| 2        | 1         | 2020-01-01T19:10:54.000Z | 20          | 27               | Not Canceled            |
| 7        | 2         | 2020-01-08T21:30:45.000Z | 25          | 25               | Not Canceled            |
| 8        | 2         | 2020-01-10T00:15:02.000Z | 23.4        | 15               | Not Canceled            |
| 10       | 1         | 2020-01-11T18:50:20.000Z | 10          | 10               | Not Canceled            |

---

#### 4- Table 4: pizza_names:

```sql
	SELECT *
	FROM pizza_runner.pizza_names;
```

| pizza_id | pizza_name |
| -------- | ---------- |
| 1        | Meatlovers |
| 2        | Vegetarian |

  - According to the results, the pizza_names table dosen't need any cleaning. But we will create a temporary table from it to keep the origin database.
 
 ```sql
	DROP TABLE IF EXISTS pizza_names_cleaned;
	CREATE TEMP TABLE pizza_names_cleaned AS
		(SELECT *
		FROM pizza_runner.pizza_names);
```

---

#### 5- Table 5: pizza_recipes:

```sql
	SELECT *
	FROM pizza_runner.pizza_recipes;
```

| pizza_id | toppings                |
| -------- | ----------------------- |
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 |
| 2        | 4, 6, 7, 9, 11, 12      |

- As we can see, toppings column need to be clean because it have multiple values in the same row, so we should expand the values in the rows.
- We will create new temporary table pizza_recipes_cleaned to handle the multiple values in the toppings column.

```sql
	DROP TABLE IF EXISTS pizza_recipes_cleaned;
	CREATE TEMP TABLE pizza_recipes_cleaned AS
		(SELECT 
			pizza_id,
			UNNEST(string_to_array(toppings, ',')) :: INT topping_id
		FROM pizza_runner.pizza_recipes);
```

```sql
	SELECT *
	FROM pizza_recipes_cleaned;
```

| pizza_id | topping_id |
| -------- | ---------- |
| 1        | 1          |
| 1        | 2          |
| 1        | 3          |
| 1        | 4          |
| 1        | 5          |
| 1        | 6          |
| 1        | 8          |
| 1        | 10         |
| 2        | 4          |
| 2        | 6          |
| 2        | 7          |
| 2        | 9          |
| 2        | 11         |
| 2        | 12         |

---

#### 6- Table 6: pizza_toppings:

```sql
	SELECT *
	FROM pizza_runner.pizza_toppings;
```

| topping_id | topping_name |
| ---------- | ------------ |
| 1          | Bacon        |
| 2          | BBQ Sauce    |
| 3          | Beef         |
| 4          | Cheese       |
| 5          | Chicken      |
| 6          | Mushrooms    |
| 7          | Onions       |
| 8          | Pepperoni    |
| 9          | Peppers      |
| 10         | Salami       |
| 11         | Tomatoes     |
| 12         | Tomato Sauce |

  - According to the results, the pizza_toppings table dosen't need any cleaning. But we will create a temporary table from it to keep the origin database.

```sql
	DROP TABLE IF EXISTS pizza_toppings_cleaned;
	CREATE TEMP TABLE pizza_toppings_cleaned AS
		(SELECT *
		FROM pizza_runner.pizza_toppings);
```

---

- At this stage we have finished all the required cleaning procedures and we can start solving the challenge questions, but we need to see the new modle of our dataset.
- To discover the tables and their columns, we can take a look at the ER Diagram of the clean dataset:

<img src="https://github.com/AliHousein/8-Week-SQL-Challenge/blob/f8626733dfd25bbc95bf6b2e07d2f609e86cc0d8/Cases_Study_2_Pizza%20Runner/ER%20Diagram_Clean.png" width="800" height="600">

---

### B. Case Study Questions:

#### a. Pizza Metrics:

1. How many pizzas were ordered?

```sql
SELECT COUNT(pizza_id) num_ordered_pizzas
FROM customer_orders_cleaned;
```

| num_ordered_pizzas |
| ------------------ |
| 14                 |


2. How many unique customer orders were made?

```sql
SELECT COUNT(DISTINCT order_id) num_unique_orders
FROM customer_orders_cleaned;
```

| num_unique_orders  |
| ------------------ |
| 10                 |


3. How many successful orders were delivered by each runner?

```sql
SELECT 
	runner_id,
	COUNT(cancellation) num_delivered_orders
FROM runner_orders_cleaned
WHERE cancellation LIKE 'Not Canceled'
GROUP BY 1;
```

| runner_id  | num_delivered_orders |
| ---------- | -------------------- |
| 1          | 4        	    |
| 2          | 3    		    |
| 3          | 1         	    |


4. How many of each type of pizza was delivered?

```sql
SELECT
	P.pizza_name,
	COUNT(C.pizza_id) num_delivered_pizza
FROM pizza_names_cleaned P
JOIN customer_orders_cleaned C
	ON P.pizza_id = C.pizza_id
JOIN runner_orders_cleaned R
	ON C.order_id = R.order_id
	AND R.cancellation LIKE 'Not Canceled'
GROUP BY 1;
```

| pizza_name  | num_delivered_pizza |
| ----------  | ------------------- |
| Meatlovers  | 9        	    |
| Vegetarian  | 3    		    |


5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
SELECT
	C.customer_id,
	P.pizza_name,
	COUNT(C.pizza_id) num_ordered_pizza
FROM customer_orders_cleaned C
JOIN pizza_names_cleaned P
	ON C.pizza_id = P.pizza_id
GROUP BY 1, 2
ORDER BY 1;
```

| customer_id | pizza_name | num_ordered_pizza |
| ----------- | ---------- | ----------------- |
| 101         | Meatlovers | 2                 |
| 101         | Vegetarian | 1                 |
| 102         | Meatlovers | 2                 |
| 102         | Vegetarian | 1                 |
| 103         | Meatlovers | 3                 |
| 103         | Vegetarian | 1                 |
| 104         | Meatlovers | 3                 |
| 105         | Vegetarian | 1                 |


6. What was the maximum number of pizzas delivered in a single order?

```sql
SELECT
	C.order_id,
	COUNT(C.order_id) num_pizza
FROM customer_orders_cleaned C
JOIN runner_orders_cleaned R
	ON C.order_id = R.order_id
	AND R.cancellation LIKE 'Not Canceled'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
```

| order_id  | num_pizza |
| --------- | --------- |
| 4         | 3        	|


7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```sql
SELECT
	C.customer_id,
	SUM(CASE
		WHEN C.row_id IN (SELECT row_id
	       			  FROM extras_cleaned)
		OR C.row_id IN (SELECT row_id
	     			FROM exclusions_cleaned)
		THEN 1
		ELSE 0
	    END) num_changed_pizza,

	SUM(CASE
		WHEN C.row_id NOT IN (SELECT row_id
	       			      FROM extras_cleaned)
		AND C.row_id NOT IN (SELECT row_id
	     			     FROM exclusions_cleaned)
		THEN 1
		ELSE 0
	    END) num_unchanged_pizza
FROM customer_orders_cleaned C
JOIN runner_orders_cleaned R
	ON C.order_id = R.order_id
	AND R.cancellation LIKE 'Not Canceled'
GROUP BY 1;
```

| customer_id | num_changed_pizza | num_unchanged_pizza |
| ----------- | ----------------- | ------------------- |
| 101         | 0                 | 2                   |
| 102         | 0                 | 3                   |
| 103         | 3                 | 0                   |
| 104         | 2                 | 1                   |
| 105         | 1                 | 0                   |


8. How many pizzas were delivered that had both exclusions and extras?

```sql
SELECT
	SUM(CASE
		WHEN C.row_id IN (SELECT row_id
				  FROM extras_cleaned)
		AND C.row_id IN (SELECT row_id
				 FROM exclusions_cleaned)
		THEN 1
		ELSE 0
	    END) num_full_changed_pizza
FROM customer_orders_cleaned C
JOIN runner_orders_cleaned R
	ON C.order_id = R.order_id
	AND R.cancellation LIKE 'Not Canceled';
```

| num_full_changed_pizza  |
| ----------------------- |
| 1                       |


9. What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT
	DATE_TRUNC('HOUR', order_time) hour_of_day,
	COUNT(pizza_id) num_ordered_pizza
FROM customer_orders_cleaned
GROUP BY 1
ORDER BY 1;
```

| hour_of_day              | num_ordered_pizza |
| ------------------------ | ----------------- |
| 2020-01-01T18:00:00.000Z | 1                 |
| 2020-01-01T19:00:00.000Z | 1                 |
| 2020-01-02T23:00:00.000Z | 2                 |
| 2020-01-04T13:00:00.000Z | 3                 |
| 2020-01-08T21:00:00.000Z | 3                 |
| 2020-01-09T23:00:00.000Z | 1                 |
| 2020-01-10T11:00:00.000Z | 1                 |
| 2020-01-11T18:00:00.000Z | 2                 |


10. What was the volume of orders for each day of the week?

```sql
SELECT
	('{Sun,Mon,Tue,Wed,Thu,Fri,Sat}'::text[])[EXTRACT(dow FROM order_time) + 1] day_of_week,
	COUNT(order_id) num_orders
FROM customer_orders_cleaned
GROUP BY 1;
```

| day_of_week              | num_orders        |
| ------------------------ | ----------------- |
| Wed 			   | 5                 |
| Fri 			   | 1                 |
| Thu 			   | 3                 |
| Sat 			   | 5                 |

---

#### b. Runner and Customer Experience:

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```sql
SELECT
	(registration_date - DATE_TRUNC('year', registration_date)::DATE) / 7 + 1 registration_week,
	COUNT(runner_id) num_runners
FROM runners_cleaned
GROUP BY 1
ORDER BY 1;
```

| registration_week        | num_runners       |
| ------------------------ | ----------------- |
| 1 			   | 2                 |
| 2 			   | 1                 |
| 3 			   | 1                 |


2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

```sql
SELECT
	runner_id,
	AVG(sub_minute) avg_time_minutes
FROM
	(SELECT DISTINCT
		R.runner_id,
		R.order_id,
		((DATE_PART('HOUR', R.pickup_time - C.order_time) * 60 ) + 
		(DATE_PART('MINUTE', R.pickup_time - C.order_time)) + 
		(DATE_PART('SECOND', R.pickup_time - C.order_time) / 60 ) ) sub_minute
	 FROM customer_orders_cleaned C
	 JOIN runner_orders_cleaned R
		ON C.order_id = R.order_id) sub_1
GROUP BY 1
ORDER BY 1;
```

| runner_id | avg_time_minutes    |
| --------- | ------------------- |
| 1 	    | 14.329166666666666  |
| 2 	    | 20.01111111111111   |
| 3 	    | 10.466666666666667  |


3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

```sql
WITH num_pizzas_in_order AS
	(SELECT
		C.order_id,
		COUNT(C.pizza_id) num_pizzas
	FROM customer_orders_cleaned C
	GROUP BY 1
	ORDER BY 1) ,
	
order_preparing_time AS
	(SELECT DISTINCT
		C.order_id,
		((DATE_PART('HOUR', R.pickup_time - C.order_time) * 60 ) + 
		(DATE_PART('MINUTE', R.pickup_time - C.order_time)) + 
		(DATE_PART('SECOND', R.pickup_time - C.order_time) / 60 ) ) sub_minute
	 FROM customer_orders_cleaned C
	 JOIN runner_orders_cleaned R
		ON C.order_id = R.order_id
	 ORDER BY 1)

SELECT 
	CTE1.order_id,
	CTE1.num_pizzas,
	CTE2.sub_minute
FROM num_pizzas_in_order CTE1
JOIN order_preparing_time CTE2
	ON CTE1.order_id = CTE2.order_id
ORDER BY 2;
```

| order_id | num_pizzas | sub_minute         |
| -------- | ---------- | ------------------ |
| 1        | 1          | 10.533333333333333 |
| 2        | 1          | 10.033333333333333 |
| 7        | 1          | 10.266666666666667 |
| 8        | 1          | 20.483333333333334 |
| 9        | 1          |                    |
| 5        | 1          | 10.466666666666667 |
| 6        | 1          |                    |
| 3        | 2          | 21.233333333333334 |
| 10       | 2          | 15.516666666666667 |
| 4        | 3          | 29.283333333333335 |

**Solution:** In order to discover the relationships more clearly, we need more records (larger database).
However, according to the current records, yes there is a relationship between the number of pizzas and how long the order takes to prepare in some cases like order_id 3, 4 and 10, the more pizzas in an order, the longer it will take to prepare the order, which makes sense. But in some orders like order_id 8, the order took long time (almost 20 minutes) although the number of pizzas is only one in the order. So as we said we need more data to determine the relatioship clearly.
			


4. What was the average distance travelled for each customer?

```sql
SELECT
	customer_id,
	AVG(distance_km) avg_distance_minutes
FROM
	(SELECT DISTINCT
		C.customer_id,
		C.order_id,
		R.distance_km
	 FROM customer_orders_cleaned C
	 JOIN runner_orders_cleaned R
		ON C.order_id = R.order_id) sub_1
GROUP BY 1
ORDER BY 1;
```

| customer_id | avg_distance_minutes |
| ----------- | -------------------- |
| 101         | 20                   |
| 102         | 18.4                 |
| 103         | 23.4                 |
| 104         | 10                   |
| 105         | 25                   |


5. What was the difference between the longest and shortest delivery times for all orders?

```sql
SELECT 
	MAX(duration_minutes) long_time,
	MIN(duration_minutes) short_time,
	MAX(duration_minutes) - MIN(duration_minutes) diff_long_short
FROM runner_orders_cleaned;
```
| long_time  | short_time | diff_long_short |
| ---------- | ---------- | --------------- |
| 40         | 10         | 30              |


6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

```sql
SELECT
	runner_id,
	AVG(distance_km) avg_distance,
	AVG(duration_minutes) avg_duration,
	AVG(distance_km / duration_minutes) avg_speed
FROM runner_orders_cleaned
GROUP BY 1
ORDER BY 1;
```

| runner_id | avg_distance       | avg_duration       | avg_speed          |
| --------- | ------------------ | ------------------ | ------------------ |
| 1         | 15.85              | 22.25              | 0.7589351851851851 |
| 2         | 23.933333333333334 | 26.666666666666668 | 1.0483333333333331 |
| 3         | 10                 | 15                 | 0.6666666666666666 |

**Soultion:** Yes, the trend makes sense, the greater the distance required to deliver the order, the longer the time to deliver the order.


7. What is the successful delivery percentage for each runner?

```sql
WITH all_orders_of_runners AS
	(SELECT 
		runner_id,
		COUNT(order_id) :: DOUBLE PRECISION  num_orders
	 FROM runner_orders_cleaned
	 GROUP BY 1),

successful_orders_of_runners AS
	(SELECT 
		runner_id,
		COUNT(cancellation) :: DOUBLE PRECISION  num_delivered_orders
	 FROM runner_orders_cleaned
	 WHERE cancellation LIKE 'Not Canceled'
	 GROUP BY 1)

SELECT 
	C1.runner_id,
	C1.num_orders,
	C2.num_delivered_orders,
	(C2.num_delivered_orders / C1.num_orders) * 100 succ_percentage
FROM all_orders_of_runners C1
JOIN successful_orders_of_runners C2
	ON C1.runner_id = C2.runner_id;
```

| runner_id | num_orders | num_delivered_orders | succ_percentage |
| --------- | ---------- | -------------------- | --------------- |
| 3         | 2          | 1                    | 50              |
| 2         | 4          | 3                    | 75              |
| 1         | 4          | 4                    | 100             |

---

#### c. Ingredient Optimisation:

1. What are the standard ingredients for each pizza?

```sql
SELECT
	PN.pizza_name,
	PT.topping_name
FROM pizza_names_cleaned PN
JOIN pizza_recipes_cleaned PR
	ON PN.pizza_id = PR.pizza_id
JOIN pizza_toppings_cleaned PT
	ON PR.topping_id = PT.topping_id
ORDER BY 1;
```

| pizza_name | topping_name |
| ---------- | ------------ |
| Meatlovers | BBQ Sauce    |
| Meatlovers | Pepperoni    |
| Meatlovers | Cheese       |
| Meatlovers | Salami       |
| Meatlovers | Chicken      |
| Meatlovers | Bacon        |
| Meatlovers | Mushrooms    |
| Meatlovers | Beef         |
| Vegetarian | Tomato Sauce |
| Vegetarian | Cheese       |
| Vegetarian | Mushrooms    |
| Vegetarian | Onions       |
| Vegetarian | Peppers      |
| Vegetarian | Tomatoes     |


2. What was the most commonly added extra?

```sql
SELECT
	PT.topping_name,
	COUNT(PE.extras_id) num_times
FROM pizza_toppings_cleaned PT
JOIN extras_cleaned PE
	ON PT.topping_id = PE.extras_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
```

| topping_name  | num_times |
| ------------- | --------- |
| Bacon         | 4         |


3. What was the most common exclusion?

```sql
SELECT
	PT.topping_name,
	COUNT(PE.exclusions_id) num_times
FROM pizza_toppings_cleaned PT
JOIN exclusions_cleaned PE
	ON PT.topping_id = PE.exclusions_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
```

| topping_name  | num_times |
| ------------- | --------- |
| Cheese        | 4         |


4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

**In order to solve this problem we will create a Function called adding_order_description which take one parameter row_id from the table customer_orders_cleaned and return the details of the order like pizza name, exclusions and extras.**

```sql
-- Function start

CREATE OR REPLACE FUNCTION adding_order_description(row_id_par INT)
RETURNS TEXT
LANGUAGE plpgsql
AS
$$
DECLARE
	adding_pizza_name TEXT;
	adding_exclusion_name TEXT;
	adding_extra_name TEXT;
	final_description TEXT;

BEGIN

	SELECT pizza_name
	INTO adding_pizza_name
	FROM pizza_names_cleaned PN
	JOIN customer_orders_cleaned CO
		ON PN.pizza_id = CO.pizza_id
	WHERE CO.row_id = row_id_par;

	SELECT 
		CASE WHEN array_length(topp_names, 1) IS NULL THEN ''
		ELSE CONCAT(' - Exclude ', ARRAY_TO_STRING(topp_names, ', '))
		END
	INTO adding_exclusion_name
	FROM
		(SELECT ARRAY
			(SELECT PT.topping_name
			FROM pizza_toppings_cleaned PT
			JOIN exclusions_cleaned PE
				ON PT.topping_id = PE.exclusions_id
			WHERE PE.row_id = row_id_par) topp_names) sub_1;

	SELECT 
		CASE WHEN array_length(topp_names, 1) IS NULL THEN ''
		ELSE CONCAT(' - Extra ', ARRAY_TO_STRING(topp_names, ', '))
		END
	INTO adding_extra_name
	FROM
		(SELECT ARRAY
			(SELECT PT.topping_name
			FROM pizza_toppings_cleaned PT
			JOIN extras_cleaned PE
				ON PT.topping_id = PE.extras_id
			WHERE PE.row_id = row_id_par) topp_names) sub_2;

	final_description = adding_pizza_name || adding_exclusion_name || adding_extra_name ;
	RETURN final_description;
END;
$$;
-- Function end

-- Call the function to get the result

SELECT *,
	adding_order_description(row_id)
FROM customer_orders_cleaned;

```

| row_id | order_id | customer_id | pizza_id | order_time               | adding_order_description 					  |
| ------ | -------- | ----------- | -------- | ------------------------ | --------------------------------------------------------------- |
| 1      | 1        | 101         | 1        | 2020-01-01T18:05:02.000Z | Meatlovers							  |
| 2      | 2        | 101         | 1        | 2020-01-01T19:00:52.000Z | Meatlovers							  |
| 3      | 3        | 102         | 1        | 2020-01-02T23:51:23.000Z | Meatlovers							  |
| 4      | 3        | 102         | 2        | 2020-01-02T23:51:23.000Z | Vegetarian							  |
| 5      | 4        | 103         | 1        | 2020-01-04T13:23:46.000Z | Meatlovers - Exclude Cheese					  |
| 6      | 4        | 103         | 1        | 2020-01-04T13:23:46.000Z | Meatlovers - Exclude Cheese					  |
| 7      | 4        | 103         | 2        | 2020-01-04T13:23:46.000Z | Vegetarian - Exclude Cheese					  |
| 8      | 5        | 104         | 1        | 2020-01-08T21:00:29.000Z | Meatlovers - Extra Bacon					  |
| 9      | 6        | 101         | 2        | 2020-01-08T21:03:13.000Z | Vegetarian							  |
| 10     | 7        | 105         | 2        | 2020-01-08T21:20:29.000Z | Vegetarian - Extra Bacon					  |
| 11     | 8        | 102         | 1        | 2020-01-09T23:54:33.000Z | Meatlovers							  |
| 12     | 9        | 103         | 1        | 2020-01-10T11:22:59.000Z | Meatlovers - Exclude Cheese - Extra Bacon, Chicken		  |
| 13     | 10       | 104         | 1        | 2020-01-11T18:34:49.000Z | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |
| 14     | 10       | 104         | 1        | 2020-01-11T18:34:49.000Z | Meatlovers							  |



5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

**In order to solve this problem we will create a Function called adding_pizza_and_toppings which take one parameter row_id from the table customer_orders_cleaned and return the details of the order like pizza name with its toppings without exclusions and adding 2x to extra ones according to the customer order.**

```sql
-- Function start
CREATE OR REPLACE FUNCTION adding_pizza_and_toppings(row_id_par INT)
RETURNS TEXT
LANGUAGE plpgsql
AS
$$
DECLARE
	pizza_order_name TEXT;
	pizza_toppings_names TEXT;
	final_description TEXT;
BEGIN

	SELECT PN.pizza_name
	INTO pizza_order_name
	FROM pizza_names_cleaned PN
	JOIN customer_orders_cleaned CO
		ON PN.pizza_id = CO.pizza_id
		AND CO.row_id = row_id_par;

	WITH order_pizza_toppings AS
			(SELECT
				PT.topping_name
			FROM pizza_recipes_cleaned PR
			JOIN pizza_toppings_cleaned PT
				ON PR.topping_id = PT.topping_id
			JOIN customer_orders_cleaned CO
				ON CO.pizza_id = PR.pizza_id
			WHERE CO.row_id = row_id_par
			ORDER BY 1),

	order_pizza_exclusions AS
			(SELECT topping_name
			FROM order_pizza_toppings
			WHERE topping_name NOT IN (
					SELECT topping_name
					FROM pizza_toppings_cleaned PT
					JOIN exclusions_cleaned PE 
						ON PT.topping_id = PE.exclusions_id
						AND PE.row_id = row_id_par)),

	order_pizza_extras AS
		(SELECT 
			topping_name
		FROM pizza_toppings_cleaned PT
		JOIN extras_cleaned PE
			ON PT.topping_id = PE.extras_id
			AND PE.row_id = row_id_par)

	SELECT ARRAY_TO_STRING(all_toppings, ', ')
	INTO pizza_toppings_names
	FROM
		(SELECT ARRAY
			(SELECT 
				CASE 
					WHEN topping_name IN 
							(SELECT *
							FROM order_pizza_extras)
						THEN CONCAT('2x', topping_name)
					ELSE topping_name
				END
			FROM order_pizza_exclusions) all_toppings) sub_1;

	final_description = pizza_order_name || ': ' || pizza_toppings_names;

	RETURN final_description;
END;
$$;

-- Function end

-- Call the function to get the result

SELECT *,
	adding_pizza_and_toppings(row_id)
FROM customer_orders_cleaned;

```

| row_id | order_id | customer_id | pizza_id | order_time               | adding_pizza_and_toppings 					  			|
| ------ | -------- | ----------- | -------- | ------------------------ | ------------------------------------------------------------------------------------- |
| 1      | 1        | 101         | 1        | 2020-01-01T18:05:02.000Z | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	|
| 2      | 2        | 101         | 1        | 2020-01-01T19:00:52.000Z | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	|
| 3      | 3        | 102         | 1        | 2020-01-02T23:51:23.000Z | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	|
| 4      | 3        | 102         | 2        | 2020-01-02T23:51:23.000Z | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes		|
| 5      | 4        | 103         | 1        | 2020-01-04T13:23:46.000Z | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami		|
| 6      | 4        | 103         | 1        | 2020-01-04T13:23:46.000Z | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami		|
| 7      | 4        | 103         | 2        | 2020-01-04T13:23:46.000Z | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes			|
| 8      | 5        | 104         | 1        | 2020-01-08T21:00:29.000Z | Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 9      | 6        | 101         | 2        | 2020-01-08T21:03:13.000Z | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes 		|
| 10     | 7        | 105         | 2        | 2020-01-08T21:20:29.000Z | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes		|
| 11     | 8        | 102         | 1        | 2020-01-09T23:54:33.000Z | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	|
| 12     | 9        | 103         | 1        | 2020-01-10T11:22:59.000Z | Meatlovers: 2xBacon, BBQ Sauce, Beef, 2xChicken, Mushrooms, Pepperoni, Salami		|
| 13     | 10       | 104         | 1        | 2020-01-11T18:34:49.000Z | Meatlovers: 2xBacon, Beef, 2xCheese, Chicken, Pepperoni, Salami			|
| 14     | 10       | 104         | 1        | 2020-01-11T18:34:49.000Z | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami	|


6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql
WITH original_toppings AS
		(SELECT
			PT.topping_name,
			COUNT(PR.topping_id) ingredient_quantity
		FROM pizza_toppings_cleaned PT
		JOIN pizza_recipes_cleaned PR
			ON PT.topping_id = PR.topping_id
		JOIN customer_orders_cleaned CO
			ON PR.pizza_id = CO.pizza_id
		JOIN runner_orders_cleaned RO
			ON CO.order_id = RO.order_id
			AND RO.cancellation LIKE 'Not Canceled'
		GROUP BY 1
		ORDER BY 2 DESC ),

execluded_toppings AS
		(SELECT 
			PT.topping_name,
			COUNT(PE.exclusions_id) execlusions_quantity
		FROM pizza_toppings_cleaned PT
		JOIN exclusions_cleaned PE
			ON PT.topping_id = PE.exclusions_id
		JOIN customer_orders_cleaned CO
			ON PE.row_id = CO.row_id
		JOIN runner_orders_cleaned RO
			ON CO.order_id = RO.order_id
			AND RO.cancellation LIKE 'Not Canceled'
		GROUP BY 1
		ORDER BY 2 DESC),

extra_toppings AS
		(SELECT 
			PT.topping_name,
			COUNT(PE.extras_id) extras_quantity
		FROM pizza_toppings_cleaned PT
		JOIN extras_cleaned PE
			ON PT.topping_id = PE.extras_id
		JOIN customer_orders_cleaned CO
			ON PE.row_id = CO.row_id
		JOIN runner_orders_cleaned RO
			ON CO.order_id = RO.order_id
			AND RO.cancellation LIKE 'Not Canceled'
		GROUP BY 1
		ORDER BY 2 DESC)

SELECT 
	OT.topping_name,
	CASE 
		WHEN EXE.execlusions_quantity IS NOT NULL
			AND EXT.extras_quantity IS NOT NULL
			THEN OT.ingredient_quantity - EXE.execlusions_quantity + EXT.extras_quantity
		WHEN EXE.execlusions_quantity IS NOT NULL
			THEN OT.ingredient_quantity - EXE.execlusions_quantity
		WHEN EXT.extras_quantity IS NOT NULL
			THEN OT.ingredient_quantity + EXT.extras_quantity
		ELSE OT.ingredient_quantity
	END AS ingredient_quantity
FROM original_toppings OT
LEFT JOIN execluded_toppings EXE
	ON OT.topping_name = EXE.topping_name
LEFT JOIN extra_toppings EXT
	ON OT.topping_name = EXT.topping_name
ORDER BY 2 DESC;
```

| topping_name | ingredient_quantity |
| ------------ | ------------------- |
| Bacon        | 12                  |
| Mushrooms    | 11                  |
| Cheese       | 10                  |
| Pepperoni    | 9                   |
| Salami       | 9                   |
| Beef         | 9                   |
| Chicken      | 9                   |
| BBQ Sauce    | 8                   |
| Peppers      | 3                   |
| Tomato Sauce | 3                   |
| Onions       | 3                   |
| Tomatoes     | 3                   |

---


#### D. Pricing and Ratings:

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?


```sql
SELECT 
	SUM(
		CASE
			WHEN CO.pizza_id = 1 THEN 12
			ELSE 10
		END) total_revenue
FROM customer_orders_cleaned CO
JOIN runner_orders_cleaned RO
	ON CO.order_id = RO.order_id
	AND RO.cancellation LIKE 'Not Canceled';
```
| total_revenue  |
| -------------- |
| 138            |


2. What if there was an additional $1 charge for any pizza extras?
- Add cheese is $1 extra.

```sql

WITH total_revenue AS(
	SELECT 
		SUM(
			CASE
				WHEN CO.pizza_id = 1 THEN 12
				ELSE 10
			END) total_revenue
	FROM customer_orders_cleaned CO
	JOIN runner_orders_cleaned RO
		ON CO.order_id = RO.order_id
		AND RO.cancellation LIKE 'Not Canceled')

SELECT 
	((SUM(
		CASE
			WHEN PE.row_id IS NOT NULL THEN 1
			ELSE 0
		END))) + (SELECT total_revenue
			  FROM total_revenue) total_revenue_with_extra_charge
FROM customer_orders_cleaned CO
JOIN runner_orders_cleaned RO
	ON CO.order_id = RO.order_id
	AND RO.cancellation LIKE 'Not Canceled'
LEFT JOIN extras_cleaned PE
	ON CO.row_id = PE.row_id;
 ```

| total_revenue_with_extra_charge  |
| -------------------------------- |
| 142                              |

