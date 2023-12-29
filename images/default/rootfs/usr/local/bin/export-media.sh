#!/usr/bin/env bash
[ "$DEBUG" = "true" ] && set -x
set -eEuo pipefail

log() {
  [ "${SILENT}" != "true" ] && echo -e "INFO: $*"
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
usage: $0 options media-dump.tar.gz
Options:
-s, --quiet: suppress messages
-z, --zip: use zip compression
-g, --gz, --gzip: use gzip compression
-b, --bz2, --bzip2: use gzip compression
-x, --xz: use xz compression
--source-dir: target directory to compress (default: data)
--target-dir: backup will be created to this directory
--target-filename: the backup will be saved using this name (without extension)
EOF
)"
}

# Set defaults
SILENT="${SILENT:-false}"
TARGET_DIR="${TARGET_DIR:-/data}"
TARGET_FILENAME="${TARGET_FILENAME:-media}"
SOURCE_DIR="${SOURCE_DIR:-/media}"
FILE_EXTENSION=".tgz"
COMPRESS_COMMAND="tar -zcvf"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      usage
      ;;
    -z|--zip)
      FILE_EXTENSION=".zip"
      COMPRESS_COMMAND="zip -r"
      shift
      ;;
    -b|--bz2|--bzip2)
      FILE_EXTENSION=".tbz2"
      COMPRESS_COMMAND="tar -jcvf"
      shift
      ;;
    -g|--gz|--gzip)
      FILE_EXTENSION=".tgz"
      COMPRESS_COMMAND="tar -zcvf"
      shift
      ;;
    -x|--xz)
      FILE_EXTENSION=".txz"
      COMPRESS_COMMAND="tar -Jcvf"
      shift
      ;;
    -s|--quiet)
      SILENT="true"
      shift
      ;;
    --source-dir)
      SOURCE_DIR="$2"
      shift 2
      ;;
    --target-dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    --target-filename)
      TARGET_FILENAME="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

export_media() {
    log "Compressing file: ${TARGET_DIR}/${TARGET_FILENAME}${FILE_EXTENSION} from ${SOURCE_DIR}"
    mkdir -p "${TARGET_DIR}"
    cd "${SOURCE_DIR}"
    eval "${COMPRESS_COMMAND} ${TARGET_DIR}/${TARGET_FILENAME}${FILE_EXTENSION} ."
}

export_media

log "Done."
