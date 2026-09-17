# Top Competitors

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** CTEs, Window Functions, Partitioning, Ranking, Aggregation, Grouping, Filtering

---

## Problem

You are given a `SUBMISSIONS` table containing scores achieved by hackers on different challenges.

A hacker may submit multiple times for the same challenge.

For each hacker:

1. Find their **highest score for every challenge**.
2. Add those highest scores together to calculate their **total score**.
3. Return the hacker's ID, name, and total score.
4. Exclude hackers whose total score is 0.
5. Sort by:
   - Total score descending
   - Hacker ID ascending when scores are tied

The important idea is:

> We must first find the best score for each hacker on each challenge before calculating their overall score.

---

# Given Tables

## `SUBMISSIONS`

Consider this simplified table:

| HACKER_ID | CHALLENGE_ID | SCORE |
|---:|---:|---:|
| 101 | 1 | 50 |
| 101 | 1 | 80 |
| 101 | 1 | 70 |
| 101 | 2 | 60 |
| 101 | 2 | 90 |
| 102 | 1 | 75 |
| 102 | 1 | 65 |
| 102 | 2 | 40 |
| 103 | 1 | 100 |
| 103 | 2 | 30 |
| 103 | 2 | 50 |

---

## `HACKERS`

| HACKER_ID | NAME |
|---:|---|
| 101 | Alice |
| 102 | Bob |
| 103 | Charlie |

---

# Step 1 — Start With the Submissions

A hacker can submit multiple times for the same challenge.

For example, Alice has submitted three times for Challenge 1:

```text
Alice
Challenge 1
    │
    ├── 50
    ├── 80
    └── 70
```

We do **not** want to add all three scores.

We only want:

```text
MAX(50, 80, 70) = 80
```

Similarly, for Challenge 2:

```text
60
90
 ↓
90
```

So Alice's eventual score should be:

```text
Challenge 1 → 80
Challenge 2 → 90
```

Total:

```text
80 + 90 = 170
```

---

# Step 2 — Create the `MAX_SCORE` CTE

The first CTE is:

```sql id="g1g56f"
WITH MAX_SCORE AS (
    SELECT
        HACKER_ID,
        CHALLENGE_ID,
        SCORE,
        ROW_NUMBER() OVER (
            PARTITION BY HACKER_ID, CHALLENGE_ID
            ORDER BY SCORE DESC
        ) AS RN
    FROM SUBMISSIONS
)
```

The purpose of this CTE is to rank every submission for each:

```text
HACKER_ID + CHALLENGE_ID
```

combination.

---

# Step 3 — Partition by Hacker and Challenge

The query uses:

```sql id="pvj8ma"
PARTITION BY HACKER_ID, CHALLENGE_ID
```

This creates a separate group for every hacker/challenge combination.

For example:

```text id="8g9x6m"
Alice + Challenge 1
    ├── 50
    ├── 80
    └── 70

Alice + Challenge 2
    ├── 60
    └── 90

Bob + Challenge 1
    ├── 75
    └── 65

Bob + Challenge 2
    └── 40

Charlie + Challenge 1
    └── 100

Charlie + Challenge 2
    ├── 30
    └── 50
```

This is important because we want the maximum score **inside each group**, not the maximum score across the entire table.

---

# Step 4 — Sort Scores Within Each Group

The query uses:

```sql id="m51a4x"
ORDER BY SCORE DESC
```

Inside every partition, the highest score comes first.

For Alice + Challenge 1:

Before:

| SCORE |
|---:|
| 50 |
| 80 |
| 70 |

After descending order:

| SCORE | RN |
|---:|---:|
| 80 | 1 |
| 70 | 2 |
| 50 | 3 |

The highest score receives:

```text
RN = 1
```

---

# Step 5 — Result of `MAX_SCORE`

Let's apply the same logic to every hacker/challenge group.

### Alice — Challenge 1

