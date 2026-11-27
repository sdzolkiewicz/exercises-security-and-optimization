#!/bin/sh
set -eu

if [ $# -ne 2 ]; then
  echo "Usage: $0 <github_user/repo> <docker_user/dockerhub_repo>" >&2
  exit 1
fi

: "${DOCKER_USER:?DOCKER_USER env variable is required}"
: "${DOCKER_PWD:?DOCKER_PWD env variable is required}"

REPO_URL="https://github.com/$1"
IMAGE="$2"

if ! echo "$IMAGE" | grep -Eq '^[a-z0-9]+/[a-z0-9._-]+(:[A-Za-z0-9._-]+)?$'; then
  echo "Error: second argument must be <docker_user>/<dockerhub_repo>, got '$IMAGE'" >&2
  exit 1
fi

WORKDIR="$(mktemp -d)"
cleanup() {
  rm -rf "$WORKDIR"
  docker logout >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Logging into Docker Hub..."
echo "$DOCKER_PWD" | docker login -u "$DOCKER_USER" --password-stdin

echo "Cloning $REPO_URL..."
git clone --depth 1 "$REPO_URL" "$WORKDIR"

echo "Building $IMAGE..."
docker build -t "$IMAGE" "$WORKDIR"

echo "Pushing $IMAGE..."
docker push "$IMAGE"

echo "Done: $IMAGE"