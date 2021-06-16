#!/bin/sh
#
# This script will create all database schemas and fill them with all the initial data.
#
# Before using this script you need to set or change the following variables below:
#
#         * SPOTFIRE_DB_HOST
#         * SPOTFIRE_DB_ADMIN_PASSWORD
#         * SPOTFIRE_DB_USER
#         * SPOTFIRE_DB_PASSWORD
#
# it is assumed that the psql binary is in the PATH

. /etc/profile.d/spotfire.env

# Set this variable to the hostname of the PostgreSQL instance
SPOTFIRE_DB_HOST=${SPOTFIRE_DB_HOST:-localhost}

# Set these variables to the username and password of a database user
# with permissions to create users and databases
SPOTFIRE_DB_ADMIN_USER=${SPOTFIRE_DB_ADMIN_USER:-dbadmin}
SPOTFIRE_DB_ADMIN_PASSWORD=${SPOTFIRE_DB_ADMIN_PASSWORD:-dbpass123!}

# Set these variables to the name of the database to be created for the TIBCO Spotfire
# Server, and the user to be created for TIBCO Spotfire Server to access the database.
# Note that the password is entered here in plain text, you might want to delete
# any sensitive information once the script has been run.
SPOTFIRE_DB_NAME=${SPOTFIRE_DB_NAME:-spotfire_server}
SPOTFIRE_DB_USER=$SPOTFIRE_DB_ADMIN_USER
SPOTFIRE_DB_PASSWORD=$SPOTFIRE_DB_ADMIN_PASSWORD

# Common error checking function
check_error()
{
  # Function.
  # Parameter 1 is the return code to check
  # Parameter 2 is the name of the SQL script run
  if [ "${1}" -ne "0" ]; then
    echo "Error while running SQL script '${2}'"
    echo "For more information consult the log (log.txt) file"
    cat log.txt
    exit 1
  fi
}

# Create the table spaces and user
echo "Creating Spotfire Server database and user"
export PGPASSWORD=${SPOTFIRE_DB_ADMIN_PASSWORD}
#psql -h ${SPOTFIRE_DB_HOST} -U ${SPOTFIRE_DB_ADMIN_USER} -f create_server_env.sql -v db_name=${SPOTFIRE_DB_NAME} -v db_user=${SPOTFIRE_DB_USER} -v db_pass=${SPOTFIRE_DB_PASSWORD} > log.txt 2>&1

# Azure: skip spotfiredb creation
#psql -h ${SPOTFIRE_DB_HOST} -U ${SPOTFIRE_DB_ADMIN_USER} -f create_server_env_azure.sql -d postgres -v db_name=${SPOTFIRE_DB_NAME} > log.txt 2>&1
#check_error $? create_server_env_azure.sql

# Create the tables and fill them with initial data
echo "Creating TIBCO Spotfire Server tables"
export PGPASSWORD=${SPOTFIRE_DB_PASSWORD}
psql -h ${SPOTFIRE_DB_HOST} -U ${SPOTFIRE_DB_USER} -d ${SPOTFIRE_DB_NAME} -f create_server_db.sql >> log.txt 2>&1
check_error $? create_server_db.sql

echo "Populating TIBCO Spotfire Server tables"
psql -h ${SPOTFIRE_DB_HOST} -U ${SPOTFIRE_DB_USER} -d ${SPOTFIRE_DB_NAME} -f populate_server_db.sql >> log.txt 2>&1
check_error $? populate_server_db.sql


echo "-----------------------------------------------------------------"
echo "Please review the log file (log.txt) for any errors or warnings!"
exit 0
