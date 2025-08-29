# Copilot Instructions for Enterprise Proxy Software

## Project Overview

This is a Golang HTTP proxy server that requires Google OAuth2 authentication. The proxy intercepts requests and redirects unauthenticated users to Google for login.

Always use Serena tools for editing or finding code in this project. Check Serena onboarding performed in the work session, and list and read memories before start the work for is we have previous knowledge about the task that you are working on.

Search in serper web search or brave search if faults the first, for more info and fetch pages that you consider useful for the task, if needed. Also use Context7 for finding the API's use and how work the libraries to use.

## Key Components

- `src/main.go`: Main server setup and proxy logic
- `src/auth.go`: Google OAuth2 authentication handlers
- `go.mod`: Go module dependencies

## Development Guidelines

- Use proper error handling for all HTTP operations
- Maintain session security with secure cookies
- Follow Go best practices for HTTP servers
- Keep authentication logic separate from proxy logic

## Security Considerations

- Never commit OAuth credentials to version control
- Use secure random keys for sessions
- Validate all user inputs and OAuth responses
- Implement proper HTTPS for production

## Testing

- Test proxy functionality with various websites
- Verify OAuth flow works correctly
- Check session persistence across requests
- Test both HTTP and HTTPS proxying

The tests folder contains various test scripts for different aspects of the proxy server. Each test script is responsible for a specific functionality and can be run independently. Please run the `xc tests` script to execute all end-to-end tests.

## Deployment

- Configure OAuth credentials as environment variables
- Use secure session keys
- Set up proper logging and monitoring
- Consider using a reverse proxy (nginx) in front for production

Build the project using `xc build`
