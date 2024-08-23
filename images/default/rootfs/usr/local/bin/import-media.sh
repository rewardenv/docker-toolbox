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
--source-file: the file that should be imported
--target-dir: target directory for extraction (default: data)
--target-subdir: target subdirectory for extraction (default: '')
--search-for: search for this directory in the archive for media (default: '')
--project-type: the type of the project (default: '')
--cleanup: remove everything from the target directory before importing
--fix-permission: change owner and group after import
--owner: change owner of files to this after the import (default: 1000)
--group: change group of files to this after the import (default: 1000)
EOF
)"
}

# Set defaults
COMPRESSION="${COMPRESSION:-gz}"
UNCOMPRESS_COMMAND="${UNCOMPRESS_COMMAND:-gzip -c}"
SILENT="${SILENT:-false}"
PROJECT_TYPE="${PROJECT_TYPE:-}"
SOURCE_FILE="${SOURCE_FILE:-}"
TARGET_DIR="${TARGET_DIR:-data}"
TARGET_SUBDIR="${TARGET_SUBDIR:-}"
SEARCH_FOR="${SEARCH_FOR:-}"
CLEANUP="${CLEANUP:-false}"
FIX_PERMISSIONS="${FIX_PERMISSIONS:-false}"
OWNER="${OWNER:-1000}"
GROUP="${GROUP:-1000}"

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
    --project-type)
      PROJECT_TYPE="$2"
      shift 2
      ;;
    --target-subdir)
      TARGET_SUBDIR="$2"
      shift 2
      ;;
    --search-for)
      SEARCH_FOR="$2"
      shift 2
      ;;
    --cleanup)
      CLEANUP="true"
      shift
      ;;
    --fix-permissions)
      FIX_PERMISSIONS="true"
      shift
      ;;
    --owner)
      OWNER="$2"
      shift 2
      ;;
    --group)
      GROUP="$2"
      shift 2
      ;;
    --source-file)
      set +e
      SOURCE_FILE=$(readlink -f "$2")
      set -e
      if [ -z "${SOURCE_FILE:+x}" ]; then
        error "Source file absolute path cannot be read: ${2}"
      fi
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

if [[ ${SOURCE_FILE} =~ (\.tar\.gz|\.tgz|\.tar\.bz2|\.tbz2|\.zip|\.tar\.xz|\.txz)$ ]]; then
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
  error "Bad media format! Accepted formats: *.txz, *.tar.xz, *.tar.gz, *.tgz, *.tar.bz2, *.tbz2, *.zip"
fi

if [ -n "${PROJECT_TYPE}" ]; then
  log "Project type is: ${PROJECT_TYPE}"

  case "${PROJECT_TYPE}" in
    magento)
      SEARCH_FOR="media"
      TARGET_SUBDIR="pub"
      log "Searching for media in: ${SEARCH_FOR}"
      ;;
    shopware)
      SEARCH_FOR="media"
      TARGET_SUBDIR="public"
      log "Searching for media in: ${SEARCH_FOR}"
      ;;
    wordpress)
      SEARCH_FOR="uploads"
      TARGET_SUBDIR="wp-content"
      log "Searching for media in: ${SEARCH_FOR}"
      ;;
    *)
      error "Unknown project type: ${PROJECT_TYPE}"
      ;;
  esac
fi

case $COMPRESSION in
gz|gzip)
  CHECK_COMMAND="tar tf ${SOURCE_FILE} ${SEARCH_FOR} 2>/dev/null | wc -l"
  UNCOMPRESS_COMMAND="tar zxvf ${SOURCE_FILE}"
  UNCOMPRESS_COMMAND_STRIPPED="mkdir -p ${TARGET_SUBDIR} && tar zxvf ${SOURCE_FILE} -C ${TARGET_SUBDIR} ${SEARCH_FOR}"
  ;;
bz2)
  CHECK_COMMAND="tar tf ${SOURCE_FILE} ${SEARCH_FOR} 2>/dev/null | wc -l"
  UNCOMPRESS_COMMAND="tar jxvf ${SOURCE_FILE}"
  UNCOMPRESS_COMMAND_STRIPPED="mkdir -p ${TARGET_SUBDIR} && tar jxvf ${SOURCE_FILE} -C ${TARGET_SUBDIR} ${SEARCH_FOR}"
  ;;
zip)
  CHECK_COMMAND="unzip -l ${SOURCE_FILE} | tail -n +4 | awk '{print \$4}' | grep \"^${SEARCH_FOR}/$\""
  UNCOMPRESS_COMMAND='unzip -o ${SOURCE_FILE}'
  UNCOMPRESS_COMMAND_STRIPPED='mkdir -p ${TARGET_SUBDIR} && unzip -o -d ${TARGET_SUBDIR} ${SOURCE_FILE}'
  ;;
xz)
  CHECK_COMMAND="tar tf ${SOURCE_FILE} ${SEARCH_FOR} 2>/dev/null | wc -l"
  UNCOMPRESS_COMMAND="tar Jxvf ${SOURCE_FILE}"
  UNCOMPRESS_COMMAND_STRIPPED="mkdir -p ${TARGET_SUBDIR} && tar Jxvf ${SOURCE_FILE} -C ${TARGET_SUBDIR} ${SEARCH_FOR}"
  ;;
unknown)
  ;;
esac

cleanup() {
  find "${TARGET_DIR}" -mindepth 1 -delete
}

import_media() {
  if [ ${COMPRESSION} = "unknown" ]; then
    error "Bad media format! Accepted formats:\n*.txz, *.tar.xz, *.tar.gz, *.tgz, *.tar.bz2, *.tbz2, *.zip"
  else
    log "Extracting ${COMPRESSION} compressed file: ${SOURCE_FILE} to ${TARGET_DIR}"

    mkdir -p "${TARGET_DIR}"
    cd "${TARGET_DIR}"

    SEARCH_CONTAINS=false
    # shellcheck disable=SC2086
    if [ -n "${SEARCH_FOR}" ]; then
      log "Checking if the archive contains ${SEARCH_FOR} directory"
      if [ "$(eval "${CHECK_COMMAND}")" -gt 0 ]; then
        log "The archive contains ${SEARCH_FOR} directory"
        SEARCH_CONTAINS=true
      fi
    fi

    if [ "${SEARCH_CONTAINS}" = "true" ]; then
      log "Extracting ${SEARCH_FOR} directory from the archive"
      eval "${UNCOMPRESS_COMMAND_STRIPPED}"
    else
      log "Extracting the whole archive"
      eval "${UNCOMPRESS_COMMAND}"
    fi
  fi
}

fix_permissions() {
  find "${TARGET_DIR}" -exec chown -v "${OWNER}:${GROUP}" {} \;
}

if [ "${CLEANUP}" = "true" ]; then
  cleanup
fi

import_media

if [ "${FIX_PERMISSIONS}" = "true" ]; then
  fix_permissions
fi

log "Done."
