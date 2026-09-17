# Print Prime Numbers

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Recursive CTEs, Number Generation, Correlated Subqueries, Divisibility, Set Filtering

---

## Problem

Generate and print all **prime numbers from 2 through 1000**.

The numbers must be printed on a single line, separated by the `&` character.

For example:

```text
2&3&5&7&11&13...
```

A **prime number** is a number greater than 1 that has no positive divisors other than `1` and itself.

---

# Overall Approach

The query has three main stages:

```text
Generate numbers 2 → 1000
          ↓
   Identify prime numbers
          ↓
 Concatenate with '&'
```

The query uses two CTEs:

```text
NUMBERS
   ↓
PRIMES
   ↓
GROUP_CONCAT
```

---

# Step 1 — Generate Numbers from 2 to 1000

The first CTE is:

```sql
WITH RECURSIVE NUMBERS AS (
    SELECT 2 AS N

    UNION ALL

    SELECT N + 1
    FROM NUMBERS
    WHERE N < 1000
)
```

Because there is no existing table containing all integers from 2 to 1000, we generate them using a **recursive CTE**.

---

## Step 1A — Starting Point

The recursive CTE begins with:

```sql
SELECT 2 AS N
```

So initially:

| N |
|---:|
| 2 |

---

## Step 1B — Recursive Step

Then:

```sql
SELECT N + 1
FROM NUMBERS
WHERE N < 1000
```

takes the current number and generates the next one.

The transformation looks like:

```text
2
↓
3
↓
4
↓
5
↓
6
↓
...
↓
1000
```

The recursion stops once `N` reaches 1000 because:

```sql
WHERE N < 1000
```

is no longer true.

---

## NUMBERS CTE Result

Conceptually:

| N |
|---:|
| 2 |
| 3 |
| 4 |
| 5 |
| 6 |
| ... |
| 999 |
| 1000 |

So now we have every number that needs to be tested.

---

# Step 2 — Find the Prime Numbers

The second CTE is:

```sql
PRIMES AS (
    SELECT N
    FROM NUMBERS N1
    WHERE NOT EXISTS (
        SELECT 1
        FROM NUMBERS N2
        WHERE N2.N < N1.N
            AND N2.N > 1
            AND N1.N % N2.N = 0
    )
)
```

This is the core of the solution.

For every number `N1`, we search for a smaller number `N2` that divides it exactly.

If such a number exists, `N1` is **not prime**.

If no such number exists, `N1` is prime.

---

# Step 3 — Compare a Number Against Smaller Numbers

The outer query uses:

```sql
FROM NUMBERS N1
```

Think of `N1` as the number currently being tested.

The inner query uses:

```sql
FROM NUMBERS N2
```

Think of `N2` as a possible divisor.

So conceptually:

```text
N1 = number being tested

N2 = possible divisor
```

---

# Step 4 — Only Consider Smaller Numbers

The condition:

```sql
N2.N < N1.N
```

means we only test divisors smaller than the number itself.

For example, if:

```text
N1 = 7
```

we check:

```text
2, 3, 4, 5, 6
```

We don't need to test `7` itself because every number is divisible by itself.

---

# Step 5 — Ignore 1

The condition:

```sql
N2.N > 1
```

removes `1` from consideration.

This is important because every number is divisible by `1`.

For example:

```text
7 % 1 = 0
```

If we considered `1`, every number would incorrectly appear to have a divisor.

So we only check:

```text
2, 3, 4, ...
```

---

# Step 6 — Check Divisibility

The key condition is:

```sql
N1.N % N2.N = 0
```

The `%` operation determines the remainder after division.

If the remainder is `0`, the number divides evenly.

### Example: 12

Check:

```text
12 % 2 = 0
```

Therefore, `2` divides `12`.

So `12` is not prime.

### Example: 13

Check:

```text
13 % 2 = 1
13 % 3 = 1
13 % 4 = 1
...
```

No smaller number greater than 1 divides `13`.

Therefore, `13` is prime.

---

# Step 7 — How `NOT EXISTS` Identifies Primes

The inner query searches for a divisor.

For example, when:

```text
N1 = 12
```

the inner query finds:

| N2 | 12 % N2 |
|---:|---:|
| 2 | 0 |
| 3 | 0 |
| 4 | 0 |
| 6 | 0 |

So matching rows **exist**.

Therefore:

```sql
NOT EXISTS (...)
```

is false.

`12` is removed.

---

Now consider:

```text
N1 = 13
```

The inner query finds no valid divisor.

Therefore:

```text
EXISTS → FALSE
NOT EXISTS → TRUE
```

So `13` remains in `PRIMES`.

---

# Step 8 — Small Example

Consider numbers from 2 to 10.

### Number 2

