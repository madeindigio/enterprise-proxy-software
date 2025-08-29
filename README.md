# Enterprise Proxy Software

A Golang-based HTTP proxy server that requires Google Apps authentication for access.

## Features

- HTTP/HTTPS proxy functionality
- Google OAuth2 authentication
- Session-based access control
- Automatic redirection to authentication for unauthenticated users

## Prerequisites

- Go 1.21 or later
- Google OAuth2 credentials (Client ID and Client Secret)

## Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd enterprise-proxy-software
   ```

2. Install dependencies:
   ```bash
   go mod tidy
   ```

3. Configure Google OAuth2:
   - Go to the [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable the Google+ API
   - Create OAuth2 credentials (Web application)
   - Set the redirect URI to your server URL + `/auth/callback` (e.g., `https://your-domain.com/auth/callback`)

4. Set up credentials (choose one method):

   **Method 1: Environment Variables**
   ```bash
   export GOOGLE_CLIENT_ID="your-client-id"
   export GOOGLE_CLIENT_SECRET="your-client-secret"
   ```

   **Method 2: CLI Arguments**
   ```bash
   ./enterprise-proxy-software --client-id="your-client-id" --client-secret="your-client-secret"
   ```

5. Build and run:
   ```bash
   go build -o enterprise-proxy-software ./src
   ./enterprise-proxy-software --server-url="https://your-domain.com"
   ```

## CLI Arguments

The application supports the following command-line arguments:

- `--client-id`: Google OAuth2 Client ID (can also be set via `GOOGLE_CLIENT_ID` env var)
- `--client-secret`: Google OAuth2 Client Secret (can also be set via `GOOGLE_CLIENT_SECRET` env var)
- `--server-url`: Server URL for OAuth redirect (default: `http://localhost:8080`)
- `--port`: Port to run the server on (default: `8080`)
- `--version`: Show version information
- `--help`: Show help information

### Examples

```bash
# Run with CLI arguments
./enterprise-proxy-software \
  --client-id="your-client-id" \
  --client-secret="your-client-secret" \
  --server-url="https://your-domain.com" \
  --port="8080"

# Run with environment variables
export GOOGLE_CLIENT_ID="your-client-id"
export GOOGLE_CLIENT_SECRET="your-client-secret"
./enterprise-proxy-software --server-url="https://your-domain.com"

# Show version
./enterprise-proxy-software --version

# Show help
./enterprise-proxy-software --help
```

## Docker Setup

### Prerequisites

- Docker and Docker Compose

### Build and Run with Docker

1. Build the Docker image:
   ```bash
   docker build -t enterprise-proxy .
   ```

2. Run the container with environment variables:
   ```bash
   docker run -p 8080:8080 \
     -e GOOGLE_CLIENT_ID=your_client_id \
     -e GOOGLE_CLIENT_SECRET=your_client_secret \
     enterprise-proxy
   ```

3. Or run with CLI arguments:
   ```bash
   docker run -p 8080:8080 enterprise-proxy \
     --client-id="your_client_id" \
     --client-secret="your_client_secret" \
     --server-url="http://localhost:8080"
   ```

### Run with Docker Compose

1. Create a `.env` file with your OAuth credentials:
   ```
   GOOGLE_CLIENT_ID=your_client_id
   GOOGLE_CLIENT_SECRET=your_client_secret
   SERVER_URL=http://localhost:8080
   ```

2. Start the services:
   ```bash
   docker-compose up -d
   ```

3. Stop the services:
   ```bash
   docker-compose down
   ```

### Run Docker Tests

Execute the Docker-based end-to-end tests:

```bash
cd tests/
bash test_docker.sh
```

## Usage

1. Start the proxy server on port 8080
2. Configure your browser to use `http://localhost:8080` as proxy
3. Access any website - you'll be redirected to Google authentication
4. After authentication, you can browse normally

## Versioning and Releases

This project uses [GoReleaser](https://goreleaser.com/) for automated releases and versioning.

### Building for Development

```bash
go build -o enterprise-proxy-software ./src
```

### Creating Releases

1. Tag your release:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. GoReleaser will automatically create releases on GitHub with:
   - Binaries for Linux, Windows, and macOS
   - Version information embedded in the binary
   - Changelog generation

### Version Information

The `--version` flag displays:
- Current version
- Git commit hash
- Build date
- Go version
- OS/Architecture

## Configuration

- **Port**: Configurable via `--port` flag (default: 8080)
- **Server URL**: Configurable via `--server-url` flag for OAuth redirects
- **Session Secret**: Change the secret key in `main.go` for production
- **OAuth Credentials**: Set via CLI args or environment variables

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Tasks

This is tasks automatization for [xc](https://xcfile.dev/) 

### build

build the project into a dist folder

interactive: true

```
go mod tidy
go build -o dist/enterprise-proxy-software src/*.go
```

### tests

run the tests

interactive: true

```
cd tests/
bash run_e2e_tests.sh
```

### docker-tests

run the docker-based tests

interactive: true

```
cd tests/
bash test_docker.sh
```

### tag

Deploys a new tag for the repo.

Specify major/minor/patch with VERSION

Env: PRERELEASE=0, VERSION=minor, FORCE_VERSION=0
Inputs: VERSION, PRERELEASE, FORCE_VERSION


```
# https://github.com/unegma/bash-functions/blob/main/update.sh

CURRENT_VERSION=`git describe --abbrev=0 --tags 2>/dev/null`
CURRENT_VERSION_PARTS=(${CURRENT_VERSION//./ })
VNUM1=${CURRENT_VERSION_PARTS[0]}
# remove v
VNUM1=${VNUM1:1}
VNUM2=${CURRENT_VERSION_PARTS[1]}
VNUM3=${CURRENT_VERSION_PARTS[2]}

if [[ $VERSION == 'major' ]]
then
  VNUM1=$((VNUM1+1))
  VNUM2=0
  VNUM3=0
elif [[ $VERSION == 'minor' ]]
then
  VNUM2=$((VNUM2+1))
  VNUM3=0
elif [[ $VERSION == 'patch' ]]
then
  VNUM3=$((VNUM3+1))
else
  echo "Invalid version"
  exit 1
fi

NEW_TAG="v$VNUM1.$VNUM2.$VNUM3"

# if command convco is available, use it to check the version
if command -v convco &> /dev/null
then
  # if the version is a prerelease, add the prerelease tag
  if [[ $PRERELEASE == '1' ]]
  then
    NEW_TAG=v$(convco version -b --prerelease)
  else
    NEW_TAG=v$(convco version -b)
  fi
fi

# if $FORCE_VERSION is different to 0 then use it as the version
if [[ $FORCE_VERSION != '0' ]]
then
  NEW_TAG=v$FORCE_VERSION
fi

echo Adding git tag with version ${NEW_TAG}
git tag ${NEW_TAG}
git push origin ${NEW_TAG}
```

### changelog

Generate a changelog for the repo.

```
convco changelog > CHANGELOG.md
git add CHANGELOG.md
git commit -m "Update changelog"
git push
```

### release

Releasing a new version into the repo.

```
goreleaser release --clean --skip sign
```

### release-snapshot

Releasing a new snapshot version into the repo.

```
goreleaser release --snapshot --skip sign --clean
```