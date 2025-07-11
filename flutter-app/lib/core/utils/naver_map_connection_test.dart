import 'dart:io';
import 'package:http/http.dart' as http;

class NaverMapConnectionTest {
  static const String naverMapApiDomain = 'navermaps.apigw.ntruss.com';
  static const String clientId = '6gmofoay96';

  static Future<Map<String, dynamic>> testConnection() async {
    Map<String, dynamic> results = {
      'networkConnectivity': false,
      'naverApiReachable': false,
      'dnsResolution': false,
      'details': [],
    };

    // 1. 기본 네트워크 연결 테스트
    try {
      final lookup = await InternetAddress.lookup('google.com');
      if (lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty) {
        results['networkConnectivity'] = true;
        results['details'].add('✅ 기본 네트워크 연결: 정상');
      }
    } catch (e) {
      results['details'].add('❌ 기본 네트워크 연결: 실패 - $e');
    }

    // 2. 네이버 맵 도메인 DNS 해석 테스트
    try {
      final lookup = await InternetAddress.lookup(naverMapApiDomain);
      if (lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty) {
        results['dnsResolution'] = true;
        results['details'].add('✅ 네이버 맵 DNS 해석: 정상 - ${lookup[0].address}');
      }
    } catch (e) {
      results['details'].add('❌ 네이버 맵 DNS 해석: 실패 - $e');
    }

    // 3. 네이버 맵 API 도달성 테스트 (간단한 HEAD 요청)
    try {
      final response = await http.get(
        Uri.parse('https://$naverMapApiDomain'),
        headers: {
          'User-Agent': 'Flutter-NaverMap-Test/1.0',
          'X-NCP-APIGW-API-KEY-ID': clientId,
        },
      ).timeout(Duration(seconds: 10));
      
      results['naverApiReachable'] = true;
      results['details'].add('✅ 네이버 맵 API 연결: 정상 (상태: ${response.statusCode})');
    } catch (e) {
      results['details'].add('❌ 네이버 맵 API 연결: 실패 - $e');
    }

    return results;
  }

  static void printTestResults(Map<String, dynamic> results) {
    print('\n🔍 네이버 맵 연결 테스트 결과:');
    print('═' * 50);
    
    print('📡 네트워크 연결: ${results['networkConnectivity'] ? "정상" : "실패"}');
    print('🌐 DNS 해석: ${results['dnsResolution'] ? "정상" : "실패"}');
    print('🗺️ 네이버 API 연결: ${results['naverApiReachable'] ? "정상" : "실패"}');
    
    print('\n📋 상세 결과:');
    for (String detail in results['details']) {
      print('  $detail');
    }
    
    print('═' * 50);
    
    // 종합 평가
    bool allGood = results['networkConnectivity'] && 
                   results['dnsResolution'] && 
                   results['naverApiReachable'];
    
    if (allGood) {
      print('✅ 전체 연결 상태: 정상 - 네이버 맵 사용 가능');
    } else {
      print('⚠️ 전체 연결 상태: 일부 문제 있음');
      print('💡 해결 방안:');
      if (!results['networkConnectivity']) {
        print('  - Wi-Fi/데이터 연결 확인');
      }
      if (!results['dnsResolution']) {
        print('  - DNS 설정 확인 (8.8.8.8, 1.1.1.1 등)');
      }
      if (!results['naverApiReachable']) {
        print('  - 네이버 클라우드 플랫폼 API 키 확인');
        print('  - 방화벽/프록시 설정 확인');
      }
    }
    print('\n');
  }
}