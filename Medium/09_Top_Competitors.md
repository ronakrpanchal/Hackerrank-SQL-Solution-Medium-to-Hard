# Top Competitors

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Multiple Table Joins, CTEs, Conditional Logic, Aggregation, Filtering, Custom Sorting

---

## Problem

You are given information about:

- Hackers
- Challenges
- Difficulty levels
- Submissions

The goal is to find hackers who achieved a **full score on more than one challenge**.

A hacker receives a full score when their submission score is equal to the maximum score available for that challenge's difficulty level.

The final output should contain:

- `HACKER_ID`
- `NAME`

The results must be ordered by:

1. Number of full-score challenges in descending order
2. `HACKER_ID` in ascending order when the full-score count is tied

---

# Tables

We will use small example tables to understand the transformations.

## `HACKERS`

| HACKER_ID | NAME |
|---:|---|
| 101 | Alice |
| 102 | Bob |
| 103 | Charlie |

---

## `CHALLENGES`

| CHALLENGE_ID | DIFFICULTY_LEVEL |
|---:|---|
| 1 | Easy |
| 2 | Medium |
| 3 | Hard |
| 4 | Easy |

---

## `DIFFICULTY`

| DIFFICULTY_LEVEL | SCORE |
|---|---:|
| Easy | 10 |
| Medium | 20 |
| Hard | 30 |

The `SCORE` here represents the **maximum possible score** for a challenge at that difficulty level.

---

## `SUBMISSIONS`

| HACKER_ID | CHALLENGE_ID | SCORE |
|---:|---:|---:|
| 101 | 1 | 10 |
| 101 | 2 | 20 |
| 101 | 3 | 25 |
| 102 | 1 | 10 |
| 102 | 2 | 15 |
| 103 | 3 | 30 |
| 103 | 4 | 10 |

---

# Step 1 — Start With `SUBMISSIONS`

The `SUBMISSIONS` table tells us:

```text
Which hacker
    ↓
submitted to which challenge
    ↓
and what score they received
```

For example:

| HACKER_ID | CHALLENGE_ID | SCORE |
|---:|---:|---:|
| 101 | 1 | 10 |
| 101 | 2 | 20 |
| 101 | 3 | 25 |

But at this point, we don't know whether each score is a **full score**.

We need information from the other tables.

---

# Step 2 — Join `HACKERS`

The first JOIN is:

```sql
JOIN HACKERS H
    ON S.HACKER_ID = H.HACKER_ID
```

This connects each submission to the hacker's name.

Before:

| HACKER_ID | CHALLENGE_ID | SCORE |
|---:|---:|---:|
| 101 | 1 | 10 |
| 101 | 2 | 20 |
| 101 | 3 | 25 |
| 102 | 1 | 10 |
| 102 | 2 | 15 |
| 103 | 3 | 30 |
| 103 | 4 | 10 |

After adding the name:

| HACKER_ID | NAME | CHALLENGE_ID | SCORE |
|---:|---|---:|---:|
| 101 | Alice | 1 | 10 |
| 101 | Alice | 2 | 20 |
| 101 | Alice | 3 | 25 |
| 102 | Bob | 1 | 10 |
| 102 | Bob | 2 | 15 |
| 103 | Charlie | 3 | 30 |
| 103 | Charlie | 4 | 10 |

Now every submission is associated with its hacker.

---

# Step 3 — Join `CHALLENGES`

The next JOIN is:

```sql
JOIN CHALLENGES C
    ON S.CHALLENGE_ID = C.CHALLENGE_ID
```

This tells us the difficulty level of each challenge.

For example:

```text
Challenge 1 → Easy
Challenge 2 → Medium
Challenge 3 → Hard
Challenge 4 → Easy
```

The table becomes:

| HACKER_ID | NAME | CHALLENGE_ID | SCORE | DIFFICULTY_LEVEL |
|---:|---|---:|---:|---|
| 101 | Alice | 1 | 10 | Easy |
| 101 | Alice | 2 | 20 | Medium |
| 101 | Alice | 3 | 25 | Hard |
| 102 | Bob | 1 | 10 | Easy |
| 102 | Bob | 2 | 15 | Medium |
| 103 | Charlie | 3 | 30 | Hard |
| 103 | Charlie | 4 | 10 | Easy |

Now we know which difficulty applies to every submission.

---

# Step 4 — Join `DIFFICULTY`

The final JOIN inside the first CTE is:

```sql
JOIN DIFFICULTY D
    ON D.DIFFICULTY_LEVEL = C.DIFFICULTY_LEVEL
```

This gives us the **maximum possible score** for each difficulty.

From the `DIFFICULTY` table:

