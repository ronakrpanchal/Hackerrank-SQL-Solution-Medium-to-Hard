# Binary Tree Nodes

**Platform:** HackerRank  
**Difficulty:** Medium  
**Topics:** Conditional Logic, Subqueries, Tree Structure, Classification

---

## Problem

You are given a binary tree represented by the `BST` table.

Each row contains:

- `N` — the value of the node
- `P` — the value of its parent node

The goal is to determine whether each node is:

- **Root** — has no parent
- **Inner** — has a parent and at least one child
- **Leaf** — has a parent but no children

The result should be ordered by `N`.

---

# Given Table

### `BST`

Consider this example:

| N | P |
|---:|---:|
| 1 | 2 |
| 2 | 5 |
| 3 | 2 |
| 4 | 5 |
| 5 | NULL |
| 6 | 7 |
| 7 | 5 |

The tree represented by this table is:

```text
             5
           /   \
          2     7
         / \     \
        1   3     6
       /
      4
```

More accurately, based on the parent relationships:

```text
              5
            /   \
           2     7
          / \     \
         1   3     6
         |
         4
```

---

# Step 1 — Identify the Root

The first condition is:

```sql
CASE
    WHEN P IS NULL THEN 'Root'
```

A root node has **no parent**.

From the table:

| N | P |
|---:|---:|
| 5 | NULL |

Therefore:

```text
N = 5
P = NULL
     ↓
Root
```

So node `5` is classified as the Root.

---

# Step 2 — Find Nodes That Have Children

The next condition is:

```sql
WHEN N IN (SELECT P FROM BST) THEN 'Inner'
```

The subquery:

```sql
SELECT P
FROM BST
```

returns all values that appear in the `P` column.

From our example:

| P |
|---:|
| 2 |
| 5 |
| 2 |
| 5 |
| NULL |
| 7 |
| 5 |

Ignoring `NULL`, the important values are:

```text
2
5
7
```

These are node values that appear as someone's parent.

Therefore:

```text
If N appears in P
        ↓
N has at least one child
        ↓
N is an Inner node
```

---

# Step 3 — Classify the Nodes

Now evaluate each node.

### Node 1

```text
N = 1
P = 2
```

`P` is not `NULL`.

Check:

```text
Is 1 present in the P column?
```

No.

Therefore:

```text
1 → Leaf
```

---

### Node 2

```text
N = 2
P = 5
```

`P` is not `NULL`.

Check:

```text
Is 2 present in the P column?
```

Yes.

Therefore:

```text
2 → Inner
```

---

### Node 3

```text
N = 3
P = 2
```

`3` does not appear in the `P` column.

Therefore:

```text
3 → Leaf
```

---

### Node 5

```text
N = 5
P = NULL
```

The first condition is true:

```sql
P IS NULL
```

Therefore:

```text
5 → Root
```

The query does not need to evaluate the later conditions because the first matching `WHEN` is used.

---

### Node 6

```text
N = 6
P = 7
```

`6` does not appear in the `P` column.

Therefore:

```text
6 → Leaf
```

---

### Node 7

```text
N = 7
P = 5
```

`7` appears in the `P` column because node `6` has:

```text
P = 7
```

Therefore:

```text
7 → Inner
```

---

# Step 4 — The `CASE` Logic

The entire classification can be thought of as:

```text
                 Node
                   │
                   ↓
             Is P NULL?
              /       \
            YES        NO
             ↓          ↓
           Root     Does N appear
                    in P column?
                      /     \
                    YES      NO
                     ↓        ↓
                   Inner    Leaf
```

The SQL implements exactly this decision process:

```sql
CASE
    WHEN P IS NULL THEN 'Root'
    WHEN N IN (SELECT P FROM BST) THEN 'Inner'
    ELSE 'Leaf'
END
```

---

# Step 5 — Final Result

After classifying every node:

| N | P | Classification |
|---:|---:|---|
| 1 | 2 | Leaf |
| 2 | 5 | Inner |
| 3 | 2 | Leaf |
| 4 | 5 | Leaf |
| 5 | NULL | Root |
| 6 | 7 | Leaf |
| 7 | 5 | Inner |

The query only selects `N` and the classification:

| N | Type |
|---:|---|
| 1 | Leaf |
| 2 | Inner |
| 3 | Leaf |
| 4 | Leaf |
| 5 | Root |
| 6 | Leaf |
| 7 | Inner |

---

# Why the Subquery Works

The key part is:

```sql
N IN (SELECT P FROM BST)
```

Think of it as asking:

> **"Does this node's value appear as a parent somewhere in the table?"**

If yes, that means another node points to it.

For example:

```text
N = 2

BST contains:

N = 1, P = 2
N = 3, P = 2
```

Therefore `2` is someone's parent.

```text
2 → has children → Inner
```

But:

```text
N = 3
```

There is no row where:

```text
P = 3
```

Therefore:

```text
3 → has no children → Leaf
```

---

# Complete Transformation

```text
                       BST
                        │
                        ↓
              Check P IS NULL
                  /          \
                YES           NO
                 ↓             ↓
               ROOT       Check whether
                          N exists in P
                            /       \
                          YES        NO
                           ↓          ↓
                         INNER      LEAF
```

The final result is then:

```text
ORDER BY N
```

which sorts the nodes numerically.

---

# Key SQL Concepts

### Conditional Logic

The `CASE` expression evaluates each node and assigns it to one of three categories.

### Subqueries

The inner query checks the parent column to determine whether the current node has children.

### Tree Relationships

The `N` and `P` columns represent the relationship between a node and its parent.

### Classification

Each node is classified based on its position in the tree:

```text
P IS NULL
    → Root

N appears as P
    → Inner

Otherwise
    → Leaf
```

---

## Solution

The complete SQL solution is available in [`04_Binary_Tree_Nodes.sql`](./04_Binary_Tree_Nodes.sql).