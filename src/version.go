package main

import (
	"fmt"
	"runtime"
)

var (
	// Version is the current version of the application
	Version = "dev"
	// Commit is the git commit hash
	Commit = "none"
	// Date is the build date
	Date = "unknown"
	// BuiltBy is the build tool
	BuiltBy = "unknown"
)

func printVersion() {
	fmt.Printf("enterprise-proxy-software %s\n", Version)
	fmt.Printf("Commit: %s\n", Commit)
	fmt.Printf("Built: %s\n", Date)
	fmt.Printf("Built by: %s\n", BuiltBy)
	fmt.Printf("Go version: %s\n", runtime.Version())
	fmt.Printf("OS/Arch: %s/%s\n", runtime.GOOS, runtime.GOARCH)
}
