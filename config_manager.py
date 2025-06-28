#!/usr/bin/env python3
"""
전북 현장 보고 시스템 - Roboflow 설정 관리
환경변수와 설정 파일을 통한 안전한 설정 관리
"""

import os
from typing import Dict, Optional
from dataclasses import dataclass
from pathlib import Path

@dataclass
class RoboflowConfig:
    """Roboflow 설정 클래스"""
    api_key: str
    workspace_id: str
    project_id: str
    model_version: int
    confidence_threshold: int
    overlap_threshold: int
    max_file_size_mb: int

@dataclass
class BackendConfig:
    """백엔드 설정 클래스"""
    url: str
    api_key: str

@dataclass
class AppConfig:
    """전체 애플리케이션 설정"""
    roboflow: RoboflowConfig
    backend: BackendConfig
    test_mode: bool
    enable_mock_data: bool
    log_level: str

class ConfigManager:
    """설정 관리자"""
    
    def __init__(self, env_file: Optional[str] = None):
        """초기화"""
        self.env_file = env_file or ".env"
        self._load_env_file()
        
    def _load_env_file(self):
        """환경 파일 로드"""
        env_path = Path(self.env_file)
        if env_path.exists():
            try:
                with open(env_path, 'r', encoding='utf-8') as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith('#') and '=' in line:
                            key, value = line.split('=', 1)
                            os.environ[key.strip()] = value.strip()
            except Exception as e:
                print(f"⚠️ 환경 파일 로드 실패: {e}")
    
    def get_config(self) -> AppConfig:
        """설정 정보 반환"""
        # Roboflow 설정
        roboflow_config = RoboflowConfig(
            api_key=os.getenv('ROBOFLOW_API_KEY', 'your_private_api_key_here'),
            workspace_id=os.getenv('ROBOFLOW_WORKSPACE', 'jeonbuk-reports'),
            project_id=os.getenv('ROBOFLOW_PROJECT', 'integrated-detection'),
            model_version=int(os.getenv('ROBOFLOW_VERSION', '1')),
            confidence_threshold=int(os.getenv('CONFIDENCE_THRESHOLD', '50')),
            overlap_threshold=int(os.getenv('OVERLAP_THRESHOLD', '30')),
            max_file_size_mb=int(os.getenv('MAX_FILE_SIZE_MB', '10'))
        )
        
        # 백엔드 설정
        backend_config = BackendConfig(
            url=os.getenv('BACKEND_URL', 'http://localhost:8080'),
            api_key=os.getenv('BACKEND_API_KEY', 'your_backend_api_key')
        )
        
        # 애플리케이션 설정
        return AppConfig(
            roboflow=roboflow_config,
            backend=backend_config,
            test_mode=os.getenv('TEST_MODE', 'true').lower() == 'true',
            enable_mock_data=os.getenv('ENABLE_MOCK_DATA', 'true').lower() == 'true',
            log_level=os.getenv('LOG_LEVEL', 'INFO')
        )
    
    def validate_config(self, config: AppConfig) -> bool:
        """설정 유효성 검사"""
        errors = []
        
        # API 키 검사
        if (config.roboflow.api_key == 'your_private_api_key_here' or 
            len(config.roboflow.api_key) < 10):
            errors.append("❌ Roboflow API 키가 설정되지 않았습니다")
        
        # 워크스페이스 ID 검사
        if not config.roboflow.workspace_id:
            errors.append("❌ Roboflow 워크스페이스 ID가 필요합니다")
        
        # 프로젝트 ID 검사
        if not config.roboflow.project_id:
            errors.append("❌ Roboflow 프로젝트 ID가 필요합니다")
        
        # 임계값 범위 검사
        if not (0 <= config.roboflow.confidence_threshold <= 100):
            errors.append("❌ 신뢰도 임계값은 0-100 사이여야 합니다")
        
        if not (0 <= config.roboflow.overlap_threshold <= 100):
            errors.append("❌ 겹침 임계값은 0-100 사이여야 합니다")
        
        if errors:
            print("🔧 설정 오류 발견:")
            for error in errors:
                print(f"  {error}")
            print("\n💡 해결 방법:")
            print("  1. .env 파일을 생성하고 실제 값으로 설정")
            print("  2. 환경변수로 직접 설정")
            print("  3. .env.example 파일을 참조하여 올바른 형식 확인")
            return False
        
        return True
    
    def print_config_status(self, config: AppConfig):
        """설정 상태 출력"""
        print("🔧 현재 설정 상태:")
        print(f"  📁 워크스페이스: {config.roboflow.workspace_id}")
        print(f"  📦 프로젝트: {config.roboflow.project_id}")
        print(f"  🔢 모델 버전: {config.roboflow.model_version}")
        print(f"  🎯 신뢰도 임계값: {config.roboflow.confidence_threshold}%")
        print(f"  📊 겹침 임계값: {config.roboflow.overlap_threshold}%")
        print(f"  🔐 API 키: {'✅ 설정됨' if self._is_api_key_valid(config.roboflow.api_key) else '❌ 미설정'}")
        print(f"  🧪 테스트 모드: {'✅ 활성화' if config.test_mode else '❌ 비활성화'}")
        print(f"  🎭 모의 데이터: {'✅ 활성화' if config.enable_mock_data else '❌ 비활성화'}")
    
    def _is_api_key_valid(self, api_key: str) -> bool:
        """API 키 유효성 간단 확인"""
        return (api_key != 'your_private_api_key_here' and 
                len(api_key) > 10 and 
                api_key.strip() != '')

def load_config(env_file: Optional[str] = None) -> AppConfig:
    """설정 로드 헬퍼 함수"""
    manager = ConfigManager(env_file)
    config = manager.get_config()
    
    if not manager.validate_config(config):
        raise ValueError("설정 검증 실패")
    
    return config

if __name__ == "__main__":
    """설정 테스트"""
    print("🔧 Roboflow 설정 관리자 테스트")
    print("=" * 50)
    
    try:
        manager = ConfigManager()
        config = manager.get_config()
        
        manager.print_config_status(config)
        
        if manager.validate_config(config):
            print("\n✅ 설정이 올바르게 구성되었습니다!")
        else:
            print("\n❌ 설정에 문제가 있습니다.")
            
    except Exception as e:
        print(f"❌ 설정 로드 실패: {e}")
