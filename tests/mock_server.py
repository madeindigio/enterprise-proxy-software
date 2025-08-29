#!/usr/bin/env python3
"""
Mock Server for Enterprise Proxy Software E2E Tests
Provides various endpoints to test proxy functionality
"""

import json
import ssl
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs


class MockHTTPRequestHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Suppress default logging
        pass

    def do_GET(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        query = parse_qs(parsed_path.query)

        # Set CORS headers
        self.send_cors_headers()

        if path == "/":
            self.send_json_response(
                200, {"message": "Mock server is running", "timestamp": time.time()})

        elif path == "/test":
            self.send_json_response(
                200, {"status": "ok", "path": path, "query": query})

        elif path == "/delay":
            delay = int(query.get("seconds", ["1"])[0])
            time.sleep(min(delay, 5))  # Max 5 second delay
            self.send_json_response(
                200, {"message": f"Delayed response by {delay} seconds"})

        elif path == "/headers":
            headers = dict(self.headers)
            self.send_json_response(200, {"headers": headers})

        elif path == "/user-agent":
            user_agent = self.headers.get("User-Agent", "Unknown")
            self.send_json_response(200, {"user_agent": user_agent})

        elif path == "/status":
            status_code = int(query.get("code", ["200"])[0])
            self.send_json_response(status_code, {"status_code": status_code})

        elif path == "/large":
            # Send a large response
            size = int(query.get("size", ["1024"])[0])
            data = "x" * min(size, 1024*1024)  # Max 1MB
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", len(data))
            self.end_headers()
            self.wfile.write(data.encode())

        else:
            self.send_json_response(404, {"error": "Not found", "path": path})

    def do_POST(self):
        content_length = int(self.headers.get("Content-Length", 0))
        post_data = self.rfile.read(
            content_length) if content_length > 0 else b""

        self.send_cors_headers()
        self.send_json_response(200, {
            "method": "POST",
            "data": post_data.decode("utf-8", errors="ignore"),
            "content_type": self.headers.get("Content-Type", "")
        })

    def send_cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")

    def send_json_response(self, status_code, data):
        response = json.dumps(data, indent=2)
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", len(response))
        self.end_headers()
        self.wfile.write(response.encode())


def create_ssl_context():
    """Create SSL context for HTTPS server"""
    try:
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        # For testing, we'll use a self-signed certificate
        # In production, use proper certificates
        context.check_hostname = False
        context.verify_mode = ssl.CERT_NONE
        return context
    except Exception as e:
        print(f"Warning: Failed to create SSL context: {e}")
        return None


def run_http_server(port=9090):
    """Run HTTP server"""
    server_address = ("", port)
    httpd = HTTPServer(server_address, MockHTTPRequestHandler)
    print(f"Mock HTTP server running on port {port}")
    httpd.serve_forever()


def run_https_server(port=9443):
    """Run HTTPS server"""
    context = create_ssl_context()
    if context is None:
        print("HTTPS server disabled due to SSL configuration issues")
        return

    server_address = ("", port)
    httpd = HTTPServer(server_address, MockHTTPRequestHandler)

    # For testing purposes, we'll skip certificate verification
    # This is not recommended for production
    httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

    print(f"Mock HTTPS server running on port {port}")
    httpd.serve_forever()


if __name__ == "__main__":
    import sys
    import threading

    if len(sys.argv) > 1 and sys.argv[1] == "--https":
        run_https_server()
    else:
        # Run both HTTP and HTTPS servers in separate threads
        http_thread = threading.Thread(target=run_http_server, args=(9090,))
        https_thread = threading.Thread(target=run_https_server, args=(9443,))

        http_thread.daemon = True
        https_thread.daemon = True

        http_thread.start()
        https_thread.start()

        print("Mock servers started:")
        print("  HTTP:  http://localhost:9090")
        print("  HTTPS: https://localhost:9443 (may be disabled if SSL fails)")
        print("Press Ctrl+C to stop")

        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\nStopping mock servers...")
            sys.exit(0)
