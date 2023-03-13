#!/bin/bash

set -e

# Check if the required environment variables are set
if [[ -z "${MYSQL_HOST}" ]] || [[ -z "${MYSQL_ROOT_USER}" ]] || [[ -z "${MYSQL_ROOT_PASSWORD}" ]] || [[ -z "${MYSQL_DATABASE}" ]] || [[ -z "${MYSQL_USER}" ]] || [[ -z "${MYSQL_PASSWORD}" ]]; then
  echo "Missing required environment variables. Exiting."
  exit 1
fi

# Connect to MySQL and check if the database and user already exist
MYSQL_COMMAND="mysql -h${MYSQL_HOST} -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD}"
DB_EXISTS=`${MYSQL_COMMAND} -se "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name='${MYSQL_DATABASE}'"`
USER_EXISTS=`${MYSQL_COMMAND} -se "SELECT COUNT(*) FROM mysql.user WHERE User='${MYSQL_USER}'"`

# Create the database and user if they don't exist
if [[ $DB_EXISTS -eq 0 ]]; then
  ${MYSQL_COMMAND} -e "CREATE DATABASE ${MYSQL_DATABASE}"
  echo "Database ${MYSQL_DATABASE} created"
else
  echo "Database ${MYSQL_DATABASE} already exists"
fi

if [[ $USER_EXISTS -eq 0 ]]; then
  ${MYSQL_COMMAND} -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}'"
  ${MYSQL_COMMAND} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%'"
  ${MYSQL_COMMAND} -e "FLUSH PRIVILEGES"
  echo "User ${MYSQL_USER} created with all privileges on ${MYSQL_DATABASE}"
else
  echo "User ${MYSQL_USER} already exists"
fi
