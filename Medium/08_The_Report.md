# The Report

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Joins, Conditional Logic, Range Matching, Custom Sorting

---

## Problem

You are given two tables:

### `STUDENTS`

| ID | NAME | MARKS |
|---:|---|---:|
| 1 | Ashley | 81 |
| 2 | Bob | 68 |
| 3 | Clara | 95 |
| 4 | David | 72 |
| 5 | Eve | 55 |

### `GRADES`

| GRADE | MIN_MARK | MAX_MARK |
|------:|---------:|---------:|
| 10 | 90 | 100 |
| 9 | 80 | 89 |
| 8 | 70 | 79 |
| 7 | 60 | 69 |
| 6 | 50 | 59 |

The task is to assign each student a grade based on their marks.

There are also different output rules:

- If the grade is **greater than 7**, display the student's name.
- If the grade is **7 or below**, display `'NULL'` instead of the student's name.
- Sort primarily by grade in descending order.
- For grades greater than 7, sort students alphabetically by name.
- For grades 7 or below, sort students by marks in ascending order.

---

# Step 1 — Start With the `STUDENTS` Table

Our simplified input is:

| ID | NAME | MARKS |
|---:|---|---:|
| 1 | Ashley | 81 |
| 2 | Bob | 68 |
| 3 | Clara | 95 |
| 4 | David | 72 |
| 5 | Eve | 55 |

Each student has a mark, but there is no grade yet.

We need to determine which grade range their marks belong to.

---

# Step 2 — Look at the `GRADES` Table

The grade table defines ranges:

| GRADE | MIN_MARK | MAX_MARK |
|------:|---------:|---------:|
| 10 | 90 | 100 |
| 9 | 80 | 89 |
| 8 | 70 | 79 |
| 7 | 60 | 69 |
| 6 | 50 | 59 |

For example:

```text
90 - 100 → Grade 10
80 - 89  → Grade 9
70 - 79  → Grade 8
60 - 69  → Grade 7
50 - 59  → Grade 6
```

---

# Step 3 — Match Students to Their Grade

The query uses:

```sql
JOIN GRADES G
    ON S.MARKS BETWEEN G.MIN_MARK AND G.MAX_MARK
```

This is a **range-based join**.

Instead of matching two columns for equality, we check whether:

```text
STUDENT MARKS
    falls between
MIN_MARK and MAX_MARK
```

---

## Student: Ashley

Ashley has:

```text
MARKS = 81
```

Check the grade ranges:

```text
90 - 100 → No
80 - 89  → YES
70 - 79  → No
60 - 69  → No
50 - 59  → No
```

Therefore:

```text
Ashley → Grade 9
```

---

## Student: Bob

Bob has:

```text
MARKS = 68
```

Check:

```text
90 - 100 → No
80 - 89  → No
70 - 79  → No
60 - 69  → YES
50 - 59  → No
```

Therefore:

```text
Bob → Grade 7
```

---

## Student: Clara

Clara has:

```text
MARKS = 95
```

This falls into:

```text
90 - 100 → Grade 10
```

Therefore:

```text
Clara → Grade 10
```

---

## Student: David

David has:

```text
MARKS = 72
```

This falls into:

```text
70 - 79 → Grade 8
```

Therefore:

```text
David → Grade 8
```

---

## Student: Eve

Eve has:

```text
MARKS = 55
```

This falls into:

```text
50 - 59 → Grade 6
```

Therefore:

```text
Eve → Grade 6
```

---

# Step 4 — Result of the JOIN

After the range-based join:

| NAME | MARKS | GRADE |
|---|---:|---:|
| Ashley | 81 | 9 |
| Bob | 68 | 7 |
| Clara | 95 | 10 |
| David | 72 | 8 |
| Eve | 55 | 6 |

The JOIN has successfully converted:

```text
Student marks
      ↓
Grade ranges
      ↓
Student grades
```

---

# Step 5 — Decide Which Names Should Be Displayed

The problem has a special rule:

```text
GRADE > 7 → show NAME
GRADE <= 7 → show NULL
```

The query implements this with:

```sql
CASE
    WHEN G.GRADE > 7 THEN S.NAME
    ELSE 'NULL'
END AS NAME
```

Let's apply it.

| NAME | GRADE | Rule | Display |
|---|---:|---|---|
| Clara | 10 | > 7 | Clara |
| Ashley | 9 | > 7 | Ashley |
| David | 8 | > 7 | David |
| Bob | 7 | <= 7 | NULL |
| Eve | 6 | <= 7 | NULL |

So the intermediate output becomes:

| NAME | GRADE | MARKS |
|---|---:|---:|
| Ashley | 9 | 81 |
| NULL | 7 | 68 |
| Clara | 10 | 95 |
| David | 8 | 72 |
| NULL | 6 | 55 |

---

# Step 6 — Sort by Grade Descending

The first sorting condition is:

```sql
G.GRADE DESC
```

This means the highest grade comes first.

Before sorting:

| NAME | GRADE | MARKS |
|---|---:|---:|
| Ashley | 9 | 81 |
| NULL | 7 | 68 |
| Clara | 10 | 95 |
| David | 8 | 72 |
| NULL | 6 | 55 |

After sorting by grade descending:

| NAME | GRADE | MARKS |
|---|---:|---:|
| Clara | 10 | 95 |
| Ashley | 9 | 81 |
| David | 8 | 72 |
| NULL | 7 | 68 |
| NULL | 6 | 55 |

