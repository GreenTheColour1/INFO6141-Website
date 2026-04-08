#!/usr/bin/env bash
set -e

echo "Building Nix image..."
nix build .#blog-image

IMAGE_PATH=$(nix build .#blog-image --print-out-path)/tarball/
echo "Loading Docker image from $IMAGE_PATH..."
docker load < "$IMAGE_PATH"

echo "Tagging image as info6141-blog:latest..."
docker tag info6141-blog:latest info6141-blog:latest 2>/dev/null || \
  docker tag $(docker images 'info6141-blog:*' --format '{{.ID}}' | head -1) info6141-blog:latest

echo "Starting containers with docker compose..."
docker compose up -d

echo "Done! App should be running at http://localhost:8042"
