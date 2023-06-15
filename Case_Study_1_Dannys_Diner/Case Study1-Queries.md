# 8 Week SQL Challenge by Danny Ma

## Case Study 1 - Danny's Diner

<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png"  width="600" height="550">



### Casestudy Information:

    #### Entity Relationship Diagram:
    
    <div class="diagram-container flex-1"><div class="diagram" style="background-color: rgb(251, 251, 251); cursor: default;"><div class="konvajs-content" role="presentation" style="position: relative; user-select: none; width: 552px; height: 670px;"><canvas width="690" height="837" style="padding: 0px; margin: 0px; border: 0px; background: transparent; position: absolute; top: 0px; left: 0px; width: 552px; height: 670px; display: block;"></canvas><canvas width="690" height="837" style="padding: 0px; margin: 0px; border: 0px; background: transparent; position: absolute; top: 0px; left: 0px; width: 552px; height: 670px; display: block;"></canvas><canvas width="690" height="837" style="padding: 0px; margin: 0px; border: 0px; background: transparent; position: absolute; top: 0px; left: 0px; width: 552px; height: 670px; display: block;"></canvas><canvas width="690" height="837" style="padding: 0px; margin: 0px; border: 0px; background: transparent; position: absolute; top: 0px; left: 0px; width: 552px; height: 670px; display: block;"></canvas><canvas width="690" height="837" style="padding: 0px; margin: 0px; border: 0px; background: transparent; position: absolute; top: 0px; left: 0px; width: 552px; height: 670px; display: block;"></canvas></div></div> <div data-v-a07b6804="" class="controller-container" style="--display-controller: flex;"><div data-v-a07b6804="" class="controller light"><label data-v-a07b6804="" class="scale-value">100%</label> <div data-v-a07b6804="" class="vue-slider vue-slider-ltr" default="default" style="padding: 7px 0px; width: 50px; height: 8px;"><div class="vue-slider-rail"><div class="vue-slider-process" style="height: 100%; top: 0px; left: 0%; width: 62.963%; transition-property: width, left; transition-duration: 0.5s;"></div><div aria-valuetext="1" class="vue-slider-dot" role="slider" aria-valuenow="1" aria-valuemin="0.15" aria-valuemax="1.5" aria-orientation="horizontal" tabindex="0" style="width: 14px; height: 14px; transform: translate(-50%, -50%); top: 50%; left: 62.963%; transition: left 0.5s ease 0s;"><div class="vue-slider-dot-handle" style="background: rgb(52, 152, 219); box-shadow: none; border: 1px solid white;"></div></div></div></div> <button data-v-a07b6804="">
      Focus
    </button> <button data-v-a07b6804="">
      Auto-arrange
    </button> <button data-v-a07b6804="">Highlight</button> <label data-v-25adc6c0="" data-v-a07b6804="" class="vue-js-switch"><input data-v-25adc6c0="" type="checkbox" class="v-switch-input"> <div data-v-25adc6c0="" class="v-switch-core" style="width: 28px; height: 16px; background-color: rgb(204, 204, 204); border-radius: 8px;"><div data-v-25adc6c0="" class="v-switch-button" style="width: 10px; height: 10px; transition: transform 300ms ease 0s; transform: translate3d(3px, 3px, 0px);"></div></div> <!----></label> <!----></div></div> <!----> <!----></div>
    
    
### Challenge Questions and Solutions:

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

2- How many days has each customer visited the restaurant?

```sql
    SELECT
        customer_id,
        COUNT(DISTINCT order_date) num_days
    FROM dannys_diner.sales
    GROUP BY 1
    ORDER BY 2 DESC;
```

| customer_id | num_days |
| ----------- | -------- |
| B           | 6        |
| A           | 4        |
| C           | 2        |

---

3- What was the first item from the menu purchased by each customer?

```sql
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
```
| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |
| C           | ramen        |

---

4- What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
    SELECT
        M.product_name,
        COUNT(S.product_id) num_times
    FROM dannys_diner.menu M
    JOIN dannys_diner.sales S
        ON M.product_id = S.product_id
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1;
```
| product_name | num_times |
| ------------ | --------- |
| ramen        | 8         |

---

5- Which item was the most popular for each customer?

```sql
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
```

| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | sushi        |
| B           | curry        |
| B           | ramen        |
| C           | ramen        |

---

6- Which item was purchased first by the customer after they became a member?

```sql
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

```

| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | sushi        |

---

7- Which item was purchased just before the customer became a member?

```sql
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

```
| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | sushi        |

---

8- What is the total items and amount spent for each member before they became a member?

```sql
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
```

| customer_id | num_items | total_amount |
| ----------- | --------- | ------------ |
| B           | 3         | 40           |
| A           | 2         | 25           |

---

9- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql
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
```

| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |

---

10- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

```sql
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
```

| customer_id | total_points |
| ----------- | ------------ |
| A           | 1370         |
| B           | 940          |

---

### Bonus Questions:

#### 1- Join All The Things:
- The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

```sql
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
```

| customer_id | order_date               | product_name | price | member |
| ----------- | ------------------------ | ------------ | ----- | ------ |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |

---

#### 2- Rank All The Things
- Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

```sql
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
            WHEN S.order_date >= MM.join_date THEN DENSE_RANK() OVER 
            (PARTITION BY S.customer_id ORDER BY CASE WHEN S.order_date >= MM.join_date THEN S.order_date END) 
        END AS ranking
    FROM dannys_diner.sales S
    JOIN dannys_diner.menu M
        ON S.product_id = M.product_id
    LEFT JOIN dannys_diner.members MM
        ON S.customer_id = MM.customer_id
    ORDER BY 1, 2;
```

| customer_id | order_date               | product_name | price | member | ranking |
| ----------- | ------------------------ | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |         |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      | 1       |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |         |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |         |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |         |

---
