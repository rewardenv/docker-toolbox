#!/usr/bin/env bash
[ "${DEBUG:-false}" = "true" ] && set -x
set -eEuo pipefail

log() {
  [ "${SILENT:-false}" != "true" ] && echo -e "INFO: $*"
}

error() {
  exitcode=$?

  echo -e "ERROR: $*"

  if [ "${exitcode}" -eq 0 ]; then
    exit 1
  fi

  exit "${exitcode}"
}

trap 'error status code: $? line: ${LINENO}' ERR

usage() {
  error "$(
    cat <<EOF
usage: $0 options
Options:
-s, --quiet: suppress messages
--source-file: the file that should be imported
--drop: drop and recreate database before import (default: false)
--host: which host to connect (default: db)
--port: which port to use (default: 3306)
--user: username (default: mysql)
--password: password (default: password)
--scheme: which db to import (default: db)
EOF
  )"
}

# Set defaults
: "${COMPRESSION:=gz}"
: "${UNCOMPRESS_COMMAND:=gzip -c}"
: "${MYSQL_ARGS:=}"
: "${MYSQL_HOST:=mysql}"
: "${MYSQL_PORT:=3306}"
: "${MYSQL_SCHEME:=magento}"
: "${MYSQL_USER:=magento}"
: "${MYSQL_PASSWORD:=magento}"
: "${MYSQL_CONNECTION_ARGS:=}"
: "${MYSQL_DEFINER_HOST:=localhost}"
: "${MYSQL_DROP:=false}"
: "${SILENT:=false}"
: "${SOURCE_FILE:=}"
: "${DELETE_DEFINERS:=false}"
: "${SED_COMMAND:=sed}"

SED_ARGS=("-e" "s/DEFINER=\`[^\`]+\`@\`[^\`]+\`/DEFINER=\`${MYSQL_USER}\`@\`${MYSQL_DEFINER_HOST}\`/g")
if [ "${DELETE_DEFINERS}" = "true" ]; then
  SED_ARGS=("-e" "s/DEFINER[ ]*=[ ]*[^*]*\*/\*/")
fi

: "${MYSQL_COMMAND:=mysql}"
if command -v mariadb &>/dev/null; then
  MYSQL_COMMAND="mariadb"
fi

while test $# -gt 0; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    -s | --quiet)
      SILENT="true"
      shift
      ;;
    --drop)
      MYSQL_DROP="true"
      shift
      ;;
    --scheme)
      MYSQL_SCHEME="$2"
      shift 2
      ;;
    --host)
      MYSQL_HOST="$2"
      shift 2
      ;;
    --port)
      MYSQL_PORT="$2"
      shift 2
      ;;
    --user)
      MYSQL_USER="$2"
      shift 2
      ;;
    --password)
      MYSQL_PASSWORD="$2"
      shift 2
      ;;
    --definer-host)
      MYSQL_DEFINER_HOST="$2"
      shift 2
      ;;
    --source-file)
      SOURCE_FILE="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

if [ -z "${SOURCE_FILE:+x}" ]; then
  usage
fi

if [ -n "${MYSQL_HOST}" ]; then MYSQL_CONNECTION_ARGS+=" --host=${MYSQL_HOST}"; fi
if [ -n "${MYSQL_PORT}" ]; then MYSQL_CONNECTION_ARGS+=" --port=${MYSQL_PORT}"; fi
if [ -n "${MYSQL_USER}" ]; then MYSQL_CONNECTION_ARGS+=" --user=${MYSQL_USER}"; fi
if [ -n "${MYSQL_PASSWORD}" ]; then MYSQL_CONNECTION_ARGS+=" --password=${MYSQL_PASSWORD}"; fi

if [[ ${SOURCE_FILE} =~ (\.sql|\.sql\.gz|\.sql\.gzip|\.gz|\.gzip|\.sql\.bz2|\.bz2|\.sql\.zip|\.zip|\.sql\.xz|\.xz)$ ]]; then
  EXTENSION=${BASH_REMATCH[1]}
  if [[ $EXTENSION =~ (\.sql)?\.(gz|gzip|bz2|zip|xz)$ ]]; then
    COMPRESSION=${BASH_REMATCH[2]}
  else
    COMPRESSION="uncompressed"
  fi
else
  error "Bad database format! Accepted formats: *.sql, *.sql.gz, *.sql.bz2, *.sql.zip, *.sql.xz"
fi

case $COMPRESSION in
  gz | gzip)
    UNCOMPRESS_COMMAND="gunzip -c"
    ;;
  bz2)
    UNCOMPRESS_COMMAND="bunzip2 -c"
    ;;
  zip)
    UNCOMPRESS_COMMAND="unzip -p"
    ;;
  xz)
    UNCOMPRESS_COMMAND="unxz -c"
    ;;
  uncompressed) ;;
esac

wait_connection_ready() {
  log "Waiting for mysql connection to be ready..."
  timeout 30 bash -c -- "while ! mysqladmin ping ${MYSQL_CONNECTION_ARGS} --silent; do sleep 5; done"
}

recreate_database() {
  log "Dropping database ${MYSQL_SCHEME}..."
  # shellcheck disable=SC2089
  DROP_ARGS="${MYSQL_ARGS}"
  DROP_ARGS+=" -e 'DROP DATABASE ${MYSQL_SCHEME}; CREATE DATABASE ${MYSQL_SCHEME};'"
  eval "${MYSQL_COMMAND} ${MYSQL_CONNECTION_ARGS} ${DROP_ARGS[*]}"
}

import_database() {
  if [ ${COMPRESSION} = "uncompressed" ]; then
    log "Importing raw file: ${SOURCE_FILE}"
    # shellcheck disable=SC2086
    eval "${SED_COMMAND} '${SED_ARGS[*]}' ${SOURCE_FILE} | ${MYSQL_COMMAND} ${MYSQL_CONNECTION_ARGS} ${MYSQL_ARGS} ${MYSQL_SCHEME}"
  else
    log "Importing ${COMPRESSION} compressed file: ${SOURCE_FILE}"

    # shellcheck disable=SC2086
    eval "${UNCOMPRESS_COMMAND} < ${SOURCE_FILE} | ${SED_COMMAND} '${SED_ARGS[*]}' | ${MYSQL_COMMAND} ${MYSQL_CONNECTION_ARGS} ${MYSQL_ARGS} ${MYSQL_SCHEME}"
  fi
}

wait_connection_ready

if [ "${MYSQL_DROP}" = "true" ]; then
  recreate_database
fi

import_database

log "Done."
