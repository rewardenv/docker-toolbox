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
usage: $0 option
Options:
-s, --quiet: suppress messages
-z, --zip: use zip compression
-g, --gz, --gzip: use gzip compression
-b, --bz2, --bzip2: use gzip compression
-x, --xz: use xz compression
--source-dir: source directory (default: /data)
--target-dir: backup will be created to this directory
--target-filename: the backup will be saved using this name (without extension)
--compress-targets: comma separated target directories to compress (default: pub/media)
--project-type: the type of the project (default: '')
EOF
)"
}

# Set defaults
SILENT="${SILENT:-false}"
TARGET_DIR="${TARGET_DIR:-/data}"
TARGET_FILENAME="${TARGET_FILENAME:-media}"
SOURCE_DIR="${SOURCE_DIR:-.}"
COMPRESS_TARGETS="${COMPRESS_TARGETS:-pub/media}"
PROJECT_TYPE="${PROJECT_TYPE:-}"
FILE_EXTENSION=".tgz"
COMPRESS_COMMAND="tar --ignore-failed-read -zcvf"

echo "Args: $*"

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
      COMPRESS_COMMAND="tar --ignore-failed-read -jcvf"
      shift
      ;;
    -g|--gz|--gzip)
      FILE_EXTENSION=".tgz"
      COMPRESS_COMMAND="tar --ignore-failed-read -zcvf"
      shift
      ;;
    -x|--xz)
      FILE_EXTENSION=".txz"
      COMPRESS_COMMAND="tar --ignore-failed-read -Jcvf"
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
    --source-dir)
      SOURCE_DIR="$2"
      shift 2
      ;;
    --compress-targets)
      COMPRESS_TARGETS="$2"
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
    --project-type)
      PROJECT_TYPE="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

if [ -n "${PROJECT_TYPE}" ]; then
  log "Project type is: ${PROJECT_TYPE}"

  case "${PROJECT_TYPE}" in
    magento)
      COMPRESS_TARGETS="pub/media,var/import,var/export,var/importexport"
      log "Compress targets: ${COMPRESS_TARGETS}"
      ;;
    shopware)
      COMPRESS_TARGETS="public/media,public/sitemap,public/thumbnail,files"
      log "Compress targets: ${COMPRESS_TARGETS}"
      ;;
    wordpress)
      COMPRESS_TARGETS="wp-content/uploads"
      log "Compress targets: ${COMPRESS_TARGETS}"
      ;;
    *)
      error "Unknown project type: ${PROJECT_TYPE}"
      ;;
  esac
fi

export_media() {
    log "Compressing file: ${TARGET_DIR}/${TARGET_FILENAME}${FILE_EXTENSION} from ${SOURCE_DIR} compress targets: ${COMPRESS_TARGETS//,/ }"
    mkdir -p "${TARGET_DIR}"
    cd "${SOURCE_DIR}"
    eval "${COMPRESS_COMMAND} ${TARGET_DIR}/${TARGET_FILENAME}${FILE_EXTENSION} ${COMPRESS_TARGETS//,/ }"
}

export_media

log "Done."