There are no numbers between 2 and 2 that are greater than 1.

```text
No divisor found → Prime
```

### Number 3

Possible divisor:

```text
2
```

But:

```text
3 % 2 ≠ 0
```

```text
No divisor found → Prime
```

### Number 4

Check:

```text
4 % 2 = 0
```

```text
Divisor found → Not prime
```

### Number 5

```text
5 % 2 ≠ 0
5 % 3 ≠ 0
5 % 4 ≠ 0
```

```text
No divisor found → Prime
```

### Number 6

```text
6 % 2 = 0
```

```text
Divisor found → Not prime
```

### Number 7

No smaller number greater than 1 divides it.

```text
Prime
```

### Number 8

```text
8 % 2 = 0
```

```text
Not prime
```

### Number 9

```text
9 % 3 = 0
```

```text
Not prime
```

### Number 10

```text
10 % 2 = 0
```

```text
Not prime
```

---

# Step 9 — Result of the `PRIMES` CTE

For numbers 2 through 10:

| N |
|---:|
| 2 |
| 3 |
| 5 |
| 7 |

For the actual problem, the CTE produces all primes from 2 through 1000.

Conceptually:

```text
2
3
5
7
11
13
17
19
23
...
997
```

---

# Step 10 — Combine the Prime Numbers into One String

The final query is:

```sql
SELECT GROUP_CONCAT(
    N
    ORDER BY N
    SEPARATOR '&'
)
FROM PRIMES
```

The prime rows are converted into one string.

Without concatenation:

```text
2
3
5
7
11
13
```

After concatenation:

```text
2&3&5&7&11&13
```

---

# Step 11 — Sort the Numbers

Inside `GROUP_CONCAT`:

```sql
ORDER BY N
```

ensures the primes appear in ascending order.

So instead of:

```text
7&2&13&3&5
```

we get:

```text
2&3&5&7&13
```

---

# Step 12 — Use `&` as the Separator

This part:

```sql
SEPARATOR '&'
```

tells SQL exactly what should appear between consecutive prime numbers.

Therefore:

```text
2
3
5
7
```

becomes:

```text
2&3&5&7
```

---

# Complete Transformation Flow

```text
                 NUMBERS
                    │
                    ▼
          Recursive CTE
                    │
                    ▼
              2 → 1000
                    │
                    ▼
          ┌─────────────────┐
          │ Test every N1   │
          │ against smaller │
          │ possible N2     │
          └─────────────────┘
                    │
                    ▼
          Check divisibility
             N1 % N2 = 0
                    │
          ┌─────────┴─────────┐
          │                   │
     Divisor exists      No divisor
          │                   │
          ▼                   ▼
      Not prime              Prime
                              │
                              ▼
                           PRIMES
                              │
                              ▼
                       GROUP_CONCAT
                              │
                              ▼
                  2&3&5&7&11&13&...
```

---

# CTE Transformation

```text
NUMBERS
─────────────────────
2
3
4
5
6
...
1000
        │
        │ test divisibility
        ▼
PRIMES
─────────────────────
2
3
5
7
11
13
...
997
        │
        │ concatenate
        ▼
FINAL OUTPUT
─────────────────────
2&3&5&7&11&13&...&997
```

---

# Why `NOT EXISTS` Instead of Counting Divisors?

The query doesn't need to know **how many** divisors a number has.

It only needs to answer:

> Does at least one smaller divisor greater than 1 exist?

For a composite number:

```text
EXISTS = TRUE
```

Therefore:

```text
NOT EXISTS = FALSE
```

For a prime:

```text
EXISTS = FALSE
```

Therefore:

```text
NOT EXISTS = TRUE
```

This makes `NOT EXISTS` a natural way to express the definition of a prime number.

---

# Key SQL Concepts

### 1. Recursive CTEs

Used to generate a sequence of numbers when a suitable numbers table isn't available.

### 2. Self-Referential CTE

The recursive part references the CTE itself to generate the next number.

### 3. Correlated Subquery

The inner query uses the current value of `N1` from the outer query.

### 4. Existence Testing

`NOT EXISTS` checks whether a valid divisor can be found.

### 5. Divisibility

The remainder operation is used to determine whether one number divides another evenly.

### 6. String Aggregation

The prime numbers are converted from multiple rows into one ordered string.

---

# Final Logic

```text
Generate every number
        ↓
For each number:
    Find a smaller divisor > 1
        ↓
    Divisor found?
      /      \
    YES       NO
     ↓         ↓
 Not prime   Prime
               ↓
        Keep in PRIMES
               ↓
       Sort ascending
               ↓
       Join using '&'
               ↓
       Final output
```

**Corresponding SQL:** `16_Print_Prime_Numbers.sql`