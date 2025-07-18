# Unified Location Service

## Overview
The UnifiedLocationService consolidates multiple location service implementations into a single, robust service that provides reliable location data with a progressive fallback strategy.

## Key Features
- Progressive fallback strategy:
  1. High accuracy real-time GPS location (with timeout)
  2. Medium accuracy fallback
  3. Last known location from device
  4. Cached location from SharedPreferences
  5. Default location from environment config
- Detailed error handling and debug logging
- Permission management
- Location caching
- Source tracking for all location results
- Loading state management

## Usage

### Basic Usage
```dart
final locationService = ref.watch(unifiedLocationServiceProvider);
final result = await locationService.getCurrentLocation();

if (result.isSuccessful && result.position != null) {
  // Use result.position (Position from geolocator package)
  print('Location: ${result.position!.latitude}, ${result.position!.longitude}');
  print('Source: ${result.source}');
} else {
  // Handle error
  print('Error: ${result.error}');
}
```

### Using with MapProvider
The MapProvider has been updated to integrate with UnifiedLocationService:

```dart
// In a widget
final mapNotifier = ref.read(mapProvider.notifier);
final locationResult = await mapNotifier.getCurrentLocation();

// The MapState will automatically be updated with location, source, and error info
```

## Migration Plan

### Phase 1: Immediate Usage (Current Implementation)
- The UnifiedLocationService has been integrated with the map functionality
- NaverMapWidget now uses it via the MapProvider
- App initializer sets up the service on app start

### Phase 2: Deprecation of Old Services (Recommended Next Steps)
1. Add @deprecated annotations to the old service methods
2. Update imports in remaining files to use the unified service
3. Add migration notes in old service files pointing to the UnifiedLocationService

### Phase 3: Complete Removal (Future)
- After ensuring all code uses the unified service, the old service implementations can be safely removed
- Update any tests that used the old services

## Implementation Details

### Location Source Tracking
The service tracks where each location comes from using the LocationSource enum:
- HIGH_ACCURACY: High-precision GPS fix
- MEDIUM_ACCURACY: Lower precision but faster location
- LAST_KNOWN: Last location stored on device
- CACHED: Previously cached location from SharedPreferences
- DEFAULT: Fallback to default location in configuration

### Error Handling
The service provides detailed error messages for:
- Permission denied
- Location services disabled
- Timeouts
- Network issues
- Other errors

## Benefits
- Improved reliability with fallback strategy
- Better user experience with appropriate feedback
- Consistent error handling
- Reduced code duplication
- Better testability
- Clear separation of concerns
