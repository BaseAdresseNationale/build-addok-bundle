#!/bin/bash
set -e

# Start Redis in the background
redis-server config/redis.conf --daemonize yes

# Wait for Redis to be ready
until redis-cli ping &>/dev/null; do
    echo "Waiting for Redis to be ready..."
    sleep 1
done

echo "Redis is ready."

# Execute the build script
build-addok-bundle.sh