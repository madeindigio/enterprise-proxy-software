package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/gorilla/sessions"
)

var store = sessions.NewCookieStore([]byte("your-secret-key")) // Change this to a secure key

func main() {
	// Define CLI flags
	var (
		clientID     = flag.String("client-id", "", "Google OAuth2 Client ID (can also be set via GOOGLE_CLIENT_ID env var)")
		clientSecret = flag.String("client-secret", "", "Google OAuth2 Client Secret (can also be set via GOOGLE_CLIENT_SECRET env var)")
		serverURL    = flag.String("server-url", "http://localhost:8080", "Server URL for OAuth redirect")
		port         = flag.String("port", "8080", "Port to run the server on")
		showVersion  = flag.Bool("version", false, "Show version information")
		showHelp     = flag.Bool("help", false, "Show help information")
	)

	// Custom usage function
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Enterprise Proxy Software - HTTP Proxy with Google OAuth2 Authentication\n\n")
		fmt.Fprintf(os.Stderr, "Usage: %s [options]\n\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nEnvironment Variables:\n")
		fmt.Fprintf(os.Stderr, "  GOOGLE_CLIENT_ID     Google OAuth2 Client ID\n")
		fmt.Fprintf(os.Stderr, "  GOOGLE_CLIENT_SECRET Google OAuth2 Client Secret\n")
		fmt.Fprintf(os.Stderr, "\nExample:\n")
		fmt.Fprintf(os.Stderr, "  %s --client-id=your-client-id --client-secret=your-client-secret --server-url=https://your-domain.com\n", os.Args[0])
	}

	flag.Parse()

	// Handle version flag
	if *showVersion {
		printVersion()
		return
	}

	// Handle help flag
	if *showHelp {
		flag.Usage()
		return
	}

	// Initialize OAuth config with provided values
	initOAuthConfig(*clientID, *clientSecret, *serverURL)

	// Set up HTTP handlers
	http.HandleFunc("/", handleProxy)
	http.HandleFunc("/auth", handleAuth)
	http.HandleFunc("/auth/callback", handleAuthCallback)

	fmt.Printf("Proxy server starting on :%s\n", *port)
	fmt.Printf("OAuth redirect URL: %s/auth/callback\n", *serverURL)
	log.Fatal(http.ListenAndServe(":"+*port, nil))
}

func handleProxy(w http.ResponseWriter, r *http.Request) {
	// Check if user is authenticated
	session, _ := store.Get(r, "session-name")
	if auth, ok := session.Values["authenticated"].(bool); !ok || !auth {
		// Not authenticated, redirect to auth
		http.Redirect(w, r, "/auth", http.StatusFound)
		return
	}

	// User is authenticated, proceed with proxy
	if r.Method == http.MethodConnect {
		handleConnect(w, r)
	} else {
		handleHTTP(w, r)
	}
}

func handleHTTP(w http.ResponseWriter, r *http.Request) {
	// Parse the target URL
	targetURL := r.URL.String()
	if !strings.HasPrefix(targetURL, "http://") && !strings.HasPrefix(targetURL, "https://") {
		targetURL = "http://" + targetURL
	}

	u, err := url.Parse(targetURL)
	if err != nil {
		http.Error(w, "Invalid URL", http.StatusBadRequest)
		return
	}

	// Create a new request to the target
	req, err := http.NewRequest(r.Method, u.String(), r.Body)
	if err != nil {
		http.Error(w, "Failed to create request", http.StatusInternalServerError)
		return
	}

	// Copy headers
	for key, values := range r.Header {
		for _, value := range values {
			req.Header.Add(key, value)
		}
	}

	// Remove proxy headers
	req.Header.Del("Proxy-Connection")
	req.Header.Del("Proxy-Authenticate")
	req.Header.Del("Proxy-Authorization")

	// Make the request
	client := &http.Client{
		Timeout: 30 * time.Second,
	}
	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, "Failed to proxy request", http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()

	// Copy response headers
	for key, values := range resp.Header {
		for _, value := range values {
			w.Header().Add(key, value)
		}
	}
	w.WriteHeader(resp.StatusCode)

	// Copy response body
	io.Copy(w, resp.Body)
}

func handleConnect(w http.ResponseWriter, r *http.Request) {
	// Parse the target host:port
	host := r.URL.Host
	if host == "" {
		http.Error(w, "Invalid CONNECT request", http.StatusBadRequest)
		return
	}

	// Establish connection to target
	targetConn, err := net.Dial("tcp", host)
	if err != nil {
		http.Error(w, "Failed to connect to target", http.StatusBadGateway)
		return
	}
	defer targetConn.Close()

	// Hijack the client connection
	hj, ok := w.(http.Hijacker)
	if !ok {
		http.Error(w, "Hijacking not supported", http.StatusInternalServerError)
		return
	}
	clientConn, _, err := hj.Hijack()
	if err != nil {
		http.Error(w, "Failed to hijack connection", http.StatusInternalServerError)
		return
	}
	defer clientConn.Close()

	// Send 200 Connection established
	clientConn.Write([]byte("HTTP/1.1 200 Connection established\r\n\r\n"))

	// Start tunneling
	go io.Copy(targetConn, clientConn)
	io.Copy(clientConn, targetConn)
}
