# Ollivander's Inventory

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Joins, Filtering, Window Functions, Partitioning, Ranking, Deduplication

---

## Problem

You are given two tables containing information about wands and their properties.

The goal is to find the **cheapest non-evil wand** for every combination of:

- `AGE`
- `POWER`

The final result should contain:

- `ID`
- `AGE`
- `COINS_NEEDED`
- `POWER`

The result should be ordered by:

1. `POWER` in descending order
2. `AGE` in descending order

---

# Given Tables

## `WANDS`

| ID | CODE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 1 | A | 50 | 10 |
| 2 | A | 40 | 10 |
| 3 | B | 70 | 10 |
| 4 | B | 60 | 10 |
| 5 | C | 80 | 15 |
| 6 | C | 75 | 15 |
| 7 | D | 100 | 20 |

This table contains the actual wand information.

---

## `WANDS_PROPERTY`

| CODE | AGE | IS_EVIL |
|---|---:|---:|
| A | 20 | 0 |
| B | 30 | 0 |
| C | 20 | 0 |
| D | 40 | 1 |

This table tells us:

- The age associated with each wand code
- Whether the wand is evil

Where:

```text
IS_EVIL = 0 → Non-evil
IS_EVIL = 1 → Evil
```

---

# Step 1 — Join the Two Tables

The query starts with:

```sql
JOIN WANDS_PROPERTY WP
    ON W.CODE = WP.CODE
```

The two tables are connected through:

```text
WANDS.CODE = WANDS_PROPERTY.CODE
```

Before the JOIN, `WANDS` does not contain the age or evil-status information.

After the JOIN:

| ID | CODE | COINS_NEEDED | POWER | AGE | IS_EVIL |
|---:|---|---:|---:|---:|---:|
| 1 | A | 50 | 10 | 20 | 0 |
| 2 | A | 40 | 10 | 20 | 0 |
| 3 | B | 70 | 10 | 30 | 0 |
| 4 | B | 60 | 10 | 30 | 0 |
| 5 | C | 80 | 15 | 20 | 0 |
| 6 | C | 75 | 15 | 20 | 0 |
| 7 | D | 100 | 20 | 40 | 1 |

Now every wand has its corresponding age and evil-status information.

---

# Step 2 — Remove Evil Wands

The query contains:

```sql
WHERE WP.IS_EVIL = 0
```

We only want non-evil wands.

So:

```text
IS_EVIL = 0 → Keep
IS_EVIL = 1 → Remove
```

The wand with `ID = 7` is removed.

Before:

| ID | AGE | COINS_NEEDED | POWER | IS_EVIL |
|---:|---:|---:|---:|---:|
| 1 | 20 | 50 | 10 | 0 |
| 2 | 20 | 40 | 10 | 0 |
| 3 | 30 | 70 | 10 | 0 |
| 4 | 30 | 60 | 10 | 0 |
| 5 | 20 | 80 | 15 | 0 |
| 6 | 20 | 75 | 15 | 0 |
| 7 | 40 | 100 | 20 | 1 |

After filtering:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 1 | 20 | 50 | 10 |
| 2 | 20 | 40 | 10 |
| 3 | 30 | 70 | 10 |
| 4 | 30 | 60 | 10 |
| 5 | 20 | 80 | 15 |
| 6 | 20 | 75 | 15 |

---

# Step 3 — Identify the Groups

The important part of the query is:

```sql
PARTITION BY WP.AGE, W.POWER
```

This divides the remaining wands into groups based on:

```text
AGE + POWER
```

Let's identify the groups.

### Group 1

```text
AGE = 20
POWER = 10
```

Rows:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 1 | 20 | 50 | 10 |
| 2 | 20 | 40 | 10 |

---

### Group 2

```text
AGE = 30
POWER = 10
```

Rows:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 3 | 30 | 70 | 10 |
| 4 | 30 | 60 | 10 |

---

### Group 3

```text
AGE = 20
POWER = 15
```

Rows:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 5 | 20 | 80 | 15 |
| 6 | 20 | 75 | 15 |

---

# Step 4 — Rank Wands by Cost Within Each Group

The query uses:

```sql
ROW_NUMBER() OVER (
    PARTITION BY WP.AGE, W.POWER
    ORDER BY W.COINS_NEEDED ASC
) AS RN
```

