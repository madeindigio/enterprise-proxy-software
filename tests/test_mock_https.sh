#!/bin/bash

# Test Mock Server HTTPS Endpoints
# This test verifies that the mock HTTPS server is working correctly

MOCK_HOST="localhost"
MOCK_HTTPS_PORT="9443"

echo "Testing mock server HTTPS endpoints..."

# Test root endpoint
echo "Testing HTTPS root endpoint..."
response=$(curl -s --insecure https://$MOCK_HOST:$MOCK_HTTPS_PORT/)

if echo "$response" | grep -q '"message": "Mock server is running"'; then
    echo "✓ HTTPS root endpoint test passed"
else
    echo "✗ HTTPS root endpoint test failed"
    echo "Response: $response"
    exit 1
fi

# Test /test endpoint
echo "Testing HTTPS /test endpoint..."
response=$(curl -s --insecure https://$MOCK_HOST:$MOCK_HTTPS_PORT/test)

if echo "$response" | grep -q '"status": "ok"'; then
    echo "✓ HTTPS /test endpoint test passed"
else
    echo "✗ HTTPS /test endpoint test failed"
    echo "Response: $response"
    exit 1
fi

# Test /headers endpoint
echo "Testing HTTPS /headers endpoint..."
response=$(curl -s --insecure -H "X-HTTPS-Test: https-value" https://$MOCK_HOST:$MOCK_HTTPS_PORT/headers)

if echo "$response" | grep -q '"X-HTTPS-Test": "https-value"'; then
    echo "✓ HTTPS /headers endpoint test passed"
else
    echo "✗ HTTPS /headers endpoint test failed"
    echo "Response: $response"
    exit 1
fi

# Test POST request
echo "Testing HTTPS POST request..."
response=$(curl -s --insecure -X POST \
    -H "Content-Type: application/json" \
    -d '{"https_post": "test"}' \
    https://$MOCK_HOST:$MOCK_HTTPS_PORT/)

if echo "$response" | grep -q '"method": "POST"' && echo "$response" | grep -q '"https_post": "test"'; then
    echo "✓ HTTPS POST request test passed"
else
    echo "✗ HTTPS POST request test failed"
    echo "Response: $response"
    exit 1
fi

# Test status codes
echo "Testing HTTPS status codes..."
for code in 200 404 500; do
    response=$(curl -s -w "%{http_code}" --insecure https://$MOCK_HOST:$MOCK_HTTPS_PORT/status?code=$code)
    status_code=${response: -3}

    if [ "$status_code" = "$code" ]; then
        echo "✓ HTTPS status code $code test passed"
    else
        echo "✗ HTTPS status code $code test failed (got $status_code)"
        exit 1
    fi
done

echo "All mock server HTTPS endpoint tests passed!"
exit 0