| DIFFICULTY_LEVEL | MAX SCORE |
|---|---:|
| Easy | 10 |
| Medium | 20 |
| Hard | 30 |

The query selects:

```sql
D.SCORE AS MAX_SCORE
```

So our combined table becomes:

| HACKER_ID | NAME | CHALLENGE_ID | SCORE | MAX_SCORE |
|---:|---|---:|---:|---:|
| 101 | Alice | 1 | 10 | 10 |
| 101 | Alice | 2 | 20 | 20 |
| 101 | Alice | 3 | 25 | 30 |
| 102 | Bob | 1 | 10 | 10 |
| 102 | Bob | 2 | 15 | 20 |
| 103 | Charlie | 3 | 30 | 30 |
| 103 | Charlie | 4 | 10 | 10 |

This is the result of:

```text
SUBMISSIONS
      │
      ├── HACKERS
      │
      ├── CHALLENGES
      │
      └── DIFFICULTY
      │
      ▼
COMBINED_TABLE
```

---

# Step 5 — Determine Full-Score Submissions

Now we need to determine whether each submission received the maximum possible score.

The condition is:

```sql
SCORE = MAX_SCORE
```

For example:

| HACKER | SCORE | MAX_SCORE | Full Score? |
|---|---:|---:|---|
| Alice | 10 | 10 | Yes |
| Alice | 20 | 20 | Yes |
| Alice | 25 | 30 | No |
| Bob | 10 | 10 | Yes |
| Bob | 15 | 20 | No |
| Charlie | 30 | 30 | Yes |
| Charlie | 10 | 10 | Yes |

So:

```text
Alice   → 2 full scores
Bob     → 1 full score
Charlie → 2 full scores
```

But we still need SQL to calculate this.

---

# Step 6 — Create `COMBINED_TABLE_2`

The second CTE is:

```sql
SELECT
    HACKER_ID,
    NAME,
    SUM(
        CASE
            WHEN SCORE = MAX_SCORE THEN 1
            ELSE 0
        END
    ) AS FULL_SCORE
FROM COMBINED_TABLE
GROUP BY HACKER_ID, NAME
```

There are two important operations here:

1. Determine whether each submission is a full score.
2. Add those full-score indicators for each hacker.

---

# Step 7 — `CASE` Creates a Full-Score Indicator

The query uses:

```sql
CASE
    WHEN SCORE = MAX_SCORE THEN 1
    ELSE 0
END
```

Think of this as converting every submission into:

```text
Full score → 1
Not full score → 0
```

Our table becomes conceptually:

| HACKER | SCORE | MAX_SCORE | Indicator |
|---|---:|---:|---:|
| Alice | 10 | 10 | 1 |
| Alice | 20 | 20 | 1 |
| Alice | 25 | 30 | 0 |
| Bob | 10 | 10 | 1 |
| Bob | 15 | 20 | 0 |
| Charlie | 30 | 30 | 1 |
| Charlie | 10 | 10 | 1 |

---

# Step 8 — Group by Hacker

The query uses:

```sql
GROUP BY HACKER_ID, NAME
```

This puts all submissions belonging to the same hacker into one group.

Conceptually:

```text
Alice
 ├── 1
 ├── 1
 └── 0

Bob
 ├── 1
 └── 0

Charlie
 ├── 1
 └── 1
```

---

# Step 9 — Add the Indicators

Now:

```sql
SUM(...)
```

adds the `1`s and `0`s for every hacker.

### Alice

```text
1 + 1 + 0 = 2
```

### Bob

```text
1 + 0 = 1
```

### Charlie

```text
1 + 1 = 2
```

Therefore `COMBINED_TABLE_2` becomes:

| HACKER_ID | NAME | FULL_SCORE |
|---:|---|---:|
| 101 | Alice | 2 |
| 102 | Bob | 1 |
| 103 | Charlie | 2 |

This CTE has transformed many submission rows into **one row per hacker**.

---

# Step 10 — Keep Hackers With More Than One Full Score

The final query uses:

```sql
WHERE FULL_SCORE > 1
```

Our table:

| HACKER_ID | NAME | FULL_SCORE |
|---:|---|---:|
| 101 | Alice | 2 |
| 102 | Bob | 1 |
| 103 | Charlie | 2 |

Apply:

```text
FULL_SCORE > 1
```

Bob is removed because:

```text
1 > 1 → False
```

Alice stays:

```text
2 > 1 → True
```

Charlie stays:

```text
2 > 1 → True
```

Result:

| HACKER_ID | NAME | FULL_SCORE |
|---:|---|---:|
| 101 | Alice | 2 |
| 103 | Charlie | 2 |

