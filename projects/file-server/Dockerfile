FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libmagic1 \
    gcc \
    libc-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/
COPY scripts/ ./scripts/

# Create necessary directories
RUN mkdir -p /app/data/uploads /app/data/thumbnails /app/data/temp /app/data/logs \
    && chmod +x /app/scripts/start.sh

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=12020 \
    HOST=0.0.0.0 \
    BASE_DIR=/app/data

EXPOSE 12020

# Set the entrypoint
ENTRYPOINT ["/app/scripts/start.sh"]
