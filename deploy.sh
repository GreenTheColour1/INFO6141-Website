#!/usr/bin/env bash
set -e

echo "Building Nix image..."
IMAGE_PATH=$(nix build .#blog-image --print-out-path)/tarball/
echo "Loading Docker image from $IMAGE_PATH..."
LOAD_OUTPUT=$(sudo docker load < "$IMAGE_PATH")
echo "$LOAD_OUTPUT"

FULL_IMAGE=$(echo "$LOAD_OUTPUT" | sed 's/Loaded image: //')
echo "Tagging image as info6141-blog:latest..."
sudo docker tag "$FULL_IMAGE" info6141-blog:latest

echo "Starting containers with docker compose..."
sudo docker compose up -d

echo "Done! App should be running at http://localhost:8042"
