# Database-Management-System-(DBMS)

is a fully functional Database Management System built entirely using **Bash Scripting**. It simulates a Relational Database Management System (RDBMS) directly on the Linux file system without relying on any external database engines like MySQL or PostgreSQL.
This project demonstrates advanced proficiency in **Shell Scripting**, **File Manipulation**, and **Text Processing** using tools like `awk`, `sed`, and `grep`.

# =====================================================================================================================================================================

## 🏗️ Architecture & Design

The system follows a flat-file database model where the file system structure mirrors a database schema:

## | Database Concept | Implementation in BashDBMS |

| **Database** | A **Directory** inside the project folder. |
| **Table** | A **Flat File** storing records. |
| **Record (Row)** | A single line in the file. |
| **Field (Column)** | Data separated by a delimiter (`:`). |
| **Metadata** | A hidden or separate file (e.g., `.meta`) storing schema details (Type, PK) **Example:** `int:PK`. |

# =====================================================================================================================================================================

## ✨ Key Features

### 1. Database Management (DDL)

- **Create Database:** Creates a new directory storage for tables.
- **List Databases:** Displays available databases.
- **Connect to Database:** Validates existence and switches context to the selected DB.
- **Drop Database:** Safely removes the database directory after user confirmation.

### 2. Table Management (DDL)

- **Create Table:**
  - Allows defining multiple columns.
  - **Data Types Supported:** `Integer`, `String`.
  - **Primary Key Configuration:** Users can set a specific column as a Primary Key (PK) , there must be only one PK in each table.
- **List Tables:** Shows all tables in the current database.
- **Drop Table:** Deletes the table file and its associated metadata.

### 3. Data Manipulation (DML)

- **Insert Data:**
  - **Validation:** Checks if the input matches the column type (int vs string).
  - **PK Constraint:** Prevents duplicate values in the Primary Key column.
  - **Sanitization:** Prevents entering the delimiter (`:`) in data fields.
- **Select Data:** Displays the entire table in formatted way.
- **Delete Data:** Removes a specific row based on the Primary Key.
- **Update Data:**
  - Modifies a specific field in a specific row.
  - **Smart Validation:** Checks the data type of the new value before updating.

# =====================================================================================================================================================================

## 🚀 Follow these steps to set up and run the project on your local machine.

### Step 1: Clone the Repository

```bash
git clone [https://github.com/YourUsername/BashDBMS.git](https://github.com/YourUsername/BashDBMS.git)
cd BashDBMS

### Step 2: Grant Execution Permissions
# Ensure all scripts are executable.
chmod +x *.sh

### Step 3: Run the Application
# Start the main engine.
--> ./DBMS
            Welcome to the Simple File-based DBMS.....
            Please select a number of action you want:
            1. Create Database
            2. List Databases
            3. Connect To Database
            4. Drop Database
            1) 1
            2) 2
            3) 3
            4) 4
            #? enter the number of the option you want to excute



1. to Creating a Table
After create and connecting to a database, choose "Create Table".
Enter Table Name.
Specify the number of columns.
For each column: Enter Name -> Choose Type (int/string) -> Set as PK (Yes/No).


2. to Inserte Data in your table
After create and connecting to a database, Choose "Insert into Table".
The system will ask for values column by column.
Note: If you enter text in an int column, the system will reject it.


3. to Update Data (substitue specific value with new one)
After create and connecting to a database, Choose "Update Table".
Enter the Primary Key of the row you want to change.
Enter the Column Name you wish to modify.
Enter the New Value (The system will validate it against the column type).

```
