# Challenges

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** CTEs, Aggregation, Window Functions, Grouping, Subqueries, Conditional Filtering

---

## Problem

You are given a `CHALLENGES` table containing challenges created by hackers.

The goal is to find hackers who satisfy **either** of these conditions:

1. They created the **maximum number of challenges**.
2. Their number of challenges is **unique**, meaning no other hacker created the same number of challenges.

The final output should contain:

- `HACKER_ID`
- `NAME`
- Number of challenges created

The result should be ordered by:

1. Number of challenges in descending order
2. `HACKER_ID` in ascending order

---

# Given Tables

## `HACKERS`

| HACKER_ID | NAME |
|---:|---|
| 101 | Alice |
| 102 | Bob |
| 103 | Charlie |
| 104 | David |
| 105 | Emma |

---

## `CHALLENGES`

Consider this simplified data:

| CHALLENGE_ID | HACKER_ID |
|---:|---:|
| 1 | 101 |
| 2 | 101 |
| 3 | 101 |
| 4 | 101 |
| 5 | 101 |
| 6 | 102 |
| 7 | 102 |
| 8 | 102 |
| 9 | 103 |
| 10 | 103 |
| 11 | 104 |
| 12 | 104 |
| 13 | 104 |
| 14 | 104 |
| 15 | 105 |

From this data:

```text
Alice   → 5 challenges
Bob     → 3 challenges
Charlie → 2 challenges
David   → 4 challenges
Emma    → 1 challenge
```

---

# Step 1 — Count Challenges for Each Hacker

The first CTE is:

```sql
WITH NO_OF_CHALLENGE AS (
    SELECT
        HACKER_ID,
        COUNT(CHALLENGE_ID) AS NUM_OF_CHALLENGE
    FROM CHALLENGES
    GROUP BY HACKER_ID
)
```

The important part is:

```sql
GROUP BY HACKER_ID
```

This creates one group for each hacker.

Then:

```sql
COUNT(CHALLENGE_ID)
```

counts the challenges inside each group.

---

# Step 2 — Transform `CHALLENGES`

Starting table:

| CHALLENGE_ID | HACKER_ID |
|---:|---:|
| 1 | 101 |
| 2 | 101 |
| 3 | 101 |
| 4 | 101 |
| 5 | 101 |
| 6 | 102 |
| 7 | 102 |
| 8 | 102 |
| 9 | 103 |
| 10 | 103 |
| 11 | 104 |
| 12 | 104 |
| 13 | 104 |
| 14 | 104 |
| 15 | 105 |

Group by `HACKER_ID`.

Conceptually:

```text
101 → 5 rows
102 → 3 rows
103 → 2 rows
104 → 4 rows
105 → 1 row
```

After the aggregation:

| HACKER_ID | NUM_OF_CHALLENGE |
|---:|---:|
| 101 | 5 |
| 102 | 3 |
| 103 | 2 |
| 104 | 4 |
| 105 | 1 |

This is the result of:

```text
NO_OF_CHALLENGE
```

---

# Step 3 — Create the Second CTE

The second CTE is:

```sql
COUNT_HACKER AS (
    SELECT
        HACKER_ID,
        NUM_OF_CHALLENGE,
        COUNT(*) OVER (
            PARTITION BY NUM_OF_CHALLENGE
        ) AS HACKER_COUNT
    FROM NO_OF_CHALLENGE
)
```

Now we have a different question:

> How many hackers have the same challenge count?

For example:

```text
5 challenges → 1 hacker
4 challenges → 1 hacker
3 challenges → 1 hacker
2 challenges → 1 hacker
1 challenge  → 1 hacker
```

---

# Step 4 — Partition by Challenge Count

The query uses:

```sql
COUNT(*) OVER (
    PARTITION BY NUM_OF_CHALLENGE
)
```

The important thing is that we are **not partitioning by `HACKER_ID`**.

We are partitioning by:

```text
NUM_OF_CHALLENGE
```

That means hackers with the same challenge count are put into the same group.

For example, if our data were:

| HACKER_ID | NUM_OF_CHALLENGE |
|---:|---:|
| 101 | 5 |
| 102 | 3 |
| 103 | 3 |
| 104 | 4 |
| 105 | 1 |

Then the partitioning would conceptually create:

```text
5 challenges
└── Hacker 101

4 challenges
└── Hacker 104

3 challenges
├── Hacker 102
└── Hacker 103

1 challenge
└── Hacker 105
```

Therefore:

```text
5 → HACKER_COUNT = 1
4 → HACKER_COUNT = 1
3 → HACKER_COUNT = 2
1 → HACKER_COUNT = 1
```

---

# Step 5 — Result of `COUNT_HACKER`

Using our original example where every count is unique:

