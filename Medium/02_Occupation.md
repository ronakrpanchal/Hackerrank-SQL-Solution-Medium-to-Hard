# Occupation

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Window Functions, ROW_NUMBER(), PARTITION BY, CASE, MAX(), GROUP BY

---

## Problem

You are given an `OCCUPATIONS` table containing the names and occupations of people.

The goal is to display the names under four separate columns:

```text
Doctor | Professor | Singer | Actor
```

The names within each occupation should be arranged alphabetically.

---

# Given Table

### `OCCUPATIONS`

Example:

| NAME | OCCUPATION |
|---|---|
| Ashley | Professor |
| Samantha | Actor |
| Julia | Doctor |
| Maria | Professor |
| Meera | Singer |
| Priya | Doctor |
| David | Actor |
| John | Singer |

The table is initially stored as rows.

We need to transform it into columns.

---

# Step 1 — Number Each Occupation

The inner query is:

```sql
SELECT
    name,
    occupation,
    ROW_NUMBER() OVER (
        PARTITION BY occupation
        ORDER BY name
    ) AS rn
FROM OCCUPATIONS
```

The important part is:

```sql
ROW_NUMBER() OVER (
    PARTITION BY occupation
    ORDER BY name
)
```

`PARTITION BY occupation` creates a separate numbering sequence for every occupation.

`ORDER BY name` sorts the people alphabetically within each occupation.

---

## Before `ROW_NUMBER()`

| NAME | OCCUPATION |
|---|---|
| Ashley | Professor |
| Samantha | Actor |
| Julia | Doctor |
| Maria | Professor |
| Meera | Singer |
| Priya | Doctor |
| David | Actor |
| John | Singer |

---

## After `ROW_NUMBER()`

For Doctors:

```text
Doctor
   ├── Julia
   └── Priya
```

Alphabetically:

| NAME | OCCUPATION | RN |
|---|---|---:|
| Julia | Doctor | 1 |
| Priya | Doctor | 2 |

For Professors:

| NAME | OCCUPATION | RN |
|---|---|---:|
| Ashley | Professor | 1 |
| Maria | Professor | 2 |

For Actors:

| NAME | OCCUPATION | RN |
|---|---|---:|
| David | Actor | 1 |
| Samantha | Actor | 2 |

For Singers:

| NAME | OCCUPATION | RN |
|---|---|---:|
| John | Singer | 1 |
| Meera | Singer | 2 |

The complete intermediate table can therefore be visualized as:

| NAME | OCCUPATION | RN |
|---|---|---:|
| Julia | Doctor | 1 |
| Priya | Doctor | 2 |
| Ashley | Professor | 1 |
| Maria | Professor | 2 |
| David | Actor | 1 |
| Samantha | Actor | 2 |
| John | Singer | 1 |
| Meera | Singer | 2 |

The important thing is that `RN` restarts for every occupation.

---

# Step 2 — Group By `RN`

The outer query contains:

```sql
GROUP BY rn
```

This groups together people who have the same position within their occupation.

For example:

```text
RN = 1
    ↓
Julia      → Doctor
Ashley     → Professor
David      → Actor
John       → Singer
```

and:

```text
RN = 2
    ↓
Priya      → Doctor
Maria      → Professor
Samantha   → Actor
Meera      → Singer
```

So the data is effectively reorganized into rows based on the person's position within their occupation.

---

# Step 3 — Use `CASE` to Create Columns

The query uses:

```sql
CASE
    WHEN occupation = 'Doctor'
    THEN name
END
```

This means:

```text
If occupation = Doctor
    → return name

Otherwise
    → return NULL
```

For example:

| NAME | OCCUPATION | Doctor |
|---|---|---|
| Julia | Doctor | Julia |
| Ashley | Professor | NULL |
| David | Actor | NULL |
| John | Singer | NULL |

Similarly:

```sql
CASE WHEN occupation = 'Professor' THEN name END
```

creates the Professor values.

The same logic is used for Singer and Actor.

---

# Step 4 — Why `MAX()`?

After the `CASE` expressions, each group contains something like:

```text
RN = 1

Doctor:
Julia

Professor:
Ashley

Singer:
John

Actor:
David
```

The query uses:

```sql
MAX(CASE WHEN occupation = 'Doctor' THEN name END)
```

Because only one row in the group contains a non-`NULL` Doctor value, `MAX()` simply returns that name.

Conceptually:

```text
MAX(
    Julia,
    NULL,
    NULL,
    NULL
)

       ↓

Julia
```

For Professor:

```text
MAX(
    NULL,
    Ashley,
    NULL,
    NULL
)

       ↓

Ashley
```

So `MAX()` is being used to **collapse the rows into a single value for each occupation column**.

---

# Step 5 — Final Transformation

After applying the `CASE` expressions and `MAX()`:

### `RN = 1`

| Doctor | Professor | Singer | Actor |
|---|---|---|---|
| Julia | Ashley | John | David |

### `RN = 2`

| Doctor | Professor | Singer | Actor |
|---|---|---|---|
| Priya | Maria | Meera | Samantha |

The final result is therefore:

| Doctor | Professor | Singer | Actor |
|---|---|---|---|
| Julia | Ashley | John | David |
| Priya | Maria | Meera | Samantha |

---

# Complete Transformation

The entire query can be visualized as:

```text
                 OCCUPATIONS
                      │
                      ↓
              PARTITION BY
               OCCUPATION
                      │
                      ↓
               ORDER BY NAME
                      │
                      ↓
                ROW_NUMBER()
                      │
                      ↓
          NAME + OCCUPATION + RN
                      │
                      ↓
                 GROUP BY RN
                      │
          ┌───────────┼───────────┐
          ↓           ↓           ↓
        CASE        CASE        CASE
       Doctor     Professor    Singer
          │           │           │
          └───────────┼───────────┘
                      ↓
                    MAX()
                      │
                      ↓
       Doctor | Professor | Singer | Actor
```

---

# Why `ROW_NUMBER()` Is Important

Consider:

```text
Doctor:
Julia
Priya
```

and:

```text
Professor:
Ashley
Maria
```

We want:

```text
Julia   Ashley
Priya   Maria
```

The `ROW_NUMBER()` gives each occupation its own position:

```text
Doctor              Professor

Julia  → 1          Ashley → 1
Priya  → 2          Maria  → 2
```

Then `GROUP BY rn` puts the first person from every occupation together, followed by the second person.

---

# Key SQL Concepts

### `ROW_NUMBER()`

Assigns a sequential number to rows.

```sql
ROW_NUMBER() OVER (...)
```

---

### `PARTITION BY`

Creates an independent numbering sequence for each occupation.

```sql
PARTITION BY occupation
```

---

### `ORDER BY`

Determines the alphabetical order within each occupation.

```sql
ORDER BY name
```

---

### `CASE`

Conditionally returns a person's name based on their occupation.

```sql
CASE
    WHEN occupation = 'Doctor'
    THEN name
END
```

---

### `MAX()`

Used to collapse the conditional values into a single value for each `rn`.

---

### `GROUP BY rn`

Combines people who have the same position within their occupation.

```text
RN 1 → first person from each occupation
RN 2 → second person from each occupation
RN 3 → third person from each occupation
```

---

## Solution

The complete SQL solution is available in [`02_Occupation.sql`](./02_Occupation.sql).