# Weather Observation Station 20

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Window Functions, Ranking, Statistical Analysis, CTEs, Aggregation

---

## Problem

Given the `STATION` table, find the **median value of `LAT_N`**.

The answer should be rounded to **4 decimal places**.

The median is the middle value after arranging all values in ascending order.

For an odd number of values:

```text
10   20   30   40   50
          ↑
        Median
```

For an even number of values:

```text
10   20   30   40   50   60
          ↑    ↑
       Middle values
```

For an even number of values, the median is the average of the two middle values.

---

# Given Table

Consider this simplified version of `STATION`:

| LAT_N |
|------:|
| 30 |
| 10 |
| 50 |
| 20 |
| 40 |

The values are not sorted.

We need to determine the median after sorting them.

---

# Step 1 — Create the `ranked` CTE

The query begins with:

```sql
WITH ranked AS (
    SELECT
        LAT_N,
        ROW_NUMBER() OVER (ORDER BY LAT_N) AS rn,
        COUNT(*) OVER () AS total
    FROM STATION
)
```

The CTE creates two additional columns:

- `rn` → position of each latitude after sorting
- `total` → total number of rows in the table

---

# Step 2 — Sort `LAT_N` and Assign Positions

This part:

```sql
ROW_NUMBER() OVER (ORDER BY LAT_N)
```

sorts the latitude values in ascending order and gives each row a position.

Before sorting:

| LAT_N |
|------:|
| 30 |
| 10 |
| 50 |
| 20 |
| 40 |

After:

| LAT_N | rn |
|------:|---:|
| 10 | 1 |
| 20 | 2 |
| 30 | 3 |
| 40 | 4 |
| 50 | 5 |

Now `rn` tells us exactly where each value sits in the sorted list.

---

# Step 3 — Calculate the Total Number of Rows

The query also uses:

```sql
COUNT(*) OVER ()
```

This counts all rows in the table.

Unlike a normal aggregation, the window operation **does not collapse the rows**.

Instead, the total is attached to every row.

So the CTE becomes:

| LAT_N | rn | total |
|------:|---:|------:|
| 10 | 1 | 5 |
| 20 | 2 | 5 |
| 30 | 3 | 5 |
| 40 | 4 | 5 |
| 50 | 5 | 5 |

We now know:

```text
total = 5
```

and:

```text
rn = position of each value
```

---

# Step 4 — Find the Middle Position

The outer query uses:

```sql
WHERE rn IN (
    FLOOR((total + 1) / 2),
    FLOOR((total + 2) / 2)
)
```

The purpose is to identify the middle position or positions.

For our example:

```text
total = 5
```

### First position

```text
FLOOR((5 + 1) / 2)
= FLOOR(6 / 2)
= 3
```

### Second position

```text
FLOOR((5 + 2) / 2)
= FLOOR(7 / 2)
= FLOOR(3.5)
= 3
```

Therefore:

```text
rn IN (3, 3)
```

Effectively, we only need:

```text
rn = 3
```

---

# Step 5 — Filter the CTE

The CTE currently contains:

| LAT_N | rn | total |
|------:|---:|------:|
| 10 | 1 | 5 |
| 20 | 2 | 5 |
| 30 | 3 | 5 |
| 40 | 4 | 5 |
| 50 | 5 | 5 |

After:

```sql
WHERE rn IN (3, 3)
```

we get:

| LAT_N | rn | total |
|------:|---:|------:|
| 30 | 3 | 5 |

The middle value is therefore:

```text
30
```

---

# Step 6 — Calculate the Median

The outer query uses:

```sql
AVG(LAT_N)
```

Since only the middle value remains:

```text
AVG(30)
= 30
```

The query then rounds it:

```sql
ROUND(AVG(LAT_N), 4)
```

Result:

```text
30.0000
```

---

# Why Does This Also Work for an Even Number of Rows?

This is the clever part of the query.

Suppose we have **6 rows**:

| LAT_N | rn |
|------:|---:|
| 10 | 1 |
| 20 | 2 |
| 30 | 3 |
| 40 | 4 |
| 50 | 5 |
| 60 | 6 |

Here:

```text
total = 6
```

The query calculates:

### First position

```text
FLOOR((6 + 1) / 2)
= FLOOR(7 / 2)
= 3
```

### Second position

```text
FLOOR((6 + 2) / 2)
= FLOOR(8 / 2)
= 4
```

Therefore:

```text
rn IN (3, 4)
```

The filtered table becomes:

| LAT_N | rn |
|------:|---:|
| 30 | 3 |
| 40 | 4 |

Then:

```sql
AVG(LAT_N)
```

calculates:

```text
(30 + 40) / 2
= 35
```

So the median is:

```text
35
```

This means the same query handles **both odd and even numbers of rows**.

---

# Complete Transformation Flow

```text
                 STATION
                    │
                    ▼
          Select LAT_N values
                    │
                    ▼
       ROW_NUMBER() OVER (ORDER BY LAT_N)
                    │
                    ▼
        Sort + assign positions
                    │
                    ▼
        COUNT(*) OVER () → total
                    │
                    ▼
              ranked CTE
                    │
                    ▼
       ┌────────────────────────┐
       │ LAT_N │ rn │ total     │
       ├───────┼────┼───────────┤
       │  10   │ 1  │ 5         │
       │  20   │ 2  │ 5         │
       │  30   │ 3  │ 5         │
       │  40   │ 4  │ 5         │
       │  50   │ 5  │ 5         │
       └────────────────────────┘
                    │
                    ▼
         Calculate middle position(s)
                    │
                    ▼
              rn IN (3, 3)
                    │
                    ▼
          Keep the middle row(s)
                    │
                    ▼
                LAT_N = 30
                    │
                    ▼
               AVG(LAT_N)
                    │
                    ▼
             ROUND(..., 4)
                    │
                    ▼
                30.0000
```

---

# Query Breakdown

### 1. CTE

```sql
WITH ranked AS (...)
```

Creates an intermediate result containing the latitude, its sorted position, and the total number of rows.

### 2. Ranking

```sql
ROW_NUMBER() OVER (ORDER BY LAT_N)
```

Sorts the values and assigns positions starting from 1.

### 3. Total Count

```sql
COUNT(*) OVER ()
```

Gets the total number of rows while keeping every row.

### 4. Find Middle Position(s)

```sql
FLOOR((total + 1) / 2)
FLOOR((total + 2) / 2)
```

Determines which row positions represent the median.

### 5. Filter

```sql
WHERE rn IN (...)
```

Keeps only the middle value for odd-sized datasets or the two middle values for even-sized datasets.

### 6. Average

```sql
AVG(LAT_N)
```

- One value → returns that value.
- Two values → returns their average.

This makes `AVG()` work for both odd and even datasets.

### 7. Round

```sql
ROUND(..., 4)
```

Rounds the final median to four decimal places.

---

# Why `AVG()` Is Used

Using `AVG()` instead of selecting a single middle value is what allows the query to handle both cases.

### Odd number of rows

```text
10  20  30  40  50
        ↑
       30
```

```text
AVG(30) = 30
```

### Even number of rows

```text
10  20  30  40  50  60
        ↑   ↑
       30  40
```

```text
AVG(30, 40) = 35
```

So the same final operation works in both situations.

---

# Key SQL Concepts

- Common Table Expressions
- Window Functions
- Ordered Row Ranking
- Windowed Aggregation
- Conditional Row Filtering
- Median Calculation
- Numerical Rounding

---

# Final Transformation

```text
STATION
   ↓
Sort LAT_N
   ↓
Assign row positions
   ↓
Calculate total row count
   ↓
Identify middle position(s)
   ↓
Filter to middle value(s)
   ↓
Average them
   ↓
Round to 4 decimal places
   ↓
Median LAT_N
```

**Corresponding SQL:** `03_Weather_Observation_Station_20.sql`