---

# Step 7 — Sort Grades Greater Than 7 by Name

The second sorting condition is:

```sql
CASE
    WHEN G.GRADE > 7 THEN S.NAME
END
```

This means:

```text
If grade > 7:
    use NAME for sorting

Otherwise:
    return NULL
```

So students with grades above 7 are alphabetically sorted.

For example:

| NAME | GRADE |
|---|---:|
| Ashley | 9 |
| Clara | 10 |
| David | 8 |

Their names determine their order **only when they have the same grade**.

For example, suppose we had:

| NAME | GRADE |
|---|---:|
| Zoe | 9 |
| Ashley | 9 |
| Bob | 9 |

After grade descending, all three have grade 9.

The name condition then sorts them:

| NAME | GRADE |
|---|---:|
| Ashley | 9 |
| Bob | 9 |
| Zoe | 9 |

---

# Step 8 — Sort Lower Grades by Marks

The final sorting condition is:

```sql
CASE
    WHEN G.GRADE <= 7 THEN S.MARKS
END
```

This means:

```text
If grade <= 7:
    use MARKS for sorting
```

So students with grades 7 or below are ordered by their marks in ascending order.

For example:

| NAME | GRADE | MARKS |
|---|---:|---:|
| NULL | 7 | 68 |
| NULL | 6 | 55 |

Because grade is already sorted first, grade 7 still appears before grade 6.

If multiple students have the same grade:

| NAME | GRADE | MARKS |
|---|---:|---:|
| NULL | 7 | 65 |
| NULL | 7 | 62 |
| NULL | 7 | 68 |

The marks condition produces:

| NAME | GRADE | MARKS |
|---|---:|---:|
| NULL | 7 | 62 |
| NULL | 7 | 65 |
| NULL | 7 | 68 |

---

# Step 9 — Final Result

Applying all sorting rules to our example:

| NAME | GRADE | MARKS |
|---|---:|---:|
| Clara | 10 | 95 |
| Ashley | 9 | 81 |
| David | 8 | 72 |
| NULL | 7 | 68 |
| NULL | 6 | 55 |

---

# Complete Transformation Flow

```text
                  STUDENTS
                     │
                     │
                     │ MARKS
                     ▼
                  GRADES
                     │
                     │
          Match MARKS to the
        MIN_MARK / MAX_MARK
              range
                     │
                     ▼
             Range-Based JOIN
                     │
                     ▼
        ┌────────────────────────┐
        │ NAME   │ MARKS │ GRADE │
        ├────────┼───────┼───────┤
        │ Ashley │  81   │   9   │
        │ Bob    │  68   │   7   │
        │ Clara  │  95   │  10   │
        │ David  │  72   │   8   │
        │ Eve    │  55   │   6   │
        └────────┴───────┴───────┘
                     │
                     ▼
              Conditional NAME
                     │
          ┌──────────┴──────────┐
          │                     │
       Grade > 7             Grade <= 7
          │                     │
      Show NAME              Show NULL
          │                     │
          └──────────┬──────────┘
                     ▼
               ORDER BY
                     │
          ┌──────────┼───────────┐
          ▼          ▼           ▼
       Grade DESC   Name       Marks
                    for >7     for <=7
          │
          ▼
              FINAL RESULT
```

---

# Query Breakdown

### Range-Based JOIN

```sql
JOIN GRADES G
    ON S.MARKS BETWEEN G.MIN_MARK AND G.MAX_MARK
```

Connects every student with the grade whose mark range contains their score.

---

### Conditional Output

```sql
CASE
    WHEN G.GRADE > 7 THEN S.NAME
    ELSE 'NULL'
END
```

Controls whether the student's name is displayed.

---

### Primary Sorting

```sql
G.GRADE DESC
```

Places higher grades first.

---

### Secondary Sorting for Higher Grades

```sql
CASE
    WHEN G.GRADE > 7 THEN S.NAME
END
```

For students sharing the same grade above 7, names are sorted alphabetically.

---

### Secondary Sorting for Lower Grades

```sql
CASE
    WHEN G.GRADE <= 7 THEN S.MARKS
END
```

For students sharing the same grade of 7 or below, marks are sorted in ascending order.

---

# Why Use `CASE` Inside `ORDER BY`?

The problem requires **different sorting rules depending on the grade**.

We cannot simply do:

```sql
ORDER BY G.GRADE DESC, S.NAME
```

because lower-grade students should **not** be sorted by their names.

Similarly, we cannot simply do:

```sql
ORDER BY G.GRADE DESC, S.MARKS
```

because higher-grade students should be sorted by their names.

The conditional expressions allow us to apply different sorting logic to different groups of rows.

---

# Key SQL Concepts

- Range-based joins
- Conditional logic
- Custom sorting
- Multiple-level ordering
- Derived output columns
- Mapping values to ranges

---

# Final Transformation

```text
STUDENTS
   ↓
Read MARKS
   ↓
Match MARKS against GRADES ranges
   ↓
Assign GRADE
   ↓
CASE determines displayed NAME
   ↓
GRADE DESC
   ↓
Same high grade → alphabetical NAME
   ↓
Same low grade → ascending MARKS
   ↓
Final Report
```

**Corresponding SQL:** `08_The_Report.sql`