There are two separate operations here:

### Partitioning

```text
AGE + POWER
```

creates independent groups.

### Ordering

```text
COINS_NEEDED ASC
```

puts the cheapest wand first inside each group.

---

# Step 5 — Rank Group 1

Group:

```text
AGE = 20
POWER = 10
```

Before ranking:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 1 | 20 | 50 | 10 |
| 2 | 20 | 40 | 10 |

Sort by `COINS_NEEDED ASC`:

| ID | AGE | COINS_NEEDED | POWER | RN |
|---:|---:|---:|---:|---:|
| 2 | 20 | 40 | 10 | 1 |
| 1 | 20 | 50 | 10 | 2 |

Therefore:

```text
ID 2 → cheapest
```

---

# Step 6 — Rank Group 2

Group:

```text
AGE = 30
POWER = 10
```

Before ranking:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 3 | 30 | 70 | 10 |
| 4 | 30 | 60 | 10 |

After sorting:

| ID | AGE | COINS_NEEDED | POWER | RN |
|---:|---:|---:|---:|---:|
| 4 | 30 | 60 | 10 | 1 |
| 3 | 30 | 70 | 10 | 2 |

Therefore:

```text
ID 4 → cheapest
```

---

# Step 7 — Rank Group 3

Group:

```text
AGE = 20
POWER = 15
```

Before ranking:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 5 | 20 | 80 | 15 |
| 6 | 20 | 75 | 15 |

After sorting:

| ID | AGE | COINS_NEEDED | POWER | RN |
|---:|---:|---:|---:|---:|
| 6 | 20 | 75 | 15 | 1 |
| 5 | 20 | 80 | 15 | 2 |

Therefore:

```text
ID 6 → cheapest
```

---

# Step 8 — Result of `RANKED_TABLE`

Putting all groups back together:

| ID | AGE | COINS_NEEDED | POWER | RN |
|---:|---:|---:|---:|---:|
| 2 | 20 | 40 | 10 | 1 |
| 1 | 20 | 50 | 10 | 2 |
| 4 | 30 | 60 | 10 | 1 |
| 3 | 30 | 70 | 10 | 2 |
| 6 | 20 | 75 | 15 | 1 |
| 5 | 20 | 80 | 15 | 2 |

This is the result of the CTE:

```sql
WITH RANKED_TABLE AS (...)
```

The key idea is:

> `ROW_NUMBER()` starts from 1 again for every `(AGE, POWER)` group.

---

# Step 9 — Keep Only `RN = 1`

The final query contains:

```sql
WHERE RN = 1
```

This keeps the first-ranked wand from every group.

Our table:

| ID | AGE | COINS_NEEDED | POWER | RN |
|---:|---:|---:|---:|---:|
| 2 | 20 | 40 | 10 | 1 |
| 1 | 20 | 50 | 10 | 2 |
| 4 | 30 | 60 | 10 | 1 |
| 3 | 30 | 70 | 10 | 2 |
| 6 | 20 | 75 | 15 | 1 |
| 5 | 20 | 80 | 15 | 2 |

After:

```text
RN = 1
```

we get:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 2 | 20 | 40 | 10 |
| 4 | 30 | 60 | 10 |
| 6 | 20 | 75 | 15 |

Now there is exactly one cheapest wand for each `(AGE, POWER)` combination.

---

# Step 10 — Final Ordering

The query ends with:

```sql
ORDER BY
    POWER DESC,
    AGE DESC;
```

First, higher power comes first.

Our current result:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 2 | 20 | 40 | 10 |
| 4 | 30 | 60 | 10 |
| 6 | 20 | 75 | 15 |

Sort by `POWER DESC`:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 6 | 20 | 75 | 15 |
| 2 | 20 | 40 | 10 |
| 4 | 30 | 60 | 10 |

For equal power values, `AGE DESC` is used.

For power 10:

```text
AGE 30
AGE 20
```

Therefore:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 6 | 20 | 75 | 15 |
| 4 | 30 | 60 | 10 |
| 2 | 20 | 40 | 10 |

---

# Final Result

The final query selects:

```sql
SELECT
    ID,
    AGE,
    COINS_NEEDED,
    POWER
```

So the final output is:

