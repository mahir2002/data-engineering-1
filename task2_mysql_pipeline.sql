-- =============================================================================
-- Task 2: MySQL Database Pipeline
-- TechReads Books Database Setup and Queries
-- =============================================================================

-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS techreads_db;
USE techreads_db;

-- Step 2: Drop existing table if present (for clean runs)
DROP TABLE IF EXISTS books;

-- Step 3: Create Table Schema
-- Schema design choices:
--   - DECIMAL(10,2) for price to avoid floating-point rounding
--   - TINYINT for rating (1-5) for efficient storage
--   - UNIQUE constraint on book_url to prevent duplicates
--   - InnoDB engine for ACID compliance
CREATE TABLE books (
    id               INT           AUTO_INCREMENT PRIMARY KEY,
    book_url         VARCHAR(500)  NOT NULL UNIQUE,
    title            VARCHAR(255)  NOT NULL,
    author           VARCHAR(255),
    publication_year INT,
    price            DECIMAL(10,2) NOT NULL,
    rating           TINYINT       NOT NULL,
    scraped_at       DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- Step 4: Load Data from CSV
-- =============================================================================
-- Note: This is typically done programmatically (see Python notebook)
-- Example for manual LOAD DATA INFILE (adjust path as needed):
-- LOAD DATA LOCAL INFILE '/Users/ecomeman/Data engineering 1/data/techreads_books.csv'
-- INTO TABLE books
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (title, author, @year, rating, @price, book_url, scraped_at)
-- SET
--     publication_year = NULLIF(@year, 'N/A'),
--     price = CAST(REPLACE(REPLACE(@price, '£', ''), 'GBP', '') AS DECIMAL(10,2));

-- Alternative: Use INSERT statements with ON DUPLICATE KEY UPDATE for idempotency
-- INSERT INTO books (book_url, title, author, publication_year, price, rating, scraped_at)
-- VALUES (?, ?, ?, ?, ?, ?, ?)
-- ON DUPLICATE KEY UPDATE
--     title=VALUES(title),
--     author=VALUES(author),
--     publication_year=VALUES(publication_year),
--     price=VALUES(price),
--     rating=VALUES(rating),
--     scraped_at=VALUES(scraped_at);

-- =============================================================================
-- Step 5: REQUIRED QUERY - Extract 3 columns and sort by price
-- =============================================================================
-- This query fulfills the Task 2 requirement:
-- "Run a SQL query that extracts three selected columns, then sort results
--  by any one column (e.g., price or rating)"

SELECT title, price, rating
FROM books
ORDER BY price DESC
LIMIT 15;

-- Expected output format:
-- Title                                            Price  Rating
-- --------------------------------------------------------------
-- Fundamentals of Music Processing                 96.46       5
-- Inside SAP BusinessObjects Explorer              94.87       4
-- Business unIntelligence                          86.92       3
-- ... (etc.)

-- =============================================================================
-- Additional Queries for Analysis
-- =============================================================================

-- Extended 5-column query with author and publication year
SELECT title, author, publication_year, price, rating
FROM books
ORDER BY price DESC
LIMIT 10;

-- Filter by rating (books rated 4 or higher)
SELECT title, author, price, rating
FROM books
WHERE rating >= 4
ORDER BY price DESC;

-- Filter by publication year (recent books)
SELECT title, author, publication_year, price, rating
FROM books
WHERE publication_year > 2018
ORDER BY publication_year DESC;

-- =============================================================================
-- Step 6: Create Indexes for Performance (LO4 - Indexing)
-- =============================================================================

-- Drop existing indexes if they exist (for clean reruns)
DROP INDEX IF EXISTS idx_price ON books;
DROP INDEX IF EXISTS idx_rating ON books;

-- Index on price - accelerates ORDER BY price queries
CREATE INDEX idx_price ON books (price);

-- Index on rating - accelerates WHERE rating >= X queries
CREATE INDEX idx_rating ON books (rating);

-- =============================================================================
-- Verification Queries
-- =============================================================================

-- Count total books in database
SELECT COUNT(*) AS total_books FROM books;

-- Check for duplicates by book_url (should return 0)
SELECT book_url, COUNT(*) as count
FROM books
GROUP BY book_url
HAVING count > 1;

-- View table schema
DESCRIBE books;

-- Show all indexes
SHOW INDEX FROM books;

-- =============================================================================
-- Performance Testing: Before and After Indexes
-- =============================================================================

-- Test 1: ORDER BY price (exercises idx_price)
-- Run EXPLAIN before and after index creation to see query plan differences
EXPLAIN SELECT title, price, rating FROM books ORDER BY price DESC LIMIT 15;

-- Test 2: WHERE rating filter (exercises idx_rating)
EXPLAIN SELECT title, author, price, rating FROM books WHERE rating >= 4 ORDER BY price DESC;

-- =============================================================================
-- End of Task 2 SQL Pipeline
-- Database: techreads_db
-- Table: books
-- Schema: id | book_url | title | author | publication_year | price | rating | scraped_at
-- =============================================================================
