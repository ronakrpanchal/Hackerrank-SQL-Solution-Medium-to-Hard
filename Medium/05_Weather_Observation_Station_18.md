# Weather Observation Station 18

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Aggregation, Mathematical Operations, Coordinate Geometry

---

## Problem

You are given a `STATION` table containing the geographical coordinates of various stations.

Each station has:

- `LAT_N` — Northern latitude
- `LONG_W` — Western longitude

The goal is to calculate the **Manhattan Distance** between two points:

```text
(minimum latitude, minimum longitude)
and
(maximum latitude, maximum longitude)
```

The result must be rounded to **4 decimal places**.

---

# Given Table

### `STATION`

A simplified example:

| ID | LAT_N | LONG_W |
|---:|---:|---:|
| 1 | 10.5 | 20.2 |
| 2 | 15.0 | 25.7 |
| 3 | 12.3 | 22.4 |
| 4 | 18.5 | 28.1 |

We need to find the minimum and maximum values of both coordinates.

---

# Step 1 — Find Minimum and Maximum Latitude

The query uses:

```sql
MIN(LAT_N)
```

and:

```sql
MAX(LAT_N)
```

From our example:

| LAT_N |
|---:|
| 10.5 |
| 15.0 |
| 12.3 |
| 18.5 |

Therefore:

```text
MIN(LAT_N) = 10.5
MAX(LAT_N) = 18.5
```

The difference is:

```text
18.5 - 10.5 = 8.0
```

---

# Step 2 — Find Minimum and Maximum Longitude

Similarly:

```sql
MIN(LONG_W)
```

and:

```sql
MAX(LONG_W)
```

From the example:

| LONG_W |
|---:|
| 20.2 |
| 25.7 |
| 22.4 |
| 28.1 |

Therefore:

```text
MIN(LONG_W) = 20.2
MAX(LONG_W) = 28.1
```

The difference is:

```text
28.1 - 20.2 = 7.9
```

---

# Step 3 — Calculate the Absolute Differences

The query uses:

```sql
ABS(MAX(LONG_W) - MIN(LONG_W))
```

For longitude:

```text
ABS(28.1 - 20.2)
= ABS(7.9)
= 7.9
```

For latitude:

```sql
ABS(MAX(LAT_N) - MIN(LAT_N))
```

we get:

```text
ABS(18.5 - 10.5)
= ABS(8.0)
= 8.0
```

The `ABS()` ensures that the distance is always positive.

---

# Step 4 — Calculate Manhattan Distance

Manhattan distance is calculated as:

```text
|x₂ - x₁| + |y₂ - y₁|
```

For our example:

```text
Longitude difference = 7.9
Latitude difference  = 8.0

Manhattan Distance
= 7.9 + 8.0
= 15.9
```

So:

```text
15.9000
```

after rounding to four decimal places.

---

# Step 5 — Round the Result

The query uses:

```sql
ROUND(
    ABS(MAX(LONG_W) - MIN(LONG_W))
    + ABS(MAX(LAT_N) - MIN(LAT_N)),
    4
)
```

The second argument:

```text
4
```

specifies that the result should be rounded to **4 decimal places**.

---

# Complete Transformation

```text
                 STATION
                    │
          ┌─────────┴─────────┐
          ↓                   ↓
       LAT_N                LONG_W
          │                   │
     ┌────┴────┐         ┌────┴────┐
     ↓         ↓         ↓         ↓
    MIN       MAX       MIN       MAX
     │         │         │         │
     └────┬────┘         └────┬────┘
          ↓                   ↓
    Latitude Difference  Longitude Difference
          │                   │
          └─────────┬─────────┘
                    ↓
              ABS differences
                    ↓
                   SUM
                    ↓
                 ROUND(4)
                    ↓
             FINAL DISTANCE
```

---

# Key SQL Concepts

### Aggregation

The coordinate extremes are obtained by calculating the minimum and maximum values from the table.

### Mathematical Operations

The coordinate differences are added together to calculate the Manhattan distance.

### Coordinate Geometry

Manhattan distance measures the total movement along the two coordinate axes rather than using the straight-line distance.

### Rounding

The final result is rounded to four decimal places.

---

## Solution

The complete SQL solution is available in [`05_Manhattan_Distance_Between_Two_Points.sql`](./05_Manhattan_Distance_Between_Two_Points.sql).