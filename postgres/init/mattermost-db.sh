#!/usr/bin/env bash
# Create database for Mattermost
# Envirinment variables MM_DB, MM_DBUSER, MM_DBPASSWORD are used as parameters
# This script will be executed only if Postgres data direcory is empty i.e. on first container run

set -e

if [[ "${MM_DB}" && "${MM_DBUSER}" && "${MM_DBPASSWORD}" ]]; then
    echo "**  Creating Mattermost DB with parameters:
    DB Name: ${MM_DB}
    DB User: ${MM_DBUSER}
    DB Password: ${MM_DBPASSWORD}"

    psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" <<-EOSQL
    CREATE USER ${MM_DBUSER} WITH PASSWORD '${MM_DBPASSWORD}';
    CREATE DATABASE ${MM_DB} WITH OWNER ${MM_DBUSER} ENCODING='UTF8';
    GRANT ALL PRIVILEGES ON DATABASE ${MM_DB} TO ${MM_DBUSER};
EOSQL
else
    echo "**  Can not create user and DB for Mattermost
    Username, password or DB name are not set
    DB Name: ${MM_DB:-DB name is no set}
    DB User: ${MM_DBUSER:-Password is not set}
    DB Password: ${MM_DBPASSWORD:-Username is not set}"
    exit 1
fi

if [[ "${MM_MON_DBUSER}" && "${MM_MON_DBPASSWORD}" ]]; then
    echo "**  Creating Monitoring DB User with parameters:
    Monitoring User: ${MM_MON_DBUSER}
    Monitoring Password: ${MM_MON_DBPASSWORD}"

    psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${MM_DB}" <<-EOSQL
    CREATE USER ${MM_MON_DBUSER} WITH PASSWORD '${MM_MON_DBPASSWORD}';
    GRANT CONNECT ON DATABASE ${MM_DB} TO ${MM_MON_DBUSER};
    GRANT USAGE ON SCHEMA public TO ${MM_MON_DBUSER};
    GRANT pg_monitor, pg_read_all_settings, pg_read_all_stats, pg_stat_scan_tables TO ${MM_MON_DBUSER};
EOSQL
else
    echo "**  Skipping monitoring user creation:
    Username or password for monitoring user are not set
    Monitoring User: ${MM_MON_DBUSER:-Username for monitoring is not set}
    Monitoring Password: ${MM_MON_DBPASSWORD:-Password for monitoring user is not set}"
fi
