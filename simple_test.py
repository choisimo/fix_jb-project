#!/usr/bin/env python3
"""
간단한 Roboflow 공개 모델 테스트
"""

import requests
from pathlib import Path

def test_demo_model():
    """데모용 공개 모델 테스트"""
    
    print("🔍 Roboflow 공개 모델 테스트")
    print("=" * 50)
    
    # Microsoft COCO 데이터셋 모델 (공개 사용 가능)
    demo_url = "https://detect.roboflow.com/coco/9"
    
    # 간단한 테스트 데이터 생성
    test_data = b"fake_image_data"
    
    try:
        print("📤 API 호출 중...")
        files = {'file': ('test.jpg', test_data, 'image/jpeg')}
        response = requests.post(demo_url, files=files, timeout=5)
        
        print(f"📊 응답 상태: {response.status_code}")
        print(f"📄 응답 내용: {response.text[:200]}...")
        
        if response.status_code == 200:
            print("✅ 공개 모델 API 호출 성공!")
        elif response.status_code == 400:
            print("⚠️ 이미지 형식 오류 (예상됨)")
        elif response.status_code == 403:
            print("❌ API 키 필요")
        else:
            print(f"⚠️ 기타 응답: {response.status_code}")
            
    except Exception as e:
        print(f"❌ 오류: {e}")

def check_env_file():
    """환경 설정 파일 확인"""
    print("\n📋 환경 설정 확인")
    print("=" * 50)
    
    env_file = Path('.env')
    if env_file.exists():
        print("✅ .env 파일 존재")
        with open(env_file, 'r') as f:
            lines = f.readlines()
        
        for line in lines[:10]:  # 처음 10줄만
            if 'API_KEY' in line:
                key_part = line.split('=')[1].strip() if '=' in line else ''
                if key_part and key_part not in ['your_private_api_key_here', 'YOUR_ACTUAL_API_KEY_HERE']:
                    print(f"🔑 API 키 설정됨: {key_part[:4]}****")
                else:
                    print("⚠️ API 키가 플레이스홀더 값입니다")
    else:
        print("❌ .env 파일이 없습니다")

if __name__ == "__main__":
    check_env_file()
    test_demo_model()
    
    print("\n🎯 해결 방안:")
    print("1. 실제 Roboflow API 키를 .env 파일에 설정")
    print("2. 또는 Flutter 앱 설정에서 직접 입력")
    print("3. 임시로 공개 모델 엔드포인트 사용")
