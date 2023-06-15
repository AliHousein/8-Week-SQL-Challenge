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


  - According to the results, it dosen't need any cleaning. But we will create a temporary table from it to keep the origin database.

 ```sql
  DROP TABLE IF EXISTS runners_cleaned;
  CREATE TEMP TABLE runners_cleaned AS
    (SELECT *
     FROM pizza_runner.runners);
```
