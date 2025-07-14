import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/enums/security_enums.dart';

class AppIntegrityVerification {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  Future<IntegrityStatus> verifyIntegrity() async {
    try {
      // Check for root/jailbreak
      if (await _isDeviceCompromised()) {
        return IntegrityStatus.compromised;
      }
      
      // Verify app signature
      if (!await _verifyAppSignature()) {
        return IntegrityStatus.unverified;
      }
      
      // Check for debugging
      if (await _isDebugging()) {
        return IntegrityStatus.unverified;
      }
      
      return IntegrityStatus.verified;
    } catch (e) {
      return IntegrityStatus.checking;
    }
  }
  
  Future<bool> _isDeviceCompromised() async {
    if (Platform.isAndroid) {
      // Check for common root indicators
      final rootPaths = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
      ];
      
      for (final path in rootPaths) {
        if (await File(path).exists()) {
          return true;
        }
      }
    } else if (Platform.isIOS) {
      // Check for jailbreak indicators
      final jailbreakPaths = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt',
        '/private/var/lib/apt/',
      ];
      
      for (final path in jailbreakPaths) {
        if (await File(path).exists()) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  Future<bool> _verifyAppSignature() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      // In production, verify the actual signature
      return packageInfo.packageName.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> _isDebugging() async {
    // In release mode, this should return false
    return false; // const bool.fromEnvironment('dart.vm.product') == false;
  }
  
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final info = <String, dynamic>{};
    
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      info['platform'] = 'Android';
      info['model'] = androidInfo.model;
      info['version'] = androidInfo.version.release;
      info['manufacturer'] = androidInfo.manufacturer;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      info['platform'] = 'iOS';
      info['model'] = iosInfo.model;
      info['version'] = iosInfo.systemVersion;
      info['name'] = iosInfo.name;
    }
    
    return info;
  }
}