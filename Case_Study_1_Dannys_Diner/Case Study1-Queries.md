# 8 Week SQL Challenge by Danny Ma

## Case Study 1 - Danny's Diner

**Query #1**
```
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
**Query #2**
```
    SELECT
      	product_id,
        product_name,
        price
    FROM dannys_diner.menu
    ORDER BY price DESC
    LIMIT 5;
```

| product_id | product_name | price |
| ---------- | ------------ | ----- |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |
| 1          | sushi        | 10    |

---
