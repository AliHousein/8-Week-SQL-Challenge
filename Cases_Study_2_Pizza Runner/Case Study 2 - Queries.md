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
