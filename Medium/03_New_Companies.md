# New Companies

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Multiple Table Joins, Hierarchical Relationships, Aggregation, Grouping

---

## Problem

You are given information about companies and their employees organized into a hierarchy:

```text
Company
   ↓
Lead Manager
   ↓
Senior Manager
   ↓
Manager
   ↓
Employee
```

For every company, the goal is to find:

- Company code
- Founder
- Number of lead managers
- Number of senior managers
- Number of managers
- Number of employees

The result should be ordered by `COMPANY_CODE`.

---

# Tables

The problem uses five related tables.

### `COMPANY`

| COMPANY_CODE | FOUNDER |
|---|---|
| C1 | Alice |
| C2 | Bob |

---

### `LEAD_MANAGER`

| COMPANY_CODE | LEAD_MANAGER_CODE |
|---|---|
| C1 | LM1 |
| C1 | LM2 |
| C2 | LM3 |

---

### `SENIOR_MANAGER`

| COMPANY_CODE | LEAD_MANAGER_CODE | SENIOR_MANAGER_CODE |
|---|---|---|
| C1 | LM1 | SM1 |
| C1 | LM1 | SM2 |
| C1 | LM2 | SM3 |
| C2 | LM3 | SM4 |

---

### `MANAGER`

| COMPANY_CODE | LEAD_MANAGER_CODE | SENIOR_MANAGER_CODE | MANAGER_CODE |
|---|---|---|---|
| C1 | LM1 | SM1 | M1 |
| C1 | LM1 | SM1 | M2 |
| C1 | LM1 | SM2 | M3 |
| C1 | LM2 | SM3 | M4 |
| C2 | LM3 | SM4 | M5 |

---

### `EMPLOYEE`

| COMPANY_CODE | LEAD_MANAGER_CODE | SENIOR_MANAGER_CODE | MANAGER_CODE | EMPLOYEE_CODE |
|---|---|---|---|---|
| C1 | LM1 | SM1 | M1 | E1 |
| C1 | LM1 | SM1 | M1 | E2 |
| C1 | LM1 | SM1 | M2 | E3 |
| C1 | LM1 | SM2 | M3 | E4 |
| C1 | LM2 | SM3 | M4 | E5 |
| C2 | LM3 | SM4 | M5 | E6 |

---

# Understanding the Hierarchy

The tables are connected through a chain of relationships:

```text
COMPANY
   │
   │ COMPANY_CODE
   ↓
LEAD_MANAGER
   │
   │ COMPANY_CODE
   │ LEAD_MANAGER_CODE
   ↓
SENIOR_MANAGER
   │
   │ COMPANY_CODE
   │ LEAD_MANAGER_CODE
   │ SENIOR_MANAGER_CODE
   ↓
MANAGER
   │
   │ COMPANY_CODE
   │ LEAD_MANAGER_CODE
   │ SENIOR_MANAGER_CODE
   │ MANAGER_CODE
   ↓
EMPLOYEE
```

The JOINs follow this hierarchy from top to bottom.

---

# Step 1 — Join Company and Lead Managers

The first JOIN is:

```sql id="5jxy4z"
JOIN LEAD_MANAGER L
    ON C.COMPANY_CODE = L.COMPANY_CODE
```

Suppose:

### `COMPANY`

| COMPANY_CODE | FOUNDER |
|---|---|
| C1 | Alice |

### `LEAD_MANAGER`

| COMPANY_CODE | LEAD_MANAGER_CODE |
|---|---|
| C1 | LM1 |
| C1 | LM2 |

After the JOIN:

| COMPANY_CODE | FOUNDER | LEAD_MANAGER_CODE |
|---|---|---|
| C1 | Alice | LM1 |
| C1 | Alice | LM2 |

The company information is now attached to every lead manager belonging to that company.

---

# Step 2 — Join Senior Managers

Next:

```sql id="f0g0m4"
JOIN SENIOR_MANAGER S
    ON C.COMPANY_CODE = S.COMPANY_CODE
    AND L.LEAD_MANAGER_CODE = S.LEAD_MANAGER_CODE
```

Two conditions are used.

The senior manager must belong to:

```text
Same company
        AND
Same lead manager
```

For example:

```text id="f2x8sa"
Company C1
   │
   ├── LM1
   │     ├── SM1
   │     └── SM2
   │
   └── LM2
         └── SM3
```

This prevents a senior manager belonging to another lead manager from being incorrectly matched.

---

# Step 3 — Join Managers

The next JOIN is:

```sql id="g8l4u0"
JOIN MANAGER M
    ON C.COMPANY_CODE = M.COMPANY_CODE
    AND L.LEAD_MANAGER_CODE = M.LEAD_MANAGER_CODE
    AND S.SENIOR_MANAGER_CODE = M.SENIOR_MANAGER_CODE
```

Now three levels must match:

```text
Company
   +
Lead Manager
   +
Senior Manager
```

For example:

```text id="8f1qye"
C1
└── LM1
    └── SM1
        ├── M1
        └── M2
```

After this JOIN, the query knows exactly which managers belong under each senior manager.

