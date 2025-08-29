# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY src/ ./src/

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o proxy ./src/

# Runtime stage
FROM gcr.io/distroless/static-debian12:latest

# Copy the binary from builder stage
COPY --from=builder /app/proxy /proxy

# Expose port
EXPOSE 8080

# Run the binary
ENTRYPOINT ["/proxy"]
