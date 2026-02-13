#!/bin/bash
# Connect_DB.sh: A script to connect to a specified database.

# while loop to continuously prompt the user until a valid database name is entered
while true; do
    # we explain it in the DBMS.sh file but here we just repeat it for clarity.
    echo "Available Databases:"
    ls -F ~/Bash_project/data/ | grep / 

    # we ask the user to enter the name of the database they want to connect to.
    # This is done if they enter an invalid name, they will be prompted again until they enter a valid one.
    read -p "Enter the name of the DB to connect: " DB_name
    if [ -d ~/Bash_project/data/"$DB_name" ]; then
        cd ~/Bash_project/data/"$DB_name"
        echo "You are now connected to $DB_name DB ."
        break
    else
        echo "-- ERROR : This DB not exist --"
    fi
done

