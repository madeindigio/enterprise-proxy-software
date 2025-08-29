# Enterprise Proxy Software - Test Configuration

# Test Environment Configuration
PROXY_HOST=localhost
PROXY_PORT=8080
MOCK_HTTP_PORT=9090
MOCK_HTTPS_PORT=9443

# Test Parameters
TEST_TIMEOUT=30
PERFORMANCE_TEST_ITERATIONS=10
CONCURRENT_REQUESTS=5

# Mock Server Configuration
MOCK_SERVER_LOG_LEVEL=INFO
MOCK_SERVER_MAX_DELAY=5
MOCK_SERVER_MAX_RESPONSE_SIZE=1048576  # 1MB

# Security Test Configuration
SECURITY_TEST_TIMEOUT=10
SECURITY_MAX_CONCURRENT_REQUESTS=3

# Performance Thresholds (in milliseconds)
PERFORMANCE_WARNING_THRESHOLD=1000
PERFORMANCE_ERROR_THRESHOLD=5000

# Test Data
TEST_USER_AGENT="Enterprise-Proxy-Test/1.0"
TEST_CUSTOM_HEADER="X-Test-Header"
TEST_CUSTOM_VALUE="test-value"

# OAuth Test Configuration (for future OAuth tests)
OAUTH_CLIENT_ID="test-client-id"
OAUTH_CLIENT_SECRET="test-client-secret"
OAUTH_REDIRECT_URI="http://localhost:8080/auth/callback"

# Logging
LOG_FILE="test_results.log"
VERBOSE_LOGGING=false
