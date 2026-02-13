#!/bin/bash
# Update_Table.sh : Script to update a specific cell in a table based on PK and Column constraints.

# this variable is used to save the current database name (which is the current directory)
DB_name=$(pwd)

# ask the user to enter the table name they want to update
read -p "Enter Table Name to Update: " tableName

# check if the table file and its metadata file exist in the current database directory
if [[ ! -f "$tableName" ]] || [[ ! -f "$tableName.meta" ]]; then
    echo "Error: Table '$tableName' or its metadata file does not exist."
    exit 1 # exit with error code 1 if either the table or the metadata file is missing
fi

# hold the names of the data file and the metadata file in variables for easier reference
data_file="$tableName"
meta_file="${tableName}.meta"


# search for the line that contains "PK" in the meta file and get its line number (which is the column number)
pk_col_index=$(awk -F: '/PK/ {print NR}' "$meta_file")

# check if we found a PK column (we must have one in each table as we defined in create.sh , but it's good to check)
if [[ -z "$pk_col_index" ]]; then
    echo "Error: No Primary Key defined in metadata file!"
    exit 1
fi

# print the PK column index to the user (for debugging and clarity)
echo "Primary Key is at Column: $pk_col_index"

# while loop to keep asking the user for a valid PK value until we find it in the data file
while true; do
    # ask the user for the PK row value they want to select for updating
    read -p "Enter Primary Key Value to select row: " pk_value
    
    # match the PK value in the specified column and get the line number of the matching row .
    # NR>1 : to skip the header line (we don't want to update it)
    # $col == val : to ensure an exact match (so we don't substitute the wrong row if there are similar values)
    row_num=$(awk -F: -v col="$pk_col_index" -v val="$pk_value" 'NR>1 && $col == val {print NR}' "$data_file")

    # check if we found a matching row (if row_num is not empty)
    if [[ -z "$row_num" ]]; then
        echo "Error: Primary Key '$pk_value' not found. Try again."
        continue # continue the loop to ask for another PK value
    else
        echo "Row found at line: $row_num"
        break # exit the loop after finding a valid PK value and its corresponding row number
    fi
done

# while loop to keep asking the user for a valid column name and new value until we successfully update the cell
while true; do

    # display the available columns to the user (by printing the header line of the data file)
    echo "----------------------------------------"
    echo "Available Columns:"
    head -n 1 "$data_file" 
    echo "----------------------------------------"

    # ask the user to enter the column name they want to update
    read -p "Enter Column Name to update: " col_name

    # search for the column number based on the column name (we look in the header line, which is line 1)
    col_num=$(awk -F: -v col="$col_name" 'NR==1{for(i=1;i<=NF;i++){if($i==col) print i}}' "$data_file")

    # check if we found a valid column number (if col_num is not empty)
    if [[ -z "$col_num" ]]; then
        echo "Error: Column '$col_name' not found."
        continue # continue the loop to ask for another column name
    fi

    # # check if the user is trying to update the Primary Key column (which is not allowed)
    # if [[ "$col_num" == "$pk_col_index" ]]; then
    #     echo "Error: You cannot update the Primary Key column."
    #     continue
    # fi

    # extract the data type of the column from the metadata file 
    # (we get the line corresponding to col_num and take the first field which is the type)
    col_type=$(sed -n "${col_num}p" "$meta_file" | cut -d: -f1)

    # ask the user to enter the new value for the specified column (we also show the expected data type for clarity)
    read -p "Enter New Value ($col_type): " new_value
    
    # check if the new value is empty (we don't allow empty values)
    if [[ -z "$new_value" ]]; then
        echo "Error: Value cannot be empty."
        continue
    fi

    # check if the new value contains the delimiter ":" (which is not allowed in string values because it would break our file format)
    if [[ "$new_value" == *:* ]]; then
        echo "Error: Value cannot contain the delimiter ':'."
        continue
    fi

    # check the data type and validate the new value accordingly 
    # (for example, if it's supposed to be an integer, we check if it's a valid integer)
    # (for strings, we can check if it contains only allowed characters, or we can skip strict validation for simplicity)
    if [[ "$col_type" == "int" ]]; then
        if ! [[ "$new_value" =~ ^-?[0-9]+$ ]]; then
            echo "Error: Invalid input. Column '$col_name' expects an Integer."
            continue
        fi
    elif [[ "$col_type" == "string" ]]; then
        if ! [[ "$new_value" =~ ^[a-zA-Z0-9\ ]+$ ]]; then
            echo "Error: Invalid input. String allows only text, numbers, and spaces."
            continue
        fi
    fi

    # perform the update using awk (we specify the row number, column number, and new value as variables)
    # we use a temporary file to store the updated data and then move it back to the original data file to apply the changes .
    awk -F: -v r="$row_num" -v c="$col_num" -v v="$new_value" '
    BEGIN {OFS=":"} 
    NR==r {$c=v} 
    {print}
    ' "$data_file" > "$data_file.tmp" && mv "$data_file.tmp" "$data_file"
    
    echo "----------------------------------------"
    echo "Update Success! Row with PK ($pk_value) updated."
    echo "Column '$col_name' changed to '$new_value'."
    echo "----------------------------------------"
    
    break # exit the loop after successful update
done

