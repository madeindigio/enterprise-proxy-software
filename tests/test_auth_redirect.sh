#!/bin/bash

# Test Authentication Redirect
# This test verifies that unauthenticated requests are redirected to the auth endpoint

PROXY_HOST="localhost"
PROXY_PORT="8080"
TEST_URL="http://httpbin.org/get"

echo "Testing authentication redirect..."

# Make a request without authentication
response=$(curl -s -w "%{http_code}" --proxy $PROXY_HOST:$PROXY_PORT --max-time 10 $TEST_URL)

# Extract status code (last 3 characters)
status_code=${response: -3}

if [ "$status_code" = "302" ]; then
    echo "✓ Authentication redirect working correctly (302 redirect)"
    exit 0
else
    echo "✗ Expected 302 redirect, got $status_code"
    exit 1
fi
