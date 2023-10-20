#!/bin/bash

. /etc/profile.d/spotfire.env

#echo "----------"
#env | sort
#echo "----------"

# colors
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'

# logging
log() {
    color=$1
    level=$2
    message=$3
    echo -e "${color}[${level}] ${message}${NC}"
}

show_result() {
  rc=$1
  if [[ $rc == 0 ]]; then
#    echo -e "${GREEN}[OK]${NC}"
    echo -e "[OK]"
  else
#    echo -e "${RED}[ERROR]${NC}"
    echo -e "[ERROR]"
    exit 1
  fi
}

# seconds
SECONDS=0

#echo "Setting variables..."

# Spotfire Server Java settings
JAVA_XMX_MEMORY=${JAVA_XMX_MEMORY:-1024M}
#JAVA_XMX_MEMORY=${JAVA_XMX_MEMORY:-512M}

# Spotfire Server ports
TSS_FRONTEND_PORT=${TSS_FRONTEND_PORT:-8080}
TSS_REGISTRATION_PORT=${TSS_REGISTRATION_PORT:-9080}
TSS_BACKEND_PORT=${TSS_BACKEND_PORT:-9443}

#TSS_RECONCILER_PORT=${TSS_RECONCILER_PORT:-8081}
#LIBADMIN_USER=${LIBADMIN_USER:-libadmin}
#TSS_CONFIGURED=${TSS_CONFIGURED:-/opt/tibco/vol/tss-configured}

TSS_HOME=/opt/tibco/tss/$TSS_VERSION
SPOTFIRE_CONFIG=/opt/tibco/tss/$TSS_VERSION/tomcat/spotfire-bin/config.sh
SPOTFIRE_BIN_DIR=/opt/tibco/tss/$TSS_VERSION/tomcat/spotfire-bin
TOMCAT_DIR=/opt/tibco/tss/$TSS_VERSION/tomcat/

# Spotfire Admin GUI
SPOTFIRE_ADMIN_USER=${SPOTFIRE_ADMIN_USER:-admin}
SPOTFIRE_ADMIN_PASSWORD=${SPOTFIRE_ADMIN_PASSWORD:-spotfire}
# Spotfire Config tool
SPOTFIRE_CONFIG_TOOL_PASSWORD=${SPOTFIRE_CONFIG_TOOL_PASSWORD:-spotfire}

# Database name, username and password for the Spotfire database.
SPOTFIRE_DB_NAME=${SPOTFIRE_DB_NAME:-spotfire_db}
SPOTFIRE_DB_USER=${SPOTFIRE_DB_USER:-spotfire}
SPOTFIRE_DB_PASSWORD=${SPOTFIRE_DB_PASSWORD:-spotfire}

# Type for the Spotfire Database
SPOTFIRE_DB_TYPE=${SPOTFIRE_DB_TYPE:-postgres}
# Spotfire Database host
SPOTFIRE_DB_HOST=${SPOTFIRE_DB_HOST:-locahost}

if [[ $SPOTFIRE_DB_TYPE == 'postgres' ]]; then
  # Database port
  SPOTFIRE_DB_PORT=${SPOTFIRE_DB_PORT:-5432}
  # Fully qualified class name of the JDBC driver for the Spotfire Database.
  SPOTFIRE_DB_DRIVER_CLASS=${SPOTFIRE_DB_DRIVER_CLASS:-org.postgresql.Driver}
  SPOTFIRE_DB_DRIVER_NAME='postgresql'
  # JDBC connection URL for the Spotfire Database
  SPOTFIRE_DB_URL="jdbc:${SPOTFIRE_DB_DRIVER_NAME}://${SPOTFIRE_DB_HOST}:${SPOTFIRE_DB_PORT}/${SPOTFIRE_DB_NAME}"
  #SPOTFIRE_DB_URL="jdbc:${SPOTFIRE_DB_DRIVER_NAME}://${SPOTFIRE_DB_HOST}:${SPOTFIRE_DB_PORT}/${SPOTFIRE_DB_NAME}?sslmode=require"