---

# Step 4 — Join Employees

Finally:

```sql id="f8e7u1"
JOIN EMPLOYEE E
    ON C.COMPANY_CODE = E.COMPANY_CODE
    AND L.LEAD_MANAGER_CODE = E.LEAD_MANAGER_CODE
    AND S.SENIOR_MANAGER_CODE = E.SENIOR_MANAGER_CODE
    AND M.MANAGER_CODE = E.MANAGER_CODE
```

Now all four levels must match:

```text id="7t2q0g"
Company
   +
Lead Manager
   +
Senior Manager
   +
Manager
```

For example:

```text id="7sh5zv"
C1
└── LM1
    └── SM1
        └── M1
            ├── E1
            └── E2
```

This produces the complete company hierarchy.

---

# Step 5 — Why `COUNT(DISTINCT)`?

After joining all five tables, the same manager or senior manager can appear across multiple employee rows.

For example:

```text id="n9o7n4"
M1
├── E1
└── E2
```

The JOIN result contains:

| MANAGER_CODE | EMPLOYEE_CODE |
|---|---|
| M1 | E1 |
| M1 | E2 |

If we simply used:

```sql id="i8z2n4"
COUNT(M.MANAGER_CODE)
```

we would count `M1` twice.

Instead:

```sql id="1p8j8j"
COUNT(DISTINCT M.MANAGER_CODE)
```

counts `M1` only once.

The same principle applies to lead managers and senior managers.

---

# Step 6 — Count Each Level

The SELECT contains four separate counts:

```sql id="e44w7m"
COUNT(DISTINCT L.LEAD_MANAGER_CODE)
```

Counts unique lead managers.

```sql id="0gq84k"
COUNT(DISTINCT S.SENIOR_MANAGER_CODE)
```

Counts unique senior managers.

```sql id="e2j1yd"
COUNT(DISTINCT M.MANAGER_CODE)
```

Counts unique managers.

```sql id="k21kq0"
COUNT(DISTINCT E.EMPLOYEE_CODE)
```

Counts unique employees.

Conceptually:

```text id="g1h5ol"
                 COMPANY
                    │
          ┌─────────┴─────────┐
          ↓                   ↓
    Lead Managers       Employees
          ↓
    Senior Managers
          ↓
       Managers
```

The query counts the number of unique nodes at each level.

---

# Step 7 — Group By Company

The query uses:

```sql id="4n0gwm"
GROUP BY C.COMPANY_CODE, C.FOUNDER
```

This means all rows belonging to the same company are combined into one result row.

For example, all of these:

```text id="q0q0wi"
C1 - LM1 - SM1 - M1 - E1
C1 - LM1 - SM1 - M1 - E2
C1 - LM1 - SM1 - M2 - E3
C1 - LM1 - SM2 - M3 - E4
C1 - LM2 - SM3 - M4 - E5
```

belong to company `C1`.

After grouping and counting:

| COMPANY_CODE | FOUNDER | LEAD MANAGERS | SENIOR MANAGERS | MANAGERS | EMPLOYEES |
|---|---|---:|---:|---:|---:|
| C1 | Alice | 2 | 3 | 4 | 5 |

---

# Step 8 — Final Result

For the example data, the final result would be:

| COMPANY_CODE | FOUNDER | Lead Managers | Senior Managers | Managers | Employees |
|---|---|---:|---:|---:|---:|
| C1 | Alice | 2 | 3 | 4 | 5 |
| C2 | Bob | 1 | 1 | 1 | 1 |

The query then sorts the result using:

```sql id="n1j4d5"
ORDER BY C.COMPANY_CODE
```

---

# Complete Transformation

```text id="k4qv40"
                    COMPANY
                       │
                       ↓
                JOIN LEAD_MANAGER
                       │
                       ↓
             COMPANY + LEAD MANAGERS
                       │
                       ↓
             JOIN SENIOR_MANAGER
                       │
                       ↓
          COMPANY + SENIOR MANAGERS
                       │
                       ↓
                JOIN MANAGER
                       │
                       ↓
             COMPANY + MANAGERS
                       │
                       ↓
                JOIN EMPLOYEE
                       │
                       ↓
              COMPLETE HIERARCHY
                       │
                       ↓
             COUNT DISTINCT
                       │
                       ↓
              GROUP BY COMPANY
                       │
                       ↓
                 FINAL RESULT
```

---

# Key SQL Concepts

### Multiple Table Joins

The query connects five related tables to reconstruct the complete organizational hierarchy.

### Hierarchical Relationships

Each table represents a different level:

```text
Company
   ↓
Lead Manager
   ↓
Senior Manager
   ↓
Manager
   ↓
Employee
```

### Aggregation

The query calculates the number of people at each management level for every company.

### Grouping

Results are grouped by company so that each company produces one final row.

### Avoiding Duplicate Counts

Because the JOIN creates multiple rows for employees belonging to the same manager, unique entities must be counted separately.

---

## Solution

The complete SQL solution is available in [`03_The_Company.sql`](./03_The_Company.sql).