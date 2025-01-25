#!/bin/bash

URL="http://localhost"

echo "Validating the service..."
status_code=$(curl -o /dev/null -s -w "%{http_code}" $URL)

if [ $status_code -eq 200 ]; then
  echo "Service is running successfully."
else
  echo "Service validation failed. HTTP Status Code: $status_code"
  exit 1
fi
