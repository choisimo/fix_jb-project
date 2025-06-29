# Roboflow AI Integration - Complete Implementation Guide

## 🎯 Overview

This document describes the complete implementation of Roboflow AI object detection integration into the Jeonbuk Field Report system, including frontend (Flutter), backend (Spring Boot), and end-to-end testing.

## 🏗️ Architecture

```
Flutter App ←→ Spring Boot Backend ←→ Roboflow API
     ↓                ↓                    ↓
UI Components    Service Layer        AI Detection
Config Manager   Domain/DTOs         Cloud Models
Error Handling   REST Controllers     JSON Response
```

## 📁 Project Structure

### Backend (Spring Boot)
```
flutter-backend/src/main/java/com/jeonbuk/report/
├── controller/
│   ├── AIAnalysisController.java      # REST API endpoints
│   └── ReportController.java          # Report management
├── service/
│   └── RoboflowService.java          # Core AI integration logic
├── dto/
│   ├── AIAnalysisRequest.java         # Request DTO
│   ├── AIAnalysisResponse.java        # Response DTO
│   └── common/CommonDto.java          # Shared DTOs
├── domain/
│   ├── report/Report.java             # Domain entities
│   └── user/User.java                 # User entities
└── config/
    └── RestClientConfig.java          # HTTP client configuration

flutter-backend/src/main/resources/
└── application.properties             # Configuration file
```

### Frontend (Flutter)
```
flutter-app/lib/
├── core/ai/
│   ├── roboflow_service.dart          # API service
│   └── roboflow_config.dart           # Configuration
├── features/settings/
│   └── roboflow_settings_page.dart    # Settings UI
└── pubspec.yaml                       # Dependencies
```

### Python Tools
```
project-root/
├── roboflow_test.py                   # Direct API testing
├── config_manager.py                 # Configuration management
├── integration_test.py               # End-to-end testing
├── setup_and_test.py                 # Environment setup
└── .env.example                      # Environment template
```

## ⚙️ Configuration

### 1. Environment Variables

Create a `.env` file in the project root:

```bash
# Roboflow API Configuration
ROBOFLOW_API_KEY=your_api_key_here
ROBOFLOW_WORKSPACE=your_workspace_name
ROBOFLOW_PROJECT=your_project_name
ROBOFLOW_VERSION=1

# Optional: Custom API URL
ROBOFLOW_API_URL=https://detect.roboflow.com
```

### 2. Backend Configuration (`application.properties`)

```properties
# Roboflow AI Integration
roboflow.api.key=${ROBOFLOW_API_KEY:}
roboflow.workspace=${ROBOFLOW_WORKSPACE:}
roboflow.project=${ROBOFLOW_PROJECT:}
roboflow.version=${ROBOFLOW_VERSION:1}
roboflow.api.url=${ROBOFLOW_API_URL:https://detect.roboflow.com}

# File Upload Settings
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=50MB
```

### 3. Flutter Configuration

The Flutter app supports runtime configuration through the settings page:
- API Key input
- Backend URL configuration
- Test connectivity
- View supported object classes

## 🚀 API Endpoints

### Backend REST API (`/api/v1/ai`)

#### 1. Single Image Analysis
```http
POST /api/v1/ai/analyze
Content-Type: multipart/form-data

Parameters:
- image: MultipartFile (required)
- confidence: Integer (0-100, default: 50)
- overlap: Integer (0-100, default: 30)

Response:
{
  "success": true,
  "detections": [
    {
      "className": "pothole",
      "koreanName": "포트홀",
      "confidence": 85.2,
      "boundingBox": {
        "x": 320.5,
        "y": 240.8,
        "width": 120.0,
        "height": 80.0
      },
      "category": "도로관리",
      "priority": "긴급"
    }
  ],
  "averageConfidence": 85.2,
  "processingTime": 1250,
  "recommendedCategory": "도로관리",
  "recommendedPriority": "긴급",
  "recommendedDepartment": "도로관리팀",
  "summary": "총 1개의 문제를 감지했습니다: 포트홀 1개"
}
```

#### 2. Batch Image Analysis
```http
POST /api/v1/ai/analyze-batch
Content-Type: multipart/form-data

Parameters:
- images: MultipartFile[] (required, max 10 files)
- confidence: Integer (0-100, default: 50)
- overlap: Integer (0-100, default: 30)

Response: Array of AIAnalysisResponse objects
```

#### 3. Asynchronous Analysis
```http
POST /api/v1/ai/analyze-async
Content-Type: multipart/form-data

Returns: Job ID (String)

GET /api/v1/ai/status/{jobId}
Returns: AIAnalysisResponse with job status
```

#### 4. Service Health Check
```http
GET /api/v1/ai/health

Response:
"✅ AI 서비스 정상 동작 중"
```

#### 5. Supported Classes
```http
GET /api/v1/ai/classes

Response:
[
  {
    "english": "pothole",
    "korean": "포트홀"
  },
  {
    "english": "crack",
    "korean": "균열"
  }
]
```

