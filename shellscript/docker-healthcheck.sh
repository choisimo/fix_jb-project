#!/bin/sh
# Simple health check for Spring Boot application

# The actuator health endpoint is exposed on port 8080 by default
curl -f http://localhost:8080/actuator/health || exit 1
