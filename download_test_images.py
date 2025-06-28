#!/usr/bin/env python3
"""
전북 현장 보고 시스템 - 테스트 이미지 다운로드
테스트용 샘플 이미지를 다운로드하여 AI 분석을 테스트합니다
"""

import os
import requests
from urllib.parse import urlparse
from typing import List, Dict

# 테스트용 샘플 이미지 URL 목록
SAMPLE_IMAGES = {
    "road_damage_1.jpg": "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800",  # 도로 파손
    "pothole_1.jpg": "https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=800",      # 포트홀
    "street_light_1.jpg": "https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=800", # 가로등
    "graffiti_1.jpg": "https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800",     # 낙서
    "trash_1.jpg": "https://images.unsplash.com/photo-1530587191325-3db32d826c18?w=800",        # 쓰레기
    "construction_1.jpg": "https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800",  # 공사 현장
}

def download_image(url: str, filename: str) -> bool:
    """이미지 다운로드"""
    try:
        print(f"📥 다운로드 중: {filename}")
        
        # 이미 파일이 존재하는지 확인
        if os.path.exists(filename):
            print(f"  ✅ 이미 존재함: {filename}")
            return True
        
        # 이미지 다운로드
        response = requests.get(url, stream=True, timeout=30)
        response.raise_for_status()
        
        # 파일 저장
        with open(filename, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        # 파일 크기 확인
        file_size = os.path.getsize(filename)
        print(f"  ✅ 다운로드 완료: {filename} ({file_size:,} bytes)")
        return True
        
    except Exception as e:
        print(f"  ❌ 다운로드 실패: {filename} - {e}")
        return False

def create_test_directory() -> str:
    """테스트 디렉토리 생성"""
    test_dir = "test_images"
    
    if not os.path.exists(test_dir):
        os.makedirs(test_dir)
        print(f"📁 테스트 디렉토리 생성: {test_dir}")
    else:
        print(f"📁 테스트 디렉토리 존재: {test_dir}")
    
    return test_dir

def create_simple_test_images():
    """간단한 테스트 이미지 생성 (다운로드 실패 시 대안)"""
    try:
        from PIL import Image, ImageDraw, ImageFont
        
        print("🎨 간단한 테스트 이미지 생성 중...")
        
        colors = [
            (255, 0, 0),    # 빨강
            (0, 255, 0),    # 초록
            (0, 0, 255),    # 파랑
            (255, 255, 0),  # 노랑
            (255, 0, 255),  # 마젠타
        ]
        
        for i, (filename, url) in enumerate(SAMPLE_IMAGES.items()):
            if not os.path.exists(filename):
                # 단색 이미지 생성
                img = Image.new('RGB', (640, 480), colors[i % len(colors)])
                draw = ImageDraw.Draw(img)
                
                # 텍스트 추가
                try:
                    font = ImageFont.load_default()
                    text = f"Test Image {i+1}\n{filename}"
                    draw.text((20, 20), text, fill=(255, 255, 255), font=font)
                except:
                    draw.text((20, 20), f"Test {i+1}", fill=(255, 255, 255))
                
                img.save(filename)
                print(f"  ✅ 생성: {filename}")
        
        return True
        
    except ImportError:
        print("❌ PIL(Pillow) 라이브러리가 필요합니다: pip install Pillow")
        return False
    except Exception as e:
        print(f"❌ 이미지 생성 실패: {e}")
        return False

def main():
    """메인 실행 함수"""
    print("🚀 전북 현장 보고 시스템 - 테스트 이미지 준비")
    print("=" * 60)
    
    # 테스트 디렉토리 생성
    test_dir = create_test_directory()
    
    # 현재 디렉토리를 테스트 디렉토리로 변경
    original_dir = os.getcwd()
    os.chdir(test_dir)
    
    try:
        # 이미지 다운로드 시도
        success_count = 0
        total_count = len(SAMPLE_IMAGES)
        
        print(f"\n📥 {total_count}개 샘플 이미지 다운로드 시작")
        print("-" * 40)
        
        for filename, url in SAMPLE_IMAGES.items():
            if download_image(url, filename):
                success_count += 1
        
        print(f"\n📊 다운로드 결과: {success_count}/{total_count} 성공")
        
        # 다운로드 실패 시 간단한 이미지 생성
        if success_count < total_count:
            print("\n🎨 일부 다운로드 실패, 대체 이미지 생성 시도...")
            create_simple_test_images()
        
        # 최종 확인
        print("\n📋 최종 테스트 이미지 목록:")
        for filename in SAMPLE_IMAGES.keys():
            if os.path.exists(filename):
                size = os.path.getsize(filename)
                print(f"  ✅ {filename} ({size:,} bytes)")
            else:
                print(f"  ❌ {filename} (없음)")
        
        print(f"\n🎉 테스트 이미지 준비 완료!")
        print(f"📁 위치: {os.path.join(original_dir, test_dir)}")
        print("\n💡 다음 단계:")
        print("  1. python roboflow_test.py 실행")
        print("  2. API 키 설정 확인")
        print("  3. 모델 훈련 상태 확인")
        
    finally:
        # 원래 디렉토리로 복귀
        os.chdir(original_dir)

if __name__ == "__main__":
    main()
