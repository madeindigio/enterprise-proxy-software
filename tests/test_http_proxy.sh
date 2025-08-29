#!/bin/bash

# Test HTTP Proxy Functionality
# This test verifies that the proxy can forward HTTP requests correctly

PROXY_HOST="localhost"
PROXY_PORT="8080"
MOCK_HOST="localhost"
MOCK_PORT="9090"

echo "Testing HTTP proxy functionality..."

# Test basic HTTP proxy
echo "Testing basic HTTP request..."
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT --max-time 10 http://$MOCK_HOST:$MOCK_PORT/test)

if echo "$response" | grep -q '"status": "ok"'; then
    echo "✓ Basic HTTP proxy test passed"
else
    echo "✗ Basic HTTP proxy test failed"
    echo "Response: $response"
    exit 1
fi

# Test headers forwarding
echo "Testing headers forwarding..."
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT --max-time 10 \
    -H "X-Custom-Header: test-value" \
    -H "User-Agent: Test-Agent/1.0" \
    http://$MOCK_HOST:$MOCK_PORT/headers)

if echo "$response" | grep -q '"X-Custom-Header": "test-value"'; then
    echo "✓ Headers forwarding test passed"
else
    echo "✗ Headers forwarding test failed"
    echo "Response: $response"
    exit 1
fi

# Test POST requests
echo "Testing POST request forwarding..."
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT --max-time 10 \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"test": "data"}' \
    http://$MOCK_HOST:$MOCK_PORT/)

if echo "$response" | grep -q '"method": "POST"'; then
    echo "✓ POST request forwarding test passed"
else
    echo "✗ POST request forwarding test failed"
    echo "Response: $response"
    exit 1
fi

# Test different status codes
echo "Testing status code forwarding..."
for code in 200 404 500; do
    response=$(curl -s -w "%{http_code}" --proxy $PROXY_HOST:$PROXY_PORT --max-time 10 \
        http://$MOCK_HOST:$MOCK_PORT/status?code=$code)

    status_code=${response: -3}

    if [ "$status_code" = "$code" ]; then
        echo "✓ Status code $code forwarding test passed"
    else
        echo "✗ Status code $code forwarding test failed (got $status_code)"
        exit 1
    fi
done

echo "All HTTP proxy tests passed!"
exit 0
