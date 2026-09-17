# SQL Project Planning

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** CTEs, Window Functions, Sequential Data Analysis, Gaps and Islands, Conditional Logic, Aggregation, Date Operations

---

## Problem

The `Projects` table contains individual tasks.

Each task has:

- `Task_ID`
- `Start_Date`
- `End_Date`

Some tasks belong to the **same project** because one task ends on the same date that the next task starts.

The goal is to combine consecutive tasks into projects and then display:

- `START_DATE`
- `END_DATE`

The projects should be ordered by:

1. Project duration in ascending order
2. `START_DATE` in ascending order when durations are equal

---

# Given Table

Consider this simplified `Projects` table:

| Task_ID | Start_Date | End_Date |
|---:|---|---|
| 1 | 2026-01-01 | 2026-01-02 |
| 2 | 2026-01-02 | 2026-01-04 |
| 3 | 2026-01-05 | 2026-01-06 |
| 4 | 2026-01-06 | 2026-01-08 |
| 5 | 2026-01-10 | 2026-01-12 |
| 6 | 2026-01-12 | 2026-01-13 |

The important relationships are:

```text
Task 1:  Jan 1 → Jan 2
Task 2:  Jan 2 → Jan 4
```

Task 2 starts exactly when Task 1 ends, so they belong to the same project.

Similarly:

```text
Task 3:  Jan 5 → Jan 6
Task 4:  Jan 6 → Jan 8
```

These form another project.

And:

```text
Task 5:  Jan 10 → Jan 12
Task 6:  Jan 12 → Jan 13
```

form another project.

Therefore:

```text
Project 1 → Task 1 + Task 2
Project 2 → Task 3 + Task 4
Project 3 → Task 5 + Task 6
```

---

# Step 1 — Look at the Previous Task

The first CTE is:

```sql
WITH PREV_TASK AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        LAG(End_Date) OVER (
            ORDER BY Start_Date
        ) AS PREV_END_DATE
    FROM Projects
)
```

The key operation is:

```sql
LAG(End_Date)
```

It allows us to look at the `End_Date` of the previous task.

---

# Step 2 — Sort Tasks by Start Date

The window operation uses:

```sql
ORDER BY Start_Date
```

So the tasks are considered chronologically.

Our data becomes:

| Task_ID | Start_Date | End_Date |
|---:|---|---|
| 1 | Jan 1 | Jan 2 |
| 2 | Jan 2 | Jan 4 |
| 3 | Jan 5 | Jan 6 |
| 4 | Jan 6 | Jan 8 |
| 5 | Jan 10 | Jan 12 |
| 6 | Jan 12 | Jan 13 |

---

# Step 3 — Add the Previous End Date

`LAG(End_Date)` looks one row backward.

For Task 1, there is no previous task:

```text
PREV_END_DATE = NULL
```

For Task 2:

```text
PREV_END_DATE = Jan 2
```

because Task 1 ended on Jan 2.

For Task 3:

```text
PREV_END_DATE = Jan 4
```

because Task 2 ended on Jan 4.

The resulting `PREV_TASK` CTE is:

| Task_ID | Start_Date | End_Date | PREV_END_DATE |
|---:|---|---|---|
| 1 | Jan 1 | Jan 2 | NULL |
| 2 | Jan 2 | Jan 4 | Jan 2 |
| 3 | Jan 5 | Jan 6 | Jan 4 |
| 4 | Jan 6 | Jan 8 | Jan 6 |
| 5 | Jan 10 | Jan 12 | Jan 8 |
| 6 | Jan 12 | Jan 13 | Jan 12 |

Now we can compare:

```text
PREV_END_DATE
       vs
Start_Date
```

---

# Step 4 — Detect Project Boundaries

The second CTE contains:

```sql
SUM(
    CASE
        WHEN PREV_END_DATE = Start_Date THEN 0
        ELSE 1
    END
) OVER (
    ORDER BY Start_Date
) AS PROJECT_ID
```

This is the main logic of the query.

We need to determine whether each task continues the previous project or starts a new one.

The rule is:

```text
Previous task ends = Current task starts
                ↓
          Same project

Otherwise
                ↓
          New project
```

---

# Step 5 — Apply the `CASE`

The query checks:

