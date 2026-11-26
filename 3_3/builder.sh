#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <repo_url> <docker_user/dockerhub_repo>" >&2
  exit 1
fi

REPO_URL="https://github.com/$1"
IMAGE="$2"

if [[ ! "$IMAGE" =~ ^[a-z0-9]+/[a-z0-9._-]+$ ]]; then
  echo "Error: second argument must be <docker_user>/<dockerhub_repo>, got '$IMAGE'" >&2
  exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "Cloning $REPO_URL..."
git clone --depth 1 "$REPO_URL" "$WORKDIR"

echo "Building $IMAGE..."
docker build -t "$IMAGE" "$WORKDIR"

echo "Pushing $IMAGE..."
docker push "$IMAGE"

echo "Done: $IMAGE"