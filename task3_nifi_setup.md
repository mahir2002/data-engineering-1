# Task 3 NiFi Setup (No XML Required)

This guide explains the NiFi flow built directly in the NiFi UI.

## Goal
Pull data from MySQL, optionally transform it, and save files locally in structured format (JSON).

## Process Group
Create a process group named: DataEngineering

## Processor Flow
1. QueryDatabaseTable
2. ConvertAvroToJSON
3. SplitJson
4. UpdateAttribute
5. PutFile

## Key Configuration

### 1) QueryDatabaseTable
- Database connection: MySQL (techreads_db)
- Table: books
- Maximum-value Columns: id
- Scheduling: every 60 sec

### 2) ConvertAvroToJSON
- Convert Avro output from QueryDatabaseTable into JSON.

### 3) SplitJson
- JsonPath: $[*]
- Splits array into one FlowFile per book record.

### 4) UpdateAttribute
- filename: book_${now():format('yyyyMMdd_HHmmss')}_${UUID()}.json

### 5) PutFile
- Directory: /tmp/techreads_output
- Conflict resolution: replace or fail (either is acceptable if explained).

## Important First-Run Fix (for "0 queued / processor not working")
1. Stop `QueryDatabaseTable`.
2. Right-click it -> **View State** -> **Clear State**.
3. Start controller service `DBCPConnectionPool` and verify it is valid.
4. Start processors from left to right.
5. Check bulletins on any processor with a warning icon and fix required properties.

If you used `ConvertRecord` instead of `ConvertAvroToJSON`, configure:
- Record Reader: `AvroReader`
- Record Writer: `JsonRecordSetWriter`
Otherwise, use `ConvertAvroToJSON` to avoid extra controller services.

## Expected Output
A JSON file is written to /tmp/techreads_output at each scheduled run.

## Evidence for Submission
- Screenshot of NiFi process group and running processors
- Screenshot of output files in /tmp/techreads_output
- Video demo showing end-to-end run with explanation

## Why No XML Is Needed
The brief asks for a working NiFi dataflow and a video demonstration. XML export is optional backup material, not a mandatory submission format.