| HACKER_ID | NUM_OF_CHALLENGE | HACKER_COUNT |
|---:|---:|---:|
| 101 | 5 | 1 |
| 102 | 3 | 1 |
| 103 | 2 | 1 |
| 104 | 4 | 1 |
| 105 | 1 | 1 |

The new column:

```text
HACKER_COUNT
```

tells us how many hackers have that particular challenge count.

---

# Step 6 — Find the Maximum Challenge Count

The final query contains:

```sql
C.NUM_OF_CHALLENGE = (
    SELECT MAX(NUM_OF_CHALLENGE)
    FROM NO_OF_CHALLENGE
)
```

The subquery:

```sql
SELECT MAX(NUM_OF_CHALLENGE)
FROM NO_OF_CHALLENGE
```

looks at:

| HACKER_ID | NUM_OF_CHALLENGE |
|---:|---:|
| 101 | 5 |
| 102 | 3 |
| 103 | 2 |
| 104 | 4 |
| 105 | 1 |

and finds:

```text
MAX = 5
```

So one condition becomes:

```text
NUM_OF_CHALLENGE = 5
```

Alice qualifies because she created 5 challenges.

---

# Step 7 — Find Unique Challenge Counts

The other condition is:

```sql
C.HACKER_COUNT = 1
```

Remember what `HACKER_COUNT` represents:

```text
Number of hackers having the same challenge count
```

Therefore:

```text
HACKER_COUNT = 1
```

means:

> Only one hacker has this number of challenges.

For our example:

| HACKER_ID | CHALLENGES | HACKER_COUNT | Unique? |
|---:|---:|---:|---|
| 101 | 5 | 1 | Yes |
| 102 | 3 | 1 | Yes |
| 103 | 2 | 1 | Yes |
| 104 | 4 | 1 | Yes |
| 105 | 1 | 1 | Yes |

Every hacker qualifies because every challenge count is unique.

---

# Step 8 — Why the `OR` Is Important

The final condition is:

```sql
WHERE C.NUM_OF_CHALLENGE = (
    SELECT MAX(NUM_OF_CHALLENGE)
    FROM NO_OF_CHALLENGE
)
OR C.HACKER_COUNT = 1
```

There are two possible ways for a hacker to qualify:

```text
                    Hacker
                      │
             ┌────────┴────────┐
             ▼                 ▼
       Maximum count?     Unique count?
             │                 │
            YES               YES
             │                 │
             └────────┬────────┘
                      ▼
                   INCLUDE
```

So a hacker is included if **either** condition is true.

---

# Important Example — When Counts Are Repeated

Let's modify the data:

| HACKER_ID | NUM_OF_CHALLENGE |
|---:|---:|
| 101 | 5 |
| 102 | 3 |
| 103 | 3 |
| 104 | 4 |
| 105 | 1 |

Now:

```text
Maximum challenge count = 5
```

And the challenge-count frequencies are:

| NUM_OF_CHALLENGE | HACKER_COUNT |
|---:|---:|
| 5 | 1 |
| 4 | 1 |
| 3 | 2 |
| 1 | 1 |

Now evaluate each hacker:

| HACKER_ID | Challenges | Count Frequency | Maximum? | Unique? | Included? |
|---:|---:|---:|---|---|---|
| 101 | 5 | 1 | Yes | Yes | Yes |
| 102 | 3 | 2 | No | No | No |
| 103 | 3 | 2 | No | No | No |
| 104 | 4 | 1 | No | Yes | Yes |
| 105 | 1 | 1 | No | Yes | Yes |

Final qualifying hackers:

| HACKER_ID | NUM_OF_CHALLENGE |
|---:|---:|
| 101 | 5 |
| 104 | 4 |
| 105 | 1 |

This demonstrates exactly why both conditions are needed.

---

# Step 9 — Join With `HACKERS`

The final query uses:

```sql
JOIN COUNT_HACKER C
    ON H.HACKER_ID = C.HACKER_ID
```

We already know each hacker's challenge count, but we need their name.

`HACKERS` provides:

```text
HACKER_ID → NAME
```

For example:

| HACKER_ID | NAME |
|---:|---|
| 101 | Alice |
| 102 | Bob |
| 103 | Charlie |
| 104 | David |
| 105 | Emma |

After the JOIN:

| HACKER_ID | NAME | NUM_OF_CHALLENGE | HACKER_COUNT |
|---:|---|---:|---:|
| 101 | Alice | 5 | 1 |
| 102 | Bob | 3 | 1 |
| 103 | Charlie | 2 | 1 |
| 104 | David | 4 | 1 |
| 105 | Emma | 1 | 1 |

Now the query has all information needed for the final result.

---

# Step 10 — Apply the Filter

The final filter is:

```sql
WHERE C.NUM_OF_CHALLENGE = (
    SELECT MAX(NUM_OF_CHALLENGE)
    FROM NO_OF_CHALLENGE
)
OR C.HACKER_COUNT = 1
```