| ID | AGE | COINS_NEEDED | POWER |
|---:|---:|---:|---:|
| 6 | 20 | 75 | 15 |
| 4 | 30 | 60 | 10 |
| 2 | 20 | 40 | 10 |

---

# Complete Transformation Flow

```text
                    WANDS
                      │
                      │ CODE
                      ▼
              WANDS_PROPERTY
                      │
                      ▼
                 JOIN TABLE
                      │
                      ▼
             Filter IS_EVIL = 0
                      │
                      ▼
        ┌─────────────────────────────┐
        │ ID │ AGE │ COST │ POWER     │
        ├────┼─────┼──────┼───────────┤
        │ 1  │ 20  │  50  │ 10        │
        │ 2  │ 20  │  40  │ 10        │
        │ 3  │ 30  │  70  │ 10        │
        │ 4  │ 30  │  60  │ 10        │
        │ 5  │ 20  │  80  │ 15        │
        │ 6  │ 20  │  75  │ 15        │
        └─────────────────────────────┘
                      │
                      ▼
          PARTITION BY AGE, POWER
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       (20,10)     (30,10)     (20,15)
          │           │           │
          ▼           ▼           ▼
      Sort cost    Sort cost    Sort cost
       ASC           ASC          ASC
          │           │           │
          ▼           ▼           ▼
       RN = 1       RN = 1       RN = 1
          │           │           │
          └───────────┼───────────┘
                      ▼
                 RN = 1
                      │
                      ▼
          Cheapest wand per group
                      │
                      ▼
              POWER DESC
                      │
                      ▼
               AGE DESC
                      │
                      ▼
                FINAL RESULT
```

---

# CTE Transformation Summary

## `RANKED_TABLE`

The CTE performs three major operations:

### 1. Join

```text
WANDS
   +
WANDS_PROPERTY
   ↓
Combined wand information
```

### 2. Filter

```text
IS_EVIL = 0
   ↓
Keep only non-evil wands
```

### 3. Rank

```text
Partition by AGE + POWER
           ↓
Sort by COINS_NEEDED ASC
           ↓
Assign RN
```

The result is:

| ID | AGE | COINS_NEEDED | POWER | RN |
|---:|---:|---:|---:|---:|
| 2 | 20 | 40 | 10 | 1 |
| 1 | 20 | 50 | 10 | 2 |
| 4 | 30 | 60 | 10 | 1 |
| 3 | 30 | 70 | 10 | 2 |
| 6 | 20 | 75 | 15 | 1 |
| 5 | 20 | 80 | 15 | 2 |

---

# Why `PARTITION BY` Is Important

Without:

```sql
PARTITION BY WP.AGE, W.POWER
```

all wands would be ranked together.

That would only give us the cheapest wand overall.

But the problem requires:

```text
cheapest wand
      ↓
for EACH AGE + POWER combination
```

`PARTITION BY` resets the ranking for every combination.

For example:

```text
AGE 20 + POWER 10
    → RN 1, 2

AGE 30 + POWER 10
    → RN 1, 2

AGE 20 + POWER 15
    → RN 1, 2
```

That is exactly what allows `RN = 1` to select one wand from every group.

---

# Why `ROW_NUMBER()` Is Used

We want exactly one cheapest wand from each group.

The ranking produces:

```text
Cheapest → RN 1
Second cheapest → RN 2
Third cheapest → RN 3
...
```

Then:

```sql
WHERE RN = 1
```

keeps only the cheapest row.

This is a common SQL pattern for:

```text
"Find the cheapest / highest / earliest row for each group."
```

---

# Key SQL Concepts

- Joining related tables
- Filtering rows before ranking
- Partitioning data into independent groups
- Ranking rows within each group
- Selecting the first-ranked row
- Removing duplicate candidates through ranking
- Multi-level sorting

---

# Final Transformation

```text
WANDS
   ↓
JOIN WANDS_PROPERTY
   ↓
Get AGE + IS_EVIL
   ↓
Remove evil wands
   ↓
Group by AGE + POWER
   ↓
Sort each group by COINS_NEEDED ASC
   ↓
Assign row numbers
   ↓
Keep RN = 1
   ↓
Cheapest wand for each AGE + POWER
   ↓
Sort POWER DESC
   ↓
Sort AGE DESC
   ↓
Final result
```

**Corresponding SQL:** `10_Ollivanders_Inventory.sql`