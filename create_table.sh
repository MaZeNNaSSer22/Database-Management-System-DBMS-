#!/bin/bash
# Create_table.sh : a script to create a new table in the current database directory as a file with its metadata file.

# this is a variable to save the current database name (the current directory).
DB_name=$(pwd)

# this while loop is for the whole process of creating a table,
# if any error happens, it will ask the user to start over again.
while true; do
    
    read -p "Enter Table Name: " tb_name

    # to validate the table name (no special characters, no spaces, must start with a letter)
    if [[ ! "$tb_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        echo "Error: Invalid table name. Use letters, numbers, and underscores only. Must start with a letter."
        continue # ask for the name again instead of exiting
    fi

    # check if the table already exists
    if [[ -f "$DB_name/$tb_name" ]]; then
        echo "Error: Table '$tb_name' already exists!"
        continue # ask for the unique name instead of exiting
    fi

    # ask for the number of columns in the table to create the metadata and the header of the data file
    read -p "Enter Number of Columns: " num_columns

    # this variable is to count how many primary keys the user has chosen, it must be exactly 1
    pkCount=0

    # this variable is to save the header line of the data file (the column names separated by :)
    headerData="" 
    
    # we will use a temporary file to save the metadata until we are sure that everything is correct,
    # then we will move it to the final name
    tempMeta="$DB_name/$tb_name.meta.temp"
    touch "$tempMeta"

    echo "========================================"
    # this for loop is to ask the user about each column's name, type, and if it's a primary key or not
    for (( i=1; i<=num_columns; i++ )); do
        echo "--- Column $i Details ---"
        
        # ask for the column name
        read -p "Name: " col_name
        
        # ask for the column type with validation (must be int or string)
        # we will use a while loop to keep asking until the user gives a valid type
        while true; do
            read -p "Type (int/string): " col_type
            if [[ "$col_type" == "int" || "$col_type" == "string" ]]; then
                break
            else
                echo "Invalid type. Please enter 'int' or 'string'."
            fi
        done

        # ask if this column is a primary key with validation (must be yes or no)
        # we will use a while loop to keep asking until the user gives a valid answer
        while true; do
            read -p "Is Primary Key? (yes/no): " is_pk
            if [[ "$is_pk" == "yes" || "$is_pk" == "no" ]]; then
                break
            else
                 echo "Invalid input. Please enter 'yes' or 'no'."
            fi
        done

        # if the user chose this column as a primary key, we will increase the pkCount and add column type with PK in the metadata,
        # otherwise we will just add the column type
        if [[ "$is_pk" == "yes" ]]; then
            ((pkCount++))
            metaRow="$col_type:PK"
        else
            metaRow="$col_type"
        fi

        # write the previous metadata row to the temporary metadata file
        echo "$metaRow" >> "$tempMeta"

        # this part is to check if we are at the last column or not,
        # if we are at the last column, we will not add the delimiter ":" at the end of the column name in the header,
        # otherwise we will add it to separate between the column names .
        if [[ $i -eq $num_columns ]]; then
            headerData+="$col_name"
        else
            headerData+="$col_name:"
        fi
    done

    echo "========================================"

    # the table must have exactly one primary key (this help us in deleting and updating rows later).
    # this part is to check if the user has chosen exactly one primary key or not,
    # if the pkCount is 1, we will move the temporary metadata file to the final metadata file ,
    # and create the data file and put the header with the headerData variable.,
    if [[ $pkCount -eq 1 ]]; then
        # if true, then we can create the table successfully
        mv "$tempMeta" "$DB_name/$tb_name.meta"
        echo "$headerData" > "$DB_name/$tb_name"
        
        echo "Success: Table '$tb_name' created."
        echo "Meta File: $tb_name.meta"
        echo "Data File: $tb_name"
        break # break the while loop to end the script .
    else
        # if false, then we have an error in the primary key selection,
        # we will show an error message and delete the temporary metadata file to start over again.
        echo "Error: You must define EXACTLY ONE Primary Key. You defined $pkCount."
        echo "Rolling back... Please try again."
        rm "$tempMeta" 2>/dev/null # delete the temporary metadata file if it exists, suppress error if it doesn't
        # the loop will continue to ask for the table name and columns details again.
    fi
done
