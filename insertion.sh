#!/bin/bash
# Insertion.sh: A script to insert data into a specific table in the DB (file).

# this variable is used to save the database name (the current directory)
DB_name=$(pwd)

# ask the user for the table name to insert into
read -p "Enter Table Name to insert into: " tableName

# check if the table exists
if [[ ! -f "$tableName" ]]; then
    echo "Error: Table '$tableName' does not exist."
    exit 1 # exit with an error code
fi

# hold the data file and the meta file names in variables for easier access
#data_file="$tableName"
meta_file="${tableName}.meta"


# hold the header line in a variable and split it into an array using IFS (Internal Field Separator)
headerLine=$(head -n 1 "$tableName")
IFS=':' read -r -a colNames <<< "$headerLine"

# hold the number of lines in the meta file (which is the same as the number of columns) in a variable
lines=$(wc -l < "$meta_file")

# this variable will be used to build the new row data before writing it to the file (to avoid multiple writes and to ensure atomicity)
row_data="" 

echo "----------------------------------------"
echo "Inserting into table: $tableName"
echo "----------------------------------------"

# for loop to go through each column and ask the user for the value, with validation based on the meta file
for (( i=1 ; i<=lines ; i++ )); do
    # get the column name from the header array (i-1 because arrays are 0-indexed but our loop starts from 1)
    colName=${colNames[$((i-1))]}
    
    # the meta file appears to have the format type:pk
    # get the column type and PK info from the meta file
    colType=$(sed -n "${i}p" "$meta_file" | cut -d ':' -f1)
    isPK=$(sed -n "${i}p" "$meta_file" | cut -d ':' -f2)

    # this while loop is for validating the user input for each column based on its type and pk status.
    while true; do
        read -p "Enter value for '$colName' ($colType): " input_val

        # check if the input is valid based on the column type (int or string)
        if [[ "$colType" == "int" ]]; then
            if ! [[ "$input_val" =~ ^-?[0-9]+$ ]]; then
                echo "Warning: Invalid input. '$colName' must be an integer."
                continue
            fi
        fi

        # check for primary key uniqueness if this column is a PK
        if [[ "$isPK" == "PK" ]]; then
            
            # tail -n +2              :- means "start from line 2 in the table to the end of the file to ignore the header"
            # cut -d ':' -f"$i"       :- means "cut the i-th column using ':' as a delimiter"
            # grep -q -w "$input_val" :- means "search for the exact word match of the input value in the output of cut"
            # if the grep command finds a match, it returns 0 (success), which means the PK value already exists,
            # so we show an error and ask for input again.
            if tail -n +2 "$tableName" | cut -d ':' -f"$i" | grep -q -w "$input_val"; then
                echo "Error: Primary Key '$input_val' already exists! Duplicate values are not allowed."
                continue # ask for input again instead of exiting, to give the user a chance to correct it
            fi
        fi

        # check if the input contains the delimiter ':' which is not allowed in string values (and also to prevent breaking the file format)
        if [[ "$input_val" == *:* ]]; then
            echo "Error: Input cannot contain ':' character."
            continue
        fi

        # check if the input is empty, which is not allowed for string values (and also to prevent breaking the file format)
        if [[ -z "$input_val" ]]; then
            echo "Error: Input cannot be empty."
            continue
        fi

        break # if all validations passed, break the loop to move to the next column
    done

    # use a temporary variable to build the row data .
    # build the row data by appending the new value with a ':' delimiter (except for the last column)
    if [[ $i -eq 1 ]]; then
        row_data="$input_val"
    else
        row_data="$row_data:$input_val"
    fi

done

# if we reached this point, it means all inputs are valid and we can write the new row to the data file (append to the end of the file)
echo "$row_data" >> "$tableName"

echo "----------------------------------------"
echo "Row Inserted Successfully!"
echo "----------------------------------------"
