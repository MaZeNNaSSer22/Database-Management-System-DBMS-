#!/bin/bash
# CreateDB.sh: A script to create a new database (directory).

read -p "Enter the name of new DB : " DB_name

# Validate the database name (only letters, numbers, underscores, and spaces allowed)
if [[ "$DB_name" =~ ^[A-Za-z][A-Za-z0-9_[:space:]]*$ ]]; then
    
    DB_name=$(echo "$DB_name" | tr -s ' ' '_')  # Replace spaces from DB name with underscores
    mkdir ~/Bash_project/data/"$DB_name"
    echo "Database '$DB_name' created successfully."
else
    echo "Invalid database name. Please use only letters, numbers, and underscores."
fi