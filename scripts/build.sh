#!/usr/bin/env bash
[ "$DEBUG" == "true" ] && set -x
set -e
trap '>&2 printf "\n\e[01;31mError: Command \`%s\` on line $LINENO failed with exit code $?\033[0m\n" "$BASH_COMMAND"' ERR

## find directory where this script is located following symlinks if necessary
readonly BASE_DIR="$(
  cd "$(
    dirname "$(
      (readlink "${BASH_SOURCE[0]}" || echo "${BASH_SOURCE[0]}") |
        sed -e "s#^../#$(dirname "$(dirname "${BASH_SOURCE[0]}")")/#"
    )"
  )" >/dev/null &&
    pwd
)/.."
pushd "${BASE_DIR}" >/dev/null

DOCKER_REGISTRY="docker.io"
IMAGE_REPO="${DOCKER_REGISTRY}/rewardenv"

function print_usage() {
  echo "build.sh [--push] [--dry-run] <IMAGE_TYPE>"
  echo
  echo "example:"
  echo "build.sh --push"
}

# Parse long args and translate them to short ones.
for arg in "$@"; do
  shift
  case "$arg" in
  "--push") set -- "$@" "-p" ;;
  "--dry-run") set -- "$@" "-n" ;;
  "--help") set -- "$@" "-h" ;;
  *) set -- "$@" "$arg" ;;
  esac
done

PUSH=${PUSH:-''}
DRY_RUN=${DRY_RUN:-''}

# Parse short args.
OPTIND=1
while getopts "pnh" opt; do
  case "$opt" in
  "p") PUSH=true ;;
  "n") DRY_RUN=true ;;
  "?" | "h")
    print_usage >&2
    exit 1
    ;;
  esac
done
shift "$((OPTIND - 1))"

if [[ ${DRY_RUN} ]]; then
  DOCKER_COMMAND="echo docker"
else
  DOCKER_COMMAND="docker"
fi

if [ "${DOCKER_USE_BUILDX}" = "true" ]; then
  DOCKER_BUILD_COMMAND=${DOCKER_BUILD_COMMAND:-buildx build}
else
  DOCKER_BUILD_COMMAND=${DOCKER_BUILD_COMMAND:-build}
fi
DOCKER_BUILD_PLATFORM=${DOCKER_BUILD_PLATFORM:-} # "linux/amd64,linux/arm/v7,linux/arm64"

# If FROM_IMAGE is defined, then we use it as the base image for all builds. In that case FROM_TAG is derived from it.
#  Else the FROM_IMAGE and the FROM_TAG are derived from the DOCKER_BASE_IMAGE.
if [ -n "${FROM_IMAGE}" ]; then
  FROM_TAG="$(echo "${DOCKER_BASE_IMAGE}" | sed -e 's/:/-/g')"
else
  FROM_IMAGE="$(echo "${DOCKER_BASE_IMAGE}" | cut -d: -f1)"
  FROM_TAG="$(echo "${DOCKER_BASE_IMAGE}" | cut -d: -f2)"
fi

ORIGIN_IMAGE="$(echo "${DOCKER_BASE_IMAGE}" | cut -d: -f1)"
ORIGIN_TAG="$(echo "${DOCKER_BASE_IMAGE}" | cut -d: -f2)"

if [ -z "${ORIGIN_IMAGE}" ]; then
  printf >&2 "\n\e[01;31mError: Missing DOCKER_BASE_IMAGE. Please set it using DOCKER_BASE_IMAGE env var!\033[0m\n"
  print_usage
  exit 1
fi

function docker_login() {
  if [[ ${PUSH} ]]; then
    if [[ ${DOCKER_USERNAME:-} ]]; then
      echo "Attempting non-interactive docker login (via provided credentials)"
      echo "${DOCKER_PASSWORD:-}" | ${DOCKER_COMMAND} login -u "${DOCKER_USERNAME:-}" --password-stdin "${DOCKER_REGISTRY}"
    elif [[ -t 1 ]]; then
      echo "Attempting interactive docker login (tty)"
      ${DOCKER_COMMAND} login "${DOCKER_REGISTRY}"
    fi
  fi
}

function docker_build() {
  if [ -n "${DOCKER_BUILD_PLATFORM}" ]; then
    DOCKER_BUILD_PLATFORM_ARG="--platform ${DOCKER_BUILD_PLATFORM}"
  fi

  BUILD_DIR="$(dirname "${file}")"
  IMAGE_NAME="${IMAGE_NAME:-docker-toolbox}"
  IMAGE_TAG="${IMAGE_REPO}/${IMAGE_NAME}"
  TAG_SUFFIX="${ORIGIN_IMAGE}-${ORIGIN_TAG}"

  IMAGE_TAG+=":${TAG_SUFFIX}"
  BUILD_TAGS=(
    "${IMAGE_TAG}:${TAG_SUFFIX}"
  )

  if [ "${LATEST_TAG:-}" = "true" ]; then
    BUILD_TAGS+=(
      "${IMAGE_TAG}:latest"
    )
  fi

  BUILD_CONTEXT="images/${FLAVOR:-default}"
  BUILD_ARGS+=("IMAGE_NAME=${FROM_IMAGE}")
  BUILD_ARGS+=("IMAGE_TAG=${FROM_TAG}")

  if [ "${PUSH}" = "true" ] && [ "${DOCKER_USE_BUILDX}" = "true" ]; then
    DOCKER_PUSH_ARG="--push"
    TAGS_ARG=$(printf -- "%s " "${BUILD_TAGS[@]/#/--tag }")
  else
    TAGS_ARG="-t ${IMAGE_TAG}"
  fi

  # shellcheck disable=SC2046
  # shellcheck disable=SC2086
  printf "\e[01;31m==> building %s from %s/Dockerfile with context %s\033[0m\n" "${IMAGE_TAG}" "${BUILD_DIR}" "${BUILD_CONTEXT}"
  ${DOCKER_COMMAND} ${DOCKER_BUILD_COMMAND} \
    ${TAGS_ARG} \
    -f "${BUILD_DIR}/Dockerfile" \
    ${DOCKER_BUILD_PLATFORM_ARG} \
    ${DOCKER_PUSH_ARG} \
    $(printf -- "%s " "${BUILD_ARGS[@]/#/--build-arg }") \
    "${BUILD_CONTEXT}"

  # We have to manually push the images if not using docker buildx
  if [ "${DOCKER_USE_BUILDX}" != "true" ]; then
    for tag in "${BUILD_TAGS[@]}"; do
      ${DOCKER_COMMAND} tag "${IMAGE_TAG}" "${tag}"

      if [ "${PUSH}" = "true" ]; then ${DOCKER_COMMAND} push "${tag}"; fi
    done
  fi

  return 0
}

## Login to docker hub as needed
docker_login

for file in $(find "images/${FLAVOR:-default}/${ORIGIN_IMAGE}" -type f -name Dockerfile | sort -t_ -k1,1 -d); do
  docker_build
done

exit 0
