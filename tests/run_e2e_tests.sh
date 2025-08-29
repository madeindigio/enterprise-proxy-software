#!/bin/bash

# Enterprise Proxy Software - End-to-End Test Runner
# This script runs comprehensive end-to-end tests for the proxy server

set -e

#!/bin/bash

# Enterprise Proxy Software - End-to-End Test Runner
# This script runs comprehensive end-to-end tests for the proxy server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROXY_HOST="localhost"
PROXY_PORT="8080"
TEST_TIMEOUT="30"
MOCK_SERVER_PORT="9090"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

test_passed() {
    ((TESTS_RUN++))
    ((TESTS_PASSED++))
    log_success "$1"
}

test_failed() {
    ((TESTS_RUN++))
    ((TESTS_FAILED++))
    log_error "$1"
}

cleanup() {
    log_info "Cleaning up test processes..."
    # Kill proxy server if running
    pkill -f "proxy" || true
    pkill -f "enterprise-proxy-software" || true
    # Kill mock server if running
    pkill -f "mock_server.py" || true
    # Kill any test processes
    pkill -f "test_proxy" || true
    # Wait a moment for processes to terminate
    sleep 2
}

trap cleanup EXIT

# Function to wait for a service to be ready
wait_for_service() {
    local host=$1
    local port=$2
    local timeout=$3
    local service_name=$4

    log_info "Waiting for $service_name to be ready on $host:$port..."

    for i in $(seq 1 $timeout); do
        if nc -z $host $port 2>/dev/null; then
            # For mock server, just check port connectivity
            if [[ "$service_name" == *"Mock Server"* ]]; then
                log_success "$service_name is ready!"
                return 0
            # For proxy server, also test with curl
            elif curl -s --max-time 2 http://$host:$port/ > /dev/null 2>&1; then
                log_success "$service_name is ready!"
                return 0
            fi
        fi
        sleep 1
    done

    log_error "$service_name failed to start within $timeout seconds"
    return 1
}

# Function to start the proxy server
start_proxy() {
    log_info "Starting proxy server..."
    
    # First, ensure no existing proxy is running
    pkill -f "proxy" || true
    sleep 1
    
    cd ../dist
    ./proxy &
    PROXY_PID=$!
    
    # Wait a moment for the process to start or fail
    sleep 2
    
    # Check if the process is still running
    if ! kill -0 $PROXY_PID 2>/dev/null; then
        log_error "Proxy server failed to start"
        cd ../tests
        exit 1
    fi
    
    cd ../tests

    if ! wait_for_service $PROXY_HOST $PROXY_PORT 10 "Proxy Server"; then
        log_error "Failed to start proxy server"
        exit 1
    fi
}

# Function to start mock server
start_mock_server() {
    log_info "Starting mock server..."
    
    # Kill any existing mock server
    pkill -f "mock_server.py" || true
    sleep 2
    
    # Start mock server
    python3 mock_server.py &
    MOCK_PID=$!
    
    # Give it more time to start up
    sleep 5
    
    # Check if the process is still running
    if ! kill -0 $MOCK_PID 2>/dev/null; then
        log_error "Mock server process exited early"
        exit 1
    fi

    if ! wait_for_service "localhost" $MOCK_SERVER_PORT 10 "Mock Server"; then
        log_error "Failed to start mock server"
        # Try to get more information about what went wrong
        if kill -0 $MOCK_PID 2>/dev/null; then
            log_info "Mock server process is still running (PID: $MOCK_PID)"
        else
            log_error "Mock server process has exited"
        fi
        exit 1
    fi
}

# Function to run a single test
run_test() {
    local test_name=$1
    local test_command=$2

    log_info "Running test: $test_name"
    if eval "$test_command"; then
        test_passed "$test_name"
    else
        test_failed "$test_name"
    fi
}

# Main test execution
main() {
    log_info "Starting Enterprise Proxy Software E2E Tests"
    log_info "=============================================="

    # Clean up any existing processes first
    cleanup

    # Check if proxy binary exists
    if [ ! -f "../dist/enterprise-proxy-software" ]; then
        log_error "Proxy binary not found. Please build the project first."
        log_info "Run: cd .. && go build -o dist/proxy src/*.go"
        exit 1
    fi

    # Start services
    start_mock_server
    start_proxy

    # Wait a bit for services to stabilize
    sleep 2

    # Run individual tests
    log_info "Running test suite..."

    # Basic connectivity tests
    run_test "Proxy Server Connectivity" "curl -s --proxy $PROXY_HOST:$PROXY_PORT --max-time $TEST_TIMEOUT http://httpbin.org/get > /dev/null"

    # Authentication tests
    run_test "Authentication Redirect" "test_auth_redirect.sh"

    # Proxy functionality tests
    run_test "HTTP Proxy Test" "test_http_proxy.sh"
    run_test "HTTPS Proxy Test" "test_https_proxy.sh"

    # Mock server tests
    run_test "Mock Server HTTP Test" "test_mock_http.sh"
    run_test "Mock Server HTTPS Test" "test_mock_https.sh"

    # Performance tests
    run_test "Proxy Performance Test" "test_performance.sh"

    # Security tests
    run_test "Security Headers Test" "test_security.sh"

    # Print test summary
    echo
    log_info "Test Summary:"
    log_info "============="
    log_info "Tests Run: $TESTS_RUN"
    log_success "Tests Passed: $TESTS_PASSED"
    if [ $TESTS_FAILED -gt 0 ]; then
        log_error "Tests Failed: $TESTS_FAILED"
    fi

    # Exit with appropriate code
    if [ $TESTS_FAILED -gt 0 ]; then
        log_error "Some tests failed. Check the output above for details."
        exit 1
    else
        log_success "All tests passed!"
        exit 0
    fi
}

