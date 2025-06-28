#!/usr/bin/env python3
"""
전북 현장 보고 시스템 - Roboflow 통합 설정 및 테스트 도구
모든 설정을 한 번에 확인하고 테스트할 수 있는 통합 스크립트
"""

import os
import sys
import subprocess
import platform
from pathlib import Path

def print_banner():
    """시작 배너 출력"""
    print("🚀 전북 현장 보고 시스템 - Roboflow 설정 도구")
    print("=" * 60)
    print("이 도구는 Roboflow API 연동을 위한 설정을 도와줍니다.")
    print("=" * 60)

def check_python_packages():
    """필요한 Python 패키지 확인"""
    print("\n📦 Python 패키지 확인 중...")
    
    required_packages = [
        'roboflow',
        'requests', 
        'Pillow',
        'python-dotenv'
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package.replace('-', '_'))
            print(f"  ✅ {package}")
        except ImportError:
            print(f"  ❌ {package} (설치 필요)")
            missing_packages.append(package)
    
    if missing_packages:
        print(f"\n⚠️ 누락된 패키지: {', '.join(missing_packages)}")
        print("다음 명령어로 설치하세요:")
        print(f"pip install {' '.join(missing_packages)}")
        return False
    else:
        print("✅ 모든 필수 패키지가 설치되어 있습니다!")
        return True

def check_environment_setup():
    """환경 설정 확인"""
    print("\n🔧 환경 설정 확인 중...")
    
    env_file = Path('.env')
    env_example = Path('.env.example')
    
    if not env_file.exists():
        print("❌ .env 파일이 없습니다.")
        if env_example.exists():
            print("💡 .env.example을 복사하여 .env 파일을 생성하세요:")
            print("cp .env.example .env")
        else:
            print("💡 .env 파일을 생성하고 API 키를 설정하세요.")
        return False
    else:
        print("✅ .env 파일이 존재합니다.")
        
        # API 키 확인
        try:
            with open(env_file, 'r') as f:
                content = f.read()
                if 'your_private_api_key_here' in content:
                    print("⚠️ API 키가 기본값으로 설정되어 있습니다.")
                    print("실제 Roboflow API 키로 변경해주세요.")
                    return False
                else:
                    print("✅ API 키가 설정되어 있는 것 같습니다.")
                    return True
        except Exception as e:
            print(f"❌ .env 파일 읽기 실패: {e}")
            return False

def run_config_test():
    """설정 테스트 실행"""
    print("\n🧪 설정 검증 테스트 실행 중...")
    
    try:
        result = subprocess.run([
            sys.executable, 'config_manager.py'
        ], capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            print("✅ 설정 검증 성공!")
            print(result.stdout)
            return True
        else:
            print("❌ 설정 검증 실패!")
            print(result.stderr)
            return False
            
    except FileNotFoundError:
        print("❌ config_manager.py 파일을 찾을 수 없습니다.")
        return False
    except subprocess.TimeoutExpired:
        print("❌ 설정 검증 시간 초과")
        return False
    except Exception as e:
        print(f"❌ 설정 검증 오류: {e}")
        return False

def run_roboflow_test():
    """Roboflow API 테스트 실행"""
    print("\n🤖 Roboflow API 테스트 실행 중...")
    
    # 테스트 이미지 다운로드 먼저 시도
    print("1. 테스트 이미지 준비 중...")
    try:
        result = subprocess.run([
            sys.executable, 'download_test_images.py'
        ], capture_output=True, text=True, timeout=60)
        
        if result.returncode == 0:
            print("   ✅ 테스트 이미지 준비 완료")
        else:
            print("   ⚠️ 테스트 이미지 다운로드 일부 실패 (계속 진행)")
    except Exception as e:
        print(f"   ⚠️ 테스트 이미지 준비 오류: {e}")
    
    # Roboflow 테스트 실행
    print("2. AI 분석 테스트 실행 중...")
    try:
        result = subprocess.run([
            sys.executable, 'roboflow_test.py'
        ], capture_output=True, text=True, timeout=120)
        
        if result.returncode == 0:
            print("✅ AI 분석 테스트 성공!")
            print(result.stdout[-500:] if len(result.stdout) > 500 else result.stdout)
            return True
        else:
            print("❌ AI 분석 테스트 실패!")
            print(result.stderr)
            return False
            
    except FileNotFoundError:
        print("❌ roboflow_test.py 파일을 찾을 수 없습니다.")
        return False
    except subprocess.TimeoutExpired:
        print("❌ AI 분석 테스트 시간 초과")
        return False
    except Exception as e:
        print(f"❌ AI 분석 테스트 오류: {e}")
        return False

def show_next_steps():
    """다음 단계 안내"""
    print("\n🎯 다음 단계:")
    print("1. Roboflow 워크스페이스에서 모델 훈련 상태 확인")
    print("2. Flutter 앱에서 AI 설정 페이지 테스트")
    print("3. 실제 현장 이미지로 정확도 검증")
    print("4. 프로덕션 배포 준비")
    
    print("\n📚 참고 문서:")
    print("- ROBOFLOW_SETUP_STEP_BY_STEP.md: 단계별 설정 가이드")
    print("- ROBOFLOW_WORKSPACE_DESIGN.md: 워크스페이스 설계 가이드")
    print("- ROBOFLOW_API_VERIFICATION.md: API 검증 가이드")

def main():
    """메인 실행 함수"""
    print_banner()
    
    # 1. Python 패키지 확인
    packages_ok = check_python_packages()
    if not packages_ok:
        print("\n❌ 패키지 설치를 먼저 완료해주세요.")
        sys.exit(1)
    
    # 2. 환경 설정 확인
    env_ok = check_environment_setup()
    if not env_ok:
        print("\n❌ 환경 설정을 먼저 완료해주세요.")
        sys.exit(1)
    
    # 3. 설정 검증
    config_ok = run_config_test()
    if not config_ok:
        print("\n❌ 설정 검증을 먼저 완료해주세요.")
        sys.exit(1)
    
    # 4. Roboflow API 테스트
    api_ok = run_roboflow_test()
    
    # 결과 요약
    print("\n" + "=" * 60)
    print("📊 테스트 결과 요약")
    print("=" * 60)
    print(f"📦 패키지 설치: {'✅ 완료' if packages_ok else '❌ 실패'}")
    print(f"🔧 환경 설정: {'✅ 완료' if env_ok else '❌ 실패'}")
    print(f"⚙️ 설정 검증: {'✅ 완료' if config_ok else '❌ 실패'}")
    print(f"🤖 API 테스트: {'✅ 완료' if api_ok else '❌ 실패'}")
    
    if packages_ok and env_ok and config_ok and api_ok:
        print("\n🎉 모든 테스트가 성공적으로 완료되었습니다!")
        print("이제 Flutter 앱에서 AI 기능을 사용할 수 있습니다.")
        show_next_steps()
    else:
        print("\n⚠️ 일부 테스트가 실패했습니다.")
        print("위의 오류 메시지를 확인하고 문제를 해결해주세요.")
        
        if not api_ok and packages_ok and env_ok and config_ok:
            print("\n💡 API 테스트 실패 원인:")
            print("1. Roboflow 모델이 아직 훈련 중일 수 있습니다")
            print("2. API 키나 프로젝트 설정이 올바르지 않을 수 있습니다")
            print("3. 인터넷 연결 상태를 확인해주세요")

if __name__ == "__main__":
    main()
