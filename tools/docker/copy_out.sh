#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-benchmarks-$(whoami):latest}"
DEST_DIR="${2:-../../}"
CONTAINER_NAME="tmp_extract_$RANDOM"
DIRS=("parsec" "jikes" "cpu2006" "cpu2006_pinballs" "npb")
SRC_BASE="/root/benchmarks"

cleanup() {
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "Image $IMAGE not found — attempting to build with 'make build'..."
  make build
fi

echo "Creating container $CONTAINER_NAME from image $IMAGE..."
docker create --name "$CONTAINER_NAME" "$IMAGE" >/dev/null

#mkdir -p "$DEST_DIR"

for d in "${DIRS[@]}"; do
  SRC_PATH="$SRC_BASE/$d"
  echo "Copying $SRC_PATH -> $DEST_DIR/$d ..."
  if docker cp "$CONTAINER_NAME":"$SRC_PATH" "$DEST_DIR"/ 2>/dev/null; then
    echo "Copied $d"
  else
    echo "Warning: $SRC_PATH not found in image"
  fi
done

echo "Done. Extracted to $DEST_DIR"
