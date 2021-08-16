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
check_error() {
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

check_table_exists() {
  DB_TABLE="persistent_sessions"
  # poor's man check for some created table
  table_exists_out=$(psql -h ${SPOTFIRE_DB_HOST} -U ${SPOTFIRE_DB_USER} -d ${SPOTFIRE_DB_NAME} -c "SELECT * FROM pg_catalog.pg_tables;")
  rc=$?
  if [[ $rc != 0 ]];then
    echo "ERROR($rc): Could not read tables in database \"$SPOTFIRE_DB_HOST\". Continue database schema creation."
    return 1
  else
    table_exists=$(echo $table_exists_out | grep -i $DB_TABLE)
    rc=$?
    if [[ $rc != 0 ]];then
      echo "ERROR($rc): Could not find table \"$DB_TABLE\" in database \"$SPOTFIRE_DB_HOST\". Continue database schema creation."
      return 2
    else
      echo "Found table \"$DB_TABLE\" in database \"$SPOTFIRE_DB_HOST\". Continue checking if required database schema creation."
    fi
  fi
}

sn_version_file="sn_version_file"
sn_version_db="sn_version_db"
check_sn_version_file() {
  sn_version_file_out=$(grep SN_VERSION populate_server_db.sql)
  rc=$?
  if [[ $rc != 0 ]];then
    echo "ERROR($rc): Could not identify SN_VERSION in file: $sn_version_file_out. Skipping database schema creation."
    exit 11
  else
    sn_version_file=$(echo $sn_version_file_out | cut -d"'" -f 2,4 --output-delimiter="|" | tr -d '[:space:]')
  fi
}
check_sn_version_db() {
  sn_version_db_out=$(psql -h ${SPOTFIRE_DB_HOST} -U ${SPOTFIRE_DB_USER} -d ${SPOTFIRE_DB_NAME} -c "SELECT spotfire_version,schema_version FROM SN_VERSION;" -t)
  rc=$?
  if [[ $rc != 0 ]];then
    echo "ERROR($rc): Could not identify SN_VERSION in database: $sn_version_db_out. Skipping database schema creation."
    exit 12
  else
    sn_version_db=$(echo $sn_version_db_out | tr -d '[:space:]')
  fi
}

# export database admin password
export PGPASSWORD=${SPOTFIRE_DB_ADMIN_PASSWORD}

if check_table_exists;then
  check_sn_version_file
  check_sn_version_db

  #if ! check_sn_version_file; then
  #  echo "ERROR: Could not identify SN_VERSION in file: $check_sn_version_file. Skipping database creation."
  #  exit 11
  #fi
  #if ! check_sn_version_db; then
  #  echo "ERROR: Could not identify SN_VERSION in database: $check_sn_version_db. Skipping database creation."
  #  exit 12
  #fi
  if [[ "$sn_version_file" == "$sn_version_db" ]]; then
    echo "Database exists and SN_VERSION in file ($sn_version_file) and ($sn_version_db) are the same. Skipping database schema creation."
    exit 0
  else
    echo "WARN: Database exists and SN_VERSION in file ($sn_version_file) and ($sn_version_db) differ. Skipping database schema creation."
    exit 13
  fi
else
  echo "Not found table. Will create Skipping database schema creation."
fi

# Create the table spaces and user
#echo "Creating Spotfire Server database and user"
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
