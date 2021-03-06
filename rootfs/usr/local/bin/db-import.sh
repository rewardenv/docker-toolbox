#!/usr/bin/env bash

[ "$DEBUG" = "true" ] && set -x
set -euo pipefail

log() {
  [ "${SILENT}" != "true" ] && echo -e "$*"
}

fatal() {
  echo -e "$*"
  exit 1
}

usage() {
  fatal "$(cat <<EOF
usage: $0 options db-dump.sql
Options:
-s, --quiet: suppress messages
--host: which host to connect (default: db)
--port: which port to use (default: 3306)
--user: username (default: mysql)
--password: password (default: password)
--scheme: which db to import (default: db)
EOF
)"
}

if [ "$#" -eq 0 ]; then
  usage
fi

# Set defaults
COMPRESSION="${COMPRESSION:-gz}"
UNCOMPRESS_COMMAND="${UNCOMPRESS_COMMAND:-gzip -c}"
MYSQL_COMMAND="${MYSQL_COMMAND:-mysql}"
MYSQL_ARGS="${MYSQL_ARGS:-}"
MYSQL_HOST="${MYSQL_HOST:-}"
MYSQL_PORT="${MYSQL_PORT:-}"
MYSQL_SCHEME="${MYSQL_SCHEME:-}"
MYSQL_USER="${MYSQL_USER:-}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"
MYSQL_DEFINER_HOST="${MYSQL_DEFINER_HOST:-localhost}"
SILENT="${SILENT:-false}"
BACKUP_FILE_PATH="${BACKUP_FILE_PATH:-}"
DELETE_DEFINERS="${DELETE_DEFINERS:-false}"
SED_COMMAND="${SED_COMMAND:-sed}"
SED_ARGS=("-e" "s/DEFINER=\`[^\`]+\`@\`[^\`]+\`/DEFINER=\`${MYSQL_USER}\`@\`${MYSQL_DEFINER_HOST}\`/g")
if [ "${DELETE_DEFINERS}" = "true" ]; then
  SED_ARGS=("-e" "s/DEFINER[ ]*=[ ]*[^*]*\*/\*/")
fi

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -s|--quiet)
      SILENT="true"
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
    *)
      BACKUP_FILE_PATH="$1"
      break
      ;;
  esac
done

if [ -n "${MYSQL_HOST}" ]; then MYSQL_ARGS+=" --host=${MYSQL_HOST}"; fi
if [ -n "${MYSQL_PORT}" ]; then MYSQL_ARGS+=" --port=${MYSQL_PORT}"; fi
if [ -n "${MYSQL_USER}" ]; then MYSQL_ARGS+=" --user=${MYSQL_USER}"; fi
if [ -n "${MYSQL_PASSWORD}" ]; then MYSQL_ARGS+=" --password=${MYSQL_PASSWORD}"; fi

if [[ ${BACKUP_FILE_PATH} =~ (\.sql|\.sql\.gz|\.sql\.gzip|\.gz|\.gzip|\.sql\.bz2|\.bz2|\.sql\.zip|\.zip|\.sql\.xz|\.xz)$ ]]; then
  EXTENSION=${BASH_REMATCH[1]}
  if [[ $EXTENSION =~ (\.sql)?\.(gz|gzip|bz2|zip|xz)$ ]]; then
    COMPRESSION=${BASH_REMATCH[2]}
  else
    COMPRESSION="uncompressed"
  fi
else
  fatal "Bad database format! Accepted formats:\n*.sql, *.sql.gz, *.sql.bz2, *.sql.zip, *.sql.xz"
fi

case $COMPRESSION in
gz|gzip)
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
uncompressed)
  ;;
esac

import_database() {
  if [ ${COMPRESSION} = "uncompressed" ]; then
    log "Importing raw file: ${BACKUP_FILE_PATH}"
    # shellcheck disable=SC2086
    ${SED_COMMAND} "${SED_ARGS[@]}" "${BACKUP_FILE_PATH}" \
      | ${MYSQL_COMMAND} ${MYSQL_ARGS} ${MYSQL_SCHEME}
  else
    log "Importing ${COMPRESSION} compressed file: ${BACKUP_FILE_PATH}"

    # shellcheck disable=SC2086
    ${UNCOMPRESS_COMMAND} < "${BACKUP_FILE_PATH}" \
      | ${SED_COMMAND} "${SED_ARGS[@]}" \
      | ${MYSQL_COMMAND} ${MYSQL_ARGS} ${MYSQL_SCHEME}
  fi
}

import_database

log "Done."
