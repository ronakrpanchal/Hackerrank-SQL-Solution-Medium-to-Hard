# Interviews

**Platform:** HackerRank  
**Difficulty:** Hard  
**Topics:** CTE, JOIN, LEFT JOIN, GROUP BY, Aggregation, COALESCE

---

## Problem

You are given information about contests, colleges, challenges, submission statistics, and view statistics.

The goal is to calculate the total number of:

- Submissions
- Accepted submissions
- Views
- Unique views

for each contest.

Contests where **all four statistics are zero** should not appear in the final result.

---

# Tables

The problem involves five main tables:

### `CONTESTS`

Contains information about each contest.

| CONTEST_ID | HACKER_ID | NAME |
|---:|---:|---|
| 1 | 100 | Contest A |
| 2 | 200 | Contest B |

---

### `COLLEGES`

Connects colleges to contests.

| COLLEGE_ID | CONTEST_ID |
|---:|---:|
| 101 | 1 |
| 102 | 1 |
| 201 | 2 |

---

### `CHALLENGES`

Connects challenges to colleges.

| CHALLENGE_ID | COLLEGE_ID |
|---:|---:|
| 1001 | 101 |
| 1002 | 101 |
| 1003 | 102 |
| 2001 | 201 |

---

### `VIEW_STATS`

Contains view statistics for challenges.

| CHALLENGE_ID | TOTAL_VIEWS | TOTAL_UNIQUE_VIEWS |
|---:|---:|---:|
| 1001 | 500 | 400 |
| 1001 | 300 | 250 |
| 1002 | 200 | 180 |
| 1003 | 100 | 90 |

---

### `SUBMISSION_STATS`

Contains submission statistics for challenges.

| CHALLENGE_ID | TOTAL_SUBMISSIONS | TOTAL_ACCEPTED_SUBMISSIONS |
|---:|---:|---:|
| 1001 | 100 | 40 |
| 1001 | 50 | 20 |
| 1002 | 80 | 30 |
| 1003 | 20 | 10 |

---

# Step 1 — Aggregate View Statistics

The first CTE is:

```sql
WITH NEW_VIEW_STATS AS (
    SELECT
        CHALLENGE_ID,
        SUM(TOTAL_VIEWS) AS TOTAL_VIEWS,
        SUM(TOTAL_UNIQUE_VIEWS) AS TOTAL_UNIQUE_VIEWS
    FROM VIEW_STATS
    GROUP BY CHALLENGE_ID
)
```

The original `VIEW_STATS` table can contain **multiple rows for the same challenge**.

For example:

| CHALLENGE_ID | TOTAL_VIEWS | TOTAL_UNIQUE_VIEWS |
|---:|---:|---:|
| 1001 | 500 | 400 |
| 1001 | 300 | 250 |
| 1002 | 200 | 180 |

We group by `CHALLENGE_ID` and calculate the totals.

### Result of `NEW_VIEW_STATS`

For challenge `1001`:

```text
TOTAL_VIEWS
500 + 300 = 800

TOTAL_UNIQUE_VIEWS
400 + 250 = 650
```

Result:

| CHALLENGE_ID | TOTAL_VIEWS | TOTAL_UNIQUE_VIEWS |
|---:|---:|---:|
| 1001 | 800 | 650 |
| 1002 | 200 | 180 |
| 1003 | 100 | 90 |

So now there is **one row per challenge**.

---

# Step 2 — Aggregate Submission Statistics

The second CTE does the same thing for submissions:

```sql
NEW_SUBMISSION_STATS AS (
    SELECT
        CHALLENGE_ID,
        SUM(TOTAL_SUBMISSIONS) AS TOTAL_SUBMISSIONS,
        SUM(TOTAL_ACCEPTED_SUBMISSIONS) AS TOTAL_ACCEPTED_SUBMISSIONS
    FROM SUBMISSION_STATS
    GROUP BY CHALLENGE_ID
)
```

Original data:

| CHALLENGE_ID | TOTAL_SUBMISSIONS | TOTAL_ACCEPTED_SUBMISSIONS |
|---:|---:|---:|
| 1001 | 100 | 40 |
| 1001 | 50 | 20 |
| 1002 | 80 | 30 |

For challenge `1001`:

