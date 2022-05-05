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
usage: $0 options media-dump.tar.gz
Options:
-s, --quiet: suppress messages
--target-dir: target directory for extraction (default: data)
--search-for: search for directory in archive (default: "")
EOF
)"
}

if [ "$#" -eq 0 ]; then
  usage
  exit 1
fi

# Set defaults
COMPRESSION="${COMPRESSION:-gz}"
UNCOMPRESS_COMMAND="${UNCOMPRESS_COMMAND:-gzip -c}"
SILENT="${SILENT:-false}"
BACKUP_FILE_PATH="${BACKUP_FILE_PATH:-}"
TARGET_DIR="${TARGET_DIR:-data}"
SEARCH_FOR="${SEARCH_FOR:-}"

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
    --target-dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    --search-for)
      SEARCH_FOR="$2"
      shift 2
      ;;
    *)
      # Allow command to fail, handle in the next line.
      set +e
      BACKUP_FILE_PATH=$(readlink -f "$1")
      set -e
      if [ -z "${BACKUP_FILE_PATH:+x}" ]; then
        fatal "Backup file path cannot be read: ${1}"
      fi
      break
      ;;
  esac
done


if [[ ${BACKUP_FILE_PATH} =~ (\.tar\.gz|\.tgz|\.tar\.bz2|\.tbz2|\.zip|\.tar\.xz|\.txz)$ ]]; then
  EXTENSION=${BASH_REMATCH[1]}
  if [[ $EXTENSION =~ (\.tar)?\.(gz|gzip|bz2|zip|xz)$ ]]; then
    COMPRESSION=${BASH_REMATCH[2]}
  elif [[ $EXTENSION =~ \.(tgz)$ ]]; then
    COMPRESSION="gz"
  elif [[ $EXTENSION =~ \.(tbz2)$ ]]; then
    COMPRESSION="bz2"
  elif [[ $EXTENSION =~ \.(txz)$ ]]; then
    COMPRESSION="xz"
  elif [[ $EXTENSION =~ \.(zip)$ ]]; then
    COMPRESSION="zip"
  else
    COMPRESSION="unknown"
  fi
else
  fatal "Bad media format! Accepted formats:\n*.txz, *.tar.xz, *.tar.gz, *.tgz, *.tar.bz2, *.tbz2, *.zip"
fi

case $COMPRESSION in
gz|gzip)
  CHECK_COMMAND="tar tf"
  UNCOMPRESS_COMMAND="tar zxvf"
  ;;
bz2)
  CHECK_COMMAND="tar tf"
  UNCOMPRESS_COMMAND="tar jxvf"
  ;;
zip)
  UNCOMPRESS_COMMAND="unzip -p"
  ;;
xz)
  CHECK_COMMAND="tar tf"
  UNCOMPRESS_COMMAND="tar Jxvf"
  ;;
unknown)
  ;;
esac

import_media() {
  if [ ${COMPRESSION} = "unknown" ]; then
    fatal "Bad media format! Accepted formats:\n*.txz, *.tar.xz, *.tar.gz, *.tgz, *.tar.bz2, *.tbz2, *.zip"
  else
    log "Extracting ${COMPRESSION} compressed file: ${BACKUP_FILE_PATH} to ${TARGET_DIR}"

    mkdir -p "${TARGET_DIR}"
    cd "${TARGET_DIR}"

    # shellcheck disable=SC2086
    if [ -n "${SEARCH_FOR}" ]; then
      if ${CHECK_COMMAND} "${BACKUP_FILE_PATH}" "${SEARCH_FOR}" &>/dev/null; then
        SEARCH_CONTAINS=true
      else
        SEARCH_CONTAINS=false
      fi
    fi

    if [ "${SEARCH_CONTAINS}" = "true" ]; then
      ${UNCOMPRESS_COMMAND} "${BACKUP_FILE_PATH}" --strip-components=1 "${SEARCH_FOR}"
    else
      ${UNCOMPRESS_COMMAND} "${BACKUP_FILE_PATH}"
    fi
  fi
}

import_media

log "Done."
