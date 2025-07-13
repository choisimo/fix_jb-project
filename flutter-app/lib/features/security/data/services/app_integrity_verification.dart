import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:safe_device/safe_device.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import '../domain/models/security_event.dart';

enum SecurityThreatLevel {
  none,
  low,
  medium,
  high,
  critical,
}

enum IntegrityStatus {
  secure,
  compromised,
  unknown,
}

class AppIntegrityVerification {
  static const String _lastCheckKey = 'last_integrity_check';
  static const Duration _checkInterval = Duration(hours: 1);
  
  final DeviceInfoPlugin _deviceInfo;
  bool _isInitialized = false;
  
  AppIntegrityVerification(this._deviceInfo);
  
  /// Initialize integrity verification system
  Future<void> initialize() async {
    try {
      await _performInitialChecks();
      _isInitialized = true;
      debugPrint('App integrity verification initialized');
    } catch (e) {
      debugPrint('Failed to initialize integrity verification: $e');
      rethrow;
    }
  }
  
  /// Perform comprehensive integrity check
  Future<IntegrityCheckResult> performIntegrityCheck() async {
    try {
      final checks = await Future.wait([
        _checkRootJailbreak(),
        _checkDebugMode(),
        _checkEmulator(),
        _checkHookingTools(),
        _checkAppSignature(),
        _checkDeveloperOptions(),
        _checkMockLocation(),
      ]);
      
      final rootJailbreakResult = checks[0] as SecurityCheckResult;
      final debugModeResult = checks[1] as SecurityCheckResult;
      final emulatorResult = checks[2] as SecurityCheckResult;
      final hookingResult = checks[3] as SecurityCheckResult;
      final signatureResult = checks[4] as SecurityCheckResult;
      final developerResult = checks[5] as SecurityCheckResult;
      final mockLocationResult = checks[6] as SecurityCheckResult;
      
      final threatLevel = _calculateThreatLevel([
        rootJailbreakResult,
        debugModeResult,
        emulatorResult,
        hookingResult,
        signatureResult,
        developerResult,
        mockLocationResult,
      ]);
      
      final status = threatLevel == SecurityThreatLevel.none 
          ? IntegrityStatus.secure 
          : IntegrityStatus.compromised;
      
      final result = IntegrityCheckResult(
        status: status,
        threatLevel: threatLevel,
        timestamp: DateTime.now(),
        checks: {
          'root_jailbreak': rootJailbreakResult,
          'debug_mode': debugModeResult,
          'emulator': emulatorResult,
          'hooking_tools': hookingResult,
          'app_signature': signatureResult,
          'developer_options': developerResult,
          'mock_location': mockLocationResult,
        },
      );
      
      debugPrint('Integrity check completed: ${result.status}');
      return result;
    } catch (e) {
      debugPrint('Error performing integrity check: $e');
      return IntegrityCheckResult(
        status: IntegrityStatus.unknown,
        threatLevel: SecurityThreatLevel.unknown,
        timestamp: DateTime.now(),
        checks: {},
        error: e.toString(),
      );
    }
  }
  
  /// Check if device is rooted or jailbroken
  Future<SecurityCheckResult> _checkRootJailbreak() async {
    try {
      bool isRooted = false;
      bool isJailbroken = false;
      
      if (Platform.isAndroid) {
        isRooted = await JailbreakRootDetection.isRooted;
      } else if (Platform.isIOS) {
        isJailbroken = await JailbreakRootDetection.isJailBroken;
      }
      
      final isCompromised = isRooted || isJailbroken;
      return SecurityCheckResult(
        name: 'Root/Jailbreak Detection',
        passed: !isCompromised,
        threatLevel: isCompromised ? SecurityThreatLevel.high : SecurityThreatLevel.none,
        details: {
          'is_rooted': isRooted,
          'is_jailbroken': isJailbroken,
          'platform': Platform.operatingSystem,
        },
      );
    } catch (e) {
      return SecurityCheckResult(
        name: 'Root/Jailbreak Detection',
        passed: false,
        threatLevel: SecurityThreatLevel.unknown,
        error: e.toString(),
      );
    }
  }
  
  /// Check if app is running in debug mode
  Future<SecurityCheckResult> _checkDebugMode() async {
    try {
      final isDebugMode = kDebugMode;
      
      return SecurityCheckResult(
        name: 'Debug Mode Detection',
        passed: !isDebugMode,
        threatLevel: isDebugMode ? SecurityThreatLevel.medium : SecurityThreatLevel.none,
        details: {
          'debug_mode': isDebugMode,
          'profile_mode': kProfileMode,
          'release_mode': kReleaseMode,
        },
      );
    } catch (e) {
      return SecurityCheckResult(
        name: 'Debug Mode Detection',
        passed: false,
        threatLevel: SecurityThreatLevel.unknown,
        error: e.toString(),
      );
    }
  }
  
