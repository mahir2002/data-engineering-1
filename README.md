# Data Engineering CW1 Pipeline

This repository contains an end-to-end coursework pipeline for data engineering using:

- Open Library API scraping
- MySQL relational storage and query indexing
- Apache NiFi flow automation
- MongoDB document storage and SQL vs NoSQL comparison

## Repository Structure

- `CW1_Pipeline.ipynb` - Main notebook containing Task 1 to Task 4
- `task2_mysql_pipeline.sql` - SQL script for MySQL pipeline task
- `task3_nifi_setup.md` - Notes and setup details for NiFi workflow
- `COMMANDS_REFERENCE.md` - Command reference used during implementation
- `data/techreads_books.csv` - Scraped and processed dataset output

## Pipeline Summary

1. **Task 1: Data Collection**
- Scrapes Open Library search API for data engineering related books.
- Filters results by relevant keywords.
- Produces CSV output with fields:
  - `title`
  - `author`
  - `year`
  - `star_rating`
  - `price`
  - `book_url`
  - `scraped_at`

2. **Task 2: MySQL Integration**
- Creates database and `books` table.
- Loads CSV rows using idempotent upsert logic.
- Benchmarks queries with and without indexes.

3. **Task 3: NiFi Automation**
- Automates extraction from MySQL and JSON output generation.
- Uses scheduled NiFi processors to reduce manual runs.

4. **Task 4: MongoDB Integration and Comparison**
- Upserts records into MongoDB collection.
- Runs equivalent analytical queries.
- Compares MySQL vs MongoDB query timings before and after indexing.

## Prerequisites

- Python 3.10+
- Jupyter Notebook
- MySQL Server (local)
- MongoDB Server (local)
- Apache NiFi

Python packages used in the notebook:

- `pandas`
- `requests`
- `beautifulsoup4`
- `mysql-connector-python`
- `pymongo`

Install with:

```bash
pip install pandas requests beautifulsoup4 mysql-connector-python pymongo
```

## How To Run

1. Open `CW1_Pipeline.ipynb`.
2. Run cells in order from top to bottom.
3. Ensure MySQL and MongoDB services are running before Task 2 and Task 4.
4. Verify output CSV is generated at `data/techreads_books.csv`.

## Notes

- The notebook includes timing-based performance comparisons for index effectiveness.
- The MySQL and MongoDB stages use upsert patterns to support safe re-runs.

## Author

Mahir
