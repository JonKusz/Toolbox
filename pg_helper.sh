#!/bin/bash

# A simple wrapper script for postgres backup and restore operations.
# Set values for the below variable block before running.
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASS=postgres
DB=postgres

OP=$1
DUMP_PATH=$2

info () {
    echo -e "\nINFO: ${1}"
}
warn () {
    echo -e "\nWARN: ${1}"
}
error () {
    echo -e "\nERROR: ${1}"
} 

if [[ $# < 1 && "${OP}" == "clean" ]] || [[ $# <2 && "${OP}" != "clean" ]]; then
    echo ""
    echo "Invalid invokation, please see usage."
    echo ""
    echo "Usage: pg_helper.sh <backup, restore> <dumpfile>"
    echo "       pg_helper.sh clean"
    echo ""
    exit 1
fi

[[ -z ${DB_HOST} ]] && echo "DB_HOST cannot be empty" && exit 1
[[ -z ${DB_PORT} ]] && echo "DB_PORT cannot be empty" && exit 1
[[ -z ${DB_USER} ]] && echo "DB_USER cannot be empty" && exit 1
[[ -z ${DB_PASS} ]] && echo "DB_PASS cannot be empty" && exit 1 
[[ -z ${DB} ]]      && echo "DB cannot be empty"      && exit 1

if [[ ! -f ~/".pgpass" ]]; then
    info ".pgpass file not found, creating it"
    touch ~/.pgpass && chmod 0600 ~/.pgpass
fi

if [[ ! $(grep "${DB_HOST}:${DB_PORT}:${DB}:${DB_USER}:${DB_PASS}" ~/.pgpass) ]]; then
    info ".pgpass file entry not found for database specified, adding it"
    echo "${DB_HOST}:${DB_PORT}:${DB}:${DB_USER}:${DB_PASS}" >> ~/.pgpass
fi

if [[ "${OP}" == "backup" ]]; then
    info "Starting backup operation."
    pg_dump -Fc -Z 9 --file ${DUMP_PATH} -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -w ${DB} -v
    info "Backup operation finished, please review the output."
elif [[ "${OP}" == "restore" ]]; then
    info "Starting restore operation."
    pg_restore -Fc -j 8 -v -U ${DB_USER} -h ${DB_HOST} -d ${DB} ${DUMP_PATH}
    info "Restore operation finished, please review the output."
elif [[ "${OP}" == "clean" ]]; then
    MSG=$(warn "The clean operation removes all .dump files, continue?")
    read -n 1 -s -r -p "${MSG}"
    rm -rf *.dump
    info "Clean operation complete."
else
    error "No matching command found, exiting..." && exit 1
fi