```sql
CASE
    WHEN PREV_END_DATE = Start_Date THEN 0
    ELSE 1
END
```

Let's evaluate every task.

### Task 1

```text
PREV_END_DATE = NULL
Start_Date = Jan 1
```

There is no previous task.

Therefore:

```text
ELSE → 1
```

This starts a new project.

---

### Task 2

```text
PREV_END_DATE = Jan 2
Start_Date = Jan 2
```

They are equal.

Therefore:

```text
THEN → 0
```

Task 2 continues the existing project.

---

### Task 3

```text
PREV_END_DATE = Jan 4
Start_Date = Jan 5
```

They are different.

Therefore:

```text
ELSE → 1
```

A new project starts.

---

### Task 4

```text
PREV_END_DATE = Jan 6
Start_Date = Jan 6
```

They are equal.

Therefore:

```text
THEN → 0
```

Task 4 continues the current project.

---

### Task 5

```text
PREV_END_DATE = Jan 8
Start_Date = Jan 10
```

They are different.

Therefore:

```text
ELSE → 1
```

A new project starts.

---

### Task 6

```text
PREV_END_DATE = Jan 12
Start_Date = Jan 12
```

They are equal.

Therefore:

```text
THEN → 0
```

Task 6 continues the project.

---

# Step 6 — The Boundary Indicator

Before applying the running sum, our data conceptually looks like:

| Task_ID | Start_Date | End_Date | PREV_END_DATE | New Project? |
|---:|---|---|---|---:|
| 1 | Jan 1 | Jan 2 | NULL | 1 |
| 2 | Jan 2 | Jan 4 | Jan 2 | 0 |
| 3 | Jan 5 | Jan 6 | Jan 4 | 1 |
| 4 | Jan 6 | Jan 8 | Jan 6 | 0 |
| 5 | Jan 10 | Jan 12 | Jan 8 | 1 |
| 6 | Jan 12 | Jan 13 | Jan 12 | 0 |

So we have:

```text
1
0
1
0
1
0
```

The `1` means:

> Start a new project.

The `0` means:

> Continue the current project.

---

# Step 7 — Create `PROJECT_ID`

Now the query performs a running sum:

```sql
SUM(...) OVER (
    ORDER BY Start_Date
)
```

We accumulate the indicators:

```text
1
1 + 0 = 1
1 + 0 + 1 = 2
1 + 0 + 1 + 0 = 2
1 + 0 + 1 + 0 + 1 = 3
1 + 0 + 1 + 0 + 1 + 0 = 3
```

Therefore:

| Task_ID | Start_Date | End_Date | New Project? | PROJECT_ID |
|---:|---|---|---:|---:|
| 1 | Jan 1 | Jan 2 | 1 | 1 |
| 2 | Jan 2 | Jan 4 | 0 | 1 |
| 3 | Jan 5 | Jan 6 | 1 | 2 |
| 4 | Jan 6 | Jan 8 | 0 | 2 |
| 5 | Jan 10 | Jan 12 | 1 | 3 |
| 6 | Jan 12 | Jan 13 | 0 | 3 |

This is the result of `PROJECT_GROUPS`.

---

# Why the Running Sum Works

This is a classic **gaps-and-islands** pattern.

We have:

```text
1 → Start new project
0 → Continue
0 → Continue
1 → Start new project
0 → Continue
```

The running sum turns that into:

```text
1 → Project 1
1 → Project 1
2 → Project 2
2 → Project 2
3 → Project 3
```

So:

```text
Indicator       Running Sum
   1                1
   0                1
   1                2
   0                2
   1                3
   0                3
```

The running sum creates a group ID automatically.

---

# Step 8 — Group Tasks Into Projects

The third CTE is:

```sql
PROJECTS AS (
    SELECT
        PROJECT_ID,
        MIN(Start_Date) AS START_DATE,
        MAX(End_Date) AS END_DATE
    FROM PROJECT_GROUPS
    GROUP BY PROJECT_ID
)
```

Now every task belonging to the same `PROJECT_ID` is grouped together.

---

# Step 9 — Find the Project Start Date

For each project:

```sql
MIN(Start_Date)
```

finds the earliest task start.

### Project 1

Tasks:

