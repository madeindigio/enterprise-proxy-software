#!/bin/bash

# Test Proxy Performance
# This test measures the performance and latency of the proxy server

PROXY_HOST="localhost"
PROXY_PORT="8080"
MOCK_HOST="localhost"
MOCK_PORT="9090"
TEST_ITERATIONS=10

echo "Testing proxy performance..."

# Function to measure request time
measure_request() {
    local url=$1
    local description=$2

    echo "Measuring $description..."

    total_time=0
    for i in $(seq 1 $TEST_ITERATIONS); do
        start_time=$(date +%s%N)
        response=$(curl -s --proxy $PROXY_HOST:$PROXY_PORT --max-time 30 $url > /dev/null)
        end_time=$(date +%s%N)

        # Calculate elapsed time in milliseconds
        elapsed=$(( (end_time - start_time) / 1000000 ))
        total_time=$((total_time + elapsed))

        echo "  Request $i: ${elapsed}ms"
    done

    avg_time=$((total_time / TEST_ITERATIONS))
    echo "  Average: ${avg_time}ms"
    echo "  Total: ${total_time}ms for $TEST_ITERATIONS requests"
    echo
}

# Test different types of requests
echo "=== Performance Test Results ==="
echo "Running $TEST_ITERATIONS iterations for each test"
echo

# Test basic HTTP request
measure_request "http://$MOCK_HOST:$MOCK_PORT/test" "basic HTTP request"

# Test HTTP request with headers
measure_request "http://$MOCK_HOST:$MOCK_PORT/headers" "HTTP request with headers"

# Test POST request
measure_request "http://$MOCK_HOST:$MOCK_PORT/" "POST request" "POST"

# Test delayed response
measure_request "http://$MOCK_HOST:$MOCK_PORT/delay?seconds=1" "delayed response (1s)"

# Test large response
measure_request "http://$MOCK_HOST:$MOCK_PORT/large?size=10000" "large response (10KB)"

# Test concurrent requests
echo "Testing concurrent requests..."
echo "Making 5 concurrent requests..."

start_time=$(date +%s%N)
for i in {1..5}; do
    curl -s --proxy $PROXY_HOST:$PROXY_PORT http://$MOCK_HOST:$MOCK_PORT/test > /dev/null &
done
wait
end_time=$(date +%s%N)

concurrent_time=$(( (end_time - start_time) / 1000000 ))
echo "Concurrent requests completed in: ${concurrent_time}ms"
echo

# Test HTTPS performance
echo "Testing HTTPS performance..."
start_time=$(date +%s%N)
for i in $(seq 1 $TEST_ITERATIONS); do
    curl -s --proxy $PROXY_HOST:$PROXY_PORT --insecure https://$MOCK_HOST:9443/test > /dev/null
done
end_time=$(date +%s%N)

https_total=$(( (end_time - start_time) / 1000000 ))
https_avg=$((https_total / TEST_ITERATIONS))
echo "HTTPS requests - Average: ${https_avg}ms, Total: ${https_total}ms"
echo

echo "Performance test completed!"
echo "Note: Actual performance may vary based on network conditions and system resources."
exit 0
