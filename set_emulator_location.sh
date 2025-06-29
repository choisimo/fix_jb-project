#!/bin/bash

# 에뮬레이터 GPS 위치 설정 스크립트
# 한국 주요 도시 좌표로 GPS 위치를 설정합니다.

echo "🌍 에뮬레이터 GPS 위치 설정 스크립트"
echo "======================================"

# ADB 연결 확인
if ! command -v adb &> /dev/null; then
    echo "❌ ADB가 설치되지 않았습니다."
    echo "Android Studio SDK를 설치하고 PATH에 추가해주세요."
    exit 1
fi

# 에뮬레이터 실행 확인
if ! adb devices | grep -q "emulator"; then
    echo "❌ 실행 중인 에뮬레이터가 없습니다."
    echo "에뮬레이터를 먼저 실행해주세요."
    exit 1
fi

echo ""
echo "📍 설정할 위치를 선택하세요:"
echo "1) 서울 (37.5665, 126.9780)"
echo "2) 부산 (35.1796, 129.0756)" 
echo "3) 대구 (35.8714, 128.6014)"
echo "4) 인천 (37.4563, 126.7052)"
echo "5) 광주 (35.1595, 126.8526)"
echo "6) 대전 (36.3504, 127.3849)"
echo "7) 울산 (35.5384, 129.3114)"
echo "8) 수원 (37.2636, 127.0286)"
echo "9) 사용자 정의 좌표 입력"
echo "0) 종료"
echo ""

read -p "선택하세요 (0-9): " choice

case $choice in
    1)
        lat="37.5665"
        lon="126.9780"
        city="서울"
        ;;
    2)
        lat="35.1796"
        lon="129.0756"
        city="부산"
        ;;
    3)
        lat="35.8714"
        lon="128.6014"
        city="대구"
        ;;
    4)
        lat="37.4563"
        lon="126.7052"
        city="인천"
        ;;
    5)
        lat="35.1595"
        lon="126.8526"
        city="광주"
        ;;
    6)
        lat="36.3504"
        lon="127.3849"
        city="대전"
        ;;
    7)
        lat="35.5384"
        lon="129.3114"
        city="울산"
        ;;
    8)
        lat="37.2636"
        lon="127.0286"
        city="수원"
        ;;
    9)
        echo ""
        read -p "위도를 입력하세요 (예: 37.5665): " lat
        read -p "경도를 입력하세요 (예: 126.9780): " lon
        city="사용자 정의"
        
        # 위도/경도 유효성 검사
        if ! [[ $lat =~ ^-?[0-9]+\.?[0-9]*$ ]] || ! [[ $lon =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
            echo "❌ 올바른 좌표 형식이 아닙니다."
            exit 1
        fi
        ;;
    0)
        echo "👋 설정을 취소합니다."
        exit 0
        ;;
    *)
        echo "❌ 올바른 번호를 선택해주세요."
        exit 1
        ;;
esac

echo ""
echo "🔧 GPS 위치 설정 중..."
echo "위치: $city"
echo "좌표: $lat, $lon"

# GPS 위치 설정
if adb emu geo fix $lon $lat; then
    echo "✅ GPS 위치가 성공적으로 설정되었습니다!"
    echo ""
    echo "📱 에뮬레이터에서 확인하는 방법:"
    echo "1. 지도 앱을 열어서 현재 위치 확인"
    echo "2. Flutter 앱에서 위치 기능 테스트"
    echo "3. 설정 > 위치 > 위치 서비스가 켜져 있는지 확인"
    echo ""
    echo "🔍 추가 설정이 필요한 경우:"
    echo "Extended Controls (... 버튼) > Location에서 수동으로도 설정 가능"
else
    echo "❌ GPS 위치 설정에 실패했습니다."
    echo ""
    echo "🔧 문제 해결 방법:"
    echo "1. 에뮬레이터가 완전히 부팅되었는지 확인"
    echo "2. ADB 연결 상태 확인: adb devices"
    echo "3. 에뮬레이터 재시작 후 다시 시도"
    echo "4. Extended Controls > Location에서 수동 설정"
fi

echo ""
echo "🌟 위치 테스트 방법:"
echo "1. Flutter 앱 실행: flutter run"
echo "2. 위치 권한 허용"
echo "3. 지도나 위치 기능 테스트"
echo "4. 콘솔 로그에서 위치 정보 확인"

echo ""
echo "📚 문제가 계속 발생하면 LOCATION_GPS_TROUBLESHOOTING.md 문서를 참조하세요."
