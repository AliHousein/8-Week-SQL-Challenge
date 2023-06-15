# 8 Week SQL Challenge by Danny Ma

## Case Study 2 - Pizza Runner

<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" width="600" height="550">

**- Access the challenge and full details about it via this link** [Case Study #2 - Pizza Runner](https://8weeksqlchallenge.com/case-study-2/).

---

### Cleaning Stage of the Dataset:

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

  1- exclusions column:
    
    ```sql
      	UPDATE customer_orders_cleaned_1
	SET exclusions = NULL
	WHERE exclusions LIKE ' ' OR exclusions LIKE '';

	UPDATE customer_orders_cleaned_1
	SET exclusions = NULL
	WHERE exclusions LIKE 'null';
    ```
  
  2- extras column:
  
  ```sql
	UPDATE customer_orders_cleaned_1
	SET extras = NULL
	WHERE extras LIKE ' ' OR extras LIKE '';

	UPDATE customer_orders_cleaned_1
	SET extras = NULL
	WHERE extras LIKE 'null';
  ```
  
 
