# Enterprise Proxy Software - End-to-End Tests

This directory contains comprehensive end-to-end tests for the Enterprise Proxy Software, a Golang-based HTTP proxy server with Google OAuth2 authentication.

## Test Structure

```
tests/
├── run_e2e_tests.sh          # Main test runner script
├── test_config.sh            # Test configuration and parameters
├── mock_server.py           # Python mock server for testing
├── test_auth_redirect.sh     # Authentication redirect tests
├── test_http_proxy.sh        # HTTP proxy functionality tests
├── test_https_proxy.sh       # HTTPS proxy functionality tests
├── test_mock_http.sh         # Mock server HTTP endpoint tests
├── test_mock_https.sh        # Mock server HTTPS endpoint tests
├── test_performance.sh       # Performance and latency tests
├── test_security.sh          # Security vulnerability tests
└── README.md                 # This file
```

## Prerequisites

Before running the tests, ensure you have:

1. **Go Environment**: Go 1.21+ installed
2. **Python 3**: For running the mock server
3. **curl**: For HTTP requests
4. **openssl**: For SSL/TLS operations
5. **netcat (nc)**: For service availability checks

## Quick Start

1. **Build the Project**:
   ```bash
   cd ..
   go build -o dist/proxy src/*.go
   ```

2. **Run All Tests**:
   ```bash
   cd tests
   chmod +x *.sh
   ./run_e2e_tests.sh
   ```

3. **Run Individual Tests**:
   ```bash
   # Test HTTP proxy functionality
   ./test_http_proxy.sh

   # Test HTTPS proxy functionality
   ./test_https_proxy.sh

   # Test performance
   ./test_performance.sh

   # Test security
   ./test_security.sh
   ```

## Test Categories

### 1. Authentication Tests (`test_auth_redirect.sh`)
- Verifies that unauthenticated requests are properly redirected to the auth endpoint
- Tests HTTP 302 redirect responses
- Ensures authentication flow is triggered correctly

### 2. HTTP Proxy Tests (`test_http_proxy.sh`)
- Tests basic HTTP request forwarding
- Verifies header forwarding and preservation
- Tests POST request handling
- Validates status code forwarding
- Checks content type and body handling

### 3. HTTPS Proxy Tests (`test_https_proxy.sh`)
- Tests HTTPS CONNECT tunneling
- Verifies SSL/TLS handshake through proxy
- Tests secure header forwarding
- Validates HTTPS POST requests
- Checks status code forwarding over HTTPS

### 4. Mock Server Tests
- **`test_mock_http.sh`**: Tests all HTTP endpoints of the mock server
- **`test_mock_https.sh`**: Tests all HTTPS endpoints of the mock server
- Validates mock server functionality before running proxy tests

### 5. Performance Tests (`test_performance.sh`)
- Measures request latency and throughput
- Tests concurrent request handling
- Compares HTTP vs HTTPS performance
- Tests large response handling
- Measures delayed response handling

### 6. Security Tests (`test_security.sh`)
- Tests proxy header filtering (prevents header leakage)
- Validates sensitive header handling
- Checks for header injection vulnerabilities
- Tests timeout handling
- Validates path traversal protection
- Checks host header handling
- Tests basic request smuggling protection

## Mock Server

The mock server (`mock_server.py`) provides various endpoints for testing:

### HTTP Endpoints (Port 9090)
- `GET /` - Basic health check
- `GET /test` - Test endpoint with query parameter support
- `GET /delay?seconds=N` - Delayed response for timeout testing
- `GET /headers` - Returns all request headers
- `GET /user-agent` - Returns User-Agent header
- `GET /status?code=N` - Returns specified HTTP status code
- `GET /large?size=N` - Returns large response of specified size
- `POST /` - Echoes POST data and headers

### HTTPS Endpoints (Port 9443)
- Same endpoints as HTTP, but over SSL/TLS
- Uses self-signed certificates for testing

## Configuration

Test parameters can be modified in `test_config.sh`:

```bash
# Server configuration
PROXY_HOST=localhost
PROXY_PORT=8080
MOCK_HTTP_PORT=9090
MOCK_HTTPS_PORT=9443

# Test parameters
TEST_TIMEOUT=30
PERFORMANCE_TEST_ITERATIONS=10
CONCURRENT_REQUESTS=5

# Performance thresholds
PERFORMANCE_WARNING_THRESHOLD=1000  # ms
PERFORMANCE_ERROR_THRESHOLD=5000    # ms
```

## Test Results

The test runner provides:
- **Real-time output** with colored status indicators
- **Test summary** with pass/fail counts
- **Detailed error messages** for failed tests
- **Performance metrics** with timing information

### Example Output
```
[INFO] Starting Enterprise Proxy Software E2E Tests
==============================================
[INFO] Starting mock server...
[SUCCESS] Mock Server is ready!
[INFO] Starting proxy server...
[SUCCESS] Proxy Server is ready!
[INFO] Running test suite...
[SUCCESS] Proxy Server Connectivity
[SUCCESS] Authentication Redirect
[SUCCESS] HTTP Proxy Test
[SUCCESS] HTTPS Proxy Test
[SUCCESS] Mock Server HTTP Test
[SUCCESS] Mock Server HTTPS Test
[SUCCESS] Proxy Performance Test
[SUCCESS] Security Headers Test

[INFO] Test Summary:
=============
Tests Run: 8
[PASS] Tests Passed: 8
[SUCCESS] All tests passed!
```

## Troubleshooting

### Common Issues

1. **Port Conflicts**:
   - Ensure ports 8080, 9090, and 9443 are available
   - Kill any existing processes using these ports

2. **SSL Certificate Errors**:
   - Tests use self-signed certificates
   - Use `--insecure` flag for HTTPS tests

3. **Timeout Errors**:
   - Increase `TEST_TIMEOUT` in configuration
   - Check network connectivity

4. **Build Errors**:
   - Ensure Go modules are properly downloaded: `go mod tidy`
   - Verify Go version: `go version`

### Debug Mode

Enable verbose logging by setting in `test_config.sh`:
```bash
VERBOSE_LOGGING=true
```

## Continuous Integration

For CI/CD pipelines, use the main test runner:

```yaml
# Example GitHub Actions
- name: Run E2E Tests
  run: |
    cd tests
    chmod +x *.sh
    ./run_e2e_tests.sh
```

## Extending Tests

### Adding New Test Cases

1. Create a new test script following the naming convention
2. Add the test to `run_e2e_tests.sh`
3. Update this README with the new test description

### Adding Mock Server Endpoints

1. Add new endpoint handlers in `mock_server.py`
2. Create corresponding tests in the appropriate test file
3. Update endpoint documentation

## Security Considerations

- Tests include basic security validation
- For production systems, consider additional penetration testing
- Mock server uses self-signed certificates (not for production)
- Test environment should be isolated from production systems

## Contributing

When contributing new tests:

1. Follow the existing naming conventions
2. Include proper error handling and cleanup
3. Add comprehensive documentation
4. Test both success and failure scenarios
5. Update this README with new test descriptions

## License

This test suite is part of the Enterprise Proxy Software project, licensed under the MIT License.