| Task_ID | Start_Date | End_Date |
|---:|---|---|
| 1 | Jan 1 | Jan 2 |
| 2 | Jan 2 | Jan 4 |

Earliest start:

```text
MIN(Jan 1, Jan 2) = Jan 1
```

---

### Project 2

| Task_ID | Start_Date | End_Date |
|---:|---|---|
| 3 | Jan 5 | Jan 6 |
| 4 | Jan 6 | Jan 8 |

Earliest start:

```text
Jan 5
```

---

### Project 3

| Task_ID | Start_Date | End_Date |
|---:|---|---|
| 5 | Jan 10 | Jan 12 |
| 6 | Jan 12 | Jan 13 |

Earliest start:

```text
Jan 10
```

---

# Step 10 — Find the Project End Date

The query uses:

```sql
MAX(End_Date)
```

This finds the latest ending task inside each project.

### Project 1

```text
Jan 2
Jan 4
 ↓
MAX = Jan 4
```

### Project 2

```text
Jan 6
Jan 8
 ↓
MAX = Jan 8
```

### Project 3

```text
Jan 12
Jan 13
 ↓
MAX = Jan 13
```

---

# Step 11 — Result of `PROJECTS`

The third CTE produces:

| PROJECT_ID | START_DATE | END_DATE |
|---:|---|---|
| 1 | Jan 1 | Jan 4 |
| 2 | Jan 5 | Jan 8 |
| 3 | Jan 10 | Jan 13 |

We have successfully transformed individual tasks into complete projects.

```text
Tasks
  ↓
Detect boundaries
  ↓
Assign PROJECT_ID
  ↓
Group by PROJECT_ID
  ↓
Find earliest start + latest end
  ↓
Projects
```

---

# Step 12 — Calculate Project Duration

The final query uses:

```sql
ORDER BY
    DATEDIFF(END_DATE, START_DATE),
    START_DATE
```

`DATEDIFF` calculates the number of days between the project start and end.

For our projects:

### Project 1

```text
Jan 4 - Jan 1 = 3 days
```

### Project 2

```text
Jan 8 - Jan 5 = 3 days
```

### Project 3

```text
Jan 13 - Jan 10 = 3 days
```

All three have the same duration.

---

# Step 13 — Break Duration Ties Using Start Date

Since all projects have the same duration:

```text
3 days
3 days
3 days
```

the second sorting condition becomes important:

```sql
START_DATE
```

Ascending order gives:

```text
Jan 1
Jan 5
Jan 10
```

Therefore:

| START_DATE | END_DATE | Duration |
|---|---|---:|
| Jan 1 | Jan 4 | 3 |
| Jan 5 | Jan 8 | 3 |
| Jan 10 | Jan 13 | 3 |

---

# Final Result

The final query selects only:

```sql
SELECT
    START_DATE,
    END_DATE
FROM PROJECTS
```

So the result is:

| START_DATE | END_DATE |
|---|---|
| Jan 1 | Jan 4 |
| Jan 5 | Jan 8 |
| Jan 10 | Jan 13 |

---

# Complete Transformation Flow

```text
                         PROJECTS
                            │
                            ▼
                 Sort tasks by Start_Date
                            │
                            ▼
                  LAG(End_Date)
                            │
                            ▼
                     PREV_TASK
                            │
                            ▼
          Compare PREV_END_DATE with Start_Date
                            │
                 ┌──────────┴──────────┐
                 │                     │
             Same date             Different
                 │                     │
                 ▼                     ▼
              0 = continue         1 = new project
                 │                     │
                 └──────────┬──────────┘
                            ▼
                      Running SUM
                            │
                            ▼
                      PROJECT_ID
                            │
                            ▼
                   PROJECT_GROUPS
                            │
                            ▼
                  GROUP BY PROJECT_ID
                            │
                  ┌─────────┴─────────┐
                  ▼                   ▼
             MIN(Start_Date)     MAX(End_Date)
                  │                   │
                  └─────────┬─────────┘
                            ▼
                         PROJECTS
                            │
                            ▼
                    Calculate duration
                            │
                            ▼
                     Sort by duration
                            │
                            ▼
                    Break ties by date
                            │
                            ▼
                       FINAL RESULT
```

---

# CTE Transformation Summary