## 🧪 Testing

### 1. Python Direct Testing

Test Roboflow API directly:
```bash
python roboflow_test.py --image test_images/sample.jpg
```

### 2. Backend Integration Testing

Test the complete backend integration:
```bash
python integration_test.py --backend-url http://localhost:8080
```

Quick test (without image analysis):
```bash
python integration_test.py --quick
```

### 3. Flutter Testing

Use the built-in settings page to:
1. Configure API credentials
2. Test connectivity
3. Upload test images
4. View analysis results

## 🏷️ Supported Object Classes

The system supports detection of the following infrastructure issues:

| English Class      | Korean Name | Category | Priority |
| ------------------ | ----------- | -------- | -------- |
| pothole            | 포트홀      | 도로관리 | 긴급     |
| crack              | 균열        | 도로관리 | 보통     |
| damaged_road       | 도로 손상   | 도로관리 | 긴급     |
| broken_manhole     | 맨홀 파손   | 시설관리 | 긴급     |
| damaged_sign       | 표지판 손상 | 시설관리 | 보통     |
| broken_streetlight | 가로등 파손 | 시설관리 | 보통     |
| litter             | 쓰레기      | 환경관리 | 낮음     |
| graffiti           | 낙서        | 환경관리 | 낮음     |

## 🔧 Implementation Details

### Backend Service Logic

The `RoboflowService` class handles:

1. **Configuration Validation**: Ensures all required API credentials are present
2. **Image Processing**: Handles multipart file uploads and validation
3. **API Communication**: Makes HTTP requests to Roboflow API
4. **Response Transformation**: Converts Roboflow JSON to structured DTOs
5. **Korean Localization**: Maps English class names to Korean equivalents
6. **Priority Assessment**: Determines urgency based on object type and confidence
7. **Category Mapping**: Groups detections into administrative categories
8. **Department Routing**: Suggests appropriate department for handling

### Error Handling

The system includes comprehensive error handling:

- **Configuration Errors**: Missing API keys or workspace settings
- **File Validation**: Size limits, format validation, filename checks
- **Network Errors**: API timeouts, connection failures
- **Processing Errors**: Invalid responses, parsing failures
- **Business Logic Errors**: Confidence thresholds, classification errors

### Performance Considerations

- **File Size Limits**: 10MB per image, 50MB per request
- **Batch Limits**: Maximum 10 images per batch request
- **Timeout Settings**: 30 seconds for single analysis, 120 seconds for batch
- **Asynchronous Processing**: Available for large images or batch operations
- **Caching**: Results stored in memory (production should use Redis)

## 🔐 Security

### Input Validation
- File type restrictions (JPEG, PNG only)
- File size limits
- Parameter validation with constraints
- Filename sanitization

### API Security
- API key validation
- Request rate limiting (configure in production)
- CORS configuration
- Input sanitization

## 📊 Monitoring & Logging

### Logging Levels
- **INFO**: Normal operations, API calls, results
- **DEBUG**: Detailed request/response data
- **ERROR**: Failures, exceptions, system errors

### Key Metrics to Monitor
- Response times
- Success/failure rates
- Detection confidence scores
- API usage patterns
- Error frequencies

## 🚀 Deployment

### Development Environment
1. Set environment variables
2. Start Spring Boot backend: `./gradlew bootRun`
3. Start Flutter app: `flutter run`
4. Run integration tests: `python integration_test.py`

### Production Considerations
- Use external configuration management (AWS Systems Manager, etc.)
- Implement Redis for async job storage
- Add API rate limiting
- Enable detailed monitoring and alerting
- Set up log aggregation
- Configure HTTPS/SSL

## 🔄 Future Enhancements

### Planned Features
1. **Model Training Integration**: Upload training data to Roboflow
2. **Real-time Processing**: WebSocket-based live image analysis
3. **Confidence Tuning**: Dynamic confidence threshold adjustment
4. **Custom Models**: Department-specific detection models
5. **Analytics Dashboard**: Detection trends and reporting
6. **Mobile Offline**: On-device inference when network unavailable

### Integration Opportunities
1. **GIS Integration**: Map-based visualization of detections
2. **Workflow Automation**: Automatic ticket creation for high-priority issues
3. **Notification System**: Real-time alerts for urgent infrastructure problems
4. **Reporting Integration**: Include AI analysis in official reports

## 📚 Resources

### Documentation
- [Roboflow API Documentation](https://docs.roboflow.com/api-reference)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Flutter Documentation](https://flutter.dev/docs)

### Support
- Check the integration test results for troubleshooting
- Review logs for detailed error information
- Use the health check endpoints to verify system status
- Consult the setup guides for configuration help

---

**Last Updated**: December 2024  
**Version**: 2.0.1  
**Maintainer**: Jeonbuk Field Report Development Team