| SCORE | RN |
|---:|---:|
| 80 | 1 |
| 70 | 2 |
| 50 | 3 |

### Alice — Challenge 2

| SCORE | RN |
|---:|---:|
| 90 | 1 |
| 60 | 2 |

### Bob — Challenge 1

| SCORE | RN |
|---:|---:|
| 75 | 1 |
| 65 | 2 |

### Bob — Challenge 2

| SCORE | RN |
|---:|---:|
| 40 | 1 |

### Charlie — Challenge 1

| SCORE | RN |
|---:|---:|
| 100 | 1 |

### Charlie — Challenge 2

| SCORE | RN |
|---:|---:|
| 50 | 1 |
| 30 | 2 |

The complete `MAX_SCORE` result is:

| HACKER_ID | CHALLENGE_ID | SCORE | RN |
|---:|---:|---:|---:|
| 101 | 1 | 80 | 1 |
| 101 | 1 | 70 | 2 |
| 101 | 1 | 50 | 3 |
| 101 | 2 | 90 | 1 |
| 101 | 2 | 60 | 2 |
| 102 | 1 | 75 | 1 |
| 102 | 1 | 65 | 2 |
| 102 | 2 | 40 | 1 |
| 103 | 1 | 100 | 1 |
| 103 | 2 | 50 | 1 |
| 103 | 2 | 30 | 2 |

---

# Step 6 — Keep Only `RN = 1`

The second CTE contains:

```sql id="4k4ovb"
FROM MAX_SCORE
WHERE RN = 1
```

Since the highest score in each group receives `RN = 1`, this removes all lower submissions.

Before:

| HACKER_ID | CHALLENGE_ID | SCORE | RN |
|---:|---:|---:|---:|
| 101 | 1 | 80 | 1 |
| 101 | 1 | 70 | 2 |
| 101 | 1 | 50 | 3 |
| 101 | 2 | 90 | 1 |
| 101 | 2 | 60 | 2 |
| 102 | 1 | 75 | 1 |
| 102 | 1 | 65 | 2 |
| 102 | 2 | 40 | 1 |
| 103 | 1 | 100 | 1 |
| 103 | 2 | 50 | 1 |
| 103 | 2 | 30 | 2 |

After `RN = 1`:

| HACKER_ID | CHALLENGE_ID | SCORE |
|---:|---:|---:|
| 101 | 1 | 80 |
| 101 | 2 | 90 |
| 102 | 1 | 75 |
| 102 | 2 | 40 |
| 103 | 1 | 100 |
| 103 | 2 | 50 |

Now every hacker has **at most one score per challenge**.

This is the critical transformation.

---

# Step 7 — Create `SUM_SCORE`

The second CTE is:

```sql id="v1cxlo"
SUM_SCORE AS (
    SELECT
        HACKER_ID,
        SUM(SCORE) AS FINAL_SCORE
    FROM MAX_SCORE
    WHERE RN = 1
    GROUP BY HACKER_ID
)
```

Now we group by hacker:

```sql id="8h6lcp"
GROUP BY HACKER_ID
```

and add their best score from each challenge.

---

# Step 8 — Calculate Alice's Total

Alice has:

| CHALLENGE_ID | Best Score |
|---:|---:|
| 1 | 80 |
| 2 | 90 |

Therefore:

```text id="0bbz6j"
80 + 90 = 170
```

Alice's final score:

```text
170
```

---

# Step 9 — Calculate Bob's Total

Bob has:

| CHALLENGE_ID | Best Score |
|---:|---:|
| 1 | 75 |
| 2 | 40 |

Therefore:

```text id="i5z8cu"
75 + 40 = 115
```

Bob's final score:

```text
115
```

---

# Step 10 — Calculate Charlie's Total

Charlie has:

| CHALLENGE_ID | Best Score |
|---:|---:|
| 1 | 100 |
| 2 | 50 |

Therefore:

```text id="zx42k7"
100 + 50 = 150
```

Charlie's final score:

