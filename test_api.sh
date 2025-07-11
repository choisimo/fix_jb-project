#!/bin/bash

BASE_URL_MAIN="http://localhost:8080"
BASE_URL_AI="http://localhost:8081"

# main-api-server (통합 API 서버)

echo "[main-api-server] /api/auth/login"
curl -X POST "$BASE_URL_MAIN/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}' \
  -o /dev/null -s -w "%{http_code}\n"

echo "[main-api-server] /api/auth/register"
curl -X POST "$BASE_URL_MAIN/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123","name":"홍길동"}' \
  -o /dev/null -s -w "%{http_code}\n"

echo "[main-api-server] /api/v1/reports/1/comments (POST)"
curl -X POST "$BASE_URL_MAIN/api/v1/reports/1/comments" \
  -H "Content-Type: application/json" \
  -d '{"content":"테스트 댓글"}' \
  -o /dev/null -s -w "%{http_code}\n"

echo "[main-api-server] /api/v1/statistics/overview"
curl "$BASE_URL_MAIN/api/v1/statistics/overview" \
  -o /dev/null -s -w "%{http_code}\n"

echo "[main-api-server] /api/v1/files/upload/1"
curl -X POST "$BASE_URL_MAIN/api/v1/files/upload/1" \
  -F "file=@test_images/road_damage_1.jpg" \
  -o /dev/null -s -w "%{http_code}\n"

echo "[main-api-server] /ai-routing/analyze"
curl -X POST "$BASE_URL_MAIN/ai-routing/analyze" \
  -H "Content-Type: application/json" \
  -d '{"imageUrl":"http://example.com/image.jpg"}' \
  -o /dev/null -s -w "%{http_code}\n"

# ai-analysis-server (AI 분석 전용 서버)

echo "[ai-analysis-server] /api/users/register"
curl -X POST "$BASE_URL_AI/api/users/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123","name":"홍길동"}' \
  -o /dev/null -s -w "%{http_code}\n"

echo "[ai-analysis-server] /api/v1/ai/routing/analyze"
curl -X POST "$BASE_URL_AI/api/v1/ai/routing/analyze" \
  -H "Content-Type: application/json" \
  -d '{"imageUrl":"http://example.com/image.jpg"}' \
  -o /dev/null -s -w "%{http_code}\n"

echo "[ai-analysis-server] /api/v1/ai/analyze/image"
curl -X POST "$BASE_URL_AI/api/v1/ai/analyze/image" \
  -F "image=@test_images/road_damage_1.jpg" \
  -o /dev/null -s -w "%{http_code}\n"

echo "[ai-analysis-server] /api/v1/alerts/analyze"
curl -X POST "$BASE_URL_AI/api/v1/alerts/analyze" \
  -H "Content-Type: application/json" \
  -d '{"message":"테스트 알림"}' \
  -o /dev/null -s -w "%{http_code}\n"
