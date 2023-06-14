# 8 Week SQL Challenge by Danny Ma

## Case Study 1 - Danny's Diner

### Challeng Questions and Solutions:

1- What is the total amount each customer spent at the restaurant?

```sql
    SELECT
        S.customer_id,
        SUM(ME.price) total_amount
    FROM dannys_diner.sales S
    JOIN dannys_diner.menu ME
        ON S.product_id = ME.product_id
    GROUP BY 1
    ORDER BY 2 DESC;
```

| customer_id | total_amount |
| ----------- | ------------ |
| A           | 76           |
| B           | 74           |
| C           | 36           |

---

