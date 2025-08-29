#!/bin/bash

# Test Mock Server HTTP Endpoints
# This test verifies that the mock server is working correctly

MOCK_HOST="localhost"
MOCK_PORT="9090"

echo "Testing mock server HTTP endpoints..."

# Test root endpoint
echo "Testing root endpoint..."
response=$(curl -s http://$MOCK_HOST:$MOCK_PORT/)

if echo "$response" | grep -q '"message": "Mock server is running"'; then
    echo "✓ Root endpoint test passed"
else
    echo "✗ Root endpoint test failed"
    echo "Response: $response"
    exit 1
fi

# Test /test endpoint
echo "Testing /test endpoint..."
response=$(curl -s http://$MOCK_HOST:$MOCK_PORT/test)

if echo "$response" | grep -q '"status": "ok"'; then
    echo "✓ /test endpoint test passed"
else
    echo "✗ /test endpoint test failed"
    echo "Response: $response"
    exit 1
fi

# Test /test endpoint with query parameters
echo "Testing /test endpoint with query parameters..."
response=$(curl -s "http://$MOCK_HOST:$MOCK_PORT/test?param1=value1&param2=value2")

if echo "$response" | grep -q '"param1": \["value1"\]' && echo "$response" | grep -q '"param2": \["value2"\]'; then
    echo "✓ /test endpoint with query parameters test passed"
else
    echo "✗ /test endpoint with query parameters test failed"
    echo "Response: $response"
    exit 1
fi

# Test /headers endpoint
echo "Testing /headers endpoint..."
response=$(curl -s -H "X-Test-Header: test-value" http://$MOCK_HOST:$MOCK_PORT/headers)

if echo "$response" | grep -q '"X-Test-Header": "test-value"'; then
    echo "✓ /headers endpoint test passed"
else
    echo "✗ /headers endpoint test failed"
    echo "Response: $response"
    exit 1
fi

# Test /user-agent endpoint
echo "Testing /user-agent endpoint..."
response=$(curl -s -H "User-Agent: Custom-Agent/1.0" http://$MOCK_HOST:$MOCK_PORT/user-agent)

if echo "$response" | grep -q '"user_agent": "Custom-Agent/1.0"'; then
    echo "✓ /user-agent endpoint test passed"
else
    echo "✗ /user-agent endpoint test failed"
    echo "Response: $response"
    exit 1
fi

# Test /status endpoint
echo "Testing /status endpoint..."
for code in 200 404 500; do
    response=$(curl -s -w "%{http_code}" http://$MOCK_HOST:$MOCK_PORT/status?code=$code)
    status_code=${response: -3}

    if [ "$status_code" = "$code" ]; then
        echo "✓ /status endpoint test passed for code $code"
    else
        echo "✗ /status endpoint test failed for code $code (got $status_code)"
        exit 1
    fi
done

# Test /delay endpoint
echo "Testing /delay endpoint..."
start_time=$(date +%s)
response=$(curl -s http://$MOCK_HOST:$MOCK_PORT/delay?seconds=2)
end_time=$(date +%s)

elapsed=$((end_time - start_time))
if [ $elapsed -ge 2 ] && echo "$response" | grep -q '"message": "Delayed response by 2 seconds"'; then
    echo "✓ /delay endpoint test passed"
else
    echo "✗ /delay endpoint test failed (elapsed: ${elapsed}s)"
    echo "Response: $response"
    exit 1
fi

# Test /large endpoint
echo "Testing /large endpoint..."
response=$(curl -s http://$MOCK_HOST:$MOCK_PORT/large?size=1000)

if [ ${#response} -eq 1000 ]; then
    echo "✓ /large endpoint test passed"
else
    echo "✗ /large endpoint test failed (expected 1000 chars, got ${#response})"
    exit 1
fi

echo "All mock server HTTP endpoint tests passed!"
exit 0