Using our modified example:

```text
Maximum count = 5
```

and:

```text
Unique counts = 5, 4, 1
```

The result becomes:

| HACKER_ID | NAME | NUM_OF_CHALLENGE |
|---:|---|---:|
| 101 | Alice | 5 |
| 104 | David | 4 |
| 105 | Emma | 1 |

---

# Step 11 — Final Ordering

The query uses:

```sql
ORDER BY
    C.NUM_OF_CHALLENGE DESC,
    H.HACKER_ID
```

First:

```text
NUM_OF_CHALLENGE DESC
```

puts the highest challenge counts first.

Then:

```text
HACKER_ID ASC
```

breaks ties using the hacker ID.

For example:

| HACKER_ID | NAME | NUM_OF_CHALLENGE |
|---:|---|---:|
| 101 | Alice | 5 |
| 104 | David | 4 |
| 105 | Emma | 1 |

is already correctly ordered.

If two hackers had 5 challenges:

| HACKER_ID | NAME | NUM_OF_CHALLENGE |
|---:|---|---:|
| 109 | Alex | 5 |
| 103 | Bob | 5 |

then `HACKER_ID ASC` would produce:

| HACKER_ID | NAME | NUM_OF_CHALLENGE |
|---:|---|---:|
| 103 | Bob | 5 |
| 109 | Alex | 5 |

---

# Complete Transformation Flow

```text
                    CHALLENGES
                         │
                         ▼
                GROUP BY HACKER_ID
                         │
                         ▼
              Count challenges
                         │
                         ▼
                NO_OF_CHALLENGE
                         │
             ┌───────────┴───────────┐
             │                       │
             ▼                       ▼
      Find maximum             Group by challenge
      challenge count               count
             │                       │
             │                       ▼
             │                Count hackers
             │                with same count
             │                       │
             │                       ▼
             │                 HACKER_COUNT
             │                       │
             └───────────┬───────────┘
                         ▼
                     FILTER
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
        Maximum count?         Unique count?
              │                     │
              └──────────┬──────────┘
                         │
                         ▼
                        OR
                         │
                         ▼
                  Qualifying hackers
                         │
                         ▼
                     JOIN HACKERS
                         │
                         ▼
                    Add NAME
                         │
                         ▼
                  ORDER BY count DESC
                         │
                         ▼
                   HACKER_ID ASC
                         │
                         ▼
                    FINAL RESULT
```

---

# CTE Transformation Summary

## `NO_OF_CHALLENGE`

Purpose:

> Calculate how many challenges each hacker created.

Transformation:

```text
CHALLENGES
    ↓
GROUP BY HACKER_ID
    ↓
COUNT(CHALLENGE_ID)
    ↓
One row per hacker
```

Example output:

| HACKER_ID | NUM_OF_CHALLENGE |
|---:|---:|
| 101 | 5 |
| 102 | 3 |
| 103 | 3 |
| 104 | 4 |
| 105 | 1 |

---

## `COUNT_HACKER`

Purpose:

> Determine how many hackers share each challenge count.

Transformation:

```text
NO_OF_CHALLENGE
       ↓
Group rows by NUM_OF_CHALLENGE
       ↓
Count hackers in each group
       ↓
HACKER_COUNT
```

Example:

| HACKER_ID | NUM_OF_CHALLENGE | HACKER_COUNT |
|---:|---:|---:|
| 101 | 5 | 1 |
| 102 | 3 | 2 |
| 103 | 3 | 2 |
| 104 | 4 | 1 |
| 105 | 1 | 1 |

---

# Why the Query Uses Two CTEs

The first CTE answers:

> **How many challenges did each hacker create?**

The second CTE answers:

> **How many hackers have that same challenge count?**

These are two different levels of aggregation.

```text
Level 1:
Hacker → Number of challenges

Level 2:
Number of challenges → Number of hackers
```

That is why separating the logic into two CTEs makes the query easier to construct.

---

# Key SQL Concepts

- Common Table Expressions
- Group-level aggregation
- Windowed aggregation
- Partitioning by an aggregated value
- Subqueries for comparison with an overall maximum
- Conditional filtering with `OR`
- Joining aggregated results back to a master table
- Multi-level sorting

---

# Final Transformation

```text
CHALLENGES
    ↓
Count challenges per hacker
    ↓
NO_OF_CHALLENGE
    ↓
Count how many hackers share each count
    ↓
COUNT_HACKER
    ↓
Find maximum challenge count
    ↓
Check:
    maximum count
       OR
    unique count
    ↓
Keep qualifying hackers
    ↓
JOIN HACKERS to get names
    ↓
Sort by challenge count DESC
    ↓
Break ties using HACKER_ID ASC
    ↓
Final HACKER_ID + NAME + challenge count
```

**Corresponding SQL:** `11_Challenges.sql`