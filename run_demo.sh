#!/bin/bash
# 전북 현장 보고 시스템 - Roboflow AI 통합 실행 스크립트

echo "🚀 전북 현장 보고 시스템 - Roboflow AI 서비스"
echo "============================================================"
echo ""

# 현재 상태 확인
echo "📋 현재 설정 상태:"
echo "✅ Python 패키지 설치 완료"
echo "✅ 테스트 이미지 다운로드 완료 (6개)"
echo "✅ 모의 테스트 정상 작동"
echo "⚠️  실제 API 키 설정 필요"
echo ""

# 메뉴 표시
echo "🎯 실행할 작업을 선택하세요:"
echo "1) 테스트 모드 실행 (API 키 불필요)"
echo "2) 설정 상태 확인"
echo "3) API 키 설정 가이드 보기"
echo "4) 실제 이미지 분석 (API 키 필요)"
echo "5) 배치 이미지 분석 (API 키 필요)"
echo "6) 백엔드 연동 테스트"
echo "7) Flutter 앱 실행"
echo "0) 종료"
echo ""

read -p "선택 (0-7): " choice

case $choice in
    1)
        echo "🧪 테스트 모드 실행 중..."
        python3 roboflow_test.py --test
        ;;
    2)
        echo "🔍 설정 상태 확인 중..."
        python3 roboflow_test.py --check-config
        ;;
    3)
        echo "📖 API 키 설정 가이드:"
        echo "============================================================"
        echo "1. https://roboflow.com 방문"
        echo "2. 계정 생성 (무료)"
        echo "3. 새 프로젝트 생성 (Object Detection)"
        echo "4. Settings > Roboflow API에서 Private API Key 복사"
        echo "5. .env 파일 수정:"
        echo "   ROBOFLOW_API_KEY=복사한_API_키"
        echo "   ROBOFLOW_WORKSPACE=워크스페이스명"
        echo "   ROBOFLOW_PROJECT=프로젝트명"
        echo ""
        echo "📝 .env 파일 편집:"
        echo "nano .env"
        ;;
    4)
        echo "🖼️  실제 이미지 분석 실행..."
        echo "사용 가능한 테스트 이미지:"
        ls -la test_images/*.jpg 2>/dev/null || echo "❌ 테스트 이미지가 없습니다. 먼저 download_test_images.py를 실행하세요."
        echo ""
        read -p "분석할 이미지 파일명 입력 (예: test_images/road_damage_1.jpg): " image_file
        if [ -f "$image_file" ]; then
            python3 roboflow_test.py --image "$image_file"
        else
            echo "❌ 파일을 찾을 수 없습니다: $image_file"
        fi
        ;;
    5)
        echo "📁 배치 이미지 분석 실행..."
        python3 roboflow_test.py --batch test_images/
        ;;
    6)
        echo "🔌 백엔드 연동 테스트 실행..."
        python3 roboflow_test.py --test-backend
        ;;
    7)
        echo "📱 Flutter 앱 실행..."
        cd flutter-app
        flutter run
        ;;
    0)
        echo "👋 종료합니다."
        exit 0
        ;;
    *)
        echo "❌ 잘못된 선택입니다."
        ;;
esac

echo ""
echo "🔄 다시 실행하려면: ./run_demo.sh"
echo "📋 상세 가이드: cat QUICK_START_GUIDE.md"
