# 15 Days of Learning SQL

**Platform:** HackerRank  
**Difficulty:** Hard  
**Topics:** CTE, DISTINCT, ROW_NUMBER(), PARTITION BY, DATEDIFF, GROUP BY, JOIN, Ranking

---

## Problem

A 15-day SQL challenge begins on **March 1, 2016**.

For each day, we need to find:

1. The number of hackers who have made at least one submission on **every day from March 1 up to that date**.
2. The hacker who made the **maximum number of submissions on that day**.
3. If multiple hackers have the same maximum number of submissions, choose the hacker with the **smallest `HACKER_ID`**.

The final output contains:

```text
SUBMISSION_DATE
UNIQUE_HACKERS
HACKER_ID
NAME
```

---

# Tables

The important tables are:

### `SUBMISSIONS`

| SUBMISSION_DATE | HACKER_ID |
|---|---:|
| 2016-03-01 | 1 |
| 2016-03-01 | 1 |
| 2016-03-01 | 2 |
| 2016-03-02 | 1 |
| 2016-03-02 | 2 |
| 2016-03-03 | 1 |
| 2016-03-03 | 3 |

A hacker can make **multiple submissions on the same day**.

For example:

```text
Hacker 1
2016-03-01 → 2 submissions
2016-03-02 → 1 submission
2016-03-03 → 1 submission
```

This is important because we need to answer two different questions:

- Did the hacker submit on that day?
- How many submissions did the hacker make that day?

These require different transformations.

---

### `HACKERS`

| HACKER_ID | NAME |
|---:|---|
| 1 | Alice |
| 2 | Bob |
| 3 | Charlie |

---

# Step 1 — Remove Duplicate Hacker/Date Combinations

The first CTE is:

```sql
WITH HACKER_DAY_UNIQUE AS (
    SELECT DISTINCT
        HACKER_ID,
        SUBMISSION_DATE
    FROM SUBMISSIONS
)
```

The original table can have multiple submissions from the same hacker on the same day.

For example:

| SUBMISSION_DATE | HACKER_ID |
|---|---:|
| 2016-03-01 | 1 |
| 2016-03-01 | 1 |
| 2016-03-01 | 2 |
| 2016-03-02 | 1 |
| 2016-03-02 | 2 |

After:

```sql
SELECT DISTINCT HACKER_ID, SUBMISSION_DATE
```

we get:

| HACKER_ID | SUBMISSION_DATE |
|---:|---|
| 1 | 2016-03-01 |
| 2 | 2016-03-01 |
| 1 | 2016-03-02 |
| 2 | 2016-03-02 |
| 1 | 2016-03-03 |
| 3 | 2016-03-03 |

Now there is **only one row per hacker per day**.

### Why?

We don't care how many submissions a hacker made when checking whether they participated on a particular day.

We only care:

```text
Did Hacker X submit on Day Y?
```

---

# Step 2 — Assign a Day Number to Each Hacker

The next CTE is:

```sql
HACKER_DAY_NUMBER AS (
    SELECT
        HACKER_ID,
        SUBMISSION_DATE,
        ROW_NUMBER() OVER (
            PARTITION BY HACKER_ID
            ORDER BY SUBMISSION_DATE
        ) AS DAY_NUMBER
    FROM HACKER_DAY_UNIQUE
)
```

The important part is:

```sql
ROW_NUMBER() OVER (
    PARTITION BY HACKER_ID
    ORDER BY SUBMISSION_DATE
)
```

Each hacker gets their own sequence.

### Before

| HACKER_ID | SUBMISSION_DATE |
|---:|---|
| 1 | 2016-03-01 |
| 1 | 2016-03-02 |
| 1 | 2016-03-03 |
| 2 | 2016-03-01 |
| 2 | 2016-03-02 |
| 3 | 2016-03-03 |

### After `ROW_NUMBER()`

| HACKER_ID | SUBMISSION_DATE | DAY_NUMBER |
|---:|---|---:|
| 1 | 2016-03-01 | 1 |
| 1 | 2016-03-02 | 2 |
| 1 | 2016-03-03 | 3 |
| 2 | 2016-03-01 | 1 |
| 2 | 2016-03-02 | 2 |
| 3 | 2016-03-03 | 1 |

Notice that the numbering **restarts for every hacker** because of:

```sql
PARTITION BY HACKER_ID
```

---

# Step 3 — Identify Hackers Who Never Missed a Day

This is the key part of the problem.

```sql
WHERE DAY_NUMBER =
      DATEDIFF(SUBMISSION_DATE, '2016-03-01') + 1
```

Let's understand it.

For March 1:

```text
DATEDIFF('2016-03-01', '2016-03-01')
= 0

0 + 1
= 1
```

For March 2:

```text
DATEDIFF('2016-03-02', '2016-03-01')
= 1

1 + 1
= 2
```

For March 3:

```text
DATEDIFF('2016-03-03', '2016-03-01')
= 2

2 + 1
= 3
```

