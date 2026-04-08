#!/usr/bin/env bash
set -e

echo "Building Nix image..."
IMAGE_PATH=$(nix build .#blog-image --print-out-paths)
echo "Loading Docker image from $IMAGE_PATH..."
sudo docker load < "$IMAGE_PATH"

echo "Tagging image as info6141-blog:latest..."
sudo docker tag info6141-blog:latest info6141-blog:latest 2>/dev/null || \
  sudo docker tag $(docker images 'info6141-blog:*' --format '{{.ID}}' | head -1) info6141-blog:latest

echo "Starting containers with docker compose..."
sudo docker compose up -d

echo "Done! App should be running at http://localhost:8043"
