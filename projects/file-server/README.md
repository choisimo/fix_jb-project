# JB-Project File Server

A high-performance Python file server for the JB-Project platform that provides file storage, URL-accessible links, thumbnails generation, and asynchronous AI analysis integration.

## Features

- Fast file uploads and downloads with async I/O
- URL-accessible files with configurable routes
- Image thumbnails generation
- Async integration with AI analysis services
- Docker container support with external volume mounting
- Nginx configuration for production deployment
- Health monitoring and disk space checks
- Webhook support for integrations

## Getting Started

### Prerequisites

- Docker and Docker Compose
- At least 1GB of free disk space
- Python 3.9+ (if running locally)

### Environment Variables

Create a `.env` file in the project root with the following variables:

```
# Server Configuration
PORT=12020
HOST=0.0.0.0
SERVER_URL=http://localhost:12020  # Change this to your public URL in production

# Storage Configuration
BASE_DIR=/app/data

# Security Configuration
API_KEY=your_secret_api_key
ENABLE_AUTH=true

# AI Service Configuration
AI_SERVICE_URL=http://ai-analysis-server:8080
AI_SERVICE_TOKEN=your_ai_service_token

# Kafka Configuration (optional)
KAFKA_ENABLED=false
KAFKA_BOOTSTRAP_SERVERS=kafka:9092
```

### Running with Docker

1. Build and start the container:

```bash
docker-compose up -d file-server
```

2. The service will be available at http://localhost:12020

### Integration with AI Analysis

The file server can automatically send files for AI analysis. To enable this:

1. Make sure your AI service is running and accessible
2. Set the `AI_SERVICE_URL` environment variable
3. Use the `analyze=true` parameter when uploading files

## API Usage

### Upload a File

```bash
curl -X POST http://localhost:12020/upload/ \
  -H "X-Auth-Token: your_api_key" \
  -F "file=@/path/to/your/file.jpg" \
  -F "analyze=true"
```

### Get File Status

```bash
curl http://localhost:12020/files/{file_id}
```

### Health Check

```bash
curl http://localhost:12020/health
```

## Volume Mounting

When running in Docker, mount your host directory to the container's data directory:

```yaml
volumes:
  - /path/on/host/data:/app/data
```

This allows for:
- Data persistence between container restarts
- Easy backups
- Flexible volume expansion

## Nginx Configuration

An Nginx configuration file is provided at `nginx/file-server.conf`. To use it:

1. Copy it to your Nginx configuration directory
2. Update the `server_name` directive
3. Reload Nginx configuration

## License

This project is licensed under the MIT License - see the LICENSE file for details.
