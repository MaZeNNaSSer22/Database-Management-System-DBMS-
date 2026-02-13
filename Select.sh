#!/bin/bash
# Select.sh: A script to display a specific table in the DB (file).

# this variable is used to save the current database name (which is the current directory)
DB_name=$(pwd)

# ask the user to enter the table name they want to select from
read -p "Enter Table Name to Show: " tbName
echo "Showing the "$tbName" Table..."

# check if the table file exists
if [[ ! -f "$tbName" ]]; then
    echo "Error: Table '$tbName' does not exist."
    exit 1
fi

# hold the data file path in a variable for easier access
data_File="$DB_name/$tbName"


echo ""
echo "=================================================="

# display the content of the table in a formatted way
# for loop to read each line of the data file and print it with proper spacing
# printf "%-20s"  :-  is used to print each column with a width of 20 characters, left-aligned
# print ""        :-  is used to move to the next line after printing all columns of the current row
# the if condition checks if the current line number (NR) is 1, which means it's the header row,
# it prints a separator line to To distinguish the table's header .
awk -F':' '
{
    for(i=1; i<=NF; i++) {
        printf "%-20s", $i
    }
    print "" 
    if (NR==1) {
        print "--------------------------------------------------"
    }
}' "$data_File"

echo "=================================================="
echo ""