elif [[ $SPOTFIRE_DB_TYPE == 'oracle' ]]; then

  SPOTFIRE_DB_PORT=${SPOTFIRE_DB_PORT:-1521}
  VENDOR_DB_DRIVER_FILE=$TOMCAT_DIR/custom-ext/ojdbc7.jar

  if [[ -s $VENDOR_DB_DRIVER_FILE ]] && jar tvf $VENDOR_DB_DRIVER_FILE; then
    #  Oracle (Vendor Driver,ojdbc7.jar)
    #     [API]:[DBDriver]:[DriverType]://[Hostname]:[Port]/[ServiceName]
    #     jdbc:oracle:thin:@//dbsrv.example.com:1521/pdborcl.example.com
    echo "Using vendor driver: ${VENDOR_DB_DRIVER_FILE}"
    SPOTFIRE_DB_DRIVER_CLASS=${SPOTFIRE_DB_DRIVER_CLASS:-jdbc:oracle:thin}
    SPOTFIRE_DB_DRIVER_NAME='oracle:thin'
  else
    #  Oracle (DataDirect Driver)
    #     [API]:[DBDriver]:[ServerType]://[Hostname]:[Port];ServiceName=[ServiceName]
    #     jdbc:tibcosoftwareinc:oracle://dbsrv.example.com:1521;ServiceName=pdborcl.example.com
    echo "Using DataDirect driver: tibcosoftwareinc:oracle"
    SPOTFIRE_DB_DRIVER_CLASS=${SPOTFIRE_DB_DRIVER_CLASS:-tibcosoftwareinc.jdbc.oracle.OracleDriver}
    SPOTFIRE_DB_DRIVER_NAME='tibcosoftwareinc:oracle'
  fi
  SPOTFIRE_DB_URL="jdbc:${SPOTFIRE_DB_DRIVER_NAME}://${SPOTFIRE_DB_HOST}:${SPOTFIRE_DB_PORT};ServiceName=${SPOTFIRE_DB_NAME}"

elif [[ $SPOTFIRE_DB_TYPE == 'oraclexe' ]]; then

  SPOTFIRE_DB_PORT=${SPOTFIRE_DB_PORT:-1521}
  VENDOR_DB_DRIVER_FILE=$TOMCAT_DIR/custom-ext/ojdbc7.jar

  if [[ -s $VENDOR_DB_DRIVER_FILE ]] && jar tvf $VENDOR_DB_DRIVER_FILE; then
    #  Oracle (Vendor Driver,ojdbc7.jar)
    #     [API]:[DBDriver]:[DriverType]://[Hostname]:[Port]:SID
    #     jdbc:oracle:thin:@dbsrv.example.com:1521:orcl
    echo "Using vendor driver: ${VENDOR_DB_DRIVER_FILE}"
    SPOTFIRE_DB_DRIVER_CLASS=${SPOTFIRE_DB_DRIVER_CLASS:-jdbc:oracle:thin}
    SPOTFIRE_DB_DRIVER_NAME='oracle:thin'

  else
    # Oracle (DataDirect Driver)
    #     [API]:[DBDriver]:[ServerType]://[Hostname]:[Port];SID=[SID]
    #     jdbc:tibcosoftwareinc:oracle://dbsrv.example.com:1521;SID=spotfire_server
    echo "Using DataDirect driver: tibcosoftwareinc:oracle"
    SPOTFIRE_DB_DRIVER_CLASS=${SPOTFIRE_DB_DRIVER_CLASS:-tibcosoftwareinc.jdbc.oracle.OracleDriver}
    SPOTFIRE_DB_DRIVER_NAME='tibcosoftwareinc:oracle'
  fi
  SPOTFIRE_DB_URL="jdbc:${SPOTFIRE_DB_DRIVER_NAME}://${SPOTFIRE_DB_HOST}:${SPOTFIRE_DB_PORT};SID=XE"

