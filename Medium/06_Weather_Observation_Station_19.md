# Weather Observation Station 19

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Aggregation, Mathematical Operations, Coordinate Geometry

---

## Problem

Given the `STATION` table, find the **Euclidean distance** between the following two points:

- Point A:
  - Minimum `LAT_N`
  - Minimum `LONG_W`
- Point B:
  - Maximum `LAT_N`
  - Maximum `LONG_W`

Round the final answer to **4 decimal places**.

The Euclidean distance formula is:

\[
Distance = \sqrt{(x_2-x_1)^2 + (y_2-y_1)^2}
\]

For this problem:

\[
Distance =
\sqrt{
(MAX(LONG\_W)-MIN(LONG\_W))^2
+
(MAX(LAT\_N)-MIN(LAT\_N))^2
}
\]

---

## Given Table

Consider a simplified `STATION` table:

| LAT_N | LONG_W |
|------:|-------:|
| 10 | 20 |
| 15 | 25 |
| 12 | 22 |
| 18 | 30 |
| 14 | 27 |

We need to find:

- Minimum latitude
- Maximum latitude
- Minimum longitude
- Maximum longitude

---

# Step 1 — Find the Minimum and Maximum Values

We use aggregation to find the four boundary values.

```sql
MAX(LONG_W)
MIN(LONG_W)
MAX(LAT_N)
MIN(LAT_N)
```

From our example:

| Calculation | Value |
|---|---:|
| `MIN(LONG_W)` | 20 |
| `MAX(LONG_W)` | 30 |
| `MIN(LAT_N)` | 10 |
| `MAX(LAT_N)` | 18 |

So the two points become:

### Point A

```text
(MIN(LONG_W), MIN(LAT_N))
= (20, 10)
```

### Point B

```text
(MAX(LONG_W), MAX(LAT_N))
= (30, 18)
```

---

# Step 2 — Calculate the Difference in Longitude

Our query contains:

```sql
MAX(LONG_W) - MIN(LONG_W)
```

Substituting the values:

```text
30 - 20 = 10
```

So:

```text
ΔX = 10
```

---

# Step 3 — Calculate the Difference in Latitude

The query also calculates:

```sql
MAX(LAT_N) - MIN(LAT_N)
```

Substituting:

```text
18 - 10 = 8
```

Therefore:

```text
ΔY = 8
```

---

# Step 4 — Square Both Differences

The Euclidean formula requires both differences to be squared.

The query uses:

```sql
POW(MAX(LONG_W) - MIN(LONG_W), 2)
```

which gives:

```text
10² = 100
```

And:

```sql
POW(MAX(LAT_N) - MIN(LAT_N), 2)
```

gives:

```text
8² = 64
```

Intermediate result:

| Component | Value |
|---|---:|
| Longitude difference² | 100 |
| Latitude difference² | 64 |

---

# Step 5 — Add the Squared Values

The query adds them:

```text
100 + 64 = 164
```

So we now have:

```text
(ΔX)² + (ΔY)² = 164
```

---

# Step 6 — Take the Square Root

The query uses:

```sql
SQRT(...)
```

Therefore:

```text
√164 ≈ 12.806248...
```

This is the Euclidean distance before rounding.

---

# Step 7 — Round to 4 Decimal Places

Finally:

```sql
ROUND(..., 4)
```

gives:

```text
12.8062
```

---

# Complete Transformation

```text
                 STATION
                    │
                    ▼
       ┌─────────────────────────┐
       │ Find boundary values    │
       │                         │
       │ MIN(LONG_W) = 20        │
       │ MAX(LONG_W) = 30        │
       │ MIN(LAT_N)  = 10        │
       │ MAX(LAT_N)  = 18        │
       └────────────┬────────────┘
                    │
                    ▼
             Two coordinate points
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
     Point A              Point B
     (20,10)              (30,18)
          │                   │
          └─────────┬─────────┘
                    ▼
          Calculate differences
                    │
                    ▼
        ΔX = 30 - 20 = 10
        ΔY = 18 - 10 = 8
                    │
                    ▼
            Square differences
                    │
                    ▼
              10² + 8²
              = 100 + 64
              = 164
                    │
                    ▼
                SQRT(164)
                    │
                    ▼
              12.806248...
                    │
                    ▼
              ROUND(..., 4)
                    │
                    ▼
                12.8062
```

---

# Query Breakdown

```sql
SELECT
    ROUND(
        SQRT(
            POW(MAX(LONG_W) - MIN(LONG_W), 2)
            + POW(MAX(LAT_N) - MIN(LAT_N), 2)
        ),
        4
    )
FROM STATION;
```

### `MAX()` and `MIN()`

Find the boundaries of the coordinates.

```text
MAX(LONG_W) - MIN(LONG_W)
MAX(LAT_N)  - MIN(LAT_N)
```

### `POW(..., 2)`

Squares each coordinate difference.

```text
ΔX²
ΔY²
```

### `SQRT()`

Applies the square-root portion of the Euclidean distance formula.

```text
√(ΔX² + ΔY²)
```

### `ROUND(..., 4)`

Rounds the final distance to four decimal places.

---

# Why No GROUP BY Is Needed

There is no need for `GROUP BY` because the query calculates aggregate values over the **entire `STATION` table**.

Functions such as:

```sql
MIN()
MAX()
```

produce a single value for the entire table.

Therefore, the query ultimately produces only **one result**.

---

# Final Result

For the illustrative data:

| Euclidean Distance |
|---:|
| 12.8062 |

The actual HackerRank result is calculated using the complete `STATION` dataset.

---

## Key SQL Concepts

- Aggregation over an entire table
- Finding coordinate boundaries
- Mathematical calculations
- Applying the Euclidean distance formula
- Rounding numerical results

---

## Transformation Summary

```text
STATION
   ↓
MIN/MAX latitude & longitude
   ↓
Coordinate differences
   ↓
Square differences
   ↓
Add squared values
   ↓
Square root
   ↓
Round to 4 decimals
   ↓
Final Euclidean distance
```

**Corresponding SQL:** `03_Euclidean_Distance_Between_Two_Points.sql`