---

# Step 11 — Sort the Final Result

The query uses:

```sql
ORDER BY
    FULL_SCORE DESC,
    HACKER_ID ASC
```

First:

```text
FULL_SCORE DESC
```

puts hackers with more full scores first.

Then:

```text
HACKER_ID ASC
```

breaks ties by smaller hacker ID.

For example:

| HACKER_ID | NAME | FULL_SCORE |
|---:|---|---:|
| 103 | Charlie | 3 |
| 101 | Alice | 2 |
| 102 | Bob | 2 |

After sorting:

| HACKER_ID | NAME | FULL_SCORE |
|---:|---|---:|
| 103 | Charlie | 3 |
| 101 | Alice | 2 |
| 102 | Bob | 2 |

Among hackers with the same full-score count, the smaller `HACKER_ID` comes first.

---

# Final Result

For our simplified data:

| HACKER_ID | NAME |
|---:|---|
| 101 | Alice |
| 103 | Charlie |

The actual HackerRank dataset determines the real final output.

---

# Complete Transformation Flow

```text
                         SUBMISSIONS
                              │
               ┌──────────────┼──────────────┐
               │              │              │
               ▼              ▼              ▼
           HACKERS        CHALLENGES      DIFFICULTY
               │              │              │
               │              │              │
               └──────┬───────┴───────┬──────┘
                      │
                      ▼
               COMBINED_TABLE
                      │
                      ▼
        ┌───────────────────────────────┐
        │ HACKER_ID                     │
        │ NAME                          │
        │ CHALLENGE_ID                  │
        │ SCORE                         │
        │ MAX_SCORE                     │
        └───────────────────────────────┘
                      │
                      ▼
             SCORE = MAX_SCORE?
                 /          \
               YES           NO
                │             │
                ▼             ▼
                1             0
                 \           /
                  \         /
                   ▼       ▼
             GROUP BY HACKER
                      │
                      ▼
                 SUM(1 / 0)
                      │
                      ▼
             COMBINED_TABLE_2
                      │
                      ▼
              FULL_SCORE > 1
                      │
                      ▼
                ORDER BY
            score DESC, ID ASC
                      │
                      ▼
                 FINAL RESULT
```

---

# CTE Transformation Summary

## `COMBINED_TABLE`

Purpose:

> Bring together all information needed to determine whether each submission achieved full marks.

Input:

```text
SUBMISSIONS
HACKERS
CHALLENGES
DIFFICULTY
```

Output:

| HACKER_ID | NAME | CHALLENGE_ID | SCORE | MAX_SCORE |
|---:|---|---:|---:|---:|
| 101 | Alice | 1 | 10 | 10 |
| 101 | Alice | 2 | 20 | 20 |
| 101 | Alice | 3 | 25 | 30 |
| 102 | Bob | 1 | 10 | 10 |
| 102 | Bob | 2 | 15 | 20 |
| 103 | Charlie | 3 | 30 | 30 |
| 103 | Charlie | 4 | 10 | 10 |

---

## `COMBINED_TABLE_2`

Purpose:

> Count how many full-score submissions each hacker has.

Transformation:

```text
SCORE = MAX_SCORE
       ↓
    1 or 0
       ↓
GROUP BY HACKER
       ↓
SUM
       ↓
FULL_SCORE
```

Output:

| HACKER_ID | NAME | FULL_SCORE |
|---:|---|---:|
| 101 | Alice | 2 |
| 102 | Bob | 1 |
| 103 | Charlie | 2 |

---

## Final Query

```text
FULL_SCORE > 1
       ↓
Remove hackers with only 1 full score
       ↓
ORDER BY FULL_SCORE DESC
       ↓
Break ties using HACKER_ID ASC
       ↓
Final HACKER_ID + NAME
```

---

# Key SQL Concepts

- Combining multiple related tables
- Range-independent relational joins
- Common Table Expressions
- Conditional counting through aggregation
- Grouping rows into entities
- Filtering aggregated results
- Multi-level sorting
- Building complex queries step by step

---

# Final Transformation

```text
SUBMISSIONS
    ↓
Attach hacker names
    ↓
Attach challenge difficulty
    ↓
Attach maximum possible score
    ↓
Compare submission score with maximum score
    ↓
Convert full score → 1
Convert non-full score → 0
    ↓
Group by hacker
    ↓
Sum full-score indicators
    ↓
Keep hackers with FULL_SCORE > 1
    ↓
Sort by FULL_SCORE DESC
    ↓
Break ties using HACKER_ID ASC
    ↓
Final HACKER_ID + NAME
```

**Corresponding SQL:** `09_Challenges.sql`