  /// Check if app is running on emulator
  Future<SecurityCheckResult> _checkEmulator() async {
    try {
      bool isEmulator = false;
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        isEmulator = await SafeDevice.isRealDevice == false ||
                    androidInfo.isPhysicalDevice == false ||
                    _isAndroidEmulator(androidInfo);
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        isEmulator = await SafeDevice.isRealDevice == false ||
                    iosInfo.isPhysicalDevice == false;
      }
      
      return SecurityCheckResult(
        name: 'Emulator Detection',
        passed: !isEmulator,
        threatLevel: isEmulator ? SecurityThreatLevel.medium : SecurityThreatLevel.none,
        details: {
          'is_emulator': isEmulator,
          'is_real_device': await SafeDevice.isRealDevice,
        },
      );
    } catch (e) {
      return SecurityCheckResult(
        name: 'Emulator Detection',
        passed: false,
        threatLevel: SecurityThreatLevel.unknown,
        error: e.toString(),
      );
    }
  }
  
  /// Check for hooking tools and runtime manipulation
  Future<SecurityCheckResult> _checkHookingTools() async {
    try {
      // Check for common hooking frameworks
      bool hookingDetected = false;
      final List<String> detectedTools = [];
      
      // Check for Frida
      if (await _checkForFrida()) {
        hookingDetected = true;
        detectedTools.add('Frida');
      }
      
      // Check for Xposed (Android)
      if (Platform.isAndroid && await _checkForXposed()) {
        hookingDetected = true;
        detectedTools.add('Xposed');
      }
      
      // Check for Substrate (iOS)
      if (Platform.isIOS && await _checkForSubstrate()) {
        hookingDetected = true;
        detectedTools.add('Substrate');
      }
      
      return SecurityCheckResult(
        name: 'Hooking Tools Detection',
        passed: !hookingDetected,
        threatLevel: hookingDetected ? SecurityThreatLevel.high : SecurityThreatLevel.none,
        details: {
          'hooking_detected': hookingDetected,
          'detected_tools': detectedTools,
        },
      );
    } catch (e) {
      return SecurityCheckResult(
        name: 'Hooking Tools Detection',
        passed: false,
        threatLevel: SecurityThreatLevel.unknown,
        error: e.toString(),
      );
    }
  }
  
  /// Check app signature integrity
  Future<SecurityCheckResult> _checkAppSignature() async {
    try {
      // In production, you would verify the app signature against a known good signature
      // This is a simplified implementation
      bool signatureValid = true;
      
      if (Platform.isAndroid) {
        // Check APK signature
        signatureValid = await _verifyAndroidSignature();
      } else if (Platform.isIOS) {
        // Check iOS code signature
        signatureValid = await _verifyIOSSignature();
      }
      
      return SecurityCheckResult(
        name: 'App Signature Verification',
        passed: signatureValid,
        threatLevel: !signatureValid ? SecurityThreatLevel.critical : SecurityThreatLevel.none,
        details: {
          'signature_valid': signatureValid,
          'platform': Platform.operatingSystem,
        },
      );
    } catch (e) {
      return SecurityCheckResult(
        name: 'App Signature Verification',
        passed: false,
        threatLevel: SecurityThreatLevel.unknown,
        error: e.toString(),
      );
    }
  }
  
  /// Check for developer options enabled (Android)
  Future<SecurityCheckResult> _checkDeveloperOptions() async {
    try {
      bool developerOptionsEnabled = false;
      
      if (Platform.isAndroid) {
        developerOptionsEnabled = await SafeDevice.isDevelopmentModeEnable;
      }
      
      return SecurityCheckResult(
        name: 'Developer Options Check',
        passed: !developerOptionsEnabled,
        threatLevel: developerOptionsEnabled ? SecurityThreatLevel.low : SecurityThreatLevel.none,
        details: {
          'developer_options_enabled': developerOptionsEnabled,
        },
      );
    } catch (e) {
      return SecurityCheckResult(
        name: 'Developer Options Check',
        passed: false,
        threatLevel: SecurityThreatLevel.unknown,
        error: e.toString(),
      );
    }
  }
  
  /// Check for mock location (Android)
  Future<SecurityCheckResult> _checkMockLocation() async {
    try {
      bool mockLocationEnabled = false;
      
      if (Platform.isAndroid) {
        mockLocationEnabled = await SafeDevice.isMockLocation;
      }
      
      return SecurityCheckResult(
        name: 'Mock Location Check',
        passed: !mockLocationEnabled,
        threatLevel: mockLocationEnabled ? SecurityThreatLevel.medium : SecurityThreatLevel.none,
        details: {
          'mock_location_enabled': mockLocationEnabled,
        },
      );
    } catch (e) {
      return SecurityCheckResult(
        name: 'Mock Location Check',
        passed: false,
        threatLevel: SecurityThreatLevel.unknown,
        error: e.toString(),
      );
    }
  }
  
  /// Get comprehensive security status
  Future<Map<String, dynamic>> getSecurityStatus() async {
    final result = await performIntegrityCheck();
    
    return {
      'integrity_status': result.status.toString(),
      'threat_level': result.threatLevel.toString(),
      'last_check': result.timestamp.toIso8601String(),
      'checks_passed': result.checks.values.where((check) => check.passed).length,
      'total_checks': result.checks.length,
      'failed_checks': result.checks.entries
          .where((entry) => !entry.value.passed)
          .map((entry) => entry.key)
          .toList(),
      'recommendations': _getSecurityRecommendations(result),
    };
  }
  
  // Private helper methods
  
  Future<void> _performInitialChecks() async {
    final result = await performIntegrityCheck();
    if (result.threatLevel == SecurityThreatLevel.critical) {
      throw SecurityException(
        'Critical security threat detected: ${result.threatLevel}',
        result,
      );
    }
  }
  
  bool _isAndroidEmulator(AndroidDeviceInfo androidInfo) {
    final suspiciousFingerprints = [
      'generic',
      'google_sdk',
      'droid4x',
      'genymotion',
      'android_x86',
    ];
    
    final model = androidInfo.model.toLowerCase();
    final product = androidInfo.product.toLowerCase();
    final fingerprint = androidInfo.fingerprint.toLowerCase();
    
    return suspiciousFingerprints.any((suspicious) =>
        model.contains(suspicious) ||
        product.contains(suspicious) ||
        fingerprint.contains(suspicious));
  }
  
  Future<bool> _checkForFrida() async {
    try {
      // Check for Frida ports
      final fridaPorts = [27042, 27043];
      for (final port in fridaPorts) {
        final socket = await Socket.connect('127.0.0.1', port, timeout: Duration(milliseconds: 100));
        socket.destroy();
        return true; // Frida detected
      }
      return false;
    } catch (e) {
      return false; // Connection failed, likely no Frida
    }
  }
  
  Future<bool> _checkForXposed() async {
    // Check for Xposed framework files and methods
    try {
      // This would involve checking for Xposed-specific files and classes
      // Implementation would depend on specific detection methods
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> _checkForSubstrate() async {
    // Check for Substrate framework (iOS)
    try {
      // This would involve checking for Substrate-specific files and symbols
      // Implementation would depend on specific detection methods
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> _verifyAndroidSignature() async {
    // Verify Android APK signature
    // In production, this would compare against known good signature
    return true; // Simplified implementation
  }
  
  Future<bool> _verifyIOSSignature() async {
    // Verify iOS code signature
    // In production, this would verify code signing certificate
    return true; // Simplified implementation
  }
  
  SecurityThreatLevel _calculateThreatLevel(List<SecurityCheckResult> results) {
    final criticalCount = results.where((r) => r.threatLevel == SecurityThreatLevel.critical).length;
    final highCount = results.where((r) => r.threatLevel == SecurityThreatLevel.high).length;
    final mediumCount = results.where((r) => r.threatLevel == SecurityThreatLevel.medium).length;
    final lowCount = results.where((r) => r.threatLevel == SecurityThreatLevel.low).length;
    
    if (criticalCount > 0) return SecurityThreatLevel.critical;
    if (highCount > 0) return SecurityThreatLevel.high;
    if (mediumCount > 1) return SecurityThreatLevel.high;
    if (mediumCount > 0 || highCount > 0) return SecurityThreatLevel.medium;
    if (lowCount > 0) return SecurityThreatLevel.low;
    
    return SecurityThreatLevel.none;
  }
  
  List<String> _getSecurityRecommendations(IntegrityCheckResult result) {
    final recommendations = <String>[];
    
    result.checks.forEach((name, check) {
      if (!check.passed) {
        switch (name) {
          case 'root_jailbreak':
            recommendations.add('Device appears to be rooted/jailbroken. This poses security risks.');
            break;
          case 'debug_mode':
            recommendations.add('App is running in debug mode. This should not occur in production.');
            break;
          case 'emulator':
            recommendations.add('App is running on an emulator. Consider if this is expected.');
            break;
          case 'hooking_tools':
            recommendations.add('Potential hooking tools detected. App may be under analysis.');
            break;
          case 'app_signature':
            recommendations.add('App signature verification failed. App may be modified.');
            break;
          case 'developer_options':
            recommendations.add('Developer options are enabled. This may pose security risks.');
            break;
          case 'mock_location':
            recommendations.add('Mock location is enabled. Location data may not be reliable.');
            break;
        }
      }
    });
    
    if (recommendations.isEmpty) {
      recommendations.add('All security checks passed. Device appears secure.');
    }
    
    return recommendations;
  }
}

// Data classes for integrity check results

class IntegrityCheckResult {
  final IntegrityStatus status;
  final SecurityThreatLevel threatLevel;
  final DateTime timestamp;
  final Map<String, SecurityCheckResult> checks;
  final String? error;
  
  IntegrityCheckResult({
    required this.status,
    required this.threatLevel,
    required this.timestamp,
    required this.checks,
    this.error,
  });
}

class SecurityCheckResult {
  final String name;
  final bool passed;
  final SecurityThreatLevel threatLevel;
  final Map<String, dynamic>? details;
  final String? error;
  
  SecurityCheckResult({
    required this.name,
    required this.passed,
    required this.threatLevel,
    this.details,
    this.error,
  });
}

// Custom exception for security threats
class SecurityException implements Exception {
  final String message;
  final IntegrityCheckResult? result;
  
  SecurityException(this.message, [this.result]);
  
  @override
  String toString() => 'SecurityException: $message';
}