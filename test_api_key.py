#!/usr/bin/env python3
"""
Roboflow API 키 검증 및 공개 모델 테스트 도구
"""

import requests
import json
import os
from pathlib import Path

def test_public_models():
    """공개적으로 사용 가능한 Roboflow 모델들을 테스트"""
    
    # 공개 모델들 (API 키 없이도 테스트 가능한 것들)
    public_models = [
        {
            "name": "COCO Dataset",
            "endpoint": "https://detect.roboflow.com/coco/9",
            "description": "일반적인 객체 감지 (사람, 차량, 동물 등)"
        },
        {
            "name": "License Plate Detection",
            "endpoint": "https://detect.roboflow.com/license-plate-recognition-rxg4e/4",
            "description": "번호판 감지"
        },
        {
            "name": "Road Damage Detection",
            "endpoint": "https://detect.roboflow.com/road-damage-detection-aug-2022/1",
            "description": "도로 손상 감지"
        }
    ]
    
    print("🔍 공개 Roboflow 모델 테스트")
    print("=" * 60)
    
    # 테스트 이미지 생성 (간단한 1x1 픽셀)
    import io
    from PIL import Image
    
    test_image = Image.new('RGB', (100, 100), color='white')
    img_buffer = io.BytesIO()
    test_image.save(img_buffer, format='JPEG')
    img_data = img_buffer.getvalue()
    
    for i, model in enumerate(public_models, 1):
        print(f"\n{i}. {model['name']}")
        print(f"   설명: {model['description']}")
        print(f"   엔드포인트: {model['endpoint']}")
        
        try:
            # API 키 없이 테스트
            files = {'file': ('test.jpg', img_data, 'image/jpeg')}
            response = requests.post(
                model['endpoint'],
                files=files,
                timeout=10
            )
            
            print(f"   📊 응답 상태: {response.status_code}")
            
            if response.status_code == 200:
                print(f"   ✅ 성공! 이 모델을 사용할 수 있습니다.")
                try:
                    result = response.json()
                    print(f"   📄 응답 형식: {type(result).__name__}")
                except:
                    print(f"   📄 응답 길이: {len(response.text)} bytes")
            elif response.status_code == 403:
                print(f"   ❌ API 키 필요")
            elif response.status_code == 404:
                print(f"   ❌ 모델을 찾을 수 없음")
            else:
                print(f"   ⚠️  기타 오류: {response.text[:100]}...")
                
        except requests.exceptions.Timeout:
            print(f"   ⏰ 타임아웃")
        except requests.exceptions.RequestException as e:
            print(f"   ❌ 연결 오류: {e}")

def validate_api_key(api_key):
    """API 키 유효성 검증"""
    if not api_key or api_key in ['your_private_api_key_here', 'YOUR_ACTUAL_API_KEY_HERE']:
        return False, "API 키가 설정되지 않았습니다"
    
    if len(api_key) < 20:
        return False, "API 키가 너무 짧습니다"
    
    # 실제 API 호출로 검증
    test_url = f"https://api.roboflow.com/workspaces?api_key={api_key}"
    
    try:
        response = requests.get(test_url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            workspaces = data.get('workspaces', [])
            return True, f"유효한 API 키입니다. 워크스페이스 {len(workspaces)}개 발견"
        elif response.status_code == 401 or response.status_code == 403:
            return False, "API 키가 유효하지 않습니다"
        else:
            return False, f"알 수 없는 오류: {response.status_code}"
    except Exception as e:
        return False, f"API 호출 실패: {e}"

def get_workspaces(api_key):
    """사용자의 워크스페이스 목록 가져오기"""
    url = f"https://api.roboflow.com/workspaces?api_key={api_key}"
    
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            return data.get('workspaces', [])
        else:
            print(f"워크스페이스 조회 실패: {response.status_code}")
            return []
    except Exception as e:
        print(f"워크스페이스 조회 오류: {e}")
        return []

def main():
    print("🚀 Roboflow API 키 검증 도구")
    print("=" * 60)
    
    # .env 파일에서 API 키 읽기
    env_file = Path('.env')
    api_key = None
    
    if env_file.exists():
        with open(env_file, 'r') as f:
            for line in f:
                if line.startswith('ROBOFLOW_API_KEY='):
                    api_key = line.split('=', 1)[1].strip()
                    break
    
    if not api_key:
        api_key = os.getenv('ROBOFLOW_API_KEY')
    
    print(f"\n📋 현재 설정된 API 키:")
    if api_key:
        masked_key = f"{api_key[:4]}****{api_key[-4:]}" if len(api_key) > 8 else "****"
        print(f"   🔑 {masked_key}")
        
        # API 키 검증
        print(f"\n🔍 API 키 검증 중...")
        is_valid, message = validate_api_key(api_key)
        if is_valid:
            print(f"   ✅ {message}")
            
            # 워크스페이스 조회
            print(f"\n📁 워크스페이스 조회 중...")
            workspaces = get_workspaces(api_key)
            if workspaces:
                print(f"   📋 사용 가능한 워크스페이스:")
                for ws in workspaces:
                    print(f"      - {ws.get('name', 'Unknown')}")
            else:
                print(f"   ⚠️  워크스페이스를 찾을 수 없습니다")
        else:
            print(f"   ❌ {message}")
    else:
        print(f"   ❌ API 키가 설정되지 않았습니다")
    
    # 공개 모델 테스트
    print(f"\n" + "=" * 60)
    test_public_models()
    
    print(f"\n" + "=" * 60)
    print("🎯 추천 사항:")
    print("1. 유효한 API 키가 있다면 본인의 프로젝트를 사용하세요")
    print("2. API 키가 없다면 https://roboflow.com 에서 무료 계정을 만드세요")
    print("3. 테스트용으로는 공개 모델들을 사용할 수 있습니다")
    print("4. Flutter 앱에서는 설정 페이지에서 API 키를 입력하세요")

if __name__ == "__main__":
    main()
