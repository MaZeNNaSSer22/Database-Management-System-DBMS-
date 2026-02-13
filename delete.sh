#!/bin/bash
# delete.sh: A script to delete data from a specific table in the DB (file).

# this variable to save the database name (the current directory)
DB_name=$(pwd) 

# ask for the table name
read -p "Enter Table Name: " tableName

# check if the table exists
if [[ ! -f "$tableName" ]]; then
    echo "Error: Table '$tableName' does not exist."
    exit 1 # exit with a non-zero status to indicate an error
fi

# hold the data file and meta file names in variables for easier reference
data_file="$tableName"
meta_file="${tableName}.meta" 

# search for the line that contains "PK" in the meta file and get its line number (which is the column number)
pk_col_index=$(awk -F: '/PK/ {print NR}' "$meta_file")

# check if we found a PK column (we must have one in each table as we defined in create.sh , but it's good to check)
if [[ -z "$pk_col_index" ]]; then
    echo "Error: No Primary Key defined in metadata!"
    exit 1
fi

# print the PK column index to the user (for debugging and clarity)
echo "Primary Key is at Column: $pk_col_index"

# while loop to keep asking the user for a valid PK value until we find it in the data file
while true; do
    # ask the user for the PK row value they want to delete
    read -p "Enter Primary Key Value to Delete: " pk_value

    # match the PK value in the specified column and get the line number of the matching row .
    # NR>1 : to skip the header line (we don't want to delete it by mistake)
    # $col == val : to ensure an exact match (so we don't delete the wrong row if there are similar values)
    row_num=$(awk -F: -v col="$pk_col_index" -v val="$pk_value" 'NR>1 && $col == val {print NR}' "$data_file")

    # check if we found a matching row (if row_num is not empty)
    if [[ -n "$row_num" ]]; then
        # delete the matching row using sed 
        sed -i "${row_num}d" "$data_file"
        echo "Row with PK '$pk_value' deleted successfully."
        break # exit the loop after successful deletion
    else
        echo "Error: Primary Key '$pk_value' not found. Try again."
    fi
done