elif [[ $SPOTFIRE_DB_TYPE == 'mssql' ]]; then
  SPOTFIRE_DB_PORT=${SPOTFIRE_DB_PORT:-1433}
  VENDOR_DB_DRIVER_FILE=$TOMCAT_DIR/custom-ext/sqljdbc4.jar

  if [[ -s $VENDOR_DB_DRIVER_FILE ]] && jar tvf $VENDOR_DB_DRIVER_FILE; then
    # Microsoft SQL Server (VendorDriver, sqljdbc4.jar)
    #     [API]:[DBDriver]://[Hostname]:[Port];DatabaseName=[DBName]
    #     jdbc:sqlserver://dbsrv.example.com:1433;DatabaseName=spotfire_server;selectMethod=cursor
    echo "Using vendor driver: $VENDOR_DB_DRIVER_FILE"
    SPOTFIRE_DB_DRIVER_CLASS=${SPOTFIRE_DB_DRIVER_CLASS:-com.microsoft.sqlserver.jdbc.SQLServerDriver}
    SPOTFIRE_DB_DRIVER_NAME='sqlserver'
    SPOTFIRE_DB_URL="jdbc:sqlserver://${SPOTFIRE_DB_HOST}:${SPOTFIRE_DB_PORT};DatabaseName=${SPOTFIRE_DB_NAME}"

  else
    # Microsoft SQL Server (DataDirect Driver)
    #     [API]:[DBDriver]:[ServerType]://[Hostname]:[Port];DatabaseName=[DBName]
    #     jdbc:tibcosoftwareinc:sqlserver://dbsrv.example.com:1433;DatabaseName=spotfire_server
    echo "Using DataDirect driver: tibcosoftwareinc:sqlserver"
    SPOTFIRE_DB_DRIVER_CLASS=${SPOTFIRE_DB_DRIVER_CLASS:-tibcosoftwareinc.jdbc.sqlserver.SQLServerDriver}
    SPOTFIRE_DB_DRIVER_NAME='tibcosoftwareinc:sqlserver'
  fi
  SPOTFIRE_DB_URL="jdbc:${SPOTFIRE_DB_DRIVER_NAME}://${SPOTFIRE_DB_HOST}:${SPOTFIRE_DB_PORT};ServiceName=${SPOTFIRE_DB_NAME}"

elif [[ $SPOTFIRE_DB_TYPE == 'mysql' ]]; then
  SPOTFIRE_DB_PORT=${SPOTFIRE_DB_PORT:-3306}
  SPOTFIRE_DB_DRIVER_CLASS=${SPOTFIRE_DB_DRIVER_CLASS:-com.mysql.jdbc.Driver}
  SPOTFIRE_DB_URL="jdbc:tibcosoftwareinc:mysql://${SPOTFIRE_DB_HOST}:${SPOTFIRE_DB_PORT}/${SPOTFIRE_DB_NAME}"

else
  echo "[ERROR] Database type not supported: $SPOTFIRE_DB_TYPE"
  exit 1

fi


# when: any time the ports are changed
config_server_ports() {
  echo "Configuring frontend & backend ports in server.xml..."
  ${TSS_HOME}/configure -s ${TSS_FRONTEND_PORT} -r ${TSS_REGISTRATION_PORT} -b ${TSS_BACKEND_PORT}
  show_result $?
  echo
}

get_address() {
  ADDRESSES=
  if [ "${ONLY_IPS}" == "true" ] ; then
    echo "nodemanager.use.ip=true" >> ${TSS_HOME}/nm/config/nodemanager.properties
    SERVER_IPS=$(ifconfig | grep inet| grep -v 127.0.0.1 | awk {'print $2'}| paste -sd "," -)
    ADDRESSES="-A${SERVER_IPS}"
    echo Assigning addresses as ${SERVER_IPS}
  fi
}

exists_bootstrap_file() {
  [[ -s ${TSS_HOME}/tomcat/webapps/spotfire/WEB-INF/bootstrap.xml ]]
}

create_bootstrap_config() {
  echo "Creating the bootstrap file database connection configuration..."
  IP_ADDRESSES=''
  echo "nodemanager.use.ip=false" >> ${TSS_HOME}/nm/config/nodemanager.properties
#  SERVER_IP_LIST=$(ifconfig | grep inet | grep -v 127.0.0.1 | grep -v ::1 | awk {'print $2'} | paste -sd "," -)
#  SERVER_IP_LIST=$(ip -o -f inet addr show eth0)
  SERVER_IP_LIST=$(hostname -I | awk '{print $1}')
#  SERVER_IP_LIST=$(hostname)
  IP_ADDRESSES="-A${SERVER_IP_LIST}"
  echo "Assigning addresses as: ${SERVER_IP_LIST}"
  #echo "nodemanager.host.names=" >> ${TSS_HOME}/nm/config/nodemanager.properties

  echo "timeout $SPOTFIRE_CONFIG \
    bootstrap --no-prompt \
      --driver-class=\"${SPOTFIRE_DB_DRIVER_CLASS}\" \
      --database-url=\"${SPOTFIRE_DB_URL}\" \
      --username=\"${SPOTFIRE_DB_USER}\" \
      --password=\"${SPOTFIRE_DB_PASSWORD}\" \
      --tool-password=\"${SPOTFIRE_CONFIG_TOOL_PASSWORD}\" \
      $IP_ADDRESSES
  "

  cd ${SPOTFIRE_BIN_DIR} && \
  ./config.sh \
    bootstrap --force --no-prompt \
      --driver-class="${SPOTFIRE_DB_DRIVER_CLASS}" \
      --database-url="${SPOTFIRE_DB_URL}" \
      --username="${SPOTFIRE_DB_USER}" \
      --password="${SPOTFIRE_DB_PASSWORD}" \
      --tool-password="${SPOTFIRE_CONFIG_TOOL_PASSWORD}" \
       $IP_ADDRESSES
  show_result $?
  echo
}

