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
  error "$(cat <<EOF
usage: $0 options
Options:
-s, --quiet: suppress messages
-g, --gz, --gzip: use gzip compression
-b, --bz2, --bzip2: use gzip compression
-x, --xz: use xz compression
--target-dir: backup will be created to this directory
--target-filename: the backup will be saved using this name (without extension)
--host: which host to connect (default: db)
--port: which port to use (default: 3306)
--user: username (default: mysql)
--password: password (default: password)
--scheme: which db to import (default: db)
-p, --procedures: dump procedures only
EOF
)"
}

# Set defaults
SILENT="${SILENT:-false}"
TARGET_DIR="${TARGET_DIR:-/data}"
TARGET_FILENAME="${TARGET_FILENAME:-db}"
MYSQLDUMP_COMMAND="${MYSQLDUMP_COMMAND:-mysqldump}"
MYSQLDUMP_ARGS="${MYSQLDUMP_ARGS:---single-transaction --quick}"
MYSQL_HOST="${MYSQL_HOST:-mysql}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_SCHEME="${MYSQL_SCHEME:-magento}"
MYSQL_USER="${MYSQL_USER:-magento}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-magento}"
MYSQL_CONNECTION_ARGS=""
FILE_EXTENSION=".sql.gz"
COMPRESS_COMMAND="gzip -c"
STRIP="${STRIP:-false}"
PROJECT_TYPE="${PROJECT_TYPE:-magento}"
PREFIX="${PREFIX:-magento}"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      usage
      ;;
    -b|--bz2|--bzip2)
      FILE_EXTENSION=".sql.bz2"
      COMPRESS_COMMAND="bzip2"
      shift
      ;;
    -g|--gz|--gzip)
      FILE_EXTENSION=".sql.gz"
      COMPRESS_COMMAND="gzip"
      shift
      ;;
    -x|--xz)
      FILE_EXTENSION=".sql.xz"
      COMPRESS_COMMAND="xz"
      shift
      ;;
    -s|--quiet)
      SILENT="true"
      shift
      ;;
    --target-dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    --target-filename)
      TARGET_FILENAME="$2"
      shift 2
      ;;
    --scheme)
      MYSQL_SCHEME="$2"
      shift 2
      ;;
    --table)
      MYSQL_TABLE="$2"
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
    -p|--procedures)
      MYSQLDUMP_ARGS+=" --triggers --routines --no-create-info --no-data --no-create-db --skip-opt"
      shift
      ;;
    --strip)
      STRIP="true"
      shift
      ;;
    --project-type)
      PROJECT_TYPE="$2"
      shift 2
      ;;
    --prefix)
      PREFIX="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

if [ -n "${MYSQL_HOST}" ]; then MYSQL_CONNECTION_ARGS+=" --host=${MYSQL_HOST}"; fi
if [ -n "${MYSQL_PORT}" ]; then MYSQL_CONNECTION_ARGS+=" --port=${MYSQL_PORT}"; fi
if [ -n "${MYSQL_USER}" ]; then MYSQL_CONNECTION_ARGS+=" --user=${MYSQL_USER}"; fi
if [ -n "${MYSQL_PASSWORD}" ]; then MYSQL_CONNECTION_ARGS+=" --password=${MYSQL_PASSWORD}"; fi

build_strip_args() {
  if [ "${STRIP}" = "true" ]; then
    case "${PROJECT_TYPE}" in
    "magento")
      STRIPPED_ARGS="--no-data ${MYSQL_SCHEME} persistent_session report_compared_product_index report_event report_viewed_product_aggregated_daily report_viewed_product_aggregated_monthly report_viewed_product_aggregated_yearly report_viewed_product_index reporting_counts reporting_module_status reporting_orders reporting_system_updates reporting_users session"
      IGNORED_TABLES_ARGS="--ignore-table=${PREFIX}.persistent_session --ignore-table=${PREFIX}.report_compared_product_index --ignore-table=${PREFIX}.report_event --ignore-table=${PREFIX}.report_viewed_product_aggregated_daily --ignore-table=${PREFIX}.report_viewed_product_aggregated_monthly --ignore-table=${PREFIX}.report_viewed_product_aggregated_yearly --ignore-table=${PREFIX}.report_viewed_product_index --ignore-table=${PREFIX}.reporting_counts --ignore-table=${PREFIX}.reporting_module_status --ignore-table=${PREFIX}.reporting_orders --ignore-table=${PREFIX}.reporting_system_updates --ignore-table=${PREFIX}.reporting_users --ignore-table=${PREFIX}.session ${MYSQL_SCHEME}"
      ;;
    *)
      STRIP="false"
      STRIPPED_ARGS=""
      IGNORED_TABLES_ARGS=""
      ;;
    esac
  fi
}

create_dir() {
  mkdir -p "${TARGET_DIR}"
  cd "${TARGET_DIR}" || error "Cannot change directory to ${TARGET_DIR}"
}

wait_connection_ready() {
  log "Waiting for mysql connection to be ready..."
  timeout 30 bash -c -- "while ! mysqladmin ping ${MYSQL_CONNECTION_ARGS} --silent; do sleep 5; done"
}

export_db() {
  log "Compressing file: ${TARGET_DIR}/${TARGET_FILENAME}${FILE_EXTENSION}"

  build_strip_args
  create_dir

  if [ "${STRIP}" = "true" ]; then
    eval "${MYSQLDUMP_COMMAND} ${MYSQL_CONNECTION_ARGS} ${MYSQLDUMP_ARGS} ${STRIPPED_ARGS} | ${COMPRESS_COMMAND} > ./${TARGET_FILENAME}${FILE_EXTENSION}"
    eval "${MYSQLDUMP_COMMAND} ${MYSQL_CONNECTION_ARGS} ${MYSQLDUMP_ARGS} ${IGNORED_TABLES_ARGS} | ${COMPRESS_COMMAND} >> ./${TARGET_FILENAME}${FILE_EXTENSION}"
  else
    eval "${MYSQLDUMP_COMMAND} ${MYSQL_CONNECTION_ARGS} ${MYSQLDUMP_ARGS} ${MYSQL_SCHEME} | ${COMPRESS_COMMAND} > ./${TARGET_FILENAME}${FILE_EXTENSION}"
  fi
}

wait_connection_ready
export_db

log "Done."
