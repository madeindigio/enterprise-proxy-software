#!/bin/bash

# Test HTTPS Proxy Functionality
# This test verifies that the proxy can handle HTTPS CONNECT requests

PROXY_HOST="localhost"
PROXY_PORT="8080"
MOCK_HOST="localhost"
MOCK_HTTPS_PORT="9443"

echo "Testing HTTPS proxy functionality..."

# Test HTTPS CONNECT tunneling
echo "Testing HTTPS CONNECT tunneling..."
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT --max-time 15 \
    --insecure \
    https://$MOCK_HOST:$MOCK_HTTPS_PORT/test)

if echo "$response" | grep -q '"status": "ok"'; then
    echo "✓ HTTPS CONNECT tunneling test passed"
else
    echo "✗ HTTPS CONNECT tunneling test failed"
    echo "Response: $response"
    exit 1
fi

# Test HTTPS headers forwarding
echo "Testing HTTPS headers forwarding..."
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT --max-time 15 \
    --insecure \
    -H "X-Custom-Header: https-test-value" \
    -H "User-Agent: HTTPS-Test-Agent/1.0" \
    https://$MOCK_HOST:$MOCK_HTTPS_PORT/headers)

if echo "$response" | grep -q '"X-Custom-Header": "https-test-value"'; then
    echo "✓ HTTPS headers forwarding test passed"
else
    echo "✗ HTTPS headers forwarding test failed"
    echo "Response: $response"
    exit 1
fi

# Test HTTPS POST requests
echo "Testing HTTPS POST request forwarding..."
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT --max-time 15 \
    --insecure \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"https_test": "data"}' \
    https://$MOCK_HOST:$MOCK_HTTPS_PORT/)

if echo "$response" | grep -q '"method": "POST"'; then
    echo "✓ HTTPS POST request forwarding test passed"
else
    echo "✗ HTTPS POST request forwarding test failed"
    echo "Response: $response"
    exit 1
fi

# Test HTTPS with different status codes
echo "Testing HTTPS status code forwarding..."
for code in 200 404 500; do
    response=$(curl -s -w "%{http_code}" --proxy $PROXY_HOST:$PROXY_PORT --max-time 15 \
        --insecure \
        https://$MOCK_HOST:$MOCK_HTTPS_PORT/status?code=$code)

    status_code=${response: -3}

    if [ "$status_code" = "$code" ]; then
        echo "✓ HTTPS status code $code forwarding test passed"
    else
        echo "✗ HTTPS status code $code forwarding test failed (got $status_code)"
        exit 1
    fi
done

echo "All HTTPS proxy tests passed!"
exit 0