exists_default_config() {
  [[ -s ${TSS_HOME}/tomcat/spotfire-bin/configuration.xml ]]
}

create_default_config() {
  if [[ -s ${TSS_HOME}/tomcat/spotfire-bin/configuration.xml ]] ; then
    echo "Skipping: Creating default config file: Already exists"
    return 0
  fi

  echo "Creating the default configuration..."
  echo $SPOTFIRE_CONFIG create-default-config
  ./config.sh create-default-config
  show_result $?

  echo "Importing the configuration to the database..."
  echo ${SPOTFIRE_CONFIG} import-config --tool-password="${SPOTFIRE_CONFIG_TOOL_PASSWORD}" --comment="First config"
  ./config.sh import-config --tool-password="${SPOTFIRE_CONFIG_TOOL_PASSWORD}" --comment="First config"
  show_result $?
  echo
}

exists_spotfire_admin_user() {
#  echo "Check if exists user: '${SPOTFIRE_UI_ADMIN_USER}'"
#  echo $SPOTFIRE_CONFIG list-users --tool-password="${SPOTFIRE_CONFIG_TOOL_PASSWORD}" -s "${SPOTFIRE_UI_ADMIN_USER}"
  ./config.sh list-users --tool-password="${SPOTFIRE_CONFIG_TOOL_PASSWORD}" -s "${SPOTFIRE_UI_ADMIN_USER}" | grep ^"${SPOTFIRE_UI_ADMIN_USER}"
}

create_spotfire_admin_user() {
  echo "Creating the '${SPOTFIRE_UI_ADMIN_USER}' user to become administrator..."
  echo $SPOTFIRE_CONFIG create-user --tool-password="${SPOTFIRE_CONFIG_TOOL_PASSWORD}" --username="${SPOTFIRE_UI_ADMIN_USER}" --password="${SPOTFIRE_UI_ADMIN_PASSWORD}"
  ./config.sh create-user --tool-password="${SPOTFIRE_CONFIG_TOOL_PASSWORD}" --username="${SPOTFIRE_UI_ADMIN_USER}" --password="${SPOTFIRE_UI_ADMIN_PASSWORD}"
  show_result $?

  echo "Promoting the user '${SPOTFIRE_UI_ADMIN_USER}' to administrator..."
  echo $SPOTFIRE_CONFIG promote-admin --tool-password="${SPOTFIRE_CONFIG_TOOL_PASSWORD}" --username="${SPOTFIRE_UI_ADMIN_USER}"
  ./config.sh promote-admin --tool-password="${SPOTFIRE_CONFIG_TOOL_PASSWORD}" --username="${SPOTFIRE_UI_ADMIN_USER}"
  show_result $?
  echo
}

config_java_env() {
  echo "Setting custom JAVA env parameters..."
  # TODO: smaller footprint for smaller environments... ENV variable?
  # https://docs.docker.com/engine/reference/run/#user-memory-constraints
  sed -i -e "s/Xmx4096M/Xmx${JAVA_XMX_MEMORY}/" ${TSS_HOME}/tomcat/bin/setenv.sh
  show_result $?
  echo
}

config_server_ports

cd "${SPOTFIRE_BIN_DIR}" || exit

# we allow to retry contacting the db in case it is not yet ready...
if exists_bootstrap_file; then
  echo "Skipping: Creating bootstrap file: Already exists"
else
  create_bootstrap_config
fi

# create and import default config (idempotent)
create_default_config

# create and promote spotfire admin user (idempotent)
if ! exists_spotfire_admin_user; then
  create_spotfire_admin_user
  show_result $?
else
  echo "Skipping: Create and promote user '${SPOTFIRE_UI_ADMIN_USER}': Already exists."
fi
echo

config_java_env


