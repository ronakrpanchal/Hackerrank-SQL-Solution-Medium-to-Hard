# Placements

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Multiple Table Joins, Self-Referential Relationships, Data Comparison, Filtering, Sorting

---

## Problem

You are given information about:

- Students
- Their friends
- Their salary packages

The goal is to find students whose **friend has a higher salary package than the student**.

The final output should contain only the student's:

```text
NAME
```

The names should be ordered by the **friend's salary in ascending order**.

---

# Given Tables

## `STUDENTS`

| ID | NAME |
|---:|---|
| 101 | Alice |
| 102 | Bob |
| 103 | Charlie |
| 104 | David |

---

## `FRIENDS`

| ID | FRIEND_ID |
|---:|---:|
| 101 | 102 |
| 102 | 103 |
| 103 | 104 |
| 104 | 101 |

This means:

```text
Alice   → Bob
Bob     → Charlie
Charlie → David
David   → Alice
```

---

## `PACKAGES`

| ID | SALARY |
|---:|---:|
| 101 | 50000 |
| 102 | 60000 |
| 103 | 55000 |
| 104 | 70000 |

So:

```text
Alice   → 50000
Bob     → 60000
Charlie → 55000
David   → 70000
```

---

# Step 1 — Start With `STUDENTS`

The query begins with:

```sql
FROM STUDENTS S
```

`S` is an alias for the `STUDENTS` table.

We have:

| ID | NAME |
|---:|---|
| 101 | Alice |
| 102 | Bob |
| 103 | Charlie |
| 104 | David |

---

# Step 2 — Join the `FRIENDS` Table

The query uses:

```sql
JOIN FRIENDS F
    ON S.ID = F.ID
```

This connects each student to their friend.

Before the JOIN:

### `STUDENTS`

| ID | NAME |
|---:|---|
| 101 | Alice |
| 102 | Bob |
| 103 | Charlie |
| 104 | David |

### `FRIENDS`

| ID | FRIEND_ID |
|---:|---:|
| 101 | 102 |
| 102 | 103 |
| 103 | 104 |
| 104 | 101 |

After the JOIN:

| Student ID | NAME | FRIEND_ID |
|---:|---|---:|
| 101 | Alice | 102 |
| 102 | Bob | 103 |
| 103 | Charlie | 104 |
| 104 | David | 101 |

Now we know who each student's friend is.

---

# Step 3 — Join `PACKAGES` for the Student

The query contains:

```sql
JOIN PACKAGES P1
    ON F.ID = P1.ID
```

Here:

```text id="jv7qk2"
P1 = Student's salary
```

Because:

```text id="2d6m3p"
F.ID = student's ID
```

we connect each student to their own salary.

After the JOIN:

| Student ID | NAME | FRIEND_ID | Student Salary |
|---:|---|---:|---:|
| 101 | Alice | 102 | 50000 |
| 102 | Bob | 103 | 60000 |
| 103 | Charlie | 104 | 55000 |
| 104 | David | 101 | 70000 |

The alias `P1` represents the student's package.

---

# Step 4 — Join `PACKAGES` Again for the Friend

This is the important part:

```sql
JOIN PACKAGES P2
    ON F.FRIEND_ID = P2.ID
```

We join the `PACKAGES` table **a second time**.

Here:

```text id="y1jz1g"
P2 = Friend's salary
```

Why do we need another JOIN?

Because both the student and the friend have salaries stored in the **same `PACKAGES` table**.

We therefore need two references to the same table:

```text id="6hrc1w"
P1 → Student's package
P2 → Friend's package
```

---

# Step 5 — Understand the Two `PACKAGES` Aliases

This is the central idea of the query.

### `P1`

```sql id="xkz0yv"
JOIN PACKAGES P1
    ON F.ID = P1.ID
```

means:

```text
Student ID
    ↓
Student's salary
```

### `P2`

```sql id="70f2hc"
JOIN PACKAGES P2
    ON F.FRIEND_ID = P2.ID
```

