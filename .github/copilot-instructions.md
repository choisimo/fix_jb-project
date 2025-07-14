# Copilot Instructions for JB Platform Project

## Project Overview
- **Multi-service architecture**: The project consists of a Main API Server (Spring Boot), AI Analysis Server (Spring Boot), and a Flutter mobile client. All services are orchestrated via API Gateway (Spring Cloud Gateway or Nginx).
- **Directory structure**: Key directories include `AI-agent/` (system/architecture docs), `main-api-server/`, `ai-analysis-server/`, `flutter-app/`, and `docs/` (project-wide documentation).
- **Documentation**: Central docs are in `docs/` and `AI-agent/`. See `AI-agent/context/` and `AI-agent/architecture/` for system, data flow, and security models. API specs and business rules are in `AI-agent/apis/` and `AI-agent/services/`.

## Developer Workflows
- **Build & Run**:
  - Main API Server: `./gradlew bootRun` in `main-api-server/`
  - AI Analysis Server: `./gradlew bootRun` in `ai-analysis-server/`
  - Flutter app: `flutter run` in `flutter-app/`
  - Use `docker-compose.yml` for local multi-service orchestration.
- **Testing**:
  - Java: `./gradlew test` in each backend service
  - Flutter: `flutter test` in `flutter-app/`
- **Task Management**: Task-driven development is encouraged (see `.windsurf/rules/dev_workflow.md`). Use `task-master` commands for listing, expanding, and updating tasks.

## Key Conventions & Patterns
- **API Versioning**: All new endpoints use `/api/v1/` prefix. Legacy endpoints remain for backward compatibility. See `frontend-backend-api-mapping-analysis-prd.md` for migration details.
- **No breaking changes**: Never delete or break existing APIs—extend only. Use feature flags and versioned controllers for gradual migration.
- **Controller Inheritance**: New API versions extend legacy controllers (see PRD for example). Use `@RequestMapping("/api/v1/...)
- **Flutter API clients**: Use versioned client classes and feature flags for endpoint selection.
- **Permissions**: Platform-specific permission handling is abstracted (see PRD for Dart examples).
- **Notifications**: Use Firebase if available, fallback to local notifications.

## 🚨 ABSOLUTE RULE: Never Delete Existing Code or APIs

**You must never delete or break any existing code or API endpoints.**

- All changes must be additive and backward compatible.
- Legacy endpoints and logic must remain functional for existing clients.
- If deprecation is needed, use feature flags or versioned controllers, but never remove or break old code.

This rule is absolute and overrides all other instructions.

## Integration & Data Flow
- **API Gateway**: All client traffic routes through the gateway, which rewrites paths and handles authentication centrally.
- **Database**: Each backend has its own schema. See `database/` for SQL and migration guides.
- **External services**: Integrations are documented in `AI-agent/services/external-services.md`.

## Where to Start
- For architecture: `AI-agent/architecture/system-architecture.md`
- For API: `AI-agent/apis/api-overview.md` and `frontend-backend-api-mapping-analysis-prd.md`
- For workflows: `.windsurf/rules/dev_workflow.md`
- For build/test: See each service's `README.md` and root `docker-compose.yml`

## Example: Adding a New Report API (Java)
- Add to both `/reports` (legacy) and `/api/v1/reports` (new)
- Use controller inheritance for v1
- Update API Gateway rules for new path

---
**Always preserve backward compatibility and follow the documented migration and extension patterns.**
