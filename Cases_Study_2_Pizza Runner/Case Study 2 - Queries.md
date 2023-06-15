# 8 Week SQL Challenge by Danny Ma

## Case Study 2 - Pizza Runner

<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" width="600" height="550">

**- Access the challenge and full details about it via this link** [Case Study #2 - Pizza Runner](https://8weeksqlchallenge.com/case-study-2/).

---

### A. Cleaning Stage of the Dataset:

  1- Table 1: runners:
  
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

  2- Table 2: customer_orders:
  
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

***3- Table 3: runner_orders:***