means:

```text
Friend ID
    ↓
Friend's salary
```

So we can compare:

```text
P1.SALARY
      vs
P2.SALARY
```

---

# Step 6 — Result After Both Package JOINs

Let's build the complete table.

| Student | Student ID | Friend | Student Salary | Friend Salary |
|---|---:|---|---:|---:|
| Alice | 101 | Bob | 50000 | 60000 |
| Bob | 102 | Charlie | 60000 | 55000 |
| Charlie | 103 | David | 55000 | 70000 |
| David | 104 | Alice | 70000 | 50000 |

Now the problem becomes simple:

> Keep rows where the friend's salary is greater than the student's salary.

---

# Step 7 — Compare the Salaries

The query uses:

```sql
WHERE P2.SALARY > P1.SALARY
```

Remember:

```text
P2 = Friend's salary
P1 = Student's salary
```

Therefore the condition means:

```text
Friend Salary > Student Salary
```

Let's evaluate every student.

---

## Alice

```text id="w65m9g"
Student salary = 50000
Friend salary  = 60000
```

Check:

```text id="y07e4k"
60000 > 50000
```

True.

Therefore:

```text id="1s5v2f"
Alice → INCLUDE
```

---

## Bob

```text id="1g6s4u"
Student salary = 60000
Friend salary  = 55000
```

Check:

```text id="6q5v3h"
55000 > 60000
```

False.

Therefore:

```text id="1p2uj7"
Bob → EXCLUDE
```

---

## Charlie

```text id="9r9i4e"
Student salary = 55000
Friend salary  = 70000
```

Check:

```text id="a0l7rx"
70000 > 55000
```

True.

Therefore:

```text id="tr9j7s"
Charlie → INCLUDE
```

---

## David

```text id="u8g3zq"
Student salary = 70000
Friend salary  = 50000
```

Check:

```text id="q8n8yf"
50000 > 70000
```

False.

Therefore:

```text id="czn4a7"
David → EXCLUDE
```

---

# Step 8 — Filtered Result

After applying:

```sql id="l9w0mx"
WHERE P2.SALARY > P1.SALARY
```

we get:

| NAME | Student Salary | Friend Salary |
|---|---:|---:|
| Alice | 50000 | 60000 |
| Charlie | 55000 | 70000 |

Only these students have friends earning more than them.

---

# Step 9 — Select Only the Student Name

The query starts with:

```sql id="5i8q0z"
SELECT S.NAME
```

So we don't return:

- Student ID
- Friend ID
- Student salary
- Friend salary

Only:

```text
NAME
```

Therefore:

| NAME |
|---|
| Alice |
| Charlie |

---

# Step 10 — Sort by Friend's Salary

The final part is:

```sql id="x0l8v5"
ORDER BY P2.SALARY
```

By default, `ORDER BY` sorts in ascending order.

Our qualifying rows are:

| NAME | Friend Salary |
|---|---:|
| Alice | 60000 |
| Charlie | 70000 |

Since:

```text
60000 < 70000
```

the final order is:

```text
Alice
Charlie
```

---

# Final Result

| NAME |
|---|
| Alice |
| Charlie |

The actual HackerRank dataset will produce the complete result.

---

# Complete Transformation Flow

```text
                    STUDENTS
                       │
                       ▼
                JOIN FRIENDS
                       │
                       ▼
           Identify each student's
                  FRIEND_ID
                       │
                       ▼
             JOIN PACKAGES P1
                       │
                       ▼
              Get STUDENT salary
                       │
                       ▼
             JOIN PACKAGES P2
                       │
                       ▼
               Get FRIEND salary
                       │
                       ▼
          ┌─────────────────────────┐
          │ Compare salaries        │
          │                         │
          │ Friend > Student?       │
          └────────────┬────────────┘
                       │
              ┌────────┴────────┐
              ▼                 ▼
             YES                NO
              │                 │
              ▼                 ▼
           INCLUDE           EXCLUDE
              │
              ▼
          Select NAME
              │
              ▼
      ORDER BY Friend Salary
              │
              ▼
         FINAL RESULT
```

