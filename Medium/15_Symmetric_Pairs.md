# Symmetric Pairs

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Self Join, Set Operations, Grouping, Filtering

---

## Problem

You are given a table called `Functions` containing two columns:

- `X`
- `Y`

A pair `(X, Y)` is **symmetric** if there is another row `(Y, X)`.

For example:

```text
(1, 2)
(2, 1)
```

These two rows form a symmetric pair.

There is one special case:

```text
(3, 3)
(3, 3)
```

A pair where `X = Y` is considered symmetric only when it appears **more than once**.

The goal is to return all symmetric pairs ordered by `X`.

---

## Given Table

Example `Functions` table:

| X | Y |
|---:|---:|
| 1 | 2 |
| 2 | 1 |
| 3 | 4 |
| 4 | 3 |
| 5 | 6 |
| 3 | 3 |
| 3 | 3 |
| 7 | 7 |

---

# Step 1 — Find `(X, Y)` pairs that have `(Y, X)`

The first part of the query uses a **self join**:

```sql
FROM Functions f1
JOIN Functions f2
    ON f1.X = f2.Y
    AND f1.Y = f2.X
```

The table is treated as two copies:

```text
Functions f1
Functions f2
```

We are asking:

> For every `(X, Y)` in `f1`, does `(Y, X)` exist in `f2`?

---

## Example

Suppose `f1` contains:

| f1.X | f1.Y |
|---:|---:|
| 1 | 2 |

The join looks for a row in `f2` where:

```text
f2.X = 2
f2.Y = 1
```

We have:

| f2.X | f2.Y |
|---:|---:|
| 2 | 1 |

So the rows match.

Therefore:

```text
(1, 2)
```

is symmetric.

The same happens in the opposite direction:

```text
(2, 1)
```

---

# Step 2 — Avoid returning both directions

The first query contains:

```sql
WHERE f1.X < f1.Y
```

Without this condition, both of these could be returned:

```text
(1, 2)
(2, 1)
```

But HackerRank expects the pair to be represented once.

The condition:

```text
X < Y
```

keeps only:

```text
(1, 2)
```

because:

```text
1 < 2
```

while:

```text
2 < 1
```

is false.

---

## Result after Step 2

From the example data:

| X | Y |
|---:|---:|
| 1 | 2 |
| 3 | 4 |

These are the symmetric pairs where `X < Y`.

---

# Step 3 — Handle pairs where `X = Y`

The first part cannot handle the special case correctly.

Consider:

```text
(3, 3)
(3, 3)
```

A row `(3, 3)` matches another `(3, 3)`.

But we need to make sure that the pair appears **more than once**.

That's why the second query is:

```sql
SELECT
    X,
    Y
FROM Functions
WHERE X = Y
GROUP BY X, Y
HAVING COUNT(*) > 1
```

---

# Step 4 — Keep only rows where `X = Y`

First:

```sql
WHERE X = Y
```

From our example:

| X | Y |
|---:|---:|
| 3 | 3 |
| 3 | 3 |
| 7 | 7 |

---

# Step 5 — Group identical pairs

We then use:

```sql
GROUP BY X, Y
```

The data becomes conceptually:

| X | Y | COUNT |
|---:|---:|---:|
| 3 | 3 | 2 |
| 7 | 7 | 1 |

---

# Step 6 — Keep pairs occurring more than once

Now:

```sql
HAVING COUNT(*) > 1
```

removes:

```text
(7, 7)
```

because it occurs only once.

We keep:

| X | Y |
|---:|---:|
| 3 | 3 |

So the second query handles the special repeated `(X, X)` case.

---

# Step 7 — Combine both sets

The query uses:

```sql
UNION
```

The first query produces:

| X | Y |
|---:|---:|
| 1 | 2 |
| 3 | 4 |

The second query produces:

| X | Y |
|---:|---:|
| 3 | 3 |

`UNION` combines them into:

| X | Y |
|---:|---:|
| 1 | 2 |
| 3 | 3 |
| 3 | 4 |

`UNION` also removes duplicate rows between the two result sets.

---

# Step 8 — Order the final result

Finally:

```sql
ORDER BY X;
```

sorts the result by `X` in ascending order.

Final result:

| X | Y |
|---:|---:|
| 1 | 2 |
| 3 | 3 |
| 3 | 4 |

---

# Complete Transformation Flow

```text
                    Functions
                        │
             ┌──────────┴──────────┐
             │                     │
             ▼                     ▼
       Self Join                X = Y
             │                     │
             │              GROUP BY X, Y
             │                     │
       Find (Y, X)                 │
             │                     │
        X < Y                COUNT(*) > 1
             │                     │
             ▼                     ▼
      Symmetric pairs       Repeated (X,X) pairs
             │                     │
             └──────────┬──────────┘
                        │
                      UNION
                        │
                        ▼
                 ORDER BY X
                        │
                        ▼
                  Final Result
```

---

# Why a Self Join?

The key idea is comparing rows **within the same table**.

For:

```text
(1, 2)
```

we need to find:

```text
(2, 1)
```

A self join allows us to treat the same table as two independent references:

```sql
Functions f1
Functions f2
```

The matching condition:

```sql
f1.X = f2.Y
AND f1.Y = f2.X
```

literally checks whether the values are reversed.

---

# Why Two Queries?

There are two types of symmetric pairs:

### Type 1 — Different values

```text
(1, 2)
(2, 1)
```

These are detected using the self join.

### Type 2 — Same values

```text
(3, 3)
(3, 3)
```

These require grouping and counting because the same pair must occur more than once.

Therefore, the solution handles both cases separately and combines them with `UNION`.

---

# Key SQL Concepts

### 1. Self Join

Joining a table with itself allows rows to be compared against other rows in the same table.

### 2. Conditional Filtering

```sql
WHERE f1.X < f1.Y
```

prevents returning both directions of the same symmetric pair.

### 3. Grouping

```sql
GROUP BY X, Y
```

groups identical `(X, Y)` pairs together.

### 4. Group-Level Filtering

```sql
HAVING COUNT(*) > 1
```

keeps only repeated pairs.

### 5. Set Combination

```sql
UNION
```

combines the results from the two different symmetric-pair cases.

### 6. Final Sorting

```sql
ORDER BY X
```

sorts the complete result after both result sets have been combined.

---

## Final Logic

```text
Different X and Y
        │
        ▼
Check whether (Y,X) exists
        │
        ▼
Keep X < Y
        │
        ├──────────────┐
        │              │
        ▼              ▼
 Symmetric pairs    X = Y pairs
                       │
                       ▼
                 Count occurrences
                       │
                       ▼
                  Keep count > 1
                       │
        └─────── UNION ────────┘
                   │
                   ▼
              ORDER BY X
```

**Corresponding SQL:** `15_Symmetric_Pairs.sql`