# Run main function
main "$@"
        log_error "Failed to start mock server"
        # Try to get more information about what went wrong
        if kill -0 $MOCK_PID 2>/dev/null; then
            log_info "Mock server process is still running (PID: $MOCK_PID)"
        else
            log_error "Mock server process has exited"
        fi
        exit 1
    fiors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROXY_HOST="localhost"
PROXY_PORT="8080"
TEST_TIMEOUT="30"
MOCK_SERVER_PORT="9090"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

test_passed() {
    ((TESTS_RUN++))
    ((TESTS_PASSED++))
    log_success "$1"
}

test_failed() {
    ((TESTS_RUN++))
    ((TESTS_FAILED++))
    log_error "$1"
}

cleanup() {
    log_info "Cleaning up test processes..."
    # Kill proxy server if running
    pkill -f "proxy" || true
    pkill -f "enterprise-proxy-software" || true
    # Kill mock server if running
    pkill -f "mock_server.py" || true
    # Kill any test processes
    pkill -f "test_proxy" || true
    # Wait a moment for processes to terminate
    sleep 2
}

trap cleanup EXIT

# Function to wait for a service to be ready
wait_for_service() {
    local host=$1
    local port=$2
    local timeout=$3
    local service_name=$4

    log_info "Waiting for $service_name to be ready on $host:$port..."

    for i in $(seq 1 $timeout); do
        if nc -z $host $port 2>/dev/null; then
            # For mock server, just check port connectivity
            if [[ "$service_name" == *"Mock Server"* ]]; then
                log_success "$service_name is ready!"
                return 0
            # For proxy server, also test with curl
            elif curl -s --max-time 2 http://$host:$port/ > /dev/null 2>&1; then
                log_success "$service_name is ready!"
                return 0
            fi
        fi
        sleep 1
    done

    log_error "$service_name failed to start within $timeout seconds"
    return 1
}

# Function to start the proxy server
start_proxy() {
    log_info "Starting proxy server..."
    
    # First, ensure no existing proxy is running
    pkill -f "proxy" || true
    sleep 1
    
    cd ../dist
    ./proxy &
    PROXY_PID=$!
    
    # Wait a moment for the process to start or fail
    sleep 2
    
    # Check if the process is still running
    if ! kill -0 $PROXY_PID 2>/dev/null; then
        log_error "Proxy server failed to start"
        cd ../tests
        exit 1
    fi
    
    cd ../tests

    if ! wait_for_service $PROXY_HOST $PROXY_PORT 10 "Proxy Server"; then
        log_error "Failed to start proxy server"
        exit 1
    fi
}

# Function to start mock server
start_mock_server() {
    log_info "Starting mock server..."
    
    # Kill any existing mock server
    pkill -f "mock_server.py" || true
    sleep 2
    
    # Start mock server
    python3 mock_server.py &
    MOCK_PID=$!
    
    # Give it more time to start up
    sleep 5
    
    # Check if the process is still running
    if ! kill -0 $MOCK_PID 2>/dev/null; then
        log_error "Mock server process exited early"
        exit 1
    fi

    if ! wait_for_service "localhost" $MOCK_SERVER_PORT 10 "Mock Server"; then
        log_error "Failed to start mock server"
        exit 1
    fi
}

# Function to run a single test
run_test() {
    local test_name=$1
    local test_command=$2

    log_info "Running test: $test_name"
    if eval "$test_command"; then
        test_passed "$test_name"
    else
        test_failed "$test_name"
    fi
}

# Main test execution
main() {
    log_info "Starting Enterprise Proxy Software E2E Tests"
    log_info "=============================================="

    # Clean up any existing processes first
    cleanup

    # Check if proxy binary exists
    if [ ! -f "../dist/enterprise-proxy-software" ]; then
        log_error "Proxy binary not found. Please build the project first."
        log_info "Run: cd .. && go build -o dist/proxy src/*.go"
        exit 1
    fi

    # Start services
    start_mock_server
    start_proxy

    # Wait a bit for services to stabilize
    sleep 2

    # Run individual tests
    log_info "Running test suite..."

    # Basic connectivity tests
    run_test "Proxy Server Connectivity" "curl -s --proxy $PROXY_HOST:$PROXY_PORT --max-time $TEST_TIMEOUT http://httpbin.org/get > /dev/null"

    # Authentication tests
    run_test "Authentication Redirect" "test_auth_redirect.sh"

    # Proxy functionality tests
    run_test "HTTP Proxy Test" "test_http_proxy.sh"
    run_test "HTTPS Proxy Test" "test_https_proxy.sh"

    # Mock server tests
    run_test "Mock Server HTTP Test" "test_mock_http.sh"
    run_test "Mock Server HTTPS Test" "test_mock_https.sh"

    # Performance tests
    run_test "Proxy Performance Test" "test_performance.sh"

    # Security tests
    run_test "Security Headers Test" "test_security.sh"

    # Print test summary
    echo
    log_info "Test Summary:"
    log_info "============="
    log_info "Tests Run: $TESTS_RUN"
    log_success "Tests Passed: $TESTS_PASSED"
    if [ $TESTS_FAILED -gt 0 ]; then
        log_error "Tests Failed: $TESTS_FAILED"
    fi

    # Exit with appropriate code
    if [ $TESTS_FAILED -gt 0 ]; then
        log_error "Some tests failed. Check the output above for details."
        exit 1
    else
        log_success "All tests passed!"
        exit 0
    fi
}

# Run main function
main "$@"