---

# Understanding the Two `PACKAGES` JOINs

This is the most important part of the query.

The table is:

```text id="fqxtw9"
PACKAGES
┌────┬────────┐
│ ID │ SALARY │
├────┼────────┤
│101 │ 50000  │
│102 │ 60000  │
│103 │ 55000  │
│104 │ 70000  │
└────┴────────┘
```

We use it twice.

### First reference: `P1`

```text id="qyk7cc"
P1
↓
Student's salary
```

### Second reference: `P2`

```text id="v2y8ir"
P2
↓
Friend's salary
```

This lets us create a comparison:

```text id="bh5f7n"
             PACKAGES
              /     \
             /       \
            ▼         ▼
          P1           P2
     Student salary  Friend salary
            \         /
             \       /
              ▼     ▼
             COMPARE
                 │
                 ▼
        Friend > Student?
```

---

# Why `P1` and `P2` Are Necessary

Without aliases, SQL would not know which occurrence of `PACKAGES` we mean when referring to salary.

We need:

```text id="0c9wbd"
P1.SALARY → student's salary
P2.SALARY → friend's salary
```

Then the condition becomes very clear:

```sql id="f6bq08"
P2.SALARY > P1.SALARY
```

which reads naturally as:

```text
Friend salary > Student salary
```

---

# Join Relationship

The complete relationship can be visualized as:

```text
STUDENTS
   │
   │ ID
   ▼
FRIENDS
   │
   ├───────────────┐
   │               │
   │ ID            │ FRIEND_ID
   ▼               ▼
PACKAGES P1     PACKAGES P2
   │               │
   ▼               ▼
Student Salary   Friend Salary
   │               │
   └───────┬───────┘
           ▼
    Compare Salaries
           │
           ▼
     Friend > Student
           │
           ▼
      Student NAME
```

---

# Query Breakdown

### 1. Connect students to friends

```sql id="yl21ut"
JOIN FRIENDS F
    ON S.ID = F.ID
```

Determines who each student's friend is.

### 2. Get student's salary

```sql id="2w9w1h"
JOIN PACKAGES P1
    ON F.ID = P1.ID
```

`P1` represents the student's salary.

### 3. Get friend's salary

```sql id="c8s0n2"
JOIN PACKAGES P2
    ON F.FRIEND_ID = P2.ID
```

`P2` represents the friend's salary.

### 4. Compare salaries

```sql id="jndn6p"
WHERE P2.SALARY > P1.SALARY
```

Keeps only students whose friend earns more.

### 5. Select the name

```sql id="r9jz3c"
SELECT S.NAME
```

Returns only the student's name.

### 6. Sort

```sql id="4d3w1c"
ORDER BY P2.SALARY
```

Sorts qualifying students by their friend's salary in ascending order.

---

# CTEs?

This solution does **not** require a CTE.

The entire transformation can be performed through the joins and filtering directly:

```text
STUDENTS
   ↓
FRIENDS
   ↓
Student Package + Friend Package
   ↓
Salary Comparison
   ↓
Filter
   ↓
Sort
   ↓
Result
```

---

# Key SQL Concepts

- Multiple table joins
- Joining the same table multiple times
- Table aliases
- Relationship traversal
- Comparing values from different rows
- Filtering based on comparisons
- Custom result ordering

---

# Final Transformation

```text
STUDENTS
    ↓
Find each student's FRIEND_ID
    ↓
Join student's salary
    ↓
Join friend's salary
    ↓
Compare:
Friend Salary > Student Salary
    ↓
Keep qualifying students
    ↓
Select student NAME
    ↓
Sort by friend's salary ASC
    ↓
Final result
```

**Corresponding SQL:** `14_Placements.sql`