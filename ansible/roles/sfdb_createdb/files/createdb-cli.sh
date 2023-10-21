#!/bin/bash
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

#cat /etc/profile.d/spotfire.env

SPOTFIRE_HOME=/opt/spotfire/spotfireserver/$SPOTFIRE_VERSION
SPOTFIRE_CONFIG=/opt/spotfire/spotfireserver/$SPOTFIRE_VERSION/tomcat/spotfire-bin/config.sh
SPOTFIRE_BIN_DIR=/opt/spotfire/spotfireserver/$SPOTFIRE_VERSION/tomcat/spotfire-bin
TOMCAT_DIR=/opt/spotfire/spotfireserver/$SPOTFIRE_VERSION/tomcat/

# Spotfire Config tool
SPOTFIRE_CONFIG_TOOL_PASSWORD=${SPOTFIRE_CONFIG_TOOL_PASSWORD:-spotfire}

# Type for the Spotfire Database
SPOTFIRE_DB_TYPE=${SPOTFIRE_DB_TYPE:-postgres}
# Set this variable to the hostname of the PostgreSQL instance
SPOTFIRE_DB_HOST=${SPOTFIRE_DB_HOST:-localhost}

# Set these variables to the username and password of a database user
# with permissions to create users and databases
SPOTFIRE_DB_ADMIN_USER=${SPOTFIRE_DB_ADMIN_USER:-dbadmin}
SPOTFIRE_DB_ADMIN_PASSWORD=${SPOTFIRE_DB_ADMIN_PASSWORD:-dbpass123!}

# Set these variables to the name of the database to be created for the Spotfire Server,
# and the user to be created for Spotfire Server to access the database.
# Note that the password is entered here in plain text, you might want to delete
# any sensitive information once the script has been run.
SPOTFIRE_DB_NAME=${SPOTFIRE_DB_NAME:-spotfire_server}
SPOTFIRE_DB_USER=$SPOTFIRE_DB_ADMIN_USER
SPOTFIRE_DB_PASSWORD=$SPOTFIRE_DB_ADMIN_PASSWORD

SPOTFIRE_DB_URL=""

show_result() {
  rc=$1
  if [[ $rc == 0 ]]; then
    echo -e "[OK]"
  else
    echo -e "[ERROR]"
    exit 1
  fi
}
get_db_url() {
  if [[ $SPOTFIRE_DB_TYPE == 'postgres' ]]; then
    DB_NAME='postgres'
    # Database port
    SPOTFIRE_DB_PORT=${SPOTFIRE_DB_PORT:-5432}
    # Fully qualified class name of the JDBC driver for the Spotfire Database.
    SPOTFIRE_DB_DRIVER_CLASS=${SPOTFIRE_DB_DRIVER_CLASS:-org.postgresql.Driver}
    SPOTFIRE_DB_DRIVER_NAME='postgresql'
    # JDBC connection URL for the Spotfire Database
    SPOTFIRE_DB_URL="jdbc:${SPOTFIRE_DB_DRIVER_NAME}://${SPOTFIRE_DB_HOST}:${SPOTFIRE_DB_PORT}/${DB_NAME}" #e=require"
  else
    echo "[ERROR] Database type not supported: $SPOTFIRE_DB_TYPE"
    exit 1

  fi
}

create_db_cli() {
  echo -e "\n\n>>>>>>>>>>>>>>>>>> Creating the database schema using the Spotfire config tool CLI..."

  echo "CMD ./config.sh create-db --tool-password=\"${SPOTFIRE_CONFIG_TOOL_PASSWORD}\" \
      --driver-class=\"${SPOTFIRE_DB_DRIVER_CLASS}\" \
      --database-url=\"${SPOTFIRE_DB_URL}\" \
      --admin-username=\"${SPOTFIRE_DB_USER}\" \
      --admin-password=\"${SPOTFIRE_DB_PASSWORD}\" \
      --spotfiredb-dbname=\"${SPOTFIRE_DB_NAME}\" \
      --do-not-create-user
  "

  #create-db --driver-class="org.postgresql.Driver" \
  #  --database-url="jdbc:postgresql://{{database-host}}:{{database-port}}/{{database-name}}" \
  #  --admin-username="{{admin-user}}" \
  #  --admin-password="{{admin-password}}" \
  #  --spotfiredb-dbname="{{spotfire-database}}" \
  #  --do-not-create-user
  cd ${SPOTFIRE_BIN_DIR} && \
  ./config.sh create-db \
      --driver-class="${SPOTFIRE_DB_DRIVER_CLASS}" \
      --database-url="${SPOTFIRE_DB_URL}" \
      --admin-username="${SPOTFIRE_DB_ADMIN_USER}" \
      --admin-password="${SPOTFIRE_DB_ADMIN_PASSWORD}" \
      --spotfiredb-dbname="${SPOTFIRE_DB_NAME}" \
      --do-not-create-user
  show_result $?
  echo
}

get_db_url
create_db_cli