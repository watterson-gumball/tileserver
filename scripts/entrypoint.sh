#!/bin/bash

if [ -f /scripts/conf.sh ]; then
  echo "Running mounted script..."
  bash /scripts/conf.sh
else
  echo "Mounted script not found, skipping..."
fi

exec "$@"