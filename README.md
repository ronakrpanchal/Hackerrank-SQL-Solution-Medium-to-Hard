# HackerRank SQL — Medium to Hard

A collection of my solutions to **Medium and Hard SQL problems from HackerRank**, with a focus on understanding how SQL transforms data step by step.

The repository contains both the **SQL solutions** and detailed **visual explanations of the intermediate tables** produced during each query.

---

## 📌 What This Repository Contains

Each problem has two files:

```text
Problem_Name.sql
Problem_Name.md
```

### `.sql`

Contains the complete SQL solution to the problem.

### `.md`

Contains a step-by-step breakdown of the query, including:

- Input tables
- Important columns and relationships
- Intermediate tables
- CTE results
- JOIN results
- Aggregations
- Window function results
- Final output
- Explanation of the SQL logic

The goal is to make it possible to understand **what happens to the data at every major step of the query**, rather than only looking at the final SQL.

---

## 🧠 SQL Topics Covered

The problems in this repository cover concepts such as:

- Common Table Expressions (`WITH`)
- Multiple CTEs
- `INNER JOIN`
- `LEFT JOIN`
- `RIGHT JOIN`
- Self Joins
- `GROUP BY`
- `HAVING`
- Aggregate Functions
- Subqueries
- `DISTINCT`
- `CASE`
- `COALESCE`
- Window Functions
- `ROW_NUMBER()`
- `RANK()`
- `DENSE_RANK()`
- `PARTITION BY`
- `ORDER BY`
- Date Functions
- String Functions
- Conditional Aggregation
- Complex Query Composition

---

## 🔍 How the Explanations Work

For problems involving complex SQL, the `.md` file breaks the query into smaller transformations.

The general approach is:

```text
Original Tables
      ↓
    CTE 1
      ↓
Intermediate Table
      ↓
    CTE 2
      ↓
Intermediate Table
      ↓
     JOIN
      ↓
Aggregated Result
      ↓
Final Result
```

Instead of treating a complex query as one large block, each transformation is shown separately.

---

## 🎯 Purpose

This repository is primarily for:

- Practicing SQL
- Preparing for SQL interviews
- Revising difficult SQL concepts
- Understanding CTEs and JOINs
- Learning how intermediate query results are formed
- Keeping a reference for previously solved problems

The emphasis is on **understanding the process behind the query**, not just memorizing the final solution.

---

## 🏆 HackerRank

These solutions are based on problems available on HackerRank.

The repository is intended for **learning and reference purposes**.

If you like this repository, please give it a star 💫.
