#!/bin/bash
# DBMS.sh: A simple script to manage a basic file-based database system.

# Set the script directory to the current working directory to ensure all sourced scripts are correctly referenced.
SCRIPT_DIR=$(pwd)

# Ensure the data directory exists for storing databases.
if [[ ! -d ~/Bash_project/data ]]; then
    mkdir -p ~/Bash_project/data
fi

echo "Welcome to the Simple File-based DBMS....."
echo "Please select a number of action you want: "
echo "1. Create Database"
echo "2. List Databases"
echo "3. Connect To Database"
echo "4. Drop Database"

# Use a select loop to handle user input for the main menu.
select action in 1 2 3 4;
do
    case $action in
        1)
            echo "Creating a new Database..."
            source "$SCRIPT_DIR"/CreateDB.sh;;
        2)
# The -F option adds a trailing slash to directories, and grep filters only DB directories.
# if there is a file created by mistake this option make the ls command ignore it
# and show only the directories that represent the DB.
            echo "Available Databases:"
            ls -F ~/Bash_project/data/ | grep / ;;
        3)
            echo "Connecting to a Database..."
            source "$SCRIPT_DIR"/Connect_DB.sh
            echo "You can perform operations like : "
            echo "1. Create Table"
            echo "2. List Tables"
            echo "3. Drop Table"
            echo "4. Insert into Table"
            echo "5. Select From Table"
            echo "6. Delete From Table"
            echo "7. Update Table"
            
            select db_action in 1 2 3 4 5 6 7;
            do
                case $db_action in
                    1)
                        echo "Creating a new Table..."
                        source "$SCRIPT_DIR"/create_table.sh;;
                    2)
                        echo "Listing all Tables..."
                        # -v here is used to display only the file names without the .meta files.
                        ls -p | grep -v '.meta' ;;
                    3)
                        echo "Dropping a Table..."
                        read -p "Enter Table Name to Drop: " tbName
                        # this is a critical operation, so we ask for confirmation before deleting the table.
                        read -p "Are you sure you want to drop the table '$tbName'? (y/n) : " confirm
                        if [[ -f "$tbName" && "$confirm" == "y" ]]; then
                            rm "$tbName" "$tbName.meta"
                            echo "Table Dropped Successfully."
                        else
                            echo "Table Not Found or Operation Cancelled."
                        fi;;    
                    4)
                        echo "Inserting into a Table..."
                        source "$SCRIPT_DIR"/insertion.sh;;
                    5)
                        echo "Available Tables:"
                        ls -p | grep -v '.meta'
                        echo "Selecting from a Table..."
                        source "$SCRIPT_DIR"/Select.sh;;

                    6)
                        echo "Deleting from a Table..."
                        source "$SCRIPT_DIR"/delete.sh;;  
                    7)
                        echo "Updating a Table..."
                        source "$SCRIPT_DIR"/update.sh;;
                        
                    *)
                        echo "Invalid option. Please select a number between 1 and 7.";;
                esac
            done;;  

        4)
            read -p "Enter Database Name to Drop: " dbName
            read -p "Are you sure you want to drop the database '$dbName'? (y/n) : " confirm
            if [[ -d "$dbName" && "$confirm" == "y" ]]; then
                rm -r ~/Bash_project/data/"$dbName"
                echo "Database Dropped Successfully."
            else
                echo "Database Not Found or Operation Cancelled."
            fi
            ;;
        *)
            echo "Invalid option. Please select 1, 2, 3, or 4.";;
esac

done


