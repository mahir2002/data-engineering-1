# TechReads Data Engineering Pipeline - Complete Commands Reference

## Table of Contents
1. [Environment Setup](#environment-setup)
2. [MongoDB Commands](#mongodb-commands)
3. [PyMongo/Python Commands](#pymongopython-commands)
4. [MySQL Commands](#mysql-commands)
5. [Terminal/Shell Commands](#terminalshell-commands)
6. [Data Pipeline Execution](#data-pipeline-execution)
7. [Troubleshooting Commands](#troubleshooting-commands)

---

## Environment Setup

### Virtual Environment
```bash
# Create virtual environment
python3 -m venv .venv

# Activate virtual environment (macOS/Linux)
source .venv/bin/activate

# Activate virtual environment (Windows)
.venv\Scripts\activate

# Deactivate virtual environment
deactivate

# Install dependencies
pip install -r requirements.txt

# Install specific packages
pip install pandas requests beautifulsoup4 mysql-connector-python pymongo
```

### Install Required Packages
```bash
# For web scraping (Task 1)
pip install requests beautifulsoup4

# For data processing
pip install pandas

# For MySQL
pip install mysql-connector-python

# For MongoDB
pip install pymongo

# For PDF generation
pip install reportlab
```

---

## MongoDB Commands

### MongoDB Server Management

```bash
# Start MongoDB server (macOS with Homebrew)
brew services start mongodb-community

# Stop MongoDB server
brew services stop mongodb-community

# Check MongoDB status
brew services list | grep mongodb

# Start MongoDB manually
mongod --config /usr/local/etc/mongod.conf

# Connect to MongoDB shell
mongo
# or newer version:
mongosh

# Quit MongoDB shell
exit
```

### MongoDB CLI Commands

```bash
# Show all databases
show dbs

# Use a specific database
use techreads_db

# Show all collections in current database
show collections

# Show all documents in a collection
db.books.find()

# Pretty print documents
db.books.find().pretty()

# Count documents
db.books.countDocuments()

# Drop a database
db.dropDatabase()

# Drop a collection
db.books.drop()

# Create an index
db.books.createIndex({ "rating": 1 })

# List all indexes
db.books.getIndexes()

# Drop an index
db.books.dropIndex("idx_rating")
```

---

## PyMongo/Python Commands

### Connection & Authentication

```python
# Import MongoClient
from pymongo import MongoClient, ASCENDING, DESCENDING

# Connect to MongoDB (default local)
client = MongoClient('mongodb://localhost:27017/')

# Connect with timeout
client = MongoClient('mongodb://localhost:27017/', serverSelectionTimeoutMS=5000)

# Access database
db = client['techreads_db']

# Access collection
collection = db['books']

# Or chained
collection = client['techreads_db']['books']

# Close connection
client.close()
```

### Basic CRUD Operations

```python
# INSERT single document
collection.insert_one({'title': 'Data Engineering 101', 'author': 'Jane Doe'})

# INSERT many documents
docs = [
    {'title': 'Book 1', 'author': 'Author 1'},
    {'title': 'Book 2', 'author': 'Author 2'}
]
collection.insert_many(docs)

# FIND single document
doc = collection.find_one({'title': 'Data Engineering 101'})

# FIND all documents
all_docs = collection.find({})

# FIND with projection (select specific fields)
PROJ = {'_id': 0, 'title': 1, 'author': 1, 'price': 1}
docs = collection.find({}, PROJ)

# FIND with filter
high_rated = collection.find({'rating': {'$gte': 4}}, PROJ)

# UPDATE single document
collection.update_one(
    {'title': 'Data Engineering 101'},
    {'$set': {'price': 29.99}}
)

# UPDATE with upsert (insert if not found)
collection.update_one(
    {'book_url': 'http://example.com/book'},
    {'$set': {'title': 'New Title', 'price': 19.99}},
    upsert=True
)

# DELETE single document
collection.delete_one({'title': 'Old Book'})

# DELETE many documents
collection.delete_many({'rating': {'$lt': 2}})
```

### Query Operators

```python
# Comparison operators
{'rating': {'$gte': 4}}          # Greater than or equal
{'rating': {'$gt': 4}}           # Greater than
{'price': {'$lte': 20.0}}        # Less than or equal
{'price': {'$lt': 20.0}}         # Less than
{'year': {'$eq': 2020}}          # Equal
{'year': {'$ne': 2020}}          # Not equal

# Logical operators
{'$and': [{'rating': {'$gte': 4}}, {'price': {'$lte': 20}}]}
{'$or': [{'author': 'John'}, {'author': 'Jane'}]}
{'$nor': [{'rating': {'$lt': 2}}]}

# Array operators
{'tags': {'$in': ['python', 'data']}}
{'tags': {'$nin': ['fiction', 'novel']}}
{'tags': {'$elemMatch': {'$eq': 'programming'}}}

# String operators (regex)
{'title': {'$regex': 'data', '$options': 'i'}}  # Case-insensitive
```

### Sorting, Limiting, and Aggregation

```python
# SORT ascending
collection.find({}).sort('price', ASCENDING)

# SORT descending
collection.find({}).sort('price', DESCENDING)

# LIMIT results
collection.find({}).limit(10)

# SKIP results (pagination)
collection.find({}).skip(20).limit(10)

# Chained operations
collection.find({'rating': {'$gte': 4}}) \
    .sort('price', DESCENDING) \
    .limit(5)

# COUNT documents
count = collection.count_documents({'rating': {'$gte': 4}})

# COUNT all
total = collection.count_documents({})
```

### Indexing

```python
# Create single field index (ascending)
collection.create_index([('rating', ASCENDING)], name='idx_rating')

# Create single field index (descending)
collection.create_index([('price', DESCENDING)], name='idx_price')

# Create compound index
collection.create_index(
    [('author', ASCENDING), ('publication_year', DESCENDING)],
    name='idx_author_year'
)

# Create unique index
collection.create_index([('book_url', ASCENDING)], unique=True)

# Get all indexes
indexes = collection.list_indexes()
for idx in indexes:
    print(idx)

# Drop index by name
collection.drop_index('idx_rating')

# Drop all indexes (except _id)
collection.drop_indexes()

# Get index info
collection.index_information()
```

### Bulk Operations

```python
# Bulk write operations
from pymongo import UpdateOne, InsertOne, DeleteOne

operations = [
    InsertOne({'title': 'New Book', 'price': 25}),
    UpdateOne({'book_url': 'url1'}, {'$set': {'price': 30}}),
    DeleteOne({'rating': {'$lt': 1}})
]
result = collection.bulk_write(operations)
```

### Aggregation Pipeline

```python
# Sample aggregation: group by author and count books
pipeline = [
    {'$group': {'_id': '$author', 'count': {'$sum': 1}}},
    {'$sort': {'count': -1}}
]
results = list(collection.aggregate(pipeline))

# Filter, project, and limit
pipeline = [
    {'$match': {'rating': {'$gte': 4}}},
    {'$project': {'title': 1, 'price': 1, '_id': 0}},
    {'$limit': 10}
]
results = list(collection.aggregate(pipeline))
```

### Error Handling

```python
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError

try:
    client = MongoClient('mongodb://localhost:27017/', serverSelectionTimeoutMS=5000)
    collection = client['techreads_db']['books']
    result = collection.find_one()
    print("Connection successful")
except (ConnectionFailure, ServerSelectionTimeoutError) as e:
    print(f"MongoDB connection error: {e}")
except Exception as e:
    print(f"Error: {e}")
finally:
    if client:
        client.close()
```

---

## MySQL Commands

### MySQL Server Management

```bash
# Start MySQL server (macOS with Homebrew)
brew services start mysql

# Stop MySQL server
brew services stop mysql

# Check MySQL status
brew services list | grep mysql

# Connect to MySQL via terminal
mysql -u root -p
# Then enter password when prompted
```

### MySQL CLI Commands

```bash
# Login to MySQL
mysql -u root -p

# Show all databases
SHOW DATABASES;

# Create database
CREATE DATABASE techreads_db;

# Use/select database
USE techreads_db;

# Show all tables
SHOW TABLES;

# Show table structure
DESCRIBE books;
DESC books;

# Quit MySQL
EXIT;
quit
```

### MySQL SQL Commands (Task 2)

```sql
-- Create table
CREATE TABLE books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    publication_year INT,
    price DECIMAL(10, 2),
    rating INT,
    book_url VARCHAR(1024),
    scraped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert single row
INSERT INTO books (title, author, publication_year, price, rating, book_url)
VALUES ('Data Engineering 101', 'Jane Doe', 2020, 29.99, 5, 'http://example.com');

-- Insert multiple rows
INSERT INTO books (title, author, price, rating) VALUES
('Book 1', 'Author 1', 25.00, 4),
('Book 2', 'Author 2', 35.00, 5);

-- SELECT all columns
SELECT * FROM books;

-- SELECT specific columns
SELECT title, author, price FROM books;

-- SELECT with WHERE (Q1 - rating filter)
SELECT title, author, publication_year, price, rating FROM books 
WHERE rating >= 4;

-- SELECT with WHERE (Q2 - price filter)
SELECT title, author, publication_year, price, rating FROM books 
WHERE price <= 20;

-- SELECT with ORDER BY (Q3 - sort by price)
SELECT title, author, publication_year, price, rating FROM books 
ORDER BY price DESC LIMIT 10;

-- SELECT with WHERE (Q4 - year filter)
SELECT title, author, publication_year, price, rating FROM books 
WHERE publication_year > 2018;

-- COUNT rows
SELECT COUNT(*) FROM books;

-- UPDATE row
UPDATE books SET rating = 5 WHERE title = 'Data Engineering 101';

-- DELETE row
DELETE FROM books WHERE rating < 1;

-- CREATE index
CREATE INDEX idx_rating ON books(rating);
CREATE INDEX idx_price ON books(price DESC);
CREATE INDEX idx_year ON books(publication_year);

-- SHOW indexes
SHOW INDEXES FROM books;

-- DROP index
DROP INDEX idx_rating ON books;

-- DROP table
DROP TABLE books;

-- DROP database
DROP DATABASE techreads_db;
```

### PyMySQL/mysql-connector-python Commands

```python
# Import connector
import mysql.connector as mc

# Define connection config
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'your_password',
    'database': 'techreads_db'
}

# Connect to MySQL
conn = mc.connect(**DB_CONFIG)

# Create cursor
cursor = conn.cursor()

# Execute query
cursor.execute("SELECT * FROM books WHERE rating >= 4;")

# Fetch results
results = cursor.fetchall()
for row in results:
    print(row)

# Fetch single row
row = cursor.fetchone()

# Fetch all rows
all_rows = cursor.fetchall()

# Get row count
cursor.execute("SELECT COUNT(*) FROM books;")
count = cursor.fetchone()[0]

# Execute INSERT with parameters (SQL injection safe)
sql = "INSERT INTO books (title, author, price) VALUES (%s, %s, %s)"
values = ('Data Engineering', 'John Doe', 29.99)
cursor.execute(sql, values)

# Execute INSERT many
sql = "INSERT INTO books (title, author, price) VALUES (%s, %s, %s)"
values = [
    ('Book 1', 'Author 1', 25.00),
    ('Book 2', 'Author 2', 35.00),
]
cursor.executemany(sql, values)

# Commit changes
conn.commit()

# Close cursor
cursor.close()

# Close connection
conn.close()

# Error handling
try:
    conn = mc.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM books;")
    results = cursor.fetchall()
except mc.Error as err:
    print(f"Error: {err}")
finally:
    cursor.close()
    conn.close()
```

---

## Terminal/Shell Commands

### File & Directory Management

```bash
# List files
ls
ls -la                          # Long format with hidden files
ls -lh                          # Human-readable sizes

# Change directory
cd /path/to/directory
cd ~                            # Home directory
cd ..                           # Parent directory
cd -                            # Previous directory

# Print working directory
pwd

# Create directory
mkdir directory_name
mkdir -p path/to/nested         # Create nested directories

# Remove file
rm filename

# Remove directory
rmdir empty_directory
rm -r directory_name            # Remove non-empty directory

# Move/rename file
mv old_name new_name

# Copy file
cp source destination
cp -r source_dir dest_dir       # Copy directory

# View file contents
cat filename
less filename
head -n 20 filename             # First 20 lines
tail -n 20 filename             # Last 20 lines

# Find files
find . -name "*.csv"
find . -type f -name "*.py"
find . -type d -name "data"

# Search in files
grep "pattern" filename
grep -r "pattern" .             # Recursive search
grep -i "pattern" filename      # Case-insensitive

# Count lines in file
wc -l filename

# File size
du -h filename
du -sh directory                # Directory size

# Permissions
chmod 755 script.sh
chmod +x script.sh              # Make executable
```

### Git Commands (Version Control)

```bash
# Initialize repository
git init

# Clone repository
git clone https://github.com/user/repo.git

# Check status
git status

# Stage changes
git add filename
git add .                       # Stage all changes

# Commit changes
git commit -m "Commit message"
git commit -am "Commit message" # Stage and commit tracked files

# View commit history
git log
git log --oneline
git log --graph --all --oneline

# Pull latest changes
git pull

# Push changes
git push

# Create branch
git branch branch_name
git checkout -b branch_name     # Create and switch

# Switch branch
git checkout branch_name

# Merge branch
git merge branch_name

# Delete branch
git branch -d branch_name
```

---

## Data Pipeline Execution

### Running the Jupyter Notebook

```bash
# Start Jupyter Lab
jupyter lab

# Start Jupyter Notebook
jupyter notebook

# Run notebook from command line
jupyter nbconvert --to notebook --execute CW1_Pipeline.ipynb

# Convert notebook to PDF
jupyter nbconvert --to pdf CW1_Pipeline.ipynb

# Convert notebook to HTML
jupyter nbconvert --to html CW1_Pipeline.ipynb
```

### Running Python Scripts

```bash
# Run Python script
python3 script.py

# Run with arguments
python3 script.py arg1 arg2

# Run in interactive mode
python3 -i script.py

# Run Python module
python3 -m module_name

# Execute Python code string
python3 -c "print('Hello World')"

# Check Python version
python3 --version

# Get Python path
which python3
```

### Data Processing Commands

```bash
# View CSV file
head techreads_books.csv
head -n 5 techreads_books.csv   # First 5 lines

# Count CSV rows
wc -l techreads_books.csv

# View CSV with column preview
cut -d',' -f1-3 techreads_books.csv | head

# Sort CSV by column
sort -t',' -k1 techreads_books.csv

# Filter CSV with grep
grep "data engineering" techreads_books.csv
```

---

## Troubleshooting Commands

### System & Network Diagnostics

```bash
# Check if port is open
lsof -i :27017                  # MongoDB
lsof -i :3306                   # MySQL

# Check if service is running
ps aux | grep mongod
ps aux | grep mysql

# Check network connectivity
ping localhost
telnet localhost 27017          # Test MongoDB connection
telnet localhost 3306           # Test MySQL connection

# List all processes
ps aux

# Kill process by PID
kill -9 process_id

# Kill process by name
pkill -f mongod
pkill -f mysql
```

### Python Diagnostics

```bash
# Check installed packages
pip list
pip list | grep pymongo

# Show package info
pip show pymongo

# Check Python path
python3 -c "import sys; print(sys.path)"

# Check import
python3 -c "import pymongo; print(pymongo.__version__)"

# List installed packages with versions
python3 -m pip list
```

### Log Viewing

```bash
# View syslog
tail -f /var/log/system.log      # macOS

# View MongoDB logs
tail -f /usr/local/var/log/mongodb/mongo.log

# View MySQL logs
tail -f /usr/local/var/mysql/mysql.log
```

### Environment Diagnostics

```bash
# Show environment variables
env
printenv

# Set environment variable
export VAR_NAME=value

# Check specific variable
echo $PATH
echo $PYTHONPATH

# View Python sys info
python3 -c "import sys; print(sys.version); print(sys.platform)"

# Disk space
df -h
du -h ~/                         # User directory size
```

---

## Complete Task 4 Workflow (All in Order)

### Step 1: Start Services
```bash
# Terminal 1 - Start MongoDB
brew services start mongodb-community
mongosh admin

# Terminal 2 - Connect Python
source .venv/bin/activate
python3
```

### Step 2: Run MongoDB Initialization
```python
from pymongo import MongoClient, ASCENDING, DESCENDING
import pandas as pd

# Connect to MongoDB
client = MongoClient('mongodb://localhost:27017/', serverSelectionTimeoutMS=5000)
collection = client['techreads_db']['books']

# Load CSV data
df = pd.read_csv('data/techreads_books.csv')

# Upsert each row
for _, row in df.iterrows():
    doc = {
        'book_url': row['book_url'],
        'title': row['title'],
        'author': row['author'],
        'publication_year': int(row['year']) if pd.notna(row['year']) else None,
        'price': float(str(row['price']).replace('£', '').replace('$', '')),
        'rating': int(row['star_rating']),
        'scraped_at': row['scraped_at']
    }
    collection.update_one({'book_url': doc['book_url']}, {'$set': doc}, upsert=True)

print(f"Total documents: {collection.count_documents({})}")
```

### Step 3: Execute Queries
```python
# Q1: Rating >= 4
q1 = list(collection.find({'rating': {'$gte': 4}}))
print(f"Q1 Results: {len(q1)} books")

# Q2: Price <= 20
q2 = list(collection.find({'price': {'$lte': 20.0}}))
print(f"Q2 Results: {len(q2)} books")

# Q3: Sort by price DESC (top 10)
q3 = list(collection.find({}).sort('price', DESCENDING).limit(10))
print(f"Q3 Results: {len(q3)} books")

# Q4: Publication year > 2018
q4 = list(collection.find({'publication_year': {'$gt': 2018}}))
print(f"Q4 Results: {len(q4)} books")
```

### Step 4: Create Indexes
```python
collection.drop_indexes()  # Reset
collection.create_index([('rating', ASCENDING)], name='idx_rating')
collection.create_index([('price', DESCENDING)], name='idx_price')
collection.create_index([('publication_year', ASCENDING)], name='idx_year')
print("Indexes created successfully")

# Verify indexes
for idx in collection.list_indexes():
    print(idx)
```

### Step 5: Performance Testing
```python
import time

# Test Q1 performance
times = []
for _ in range(10):
    t0 = time.perf_counter()
    list(collection.find({'rating': {'$gte': 4}}))
    times.append((time.perf_counter() - t0) * 1000)

avg_time = sum(times) / len(times)
print(f"Q1 Average time: {avg_time:.3f}ms")
```

### Step 6: Cleanup
```bash
# Close Python
exit()

# Stop services
brew services stop mongodb-community
deactivate
```

---

## Quick Reference Cheat Sheet

| Task | Command |
|------|---------|
| Start MongoDB | `brew services start mongodb-community` |
| Start MySQL | `brew services start mysql` |
| Activate venv | `source .venv/bin/activate` |
| Install packages | `pip install -r requirements.txt` |
| Connect to MongoDB | `mongosh` |
| Connect to MySQL | `mysql -u root -p` |
| Run Jupyter | `jupyter lab` |
| Run notebook | `jupyter nbconvert --to notebook --execute CW1_Pipeline.ipynb` |
| Convert to PDF | `jupyter nbconvert --to pdf CW1_Pipeline.ipynb` |
| View CSV | `head -20 data/techreads_books.csv` |
| Check MongoDB | `lsof -i :27017` |
| Check MySQL | `lsof -i :3306` |
| Kill MongoDB | `pkill -f mongod` |
| Kill MySQL | `pkill -f mysql` |

---

## Additional Resources

- **MongoDB Documentation**: https://docs.mongodb.com/
- **PyMongo Documentation**: https://pymongo.readthedocs.io/
- **MySQL Documentation**: https://dev.mysql.com/doc/
- **Jupyter Documentation**: https://jupyter.readthedocs.io/
- **Python Documentation**: https://docs.python.org/3/

