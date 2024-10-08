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
  error "Usage: $0 domain.com"
}

MYSQL_COMMAND="${MYSQL_COMMAND:-mysql}"
MYSQL_ARGS="${MYSQL_ARGS:-}"
MYSQL_HOST="${MYSQL_HOST:-}"
MYSQL_PORT="${MYSQL_PORT:-}"
MYSQL_SCHEME="${MYSQL_SCHEME:-}"
MYSQL_USER="${MYSQL_USER:-}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"
MYSQL_DEFINER_HOST="${MYSQL_DEFINER_HOST:-localhost}"
if [ -n "${MYSQL_HOST}" ]; then MYSQL_ARGS+=" --host=${MYSQL_HOST}"; fi
if [ -n "${MYSQL_PORT}" ]; then MYSQL_ARGS+=" --port=${MYSQL_PORT}"; fi
if [ -n "${MYSQL_USER}" ]; then MYSQL_ARGS+=" --user=${MYSQL_USER}"; fi
if [ -n "${MYSQL_PASSWORD}" ]; then MYSQL_ARGS+=" --password=${MYSQL_PASSWORD}"; fi

SILENT="${SILENT:-true}"
PROJECT_TYPE="${PROJECT_TYPE:-magento}"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      usage
      ;;
    -s|--quiet)
      SILENT="true"
      shift
      ;;
    --project-type)
      PROJECT_TYPE="$2"
      shift 2
      ;;
    *)
      BASE_URL="$1"
      break
      ;;
  esac
done

if [ -z ${BASE_URL:+x} ]; then
  usage
fi

case $PROJECT_TYPE in
  "magento" )
    # Add a trailing slash if missing
    BASE_URL="${BASE_URL%/}/"
    ${MYSQL_COMMAND} ${MYSQL_ARGS} <<EOF
UPDATE ${MYSQL_SCHEME}.core_config_data SET value = "http://${BASE_URL#http*://}" WHERE scope = "default" AND path = "web/unsecure/base_url";
UPDATE ${MYSQL_SCHEME}.core_config_data SET value = "https://${BASE_URL#http*://}" WHERE scope = "default" AND path = "web/secure/base_url";
UPDATE ${MYSQL_SCHEME}.core_config_data SET value = "http://${BASE_URL#http*://}" WHERE scope = "default" AND path = "web/unsecure/base_link_url";
UPDATE ${MYSQL_SCHEME}.core_config_data SET value = "https://${BASE_URL#http*://}" WHERE scope = "default" AND path = "web/secure/base_link_url";
UPDATE ${MYSQL_SCHEME}.core_config_data SET value = NULL WHERE scope = "default" AND path = "web/cookie/cookie_domain";
EOF
    ;;
  * )
    exit
    ;;
esac