Therefore:

| Date | Required DAY_NUMBER |
|---|---:|
| March 1 | 1 |
| March 2 | 2 |
| March 3 | 3 |
| March 4 | 4 |

A hacker who submitted **every single day** will have exactly that sequence.

---

## Example

Hacker 1:

| DATE | DAY_NUMBER | REQUIRED |
|---|---:|---:|
| Mar 1 | 1 | 1 |
| Mar 2 | 2 | 2 |
| Mar 3 | 3 | 3 |

All rows match.

Therefore Hacker 1 has participated continuously.

Hacker 2:

| DATE | DAY_NUMBER | REQUIRED |
|---|---:|---:|
| Mar 1 | 1 | 1 |
| Mar 2 | 2 | 2 |

On March 3 there is no row.

Therefore Hacker 2 is **not** counted on March 3.

Hacker 3:

| DATE | DAY_NUMBER | REQUIRED |
|---|---:|---:|
| Mar 3 | 1 | 3 |

The values don't match.

Therefore Hacker 3 is not counted.

---

# Step 4 — Count the Continuous Hackers

The third CTE:

```sql
COUNT_UNIQUE_HACKERS AS (
    SELECT
        SUBMISSION_DATE,
        COUNT(HACKER_ID) AS UNIQUE_HACKERS
    FROM HACKER_DAY_NUMBER
    WHERE DAY_NUMBER =
          DATEDIFF(SUBMISSION_DATE, '2016-03-01') + 1
    GROUP BY SUBMISSION_DATE
)
```

After applying the condition, we might have:

| HACKER_ID | SUBMISSION_DATE | DAY_NUMBER |
|---:|---|---:|
| 1 | 2016-03-01 | 1 |
| 2 | 2016-03-01 | 1 |
| 1 | 2016-03-02 | 2 |
| 2 | 2016-03-02 | 2 |
| 1 | 2016-03-03 | 3 |

Then:

```sql
GROUP BY SUBMISSION_DATE
```

produces:

| SUBMISSION_DATE | UNIQUE_HACKERS |
|---|---:|
| 2016-03-01 | 2 |
| 2016-03-02 | 2 |
| 2016-03-03 | 1 |

So this CTE answers:

> **How many hackers have submitted every day since March 1?**

---

# Step 5 — Count Submissions Per Hacker Per Day

Now we switch back to the original `SUBMISSIONS` table.

The fourth CTE is:

```sql
COUNT_MAX_SUBMISSIONS AS (
    SELECT
        SUBMISSION_DATE,
        HACKER_ID,
        COUNT(HACKER_ID) AS MAX_SUBMISSIONS
    FROM SUBMISSIONS
    GROUP BY SUBMISSION_DATE, HACKER_ID
)
```

This time we **do care about multiple submissions**.

Suppose the original data is:

| SUBMISSION_DATE | HACKER_ID |
|---|---:|
| 2016-03-01 | 1 |
| 2016-03-01 | 1 |
| 2016-03-01 | 2 |
| 2016-03-02 | 1 |
| 2016-03-02 | 1 |
| 2016-03-02 | 2 |
| 2016-03-02 | 2 |

After:

```sql
GROUP BY SUBMISSION_DATE, HACKER_ID
```

we get:

| SUBMISSION_DATE | HACKER_ID | MAX_SUBMISSIONS |
|---|---:|---:|
| 2016-03-01 | 1 | 2 |
| 2016-03-01 | 2 | 1 |
| 2016-03-02 | 1 | 2 |
| 2016-03-02 | 2 | 2 |

Now we know how many submissions each hacker made each day.

---

# Step 6 — Rank Hackers Within Each Day

The fifth CTE is:

```sql
RANK_MAX_SUBS AS (
    SELECT
        SUBMISSION_DATE,
        HACKER_ID,
        MAX_SUBMISSIONS,
        ROW_NUMBER() OVER (
            PARTITION BY SUBMISSION_DATE
            ORDER BY MAX_SUBMISSIONS DESC, HACKER_ID
        ) AS RN
    FROM COUNT_MAX_SUBMISSIONS
)
```

The important part is:

```sql
PARTITION BY SUBMISSION_DATE
```

This means the ranking starts again for every date.

Then:

```sql
ORDER BY MAX_SUBMISSIONS DESC, HACKER_ID
```

means:

1. More submissions → higher position.
2. If submissions are tied → smaller `HACKER_ID` comes first.

### Before ranking

| DATE | HACKER | SUBMISSIONS |
|---|---:|---:|
| Mar 1 | 1 | 2 |
| Mar 1 | 2 | 1 |
| Mar 2 | 1 | 2 |
| Mar 2 | 2 | 2 |

### After `ROW_NUMBER()`

| DATE | HACKER | SUBMISSIONS | RN |
|---|---:|---:|---:|
| Mar 1 | 1 | 2 | 1 |
| Mar 1 | 2 | 1 | 2 |
| Mar 2 | 1 | 2 | 1 |
| Mar 2 | 2 | 2 | 2 |