## `PREV_TASK`

Purpose:

> Determine when each task starts relative to the previous task.

Transformation:

```text
PROJECTS
   ↓
Sort by Start_Date
   ↓
Look at previous End_Date
   ↓
PREV_TASK
```

Result:

| Task_ID | Start_Date | End_Date | PREV_END_DATE |
|---:|---|---|---|
| 1 | Jan 1 | Jan 2 | NULL |
| 2 | Jan 2 | Jan 4 | Jan 2 |
| 3 | Jan 5 | Jan 6 | Jan 4 |
| 4 | Jan 6 | Jan 8 | Jan 6 |
| 5 | Jan 10 | Jan 12 | Jan 8 |
| 6 | Jan 12 | Jan 13 | Jan 12 |

---

## `PROJECT_GROUPS`

Purpose:

> Detect project boundaries and assign a project ID.

Transformation:

```text
PREV_TASK
    ↓
Compare previous End_Date with current Start_Date
    ↓
Same → 0
Different → 1
    ↓
Running SUM
    ↓
PROJECT_ID
```

Result:

| Task_ID | Start_Date | End_Date | PROJECT_ID |
|---:|---|---|---:|
| 1 | Jan 1 | Jan 2 | 1 |
| 2 | Jan 2 | Jan 4 | 1 |
| 3 | Jan 5 | Jan 6 | 2 |
| 4 | Jan 6 | Jan 8 | 2 |
| 5 | Jan 10 | Jan 12 | 3 |
| 6 | Jan 12 | Jan 13 | 3 |

---

## `PROJECTS`

Purpose:

> Convert groups of tasks into one row per project.

Transformation:

```text
PROJECT_GROUPS
       ↓
GROUP BY PROJECT_ID
       ↓
MIN(Start_Date)
       +
MAX(End_Date)
       ↓
One row per project
```

Result:

| PROJECT_ID | START_DATE | END_DATE |
|---:|---|---|
| 1 | Jan 1 | Jan 4 |
| 2 | Jan 5 | Jan 8 |
| 3 | Jan 10 | Jan 13 |

---

# Why `LAG()` Is Needed

We need to know whether the current task is connected to the previous task.

For example:

```text
Previous task:
Jan 1 → Jan 2

Current task:
Jan 2 → Jan 4
```

The current task starts exactly when the previous task ends.

Without looking at the previous row, we cannot determine this relationship.

`LAG()` gives us:

```text
Current row
    │
    ▼
Previous row's End_Date
```

which allows the comparison:

```text
PREV_END_DATE = Start_Date
```

---

# Why the Running `SUM()` Is Needed

The `CASE` expression only tells us:

```text
0 → same project
1 → new project
```

It does not directly give us a project number.

For example:

```text
1
0
0
1
0
1
```

A running sum transforms this into:

```text
1
1
1
2
2
3
```

Now every row has a project identifier.

This is what makes the later:

```sql
GROUP BY PROJECT_ID
```

possible.

---

# Why `MIN()` and `MAX()` Are Used

Once the tasks are grouped into projects:

```text
Project 1
├── Task 1
└── Task 2
```

we need one start and one end date.

The project starts at the **earliest task start**:

```text
MIN(Start_Date)
```

and ends at the **latest task end**:

```text
MAX(End_Date)
```

So:

```text
Project Start = earliest task start
Project End   = latest task end
```

---

# Key SQL Concepts

- Common Table Expressions
- Sequential row analysis
- Looking at previous rows
- Detecting gaps between records
- Creating groups from sequential data
- Running aggregations
- Grouping related rows
- Deriving date ranges
- Sorting by calculated duration

---

# Final Transformation

```text
Individual Tasks
       ↓
Sort chronologically
       ↓
Find previous task's End_Date
       ↓
Check if current Start_Date matches
previous End_Date
       ↓
Identify project boundaries
       ↓
Create running project ID
       ↓
Group tasks by project
       ↓
Earliest Start_Date
+
Latest End_Date
       ↓
Complete Projects
       ↓
Calculate project duration
       ↓
Sort shortest → longest
       ↓
Break ties using Start_Date
       ↓
Final START_DATE + END_DATE
```

**Corresponding SQL:** `13_SQL_Project_Planning.sql`