```text
150
```

---

# Step 11 — Result of `SUM_SCORE`

The second CTE produces:

| HACKER_ID | FINAL_SCORE |
|---:|---:|
| 101 | 170 |
| 102 | 115 |
| 103 | 150 |

Notice the transformation:

```text
Multiple submissions
        ↓
Best score per challenge
        ↓
One score per challenge
        ↓
SUM
        ↓
One total score per hacker
```

---

# Step 12 — Join With `HACKERS`

The final query uses:

```sql id="0w1oz0"
JOIN SUM_SCORE SS
    ON H.HACKER_ID = SS.HACKER_ID
```

`SUM_SCORE` contains the scores, while `HACKERS` contains the names.

Before the JOIN:

### `HACKERS`

| HACKER_ID | NAME |
|---:|---|
| 101 | Alice |
| 102 | Bob |
| 103 | Charlie |

### `SUM_SCORE`

| HACKER_ID | FINAL_SCORE |
|---:|---:|
| 101 | 170 |
| 102 | 115 |
| 103 | 150 |

After the JOIN:

| HACKER_ID | NAME | FINAL_SCORE |
|---:|---|---:|
| 101 | Alice | 170 |
| 102 | Bob | 115 |
| 103 | Charlie | 150 |

---

# Step 13 — Remove Zero Scores

The query contains:

```sql id="yp42lc"
WHERE SS.FINAL_SCORE > 0
```

This removes hackers whose total score is zero.

For example, if we had:

| HACKER_ID | NAME | FINAL_SCORE |
|---:|---|---:|
| 101 | Alice | 170 |
| 102 | Bob | 115 |
| 103 | Charlie | 150 |
| 104 | David | 0 |

David would be removed because:

```text
0 > 0 → False
```

Our example has no zero-score hacker, so nothing is removed.

---

# Step 14 — Final Ordering

The query uses:

```sql id="5g7n1n"
ORDER BY
    SS.FINAL_SCORE DESC,
    H.HACKER_ID
```

First, sort by total score descending:

```text
170
150
115
```

So:

| HACKER_ID | NAME | FINAL_SCORE |
|---:|---|---:|
| 101 | Alice | 170 |
| 103 | Charlie | 150 |
| 102 | Bob | 115 |

If two hackers have the same score, `HACKER_ID` determines their order.

For example:

| HACKER_ID | NAME | FINAL_SCORE |
|---:|---|---:|
| 105 | Emma | 200 |
| 102 | Bob | 200 |
| 101 | Alice | 170 |

After sorting:

| HACKER_ID | NAME | FINAL_SCORE |
|---:|---|---:|
| 102 | Bob | 200 |
| 105 | Emma | 200 |
| 101 | Alice | 170 |

because:

```text
102 < 105
```

---

# Final Result

For our simplified dataset:

| HACKER_ID | NAME | FINAL_SCORE |
|---:|---|---:|
| 101 | Alice | 170 |
| 103 | Charlie | 150 |
| 102 | Bob | 115 |

---

# Complete Transformation Flow

```text id="gohs6v"
                    SUBMISSIONS
                         │
                         ▼
              Group by Hacker + Challenge
                         │
                         ▼
                Sort SCORE DESC
                         │
                         ▼
                  Assign RN
                         │
                         ▼
                    RN = 1
                         │
                         ▼
             Highest score per challenge
                         │
                         ▼
                   MAX_SCORE
                         │
                         ▼
                Group by HACKER_ID
                         │
                         ▼
                    SUM(SCORE)
                         │
                         ▼
                   SUM_SCORE
                         │
                         ▼
                  JOIN HACKERS
                         │
                         ▼
                    Add NAME
                         │
                         ▼
              FINAL_SCORE > 0
                         │
                         ▼
               Sort SCORE DESC
                         │
                         ▼
               HACKER_ID ASC
                         │
                         ▼
                   FINAL RESULT
```

---

# CTE Transformation Summary

