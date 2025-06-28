#!/usr/bin/env python3
"""
Roboflow AI 서비스 실행 가이드
============================

이 스크립트는 Roboflow AI 분석 서비스를 단계별로 실행하는 방법을 제공합니다.
"""

import os
import sys
import subprocess
from pathlib import Path

def check_environment():
    """환경 설정 확인"""
    print("🔍 환경 설정 확인 중...")
    
    issues = []
    
    # 1. Python 버전 확인
    if sys.version_info < (3, 8):
        issues.append("Python 3.8 이상이 필요합니다")
    else:
        print(f"✅ Python 버전: {sys.version}")
    
    # 2. 필수 패키지 확인
    required_packages = ['roboflow', 'requests', 'pillow']
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package.replace('-', '_'))
            print(f"✅ {package} 설치됨")
        except ImportError:
            missing_packages.append(package)
            print(f"❌ {package} 누락")
    
    if missing_packages:
        issues.append(f"누락된 패키지: {', '.join(missing_packages)}")
    
    # 3. 환경변수 확인
    env_vars = ['ROBOFLOW_API_KEY', 'ROBOFLOW_WORKSPACE', 'ROBOFLOW_PROJECT']
    missing_env = []
    
    for var in env_vars:
        if not os.getenv(var):
            missing_env.append(var)
            print(f"❌ {var} 환경변수 누락")
        else:
            print(f"✅ {var} 설정됨")
    
    if missing_env:
        issues.append(f"누락된 환경변수: {', '.join(missing_env)}")
    
    return issues

def setup_environment():
    """환경 설정"""
    print("\n🛠️ 환경 설정 시작...")
    
    # 1. 패키지 설치
    print("📦 필수 패키지 설치 중...")
    packages = ['roboflow', 'requests', 'pillow', 'python-dotenv']
    
    for package in packages:
        try:
            subprocess.run([sys.executable, '-m', 'pip', 'install', package], 
                         check=True, capture_output=True)
            print(f"✅ {package} 설치 완료")
        except subprocess.CalledProcessError as e:
            print(f"❌ {package} 설치 실패: {e}")
    
    # 2. .env 파일 생성
    env_file = Path('.env')
    if not env_file.exists():
        print("📝 .env 파일 생성 중...")
        env_content = """# Roboflow AI 설정
# =================

# Roboflow API 설정 (필수)
ROBOFLOW_API_KEY=your_api_key_here
ROBOFLOW_WORKSPACE=your_workspace_name
ROBOFLOW_PROJECT=your_project_name
ROBOFLOW_VERSION=1

# 분석 설정 (선택사항)
CONFIDENCE_THRESHOLD=50
OVERLAP_THRESHOLD=30

# 백엔드 설정 (Spring Boot 연동용)
BACKEND_URL=http://localhost:8080
"""
        with open('.env', 'w', encoding='utf-8') as f:
            f.write(env_content)
        print("✅ .env 파일 생성 완료")
        print("📋 .env 파일을 편집하여 실제 API 키를 입력하세요!")
    
def show_usage_examples():
    """사용 예제 출력"""
    print("\n📖 사용 방법:")
    print("=" * 50)
    
    examples = [
        {
            "title": "1. 단일 이미지 분석",
            "command": "python roboflow_test.py --image path/to/image.jpg",
            "description": "지정된 이미지 파일을 분석합니다"
        },
        {
            "title": "2. 배치 이미지 분석", 
            "command": "python roboflow_test.py --batch path/to/images/",
            "description": "폴더 내 모든 이미지를 일괄 분석합니다"
        },
        {
            "title": "3. 테스트 모드",
            "command": "python roboflow_test.py --test",
            "description": "샘플 이미지로 테스트를 수행합니다"
        },
        {
            "title": "4. 설정 확인",
            "command": "python roboflow_test.py --check-config",
            "description": "API 설정 상태를 확인합니다"
        },
        {
            "title": "5. 백엔드 연동 테스트",
            "command": "python roboflow_test.py --test-backend",
            "description": "Spring Boot 백엔드와의 연동을 테스트합니다"
        }
    ]
    
    for example in examples:
        print(f"\n{example['title']}")
        print(f"   명령어: {example['command']}")
        print(f"   설명: {example['description']}")

def show_troubleshooting():
    """문제 해결 가이드"""
    print("\n🔧 문제 해결 가이드:")
    print("=" * 50)
    
    problems = [
        {
            "issue": "403 Forbidden 오류",
            "solutions": [
                "API 키가 올바른지 확인하세요",
                "Roboflow 대시보드에서 API 키를 재생성하세요",
                "Workspace와 Project 이름이 정확한지 확인하세요",
                "인터넷 연결 상태를 확인하세요"
            ]
        },
        {
            "issue": "패키지 임포트 오류",
            "solutions": [
                "pip install roboflow requests pillow 실행",
                "가상 환경이 활성화되어 있는지 확인",
                "Python 버전이 3.8 이상인지 확인"
            ]
        },
        {
            "issue": "이미지 파일 오류",
            "solutions": [
                "이미지 파일 경로가 올바른지 확인",
                "지원되는 형식인지 확인 (JPG, PNG)",
                "파일 크기가 10MB 이하인지 확인"
            ]
        }
    ]
    
    for problem in problems:
        print(f"\n❌ {problem['issue']}")
        for i, solution in enumerate(problem['solutions'], 1):
            print(f"   {i}. {solution}")

def main():
    """메인 실행 함수"""
    print("🚀 Roboflow AI 서비스 실행 가이드")
    print("=" * 50)
    
    # 환경 확인
    issues = check_environment()
    
    if issues:
        print(f"\n⚠️ 발견된 문제: {len(issues)}개")
        for i, issue in enumerate(issues, 1):
            print(f"   {i}. {issue}")
        
        print("\n🛠️ 환경 설정을 시작하시겠습니까? (y/n): ", end="")
        if input().lower() in ['y', 'yes', '예']:
            setup_environment()
    else:
        print("\n✅ 환경 설정이 완료되었습니다!")
    
    show_usage_examples()
    show_troubleshooting()
    
    print("\n🎯 다음 단계:")
    print("1. .env 파일에 실제 Roboflow API 키 입력")
    print("2. python roboflow_test.py --test 명령으로 테스트 실행")
    print("3. 문제 발생 시 위의 문제 해결 가이드 참조")

if __name__ == "__main__":
    main()