```text
TOTAL_SUBMISSIONS
100 + 50 = 150

TOTAL_ACCEPTED_SUBMISSIONS
40 + 20 = 60
```

### Result of `NEW_SUBMISSION_STATS`

| CHALLENGE_ID | TOTAL_SUBMISSIONS | TOTAL_ACCEPTED_SUBMISSIONS |
|---:|---:|---:|
| 1001 | 150 | 60 |
| 1002 | 80 | 30 |
| 1003 | 20 | 10 |

Again, we now have **one row per challenge**.

---

# Step 3 — Connect Challenges to Contests

Now we need to determine which contest each challenge belongs to.

The relationship is:

```text
CONTEST
   │
   ↓
COLLEGE
   │
   ↓
CHALLENGE
```

The query starts with:

```sql
FROM CHALLENGES CH
JOIN COLLEGES CO
    ON CO.COLLEGE_ID = CH.COLLEGE_ID
```

For example:

```text
CHALLENGES

CHALLENGE_ID    COLLEGE_ID
-----------     ----------
1001            101
1002            101
1003            102
```

and:

```text
COLLEGES

COLLEGE_ID      CONTEST_ID
----------      ----------
101             1
102             1
```

After the JOIN:

| CHALLENGE_ID | COLLEGE_ID | CONTEST_ID |
|---:|---:|---:|
| 1001 | 101 | 1 |
| 1002 | 101 | 1 |
| 1003 | 102 | 1 |

Now we know which contest owns each challenge.

---

# Step 4 — LEFT JOIN View Statistics

Next:

```sql
LEFT JOIN NEW_VIEW_STATS VS
    ON CH.CHALLENGE_ID = VS.CHALLENGE_ID
```

The challenge table is matched with the aggregated view statistics.

Before:

| CHALLENGE_ID | CONTEST_ID |
|---:|---:|
| 1001 | 1 |
| 1002 | 1 |
| 1003 | 1 |

`NEW_VIEW_STATS`:

| CHALLENGE_ID | TOTAL_VIEWS | TOTAL_UNIQUE_VIEWS |
|---:|---:|---:|
| 1001 | 800 | 650 |
| 1002 | 200 | 180 |
| 1003 | 100 | 90 |

After the JOIN:

| CHALLENGE_ID | CONTEST_ID | TOTAL_VIEWS | TOTAL_UNIQUE_VIEWS |
|---:|---:|---:|---:|
| 1001 | 1 | 800 | 650 |
| 1002 | 1 | 200 | 180 |
| 1003 | 1 | 100 | 90 |

We use a **LEFT JOIN** because a challenge might not have corresponding view statistics.

---

# Step 5 — LEFT JOIN Submission Statistics

We then perform another LEFT JOIN:

```sql
LEFT JOIN NEW_SUBMISSION_STATS SS
    ON CH.CHALLENGE_ID = SS.CHALLENGE_ID
```

This adds the submission information:

| CHALLENGE_ID | CONTEST_ID | VIEWS | UNIQUE_VIEWS | SUBMISSIONS | ACCEPTED |
|---:|---:|---:|---:|---:|---:|
| 1001 | 1 | 800 | 650 | 150 | 60 |
| 1002 | 1 | 200 | 180 | 80 | 30 |
| 1003 | 1 | 100 | 90 | 20 | 10 |

At this point, we have all the information needed to calculate the contest totals.

---

# Step 6 — Handle NULL Values

The query uses:

```sql
COALESCE(VS.TOTAL_VIEWS, 0)
```

and:

```sql
COALESCE(SS.TOTAL_SUBMISSIONS, 0)
```

Why?

Because `LEFT JOIN` can produce `NULL` when a challenge has no corresponding statistics.

For example:

| CHALLENGE_ID | TOTAL_VIEWS |
|---:|---:|
| 1001 | 800 |
| 1002 | NULL |
| 1003 | 100 |

Using:

```sql
COALESCE(TOTAL_VIEWS, 0)
```

turns this into:

| CHALLENGE_ID | TOTAL_VIEWS |
|---:|---:|
| 1001 | 800 |
| 1002 | 0 |
| 1003 | 100 |

So missing statistics are treated as **0**.

---

# Step 7 — Aggregate Everything by Contest

The third CTE is:

```sql
COMBINE_TABLE AS (
    SELECT
        CO.CONTEST_ID,
        SUM(COALESCE(VS.TOTAL_VIEWS, 0)) AS TV,
        SUM(COALESCE(VS.TOTAL_UNIQUE_VIEWS, 0)) AS TUV,
        SUM(COALESCE(SS.TOTAL_SUBMISSIONS, 0)) AS TS,
        SUM(COALESCE(SS.TOTAL_ACCEPTED_SUBMISSIONS, 0)) AS TAS
    ...
    GROUP BY CO.CONTEST_ID
)
```

We group everything by `CONTEST_ID`.

For Contest `1`:

```text
Views:
800 + 200 + 100 = 1100

Unique Views:
650 + 180 + 90 = 920

Submissions:
150 + 80 + 20 = 250

Accepted Submissions:
60 + 30 + 10 = 100
```

### Result of `COMBINE_TABLE`

| CONTEST_ID | TV | TUV | TS | TAS |
|---:|---:|---:|---:|---:|
| 1 | 1100 | 920 | 250 | 100 |

The CTE has now reduced all challenge-level statistics into **contest-level statistics**.

---

# Step 8 — JOIN With `CONTESTS`

Finally, we need the contest information:

```sql
FROM CONTESTS C
JOIN COMBINE_TABLE CT
    ON C.CONTEST_ID = CT.CONTEST_ID
```

This combines:

### `CONTESTS`

| CONTEST_ID | HACKER_ID | NAME |
|---:|---:|---|
| 1 | 100 | Contest A |

### `COMBINE_TABLE`

| CONTEST_ID | TS | TAS | TV | TUV |
|---:|---:|---:|---:|---:|
| 1 | 250 | 100 | 1100 | 920 |

After the JOIN:

| CONTEST_ID | HACKER_ID | NAME | TS | TAS | TV | TUV |
|---:|---:|---|---:|---:|---:|---:|
| 1 | 100 | Contest A | 250 | 100 | 1100 | 920 |

---

# Step 9 — Remove Contests With No Activity

The final filter is:

```sql
WHERE CT.TS > 0
   OR CT.TAS > 0
   OR CT.TUV > 0
   OR CT.TV > 0
```

This means a contest is included if **at least one** of these values is greater than zero:

```text
Total Submissions
        OR
Total Accepted Submissions
        OR
Total Views
        OR
Total Unique Views
```

A contest with:

| TS | TAS | TV | TUV |
|---:|---:|---:|---:|
| 0 | 0 | 0 | 0 |

is excluded.

---

# Complete Transformation

The entire query can be visualized as:

```text
VIEW_STATS
     │
     │ GROUP BY CHALLENGE_ID
     ↓
NEW_VIEW_STATS
     │
     │
     ├──────────────────┐
     │                  │
     ↓                  ↓
CHALLENGES ────────→ NEW_SUBMISSION_STATS
     │
     │ JOIN COLLEGES
     ↓
CHALLENGES + CONTEST
     │
     │ LEFT JOIN VIEW_STATS
     │ LEFT JOIN SUBMISSION_STATS
     ↓
COMBINE_TABLE
     │
     │ GROUP BY CONTEST_ID
     ↓
CONTEST-LEVEL TOTALS
     │
     │ JOIN CONTESTS
     ↓
FINAL RESULT
```

---

# Key SQL Concepts

### 1. CTE

Three CTEs are used:

```text
NEW_VIEW_STATS
        ↓
NEW_SUBMISSION_STATS
        ↓
COMBINE_TABLE
```

Each CTE creates an intermediate result that is used by the next stage.

### 2. `GROUP BY`

Used to aggregate:

```sql
GROUP BY CHALLENGE_ID
```

and later:

```sql
GROUP BY CONTEST_ID
```

### 3. `LEFT JOIN`

Used for statistics because a challenge may not have statistics.

### 4. `COALESCE`

Converts missing values:

```text
NULL → 0
```

### 5. Multiple JOINs

The data follows:

```text
CONTEST
   ↓
COLLEGE
   ↓
CHALLENGE
   ↓
STATISTICS
```

and the query aggregates the data back upward:

```text
STATISTICS
   ↓
CHALLENGE
   ↓
CONTEST
```

---

## Solution

The complete SQL solution is available in [`01_Interviews.sql`](./01_Interviews.sql).