## `MAX_SCORE`

Purpose:

> Keep the highest score for every hacker on every challenge.

Transformation:

```text id="pkv9ud"
SUBMISSIONS
     ↓
PARTITION BY HACKER_ID + CHALLENGE_ID
     ↓
Sort scores DESC
     ↓
Assign row numbers
     ↓
RN = 1
     ↓
Best score for each challenge
```

Example:

| HACKER_ID | CHALLENGE_ID | SCORE | RN |
|---:|---:|---:|---:|
| 101 | 1 | 80 | 1 |
| 101 | 1 | 70 | 2 |
| 101 | 1 | 50 | 3 |
| 101 | 2 | 90 | 1 |
| 101 | 2 | 60 | 2 |

After `RN = 1`:

| HACKER_ID | CHALLENGE_ID | SCORE |
|---:|---:|---:|
| 101 | 1 | 80 |
| 101 | 2 | 90 |

---

## `SUM_SCORE`

Purpose:

> Add each hacker's best scores across all challenges.

Transformation:

```text id="g9q0fm"
Best score per challenge
        ↓
GROUP BY HACKER_ID
        ↓
SUM scores
        ↓
Final score per hacker
```

Example:

| HACKER_ID | Best Scores | FINAL_SCORE |
|---:|---|---:|
| 101 | 80 + 90 | 170 |
| 102 | 75 + 40 | 115 |
| 103 | 100 + 50 | 150 |

---

# Why We Cannot Directly Use `SUM(SCORE)`

Suppose Alice has:

| CHALLENGE_ID | SCORE |
|---:|---:|
| 1 | 50 |
| 1 | 80 |
| 1 | 70 |
| 2 | 60 |
| 2 | 90 |

If we simply calculate:

```sql
SUM(SCORE)
```

we would get:

```text
50 + 80 + 70 + 60 + 90 = 350
```

But that is incorrect.

We need:

```text
Challenge 1 → MAX(50,80,70) = 80
Challenge 2 → MAX(60,90) = 90

80 + 90 = 170
```

That's why the query has **two stages**:

```text
Stage 1:
Find maximum score per hacker + challenge

Stage 2:
Sum those maximum scores per hacker
```

---

# Why `PARTITION BY HACKER_ID, CHALLENGE_ID`?

We need to find the best score **for each hacker on each challenge**.

Therefore both columns are required.

If we partitioned only by:

```sql id="r5h8cw"
PARTITION BY HACKER_ID
```

we would find only the highest score that a hacker achieved across **all challenges**.

That would lose the separate challenge scores.

For example:

```text id="5v94a1"
Alice:
Challenge 1 → 80
Challenge 2 → 90
```

We need both 80 and 90.

Therefore:

```text id="k1u6un"
PARTITION BY HACKER_ID, CHALLENGE_ID
```

creates:

```text
Alice + Challenge 1 → rank separately
Alice + Challenge 2 → rank separately
```

---

# Key SQL Concepts

- Common Table Expressions
- Window-based ranking
- Partitioning data by multiple columns
- Selecting the top row from each group
- Multi-stage aggregation
- Grouping by an entity
- Joining aggregated results
- Filtering final results
- Multi-level sorting

---

# Final Transformation

```text id="m4fsnq"
SUBMISSIONS
    ↓
Separate each Hacker + Challenge combination
    ↓
Rank scores from highest to lowest
    ↓
Keep RN = 1
    ↓
Best score for each challenge
    ↓
Group by Hacker
    ↓
Add all best challenge scores
    ↓
FINAL_SCORE
    ↓
JOIN HACKERS
    ↓
Get hacker name
    ↓
Remove FINAL_SCORE = 0
    ↓
Sort by FINAL_SCORE DESC
    ↓
Break ties using HACKER_ID ASC
    ↓
Final HACKER_ID + NAME + FINAL_SCORE
```

**Corresponding SQL:** `12_Top_Competitors.sql`