On March 2, both hackers made 2 submissions.

Because we use:

```sql
HACKER_ID
```

as the second sorting condition, Hacker 1 gets `RN = 1`.

---

# Step 7 — Keep Only the Daily Winner

The final query contains:

```sql
WHERE RN = 1
```

Therefore:

| DATE | HACKER_ID | MAX_SUBMISSIONS |
|---|---:|---:|
| 2016-03-01 | 1 | 2 |
| 2016-03-02 | 1 | 2 |

Only the hacker ranked first on each day remains.

---

# Step 8 — Combine the Two Results

We now have two important pieces of information.

### `COUNT_UNIQUE_HACKERS`

```text
Date → Number of continuous hackers
```

| DATE | UNIQUE_HACKERS |
|---|---:|
| Mar 1 | 2 |
| Mar 2 | 2 |
| Mar 3 | 1 |

### `RANK_MAX_SUBS`

```text
Date → Hacker with most submissions
```

| DATE | HACKER_ID | RN |
|---|---:|---:|
| Mar 1 | 1 | 1 |
| Mar 2 | 1 | 1 |
| Mar 3 | 1 | 1 |

They are joined using:

```sql
ON C.SUBMISSION_DATE = R.SUBMISSION_DATE
```

Result:

| DATE | UNIQUE_HACKERS | HACKER_ID |
|---|---:|---:|
| Mar 1 | 2 | 1 |
| Mar 2 | 2 | 1 |
| Mar 3 | 1 | 1 |

---

# Step 9 — Get the Hacker's Name

Finally:

```sql
JOIN HACKERS H
    ON H.HACKER_ID = R.HACKER_ID
```

This converts:

```text
HACKER_ID = 1
```

into:

```text
NAME = Alice
```

Final result:

| SUBMISSION_DATE | UNIQUE_HACKERS | HACKER_ID | NAME |
|---|---:|---:|---|
| 2016-03-01 | 2 | 1 | Alice |
| 2016-03-02 | 2 | 1 | Alice |
| 2016-03-03 | 1 | 1 | Alice |

---

# Complete Transformation

The entire query can be visualized as:

```text
                    SUBMISSIONS
                         │
              ┌──────────┴──────────┐
              │                     │
              ↓                     ↓
       SELECT DISTINCT        GROUP BY DATE,
       HACKER + DATE             HACKER
              │                     │
              ↓                     ↓
    HACKER_DAY_UNIQUE       COUNT_MAX_SUBMISSIONS
              │                     │
              ↓                     ↓
       ROW_NUMBER()           ROW_NUMBER()
       per HACKER             per DATE
              │                     │
              ↓                     ↓
    HACKER_DAY_NUMBER        RANK_MAX_SUBS
              │                     │
              ↓                     ↓
       DATEDIFF check          WHERE RN = 1
              │                     │
              ↓                     │
   COUNT_UNIQUE_HACKERS             │
              │                     │
              └──────────┬──────────┘
                         │
                         ↓
                       JOIN
                         │
                         ↓
                     HACKERS
                         │
                         ↓
                   FINAL RESULT
```

---

# The Key Idea

The query actually solves **two separate problems**.

### Problem 1 — Continuous participation

```text
DISTINCT
   ↓
ROW_NUMBER per hacker
   ↓
Compare with expected day number
   ↓
GROUP BY date
```

This determines:

> How many hackers have submitted every day?

---

### Problem 2 — Most submissions

```text
GROUP BY date + hacker
   ↓
COUNT submissions
   ↓
ROW_NUMBER per date
   ↓
ORDER BY submissions DESC, hacker_id
   ↓
RN = 1
```

This determines:

> Who made the most submissions each day?

Finally, the two results are joined by `SUBMISSION_DATE`.

---

# Key SQL Concepts

### `DISTINCT`

Used to convert:

```text
Multiple submissions by the same hacker on one day
```

into:

```text
One hacker + one date
```

---

### `ROW_NUMBER()`

Used twice for two completely different purposes:

```text
1. Number each hacker's submission days
2. Rank hackers by daily submission count
```

---

### `PARTITION BY`

First:

```sql
PARTITION BY HACKER_ID
```

The numbering restarts for every hacker.

Second:

```sql
PARTITION BY SUBMISSION_DATE
```

The ranking restarts for every day.

---

### `DATEDIFF()`

Used to calculate the expected day number:

```text
March 1 → 1
March 2 → 2
March 3 → 3
...
```

---

### Tie-breaking

The ranking uses:

```sql
ORDER BY MAX_SUBMISSIONS DESC, HACKER_ID
```

So:

```text
Most submissions
       ↓
If tied
       ↓
Smallest HACKER_ID
```

---

## Solution

The complete SQL solution is available in [`02_15_Days_of_LeetCode.sql`](./02_15_Days_of_LeetCode.sql).