#!/bin/bash

# Enterprise Proxy Software - Docker E2E Test Runner
# This script runs comprehensive end-to-end tests for the dockerized proxy server

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
    log_info "Cleaning up test resources..."
    # Stop docker-compose services
    docker-compose down >/dev/null 2>&1 || true
    # Kill any remaining test processes
    pkill -f "test_proxy" || true
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
            log_success "$service_name is ready!"
            return 0
        fi
        sleep 1
    done

    log_error "$service_name failed to start within $timeout seconds"
    return 1
}

# Function to build Docker image
build_docker_image() {
    log_info "Building Docker images with docker-compose"
    if ! docker-compose build; then
        log_error "Failed to build Docker images"
        exit 1
    fi
    log_success "Docker images built successfully"
}

# Function to start services with docker-compose
start_services() {
    log_info "Starting services with docker-compose..."
    if ! docker-compose up -d; then
        log_error "Failed to start services with docker-compose"
        exit 1
    fi

    if ! wait_for_service $PROXY_HOST $PROXY_PORT 15 "Proxy Service"; then
        log_error "Failed to start proxy service"
        exit 1
    fi

    if ! wait_for_service "localhost" $MOCK_SERVER_PORT 5 "Mock Server HTTP Service"; then
        log_error "Failed to start mock server HTTP service"
        exit 1
    fi

    # Wait for HTTPS port as well
    if ! wait_for_service "localhost" 9443 5 "Mock Server HTTPS Service"; then
        log_error "Failed to start mock server HTTPS service"
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
    log_info "Starting Enterprise Proxy Software Docker E2E Tests"
    log_info "=================================================="

    # Build Docker image
    build_docker_image

    # Start services
    start_services

    # Wait a bit for services to stabilize
    sleep 3

    # Run individual tests
    log_info "Running test suite..."

    # Basic connectivity tests
    run_test "Proxy Container Connectivity" "curl -s --proxy $PROXY_HOST:$PROXY_PORT --max-time $TEST_TIMEOUT http://httpbin.org/get > /dev/null"

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
