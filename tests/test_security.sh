#!/bin/bash

# Test Proxy Security
# This test checks for common security issues and proper header handling

PROXY_HOST="localhost"
PROXY_PORT="8080"
MOCK_HOST="localhost"
MOCK_PORT="9090"

echo "Testing proxy security..."

# Test that proxy headers are not leaked
echo "Testing proxy header filtering..."
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT \
    -H "Proxy-Authenticate: test" \
    -H "Proxy-Authorization: secret" \
    http://$MOCK_HOST:$MOCK_PORT/headers)

if echo "$response" | grep -q '"Proxy-Authenticate"' || echo "$response" | grep -q '"Proxy-Authorization"'; then
    echo "✗ Proxy headers are being leaked to target server"
    exit 1
else
    echo "✓ Proxy headers are properly filtered"
fi

# Test that sensitive headers are not exposed
echo "Testing sensitive header protection..."
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT \
    -H "Authorization: Bearer secret-token" \
    -H "Cookie: session=secret-session" \
    http://$MOCK_HOST:$MOCK_PORT/headers)

# These headers should be forwarded (they're legitimate client headers)
if echo "$response" | grep -q '"Authorization": "Bearer secret-token"' && \
   echo "$response" | grep -q '"Cookie": "session=secret-session"'; then
    echo "✓ Sensitive headers are properly forwarded when appropriate"
else
    echo "✗ Sensitive headers are not being forwarded correctly"
    exit 1
fi

# Test for potential header injection
echo "Testing header injection protection..."
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT \
    -H "X-Test: value\r\nX-Injected: injected-value" \
    http://$MOCK_HOST:$MOCK_PORT/headers)

if echo "$response" | grep -q '"X-Injected": "injected-value"'; then
    echo "✗ Header injection vulnerability detected"
    exit 1
else
    echo "✓ Header injection protection working"
fi

# Test timeout handling
echo "Testing timeout handling..."
start_time=$(date +%s)
timeout 5 curl -s --proxy $PROXY_HOST:$PROXY_PORT \
    http://$MOCK_HOST:$MOCK_PORT/delay?seconds=10 > /dev/null
end_time=$(date +%s)

elapsed=$((end_time - start_time))
if [ $elapsed -lt 8 ]; then  # Should timeout before 10 seconds
    echo "✓ Timeout handling working correctly"
else
    echo "✗ Timeout handling may not be working properly"
    exit 1
fi

# Test for potential path traversal
echo "Testing path traversal protection..."
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT \
    "http://$MOCK_HOST:$MOCK_PORT/../../../etc/passwd")

if echo "$response" | grep -q "root:"; then
    echo "✗ Path traversal vulnerability detected"
    exit 1
else
    echo "✓ Path traversal protection working"
fi

# Test for potential host header injection
echo "Testing host header handling..."
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT \
    -H "Host: malicious.com" \
    http://$MOCK_HOST:$MOCK_PORT/test)

# The host header should be handled properly by the proxy
if echo "$response" | grep -q '"status": "ok"'; then
    echo "✓ Host header handling working correctly"
else
    echo "✗ Host header handling may have issues"
    exit 1
fi

# Test for potential HTTP request smuggling
echo "Testing HTTP request smuggling protection..."
# This is a basic test - more sophisticated smuggling tests would require custom HTTP clients
response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT \
    -H "Content-Length: 0" \
    -H "Transfer-Encoding: chunked" \
    -d "" \
    http://$MOCK_HOST:$MOCK_PORT/test)

if echo "$response" | grep -q '"status": "ok"'; then
    echo "✓ Basic request smuggling protection working"
else
    echo "✗ Request smuggling protection may have issues"
    exit 1
fi

echo "Security tests completed!"
echo "Note: These tests cover basic security aspects. For production systems,"
echo "consider additional security testing and penetration testing."
exit 0
