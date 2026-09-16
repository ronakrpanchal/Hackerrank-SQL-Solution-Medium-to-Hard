# The PADS

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** UNION ALL, GROUP BY, COUNT(), String Functions, Subquery, Custom Sorting

---

## Problem

You are given an `OCCUPATIONS` table containing the names and occupations of people.

The output needs to contain two different types of results:

1. Each person's name followed by the first letter of their occupation.
2. A summary showing how many people belong to each occupation.

The two sets of results need to appear in a specific order.

---

# Given Table

### `OCCUPATIONS`

A simplified example:

| NAME | OCCUPATION |
|---|---|
| Ashley | Doctor |
| Samantha | Professor |
| Julia | Actor |
| Maria | Doctor |
| Meera | Professor |

---

# Part 1 — Format Each Person

The first query is:

```sql
SELECT
    CONCAT(NAME, '(', LEFT(OCCUPATION, 1), ')') AS result,
    NAME AS sort_col,
    1 AS order_col
FROM OCCUPATIONS
```

The important expression is:

```sql
CONCAT(NAME, '(', LEFT(OCCUPATION, 1), ')')
```

For example:

```text
NAME       OCCUPATION
Ashley     Doctor

        ↓ LEFT(OCCUPATION, 1)

D

        ↓ CONCAT()

Ashley(D)
```

### Result

| result | sort_col | order_col |
|---|---|---:|
| Ashley(D) | Ashley | 1 |
| Samantha(P) | Samantha | 1 |
| Julia(A) | Julia | 1 |
| Maria(D) | Maria | 1 |
| Meera(P) | Meera | 1 |

The `order_col` is set to:

```text
1
```

This will later ensure that these rows appear before the occupation-count rows.

---

# Part 2 — Count Each Occupation

The second query is:

```sql
SELECT
    CONCAT(
        'There are a total of ',
        COUNT(*),
        ' ',
        LOWER(OCCUPATION),
        's.'
    ) AS result,
    COUNT(*) AS sort_col,
    2 AS order_col
FROM OCCUPATIONS
GROUP BY OCCUPATION
```

Here we group the table by occupation.

### Before `GROUP BY`

| NAME | OCCUPATION |
|---|---|
| Ashley | Doctor |
| Samantha | Professor |
| Julia | Actor |
| Maria | Doctor |
| Meera | Professor |

### After `GROUP BY OCCUPATION`

The rows are grouped conceptually as:

```text
Doctor
    → Ashley
    → Maria

Professor
    → Samantha
    → Meera

Actor
    → Julia
```

Then:

```sql
COUNT(*)
```

counts the number of people in each group.

### Result

| OCCUPATION | COUNT(*) |
|---|---:|
| Doctor | 2 |
| Professor | 2 |
| Actor | 1 |

---

# Part 3 — Build the Summary String

The query uses:

```sql
CONCAT(
    'There are a total of ',
    COUNT(*),
    ' ',
    LOWER(OCCUPATION),
    's.'
)
```

For `Doctor`:

```text
'There are a total of '
        +
2
        +
' '
        +
'doctor'
        +
's.'
```

Result:

```text
There are a total of 2 doctors.
```

For `Professor`:

```text
There are a total of 2 professors.
```

For `Actor`:

```text
There are a total of 1 actors.
```

The `LOWER()` function converts the occupation to lowercase.

---

# Part 4 — Why `UNION ALL`?

Now we have two separate result sets.

### First query

```text
Ashley(D)
Samantha(P)
Julia(A)
Maria(D)
Meera(P)
```

### Second query

```text
There are a total of 2 doctors.
There are a total of 2 professors.
There are a total of 1 actors.
```

We combine them using:

```sql
UNION ALL
```

Conceptually:

```text
FIRST QUERY
     │
     │
     ├──────────────┐
     │              │
     ↓              │
Names + occupation │
                    │
                    ↓
                UNION ALL
                    ↑
                    │
     ┌──────────────┤
     │
     ↓
Occupation counts
```

### Combined Result

| result | sort_col | order_col |
|---|---|---:|
| Ashley(D) | Ashley | 1 |
| Samantha(P) | Samantha | 1 |
| Julia(A) | Julia | 1 |
| Maria(D) | Maria | 1 |
| Meera(P) | Meera | 1 |
| There are a total of 2 doctors. | 2 | 2 |
| There are a total of 2 professors. | 2 | 2 |
| There are a total of 1 actors. | 1 | 2 |

`UNION ALL` keeps all rows from both queries.

---

# Part 5 — Why Do We Need `sort_col` and `order_col`?

The problem requires a specific ordering.

We don't simply want:

```sql
ORDER BY result
```

because the two types of output need to be separated.

The query creates:

```sql
1 AS order_col
```

for the first query.

And:

```sql
2 AS order_col
```

for the second query.

So we effectively have:

```text
order_col = 1
    ↓
All individual names

order_col = 2
    ↓
All occupation summaries
```

---

# Part 6 — Final Sorting

The final query is:

```sql
SELECT result
FROM (...) AS combined
ORDER BY order_col, sort_col;
```

The sorting happens in two stages.

### First: `order_col`

```sql
ORDER BY order_col
```

gives:

```text
order_col = 1
        ↓
Names

order_col = 2
        ↓
Occupation summaries
```

### Second: `sort_col`

Within the first group:

```sql
NAME AS sort_col
```

so the names are sorted alphabetically.

Within the second group:

```sql
COUNT(*) AS sort_col
```

so occupation summaries are sorted by their count.

---

# Complete Transformation

```text
                    OCCUPATIONS
                         │
             ┌───────────┴───────────┐
             │                       │
             ↓                       ↓
      SELECT NAME +             GROUP BY
      first occupation          OCCUPATION
      letter                        │
             │                       ↓
             │                  COUNT(*)
             │                       │
             ↓                       ↓
       Individual              Occupation
       results                 summaries
             │                       │
             └───────────┬───────────┘
                         │
                     UNION ALL
                         │
                         ↓
                   COMBINED TABLE
                         │
                         ↓
               ORDER BY order_col,
                        sort_col
                         │
                         ↓
                    FINAL RESULT
```

---

# Key SQL Concepts

### `CONCAT()`

Combines multiple values into a single string.

```sql
CONCAT(NAME, '(', LEFT(OCCUPATION, 1), ')')
```

---

### `LEFT()`

Extracts the first character:

```sql
LEFT('Doctor', 1)
```

Result:

```text
D
```

---

### `LOWER()`

Converts text to lowercase:

```sql
LOWER('Doctor')
```

Result:

```text
doctor
```

---

### `GROUP BY`

Groups people according to their occupation:

```sql
GROUP BY OCCUPATION
```

---

### `COUNT()`

Counts the number of rows in each occupation group:

```sql
COUNT(*)
```

---

### `UNION ALL`

Combines the results of two `SELECT` statements while keeping all rows.

---

### Subquery

The two queries are combined inside:

```sql
FROM (
    ...
) AS combined
```

This creates a derived table that can then be sorted.

---

### Custom Sorting

The query creates helper columns:

```sql
1 AS order_col
2 AS order_col
```

and then uses:

```sql
ORDER BY order_col, sort_col
```

to control the final ordering.

---

## Solution

The complete SQL solution is available in [`03_The_PADS.sql`](./03_The_PADS.sql).