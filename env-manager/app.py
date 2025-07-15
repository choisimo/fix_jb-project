from flask import Flask, render_template, request, redirect, jsonify, flash
import os
import yaml
import json
import docker
import re
from collections import OrderedDict
import logging
import subprocess
import urllib3
import requests
from urllib.parse import urlparse

# PostgreSQL과 Redis는 선택적 import (없어도 기본 기능은 동작)
try:
    import psycopg2
    PSYCOPG2_AVAILABLE = True
except ImportError:
    PSYCOPG2_AVAILABLE = False
    logger.warning("psycopg2를 찾을 수 없습니다. 데이터베이스 연결 테스트를 사용할 수 없습니다.")

try:
    import redis as redis_client
    REDIS_AVAILABLE = True
except ImportError:
    REDIS_AVAILABLE = False
    logger.warning("redis를 찾을 수 없습니다. Redis 연결 테스트를 사용할 수 없습니다.")

app = Flask(__name__, template_folder='app/templates', static_folder='app/static')
app.secret_key = 'env-manager-secret-key'

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Docker 클라이언트 초기화
try:
    # Docker 소켓 경로 확인
    import os
    socket_path = '/var/run/docker.sock'
    if os.path.exists(socket_path):
        # Docker 그룹 권한 확인
        stat_info = os.stat(socket_path)
        logger.info(f"Docker 소켓 정보: uid={stat_info.st_uid}, gid={stat_info.st_gid}, mode={oct(stat_info.st_mode)}")
        
        # 여러 연결 방법 시도
        try:
            client = docker.DockerClient(base_url='unix:///var/run/docker.sock')
            client.ping()
            logger.info("Docker 클라이언트 연결 성공 (unix socket)")
        except Exception as e1:
            logger.warning(f"Unix socket 연결 실패: {e1}")
            try:
                # 대안: TCP 연결 시도 (Docker daemon이 TCP로 노출된 경우)
                client = docker.from_env()
                client.ping()
                logger.info("Docker 클라이언트 연결 성공 (from_env)")
            except Exception as e2:
                logger.warning(f"from_env 연결도 실패: {e2}")
                # 마지막으로 docker 명령어 직접 실행으로 대체
                client = None
    else:
        logger.warning(f"Docker 소켓을 찾을 수 없습니다: {socket_path}")
        client = None
except Exception as e:
    logger.warning(f"Docker 클라이언트 초기화 실패: {e}")
    client = None

# 도커 네트워크 기반 자동 환경변수 설정
DOCKER_NETWORK_ENV_MAP = {
    'postgres-main': {
        'service_name': 'postgres-main',
        'default_port': 5432,
        'env_vars': {
            'DB_HOST': 'postgres-main',
            'DATABASE_HOST': 'postgres-main',
            'POSTGRES_HOST': 'postgres-main'
        }
    },
    'postgres-ai': {
        'service_name': 'postgres-ai', 
        'default_port': 5432,
        'env_vars': {
            'AI_DB_HOST': 'postgres-ai',
            'AI_DATABASE_HOST': 'postgres-ai'
        }
    },
    'redis': {
        'service_name': 'redis',
        'default_port': 6379,
        'env_vars': {
            'REDIS_HOST': 'redis',
            'CACHE_HOST': 'redis'
        }
    },
    'kafka': {
        'service_name': 'kafka',
        'default_port': 29092,
        'env_vars': {
            'KAFKA_HOST': 'kafka:29092',
            'KAFKA_BOOTSTRAP_SERVERS': 'kafka:29092'
        }
    },
    'elasticsearch': {
        'service_name': 'elasticsearch',
        'default_port': 9200,
        'env_vars': {
            'ELASTICSEARCH_HOST': 'elasticsearch',
            'ES_HOST': 'elasticsearch:9200'
        }
    },
    'keycloak': {
        'service_name': 'keycloak',
        'default_port': 8080,
        'env_vars': {
            'KEYCLOAK_HOST': 'keycloak:8080',
            'AUTH_SERVER_URL': 'http://keycloak:8080'
        }
    },
    'main-api-server': {
        'service_name': 'main-api-server',
        'default_port': 8080,
        'env_vars': {
            'MAIN_API_HOST': 'main-api-server:8080',
            'API_SERVICE_URL': 'http://main-api-server:8080'
        }
    },
    'ai-analysis-server': {
        'service_name': 'ai-analysis-server',
        'default_port': 8086,
        'env_vars': {
            'AI_SERVICE_HOST': 'ai-analysis-server:8086',
            'AI_SERVICE_URL': 'http://ai-analysis-server:8086'
        }
    },
    'file-server': {
        'service_name': 'file-server',
        'default_port': 12020,
        'env_vars': {
            'FILE_SERVER_HOST': 'file-server:12020',
            'FILE_SERVICE_URL': 'http://file-server:12020'
        }
    }
}

# 환경변수 파일 설정
ENV_FILES_CONFIG = {
    'domain-config': {
        'path': '/app/data/domain-config.json',
        'display_name': '🌐 도메인 통합 관리',
        'format': 'json',
        'service': 'global'
    },
    'main-env': {
        'path': '/app/data/.env',
        'display_name': '메인 환경변수',
        'format': 'dotenv',
        'service': 'main-api-server'
    },
    'main-api-server': {
        'path': '/app/data/main-api-server/.env',
        'display_name': 'Main API Server',
        'format': 'dotenv',
        'service': 'main-api-server'
    },
    'main-api-yml': {
        'path': '/app/data/main-api-server/application.yml',
        'display_name': 'Main API YAML 설정',
        'format': 'yaml',
        'service': 'main-api-server'
    },
    'ai-analysis-server': {
        'path': '/app/data/ai-analysis-server/.env',
        'display_name': 'AI Analysis Server',
        'format': 'dotenv',
        'service': 'ai-analysis-server'
    },
    'ai-analysis-yml': {
        'path': '/app/data/ai-analysis-server/application.yml',
        'display_name': 'AI Analysis YAML 설정',
        'format': 'yaml',
        'service': 'ai-analysis-server'
    },
    # Flutter 앱 환경변수 추가
    'flutter-app-dev': {
        'path': '/app/data/flutter-app/env.development.json',
        'display_name': 'Flutter 앱 (Development)',
        'format': 'json',
        'service': 'flutter-app'
    },
    'flutter-app-staging': {
        'path': '/app/data/flutter-app/env.staging.json',
        'display_name': 'Flutter 앱 (Staging)',
        'format': 'json',
        'service': 'flutter-app'
    },
    'flutter-app-prod': {
        'path': '/app/data/flutter-app/env.production.json',
        'display_name': 'Flutter 앱 (Production)',
        'format': 'json',
        'service': 'flutter-app'
    }
}

# 중복 환경변수 키 통합 관리
GLOBAL_ENV_KEYS = {
    'DATABASE_URL': {
        'description': 'PostgreSQL 메인 데이터베이스 연결 URL',
        'dummy_value': 'jdbc:postgresql://postgres-main:5432/jb_reports?user=jb_user&password=jb_password',
        'required': True,
        'used_by': ['main-api-server'],
        'primary_service': 'main-api-server'
    },
    'AI_DATABASE_URL': {
        'description': 'PostgreSQL AI 데이터베이스 연결 URL',
        'dummy_value': 'jdbc:postgresql://postgres-ai:5432/ai_analysis?user=ai_user&password=ai_password',
        'required': True,
        'used_by': ['ai-analysis-server'],
        'primary_service': 'ai-analysis-server'
    },
    'JWT_SECRET': {
        'description': 'JWT 토큰 서명을 위한 비밀키 (최소 32자)',
        'dummy_value': 'your-super-secret-jwt-key-min-32-chars',
        'required': True,
        'used_by': ['main-api-server', 'ai-analysis-server'],
        'primary_service': 'main-api-server'
    },
    'REDIS_HOST': {
        'description': 'Redis 호스트 (도커 네트워크)',
        'dummy_value': 'redis',
        'required': False,
        'used_by': ['main-api-server', 'ai-analysis-server'],
        'primary_service': 'main-api-server'
    },
    'REDIS_URL': {
        'description': 'Redis 캐시 서버 전체 URL',
        'dummy_value': 'redis://redis:6379/0',
        'required': False,
        'used_by': ['main-api-server'],
        'primary_service': 'main-api-server'
    },
    'naverMapClientId': {
        'description': 'Naver Cloud Platform에서 발급받은 지도 클라이언트 ID',
        'dummy_value': 'your_naver_map_client_id_here',
        'required': True,
        'used_by': ['flutter-app-dev', 'flutter-app-staging', 'flutter-app-prod'],
        'primary_service': 'flutter-app-dev'
    },
    'ROBOFLOW_API_KEY': {
        'description': 'Roboflow에서 발급받은 API 키',
        'dummy_value': 'your_roboflow_api_key_here',
        'required': True,
        'used_by': ['ai-analysis-server'],
        'primary_service': 'ai-analysis-server'
    }
}

# 필수 필드 및 더미값 가이드 설정
FIELD_METADATA = {
    'domain-config': {
        'required_fields': ['domains.development.api_domain', 'domains.staging.api_domain', 'domains.production.api_domain'],
        'dummy_values': {
            'domains.development.api_domain': 'localhost:8080',
            'domains.development.file_domain': 'localhost:12020', 
            'domains.development.ai_domain': 'localhost:8086',
            'domains.staging.api_domain': 'staging-api.yourcompany.com',
            'domains.staging.file_domain': 'staging-file.yourcompany.com',
            'domains.staging.ai_domain': 'staging-ai.yourcompany.com',
            'domains.production.api_domain': 'api.yourcompany.com',
            'domains.production.file_domain': 'file.yourcompany.com',
            'domains.production.ai_domain': 'ai.yourcompany.com'
        },
        'descriptions': {
            'domains.development.api_domain': '개발환경 API 서버 도메인 (포트 포함)',
            'domains.development.file_domain': '개발환경 파일 서버 도메인 (포트 포함)',
            'domains.development.ai_domain': '개발환경 AI 서버 도메인 (포트 포함)',
            'domains.staging.api_domain': '스테이징 API 서버 도메인',
            'domains.staging.file_domain': '스테이징 파일 서버 도메인',
            'domains.staging.ai_domain': '스테이징 AI 서버 도메인',
            'domains.production.api_domain': '운영환경 API 서버 도메인',
            'domains.production.file_domain': '운영환경 파일 서버 도메인',
            'domains.production.ai_domain': '운영환경 AI 서버 도메인',
            'global_settings.base_domain': '기본 도메인 설정',
            'global_settings.api_path': 'API 경로 (기본: /api/v1)',
            'global_settings.ai_path': 'AI API 경로 (기본: /api/v1)'
        }
    },
    'flutter-app-dev': {
        'required_fields': ['naverMapClientId', 'mainApiBaseUrl'],
        'dummy_values': {
            'mainApiBaseUrl': 'http://localhost:8080/api/v1',
            'fileServerUrl': 'http://localhost:12020',
            'aiServerUrl': 'http://localhost:8086/api/v1'
        },
        'descriptions': {
            'mainApiBaseUrl': '메인 API 서버 주소',
            'enableAnalytics': '구글 애널리틱스 활성화 여부'
        }
    },
    'flutter-app-staging': {
        'required_fields': ['naverMapClientId', 'mainApiBaseUrl'],
        'dummy_values': {
            'mainApiBaseUrl': 'https://staging-api.yourcompany.com/api/v1'
        }
    },
    'flutter-app-prod': {
        'required_fields': ['naverMapClientId', 'mainApiBaseUrl'],
        'dummy_values': {
            'mainApiBaseUrl': 'https://api.yourcompany.com/api/v1'
        }
    },
    'main-api-server': {
        'required_fields': ['DATABASE_URL', 'JWT_SECRET'],
        'dummy_values': {
            'MAIL_HOST': 'smtp.gmail.com',
            'MAIL_USERNAME': 'your-email@gmail.com',
            'MAIL_PASSWORD': 'your-app-password',
            # 도커 네트워크 기반 자동 환경변수들
            'DB_HOST': 'postgres-main',
            'DB_PORT': '5432',
            'DB_NAME': 'jb_reports',
            'DB_USERNAME': 'jb_user',
            'DB_PASSWORD': 'jb_password',
            'AI_SERVICE_URL': 'http://ai-analysis-server:8086',
            'FILE_SERVICE_URL': 'http://file-server:12020'
        },
        'descriptions': {
            'MAIL_HOST': '이메일 서버 호스트',
            'MAIL_USERNAME': '이메일 사용자명',
            'MAIL_PASSWORD': '이메일 비밀번호',
            'DB_HOST': '메인 데이터베이스 호스트명',
            'DB_PORT': '메인 데이터베이스 포트',
            'DB_NAME': '메인 데이터베이스명 (jb_reports)',
            'DB_USERNAME': '메인 데이터베이스 사용자명 (jb_user)',
            'DB_PASSWORD': '메인 데이터베이스 비밀번호',
            'AI_SERVICE_URL': 'AI 분석 서비스 URL (포트 8086)',
            'FILE_SERVICE_URL': '파일 서버 URL (포트 12020)'
        }
    },
    'ai-analysis-server': {
        'required_fields': ['ROBOFLOW_API_KEY', 'AI_DATABASE_URL'],
        'dummy_values': {
            'ROBOFLOW_WORKSPACE_URL': 'https://detect.roboflow.com/your-workspace/version',
            'GOOGLE_APPLICATION_CREDENTIALS': '/path/to/google-cloud-credentials.json',
            # 도커 네트워크 기반 자동 환경변수들
            'AI_DB_HOST': 'postgres-ai',
            'AI_DB_PORT': '5432',
            'AI_DB_NAME': 'ai_analysis',
            'AI_DB_USERNAME': 'ai_user',
            'AI_DB_PASSWORD': 'ai_password',
            'MAIN_API_URL': 'http://main-api-server:8080',
            'FILE_SERVICE_URL': 'http://file-server:12020'
        },
        'descriptions': {
            'ROBOFLOW_WORKSPACE_URL': 'Roboflow 워크스페이스 URL',
            'GOOGLE_APPLICATION_CREDENTIALS': 'Google Cloud Vision API 인증 파일 경로',
            'AI_DB_HOST': 'AI 데이터베이스 호스트명',
            'AI_DB_PORT': 'AI 데이터베이스 포트',
            'AI_DB_NAME': 'AI 데이터베이스명 (ai_analysis)',
            'AI_DB_USERNAME': 'AI 데이터베이스 사용자명 (ai_user)',
            'AI_DB_PASSWORD': 'AI 데이터베이스 비밀번호',
            'MAIN_API_URL': '메인 API 서버 URL (포트 8080)',
            'FILE_SERVICE_URL': '파일 서버 URL (포트 12020)'
        }
    }
}

def parse_dotenv(file_path):
    """dotenv 파일 파싱"""
    env_data = OrderedDict()
    if not os.path.exists(file_path):
        return env_data
    
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()
            
        current_section = "기본 설정"
        env_data[current_section] = OrderedDict()
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
            
            # 섹션 주석 처리
            if line.startswith('# ====='):
                continue
            elif line.startswith('#') and '=' not in line:
                # 새 섹션
                section_name = line.replace('#', '').strip()
                if section_name and section_name != '=':
                    current_section = section_name
                    env_data[current_section] = OrderedDict()
                continue
            elif line.startswith('#'):
                # 인라인 주석은 건너뛰기
                continue
            
            if '=' in line:
                key, value = line.split('=', 1)
                env_data[current_section][key] = value
    
    except Exception as e:
        logger.error(f"dotenv 파일 파싱 오류: {e}")
        env_data["오류"] = {"error": str(e)}
    
    return env_data

def get_global_env_value(key):
    """글로벌 환경변수의 현재 값을 가져오기 (primary service에서)"""
    if key not in GLOBAL_ENV_KEYS:
        return None
    
    global_config = GLOBAL_ENV_KEYS[key]
    primary_service = global_config['primary_service']
    
    try:
        config = ENV_FILES_CONFIG.get(primary_service)
        if not config:
            return None
        
        file_path = config['path']
        file_format = config['format']
        
        if file_format == 'json':
            data = parse_json(file_path)
            return data.get(key)
        else:  # dotenv
            data = parse_dotenv(file_path)
            for section in data.values():
                if key in section:
                    return section[key]
    except Exception as e:
        logger.error(f"글로벌 환경변수 값 가져오기 오류 ({key}): {e}")
    
    return None

def set_global_env_value(key, value):
    """글로벌 환경변수 값을 모든 관련 서비스에 동기화"""
    if key not in GLOBAL_ENV_KEYS:
        return False
    
    global_config = GLOBAL_ENV_KEYS[key]
    used_by_services = global_config['used_by']
    success_count = 0
    
    for service_id in used_by_services:
        try:
            config = ENV_FILES_CONFIG.get(service_id)
            if not config:
                continue
            
            file_path = config['path']
            file_format = config['format']
            
            if file_format == 'json':
                data = parse_json(file_path)
                data[key] = value
                if save_json(file_path, data):
                    success_count += 1
                    logger.info(f"글로벌 환경변수 동기화: {service_id}.{key} = {value}")
            else:  # dotenv
                data = parse_dotenv(file_path)
                
                # 기존 섹션에서 키를 찾아 업데이트
                found = False
                for section in data:
                    if key in data[section]:
                        data[section][key] = value
                        found = True
                        break
                
                # 새 키는 기본 설정에 추가
                if not found:
                    if "기본 설정" not in data:
                        data["기본 설정"] = OrderedDict()
                    data["기본 설정"][key] = value
                
                if save_dotenv(file_path, data):
                    success_count += 1
                    logger.info(f"글로벌 환경변수 동기화: {service_id}.{key} = {value}")
                    
        except Exception as e:
            logger.error(f"글로벌 환경변수 동기화 오류 ({service_id}.{key}): {e}")
    
    return success_count > 0

def is_global_env_key(key):
    """글로벌 환경변수인지 확인"""
    return key in GLOBAL_ENV_KEYS

def get_global_env_info(key):
    """글로벌 환경변수 정보 가져오기"""
    return GLOBAL_ENV_KEYS.get(key, {})

def is_required_field(service_id, field_key):
    """필수 필드인지 확인 (글로벌 키 우선 검사)"""
    # 글로벌 환경변수인 경우
    if is_global_env_key(field_key):
        global_info = get_global_env_info(field_key)
        return global_info.get('required', False)
    
    # 서비스별 환경변수인 경우
    metadata = FIELD_METADATA.get(service_id, {})
    required_fields = metadata.get('required_fields', [])
    return field_key in required_fields

def get_dummy_value(service_id, field_key):
    """더미값 가져오기 (글로벌 키 우선 검사)"""
    # 글로벌 환경변수인 경우
    if is_global_env_key(field_key):
        global_info = get_global_env_info(field_key)
        return global_info.get('dummy_value', '')
    
    # 서비스별 환경변수인 경우
    metadata = FIELD_METADATA.get(service_id, {})
    dummy_values = metadata.get('dummy_values', {})
    return dummy_values.get(field_key, '')

def get_field_description(service_id, field_key):
    """필드 설명 가져오기 (글로벌 키 우선 검사)"""
    # 글로벌 환경변수인 경우
    if is_global_env_key(field_key):
        global_info = get_global_env_info(field_key)
        description = global_info.get('description', '')
        used_by = global_info.get('used_by', [])
        primary = global_info.get('primary_service', '')
        
        if len(used_by) > 1:
            description += f" (통합관리: {', '.join(used_by)} / 기준: {primary})"
        
        return description
    
    # 서비스별 환경변수인 경우
    metadata = FIELD_METADATA.get(service_id, {})
    descriptions = metadata.get('descriptions', {})
    return descriptions.get(field_key, '')

def is_dummy_value(value):
    """더미값인지 확인"""
    dummy_indicators = [
        'your_', 'YOUR_', 'your-', 'YOUR-',
        'localhost', '127.0.0.1', 
        'example.com', 'yourcompany.com',
        'your-super-secret', 'change-me',
        'put-your-', 'enter-your-'
    ]
    
    if not value or not isinstance(value, str):
        return False
        
    return any(indicator in value for indicator in dummy_indicators)

def save_dotenv(file_path, env_data):
    """dotenv 파일 저장"""
    try:
        lines = []
        for section, variables in env_data.items():
            if section != "기본 설정":
                lines.append(f"# {section}")
            
            for key, value in variables.items():
                if key != "error":
                    lines.append(f"{key}={value}")
            
            lines.append("")  # 빈 줄 추가
        
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write('\n'.join(lines))
        return True
    except Exception as e:
        logger.error(f"dotenv 파일 저장 오류: {e}")
        return False

def parse_yaml(file_path):
    """YAML 파일 파싱"""
    if not os.path.exists(file_path):
        return {}
    
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
            # 여러 문서가 있는 경우 첫 번째 문서만 사용
            if '---' in content:
                documents = content.split('---')
                for doc in documents:
                    doc = doc.strip()
                    if doc:
                        return yaml.safe_load(doc) or {}
            else:
                return yaml.safe_load(content) or {}
    except Exception as e:
        logger.error(f"YAML 파일 파싱 오류: {e}")
        return {"error": str(e)}

def save_yaml(file_path, yaml_data):
    """YAML 파일 저장"""
    try:
        # YAML 파일 저장
        with open(file_path, 'w', encoding='utf-8') as file:
            yaml.safe_dump(yaml_data, file, default_flow_style=False, allow_unicode=True)
        return True
    except Exception as e:
        logger.error(f"YAML 파일 저장 오류: {e}")
        return False

def parse_json(file_path):
    """JSON 파일 파싱"""
    if not os.path.exists(file_path):
        # 기본 JSON 구조 생성
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        return {}
    
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return json.load(file)
    except Exception as e:
        logger.error(f"JSON 파일 파싱 오류: {e}")
        return {"error": str(e)}

def save_json(file_path, json_data):
    """JSON 파일 저장"""
    try:
        # 디렉토리가 없으면 생성
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        
        # JSON 파일 저장
        with open(file_path, 'w', encoding='utf-8') as file:
            json.dump(json_data, file, indent=2, ensure_ascii=False)
        return True
    except Exception as e:
        logger.error(f"JSON 파일 저장 오류: {e}")
        return False

def flatten_dict(d, parent_key='', sep='.'):
    """중첩된 딕셔너리를 평면화"""
    items = []
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten_dict(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)

def get_docker_network_env_vars():
    """도커 네트워크에서 자동으로 생성할 환경변수들을 반환"""
    # Docker 클라이언트가 없어도 정적으로 네트워크 환경변수 제공
    network_vars = {}
    
    # 표준 도커 컴포즈 네트워크 설정 기반으로 정적 환경변수 생성
    static_network_vars = {
        'DB_HOST': 'postgres-main',
        'DB_PORT': '5432',
        'DB_NAME': 'jb_reports',
        'DB_USERNAME': 'jb_user',
        'DB_PASSWORD': 'jb_password',
        'REDIS_HOST': 'redis',
        'REDIS_PORT': '6379',
        'AI_SERVICE_URL': 'http://ai-analysis-server:8086',
        'FILE_SERVICE_URL': 'http://file-server:12020',
        'AI_DB_HOST': 'postgres-ai',
        'AI_DB_PORT': '5432', 
        'AI_DB_NAME': 'ai_analysis',
        'AI_DB_USERNAME': 'ai_user',
        'AI_DB_PASSWORD': 'ai_password',
        'MAIN_API_URL': 'http://main-api-server:8080',
        'KAFKA_HOST': 'kafka:29092',
        'KAFKA_BOOTSTRAP_SERVERS': 'kafka:29092',
        'ELASTICSEARCH_HOST': 'elasticsearch',
        'ES_HOST': 'elasticsearch:9200',
        'KEYCLOAK_HOST': 'keycloak:8080',
        'AUTH_SERVER_URL': 'http://keycloak:8080'
    }
    
    if client:
        try:
            # 실행 중인 컨테이너 목록 가져오기
            containers = client.containers.list()
            running_services = {container.name for container in containers}
            
            # 정의된 서비스들에 대해 환경변수 생성
            for service_key, service_info in DOCKER_NETWORK_ENV_MAP.items():
                service_name = service_info['service_name']
                
                # 서비스가 실행 중인 경우에만 환경변수 추가
                if service_name in running_services:
                    for env_key, env_value in service_info['env_vars'].items():
                        network_vars[env_key] = env_value
                    logger.info(f"도커 네트워크 환경변수 추가: {service_name}")
                else:
                    logger.debug(f"서비스가 실행 중이 아님: {service_name}")
                    
        except Exception as e:
            logger.error(f"도커 네트워크 환경변수 생성 오류: {e}")
    else:
        # Docker 클라이언트가 없으면 정적 환경변수 사용
        logger.info("Docker 클라이언트 없음. 정적 네트워크 환경변수 사용")
        network_vars = static_network_vars
    
    return network_vars

def update_env_with_docker_network_vars(service_id, env_data):
    """환경변수에 도커 네트워크 기반 변수들을 자동으로 추가/업데이트"""
    if service_id not in ['main-api-server', 'ai-analysis-server']:
        return env_data
    
    network_vars = get_docker_network_env_vars()
    
    if not network_vars:
        return env_data
    
    try:
        if isinstance(env_data, dict):
            # dotenv 형식
            if "기본 설정" not in env_data:
                env_data["기본 설정"] = OrderedDict()
            
            # 네트워크 환경변수 섹션 생성
            if "Docker 네트워크 자동설정" not in env_data:
                env_data["Docker 네트워크 자동설정"] = OrderedDict()
            
            # 관련 네트워크 환경변수만 추가
            service_related_vars = []
            if service_id == 'main-api-server':
                service_related_vars = ['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USERNAME', 'DB_PASSWORD', 'REDIS_HOST', 'REDIS_PORT', 'AI_SERVICE_URL', 'FILE_SERVICE_URL']
            elif service_id == 'ai-analysis-server':
                service_related_vars = ['AI_DB_HOST', 'AI_DB_PORT', 'AI_DB_NAME', 'AI_DB_USERNAME', 'AI_DB_PASSWORD', 'REDIS_HOST', 'REDIS_PORT', 'MAIN_API_URL', 'FILE_SERVICE_URL']
            
            for var_name in service_related_vars:
                if var_name in network_vars:
                    env_data["Docker 네트워크 자동설정"][var_name] = network_vars[var_name]
                    logger.info(f"자동 추가된 네트워크 환경변수: {var_name}={network_vars[var_name]}")
        
        return env_data
    except Exception as e:
        logger.error(f"도커 네트워크 환경변수 업데이트 오류: {e}")
        return env_data

def unflatten_dict(flat_dict, sep='.'):
    """평면화된 딕셔너리를 중첩 구조로 복원"""
    result = {}
    for key, value in flat_dict.items():
        parts = key.split(sep)
        d = result
        for part in parts[:-1]:
            if part not in d:
                d[part] = {}
            d = d[part]
        d[parts[-1]] = value
    return result

def create_default_domain_config():
    """기본 도메인 설정 생성"""
    return {
        "domains": {
            "development": {
                "display_name": "Development (로컬)",
                "api_domain": "localhost:8080",
                "file_domain": "localhost:12020",
                "ai_domain": "localhost:8083",
                "protocol": "http"
            },
            "staging": {
                "display_name": "Staging (스테이징)",
                "api_domain": "staging-api.yourcompany.com",
                "file_domain": "staging-file.yourcompany.com",
                "ai_domain": "staging-ai.yourcompany.com",
                "protocol": "https"
            },
            "production": {
                "display_name": "Production (운영)",
                "api_domain": "api.yourcompany.com",
                "file_domain": "file.yourcompany.com",
                "ai_domain": "ai.yourcompany.com",
                "protocol": "https"
            }
        },
        "global_settings": {
            "base_domain": "yourcompany.com",
            "api_path": "/api/v1",
            "ai_path": "/api/v1"
        }
    }

@app.route('/')
def dashboard():
    """메인 대시보드"""
    all_envs = {}
    
    for service_id, config in ENV_FILES_CONFIG.items():
        file_path = config['path']
        file_format = config['format']
        display_name = config['display_name']
        
        if file_format == 'yaml':
            env_data = parse_yaml(file_path)
            # YAML을 평면화하여 표시
            if isinstance(env_data, dict) and "error" not in env_data:
                flat_data = flatten_dict(env_data)
                all_envs[service_id] = {
                    'data': flat_data,
                    'display_name': display_name,
                    'format': file_format,
                    'exists': True
                }
            else:
                all_envs[service_id] = {
                    'data': env_data,
                    'display_name': display_name,
                    'format': file_format,
                    'exists': False
                }
        elif file_format == 'json':
            env_data = parse_json(file_path)
            
            # 도메인 설정이 없으면 기본값 생성
            if service_id == 'domain-config' and not env_data:
                env_data = create_default_domain_config()
                save_json(file_path, env_data)
                logger.info("기본 도메인 설정이 생성되었습니다.")
            
            # JSON을 평면화하여 표시
            if isinstance(env_data, dict) and "error" not in env_data:
                flat_data = flatten_dict(env_data)
                all_envs[service_id] = {
                    'data': flat_data,
                    'display_name': display_name,
                    'format': file_format,
                    'exists': True
                }
            else:
                all_envs[service_id] = {
                    'data': env_data,
                    'display_name': display_name,
                    'format': file_format,
                    'exists': False
                }
        else:  # dotenv
            env_data = parse_dotenv(file_path)
            
            # 도커 네트워크 환경변수 자동 추가
            if service_id in ['main-api-server', 'ai-analysis-server']:
                env_data = update_env_with_docker_network_vars(service_id, env_data)
            
            all_envs[service_id] = {
                'data': env_data,
                'display_name': display_name,
                'format': file_format,
                'exists': os.path.exists(file_path)
            }
    
    return render_template('dashboard.html', 
                          services=all_envs, 
                          field_metadata=FIELD_METADATA,
                          global_env_keys=GLOBAL_ENV_KEYS,
                          is_required_field=is_required_field,
                          get_dummy_value=get_dummy_value,
                          get_field_description=get_field_description,
                          is_dummy_value=is_dummy_value,
                          is_global_env_key=is_global_env_key,
                          get_global_env_info=get_global_env_info,
                          get_global_env_value=get_global_env_value)

@app.route('/save', methods=['POST'])
def save():
    """환경변수 저장"""
    try:
        service_id = request.form.get('service')
        config = ENV_FILES_CONFIG.get(service_id)
        
        if not config:
            return jsonify({'status': 'error', 'message': '설정을 찾을 수 없습니다.'})
            
        file_path = config.get('path')
        file_format = config.get('format')
        
        if file_format == 'yaml':
            # YAML 형식 처리
            existing_data = parse_yaml(file_path)
            
            # 평면화된 폼 데이터 처리
            flat_data = {}
            for key, value in request.form.items():
                if key.startswith(f'{service_id}_') and key != 'service':
                    flat_data[key.replace(f'{service_id}_', '')] = value
            
            # 중첩된 구조로 변환
            nested_data = unflatten_dict(flat_data)
            
            # 기존 데이터 업데이트
            if isinstance(existing_data, dict):
                for k, v in nested_data.items():
                    existing_data[k] = v
            else:
                existing_data = nested_data
                
            success = save_yaml(file_path, existing_data)
        elif file_format == 'json':
            # JSON 형식 처리
            existing_data = parse_json(file_path)
            
            # 폼 데이터로 업데이트
            updated_data = {}
            global_keys_updated = []
            
            for key, value in request.form.items():
                if key.startswith(f'{service_id}_') and key != 'service':
                    env_key = key.replace(f'{service_id}_', '')
                    
                    # 글로벌 환경변수인지 확인
                    if is_global_env_key(env_key):
                        global_keys_updated.append((env_key, value))
                        # 글로벌 키도 현재 서비스에 저장하기 위해 updated_data에 추가
                        updated_data[env_key] = value
                    else:
                        updated_data[env_key] = value
            
            # 기존 데이터 업데이트 (기존 데이터가 없으면 새로 생성)
            if not existing_data:
                existing_data = {}
            
            # 중첩된 키 처리를 위한 unflatten_dict 사용
            for k, v in updated_data.items():
                # 중첩된 키인지 확인 (예: domains.development.api_domain)
                if '.' in k:
                    # unflatten을 위한 임시 딕셔너리 생성
                    temp_dict = {k: v}
                    nested_update = unflatten_dict(temp_dict)
                    
                    # 기존 데이터에 중첩된 업데이트 적용
                    def deep_update(base_dict, update_dict):
                        for key, value in update_dict.items():
                            if key in base_dict and isinstance(base_dict[key], dict) and isinstance(value, dict):
                                deep_update(base_dict[key], value)
                            else:
                                base_dict[key] = value
                    
                    deep_update(existing_data, nested_update)
                else:
                    # 평면 키 처리
                    # 타입 변환 처리 (문자열, 숫자, 불리언 등)
                    if v.lower() in ('true', 'yes', 'y', 'on'):
                        existing_data[k] = True
                    elif v.lower() in ('false', 'no', 'n', 'off'):
                        existing_data[k] = False
                    # 숫자 처리
                    elif v.isdigit():
                        existing_data[k] = int(v)
                    elif re.match(r'^-?\d+(\.\d+)?$', v):
                        existing_data[k] = float(v)
                    # 그 외는 문자열로 처리
                    else:
                        existing_data[k] = v
            
            # 글로벌 환경변수 다른 서비스들에 동기화
            for env_key, value in global_keys_updated:
                set_global_env_value(env_key, value)
            
            success = save_json(file_path, existing_data)
        else:
            # dotenv 형식 처리
            existing_data = parse_dotenv(file_path)
            
            # 폼 데이터로 업데이트
            global_keys_updated = []
            for key, value in request.form.items():
                if key.startswith(f'{service_id}_') and key != 'service':
                    env_key = key.replace(f'{service_id}_', '')
                    
                    # 글로벌 환경변수인지 확인
                    if is_global_env_key(env_key):
                        global_keys_updated.append((env_key, value))
                        # 글로벌 키는 나중에 일괄 처리
                        continue
                    
                    # 일반 환경변수 처리
                    # 섹션 찾기
                    found = False
                    for section in existing_data:
                        if env_key in existing_data[section]:
                            existing_data[section][env_key] = value
                            found = True
                            break
                    
                    # 새 변수는 기본 설정에 추가
                    if not found:
                        if "기본 설정" not in existing_data:
                            existing_data["기본 설정"] = OrderedDict()
                        existing_data["기본 설정"][env_key] = value
            
            # 글로벌 환경변수 동기화 처리
            for env_key, value in global_keys_updated:
                # 현재 서비스에도 업데이트
                found = False
                for section in existing_data:
                    if env_key in existing_data[section]:
                        existing_data[section][env_key] = value
                        found = True
                        break
                
                if not found:
                    if "기본 설정" not in existing_data:
                        existing_data["기본 설정"] = OrderedDict()
                    existing_data["기본 설정"][env_key] = value
                
                # 다른 관련 서비스들에도 동기화
                set_global_env_value(env_key, value)
            
            # 도커 네트워크 환경변수 자동 업데이트
            if service_id in ['main-api-server', 'ai-analysis-server']:
                existing_data = update_env_with_docker_network_vars(service_id, existing_data)
            
            success = save_dotenv(file_path, existing_data)
        
        if success:
            # 도메인 설정 변경 시 Flutter URL 자동 업데이트
            if service_id == 'domain-config':
                domain_data = parse_json(file_path)
                if update_flutter_urls_from_domain(domain_data):
                    logger.info("도메인 설정 변경으로 Flutter URL들이 자동 업데이트되었습니다.")
            
            # Docker 컨테이너 재시작 시도
            if client and config.get('service'):
                try:
                    containers = client.containers.list(filters={'name': config['service']})
                    for container in containers:
                        container.restart()
                except Exception as e:
                    logger.warning(f"컨테이너 재시작 실패: {e}")
            
            return jsonify({'status': 'success', 'message': '환경변수가 성공적으로 저장되었습니다.'})
        else:
            return jsonify({'status': 'error', 'message': '파일 저장에 실패했습니다.'})
            
    except Exception as e:
        logger.error(f"저장 중 오류: {e}")
        return jsonify({'status': 'error', 'message': str(e)})

@app.route('/restart', methods=['POST'])
def restart_service():
    """서비스 재시작"""
    service_id = request.form.get('service')
    config = ENV_FILES_CONFIG.get(service_id)
    
    if not config:
        return jsonify({'status': 'error', 'message': 'Service not found'})
    
    container_name = config.get('service')
    if not container_name:
        return jsonify({'status': 'error', 'message': '재시작할 서비스가 지정되지 않았습니다'})
    
    # Docker API 클라이언트 사용 시도
    if client:
        try:
            containers = client.containers.list(filters={'name': container_name})
            restarted = []
            for container in containers:
                container.restart()
                restarted.append(container.name)
            
            if restarted:
                return jsonify({'status': 'success', 'message': f'컨테이너가 재시작되었습니다: {", ".join(restarted)}'})
            else:
                return jsonify({'status': 'warning', 'message': f'실행 중인 {container_name} 컨테이너를 찾을 수 없습니다'})
                
        except Exception as e:
            logger.error(f"Docker API를 통한 재시작 실패: {str(e)}")
            # Docker API 실패 시 명령어로 대체
    
    # Docker CLI 명령어로 재시작 시도
    try:
        import subprocess
        result = subprocess.run(
            ['docker', 'restart', container_name], 
            capture_output=True, 
            text=True, 
            timeout=30
        )
        
        if result.returncode == 0:
            return jsonify({'status': 'success', 'message': f'컨테이너가 재시작되었습니다: {container_name}'})
        else:
            error_msg = result.stderr.strip() if result.stderr else '알 수 없는 오류'
            return jsonify({'status': 'error', 'message': f'재시작 실패: {error_msg}'})
            
    except subprocess.TimeoutExpired:
        return jsonify({'status': 'error', 'message': '재시작 명령이 시간 초과되었습니다'})
    except FileNotFoundError:
        return jsonify({'status': 'error', 'message': 'Docker 명령어를 찾을 수 없습니다'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': f'재시작 실패: {str(e)}'})

@app.route('/backup', methods=['POST'])
def backup():
    """환경변수 백업"""
    try:
        backup_data = {}
        for service_id, config in ENV_FILES_CONFIG.items():
            file_path = config['path']
            if os.path.exists(file_path):
                if config['format'] == 'yaml':
                    backup_data[service_id] = parse_yaml(file_path)
                else:
                    backup_data[service_id] = parse_dotenv(file_path)
        
        return jsonify({
            'status': 'success', 
            'data': backup_data,
            'message': '백업이 완료되었습니다'
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': f'백업 실패: {str(e)}'})

# Flutter 앱용 API 엔드포인트
@app.route('/api/env/<env_type>', methods=['GET'])
def get_flutter_env(env_type):
    """플러터 앱용 환경변수 API 엔드포인트
    
    env_type: 'development', 'staging', 'production' 중 하나
    """
    try:
        if env_type not in ['development', 'staging', 'production']:
            return jsonify({
                'status': 'error', 
                'message': '유효하지 않은 환경 유형입니다. development, staging, production 중 하나를 사용해주세요.'
            }), 400
        
        # 해당 환경에 대한 환경 변수 가져오기
        service_id = f'flutter-app-{env_type.lower()}' if env_type != 'production' else 'flutter-app-prod'
        config = ENV_FILES_CONFIG.get(service_id)
        
        if not config:
            return jsonify({'status': 'error', 'message': '환경 설정을 찾을 수 없습니다.'}), 404
        
        file_path = config['path']
        env_data = parse_json(file_path)
        
        # 기본 값이 없으면 초기화
        if not env_data:
            # Flutter 앱용 기본 환경 설정
            if env_type == 'development':
                env_data = {
                    "appName": "JB Platform Dev",
                    "mainApiBaseUrl": "http://10.0.2.2:8080/api/v1",
                    "legacyApiBaseUrl": "http://10.0.2.2:8080",
                    "fileServerUrl": "http://10.0.2.2:12020",
                    "aiServerUrl": "http://10.0.2.2:8086/api/v1",
                    "naverMapClientId": "YOUR_NAVER_MAP_CLIENT_ID",
                    "enableAnalytics": False,
                    "enableNetworkLogs": True,
                    "enableCrashlytics": False,
                    "mapDefaultLocation": {
                        "latitude": 35.8242238,
                        "longitude": 127.1479532,
                        "zoom": 15
                    }
                }
            elif env_type == 'staging':
                env_data = {
                    "appName": "JB Platform Staging",
                    "mainApiBaseUrl": "https://staging-api.jbplatform.com/api/v1",
                    "legacyApiBaseUrl": "https://staging-api.jbplatform.com",
                    "fileServerUrl": "https://staging-file.jbplatform.com",
                    "aiServerUrl": "https://staging-ai.jbplatform.com/api/v1",
                    "naverMapClientId": "YOUR_NAVER_MAP_CLIENT_ID",
                    "enableAnalytics": True,
                    "enableNetworkLogs": True,
                    "enableCrashlytics": True,
                    "mapDefaultLocation": {
                        "latitude": 35.8242238,
                        "longitude": 127.1479532,
                        "zoom": 15
                    }
                }
            else:  # production
                env_data = {
                    "appName": "JB Platform",
                    "mainApiBaseUrl": "https://api.jbplatform.com/api/v1",
                    "legacyApiBaseUrl": "https://api.jbplatform.com",
                    "fileServerUrl": "https://file.jbplatform.com",
                    "aiServerUrl": "https://ai.jbplatform.com/api/v1",
                    "naverMapClientId": "YOUR_NAVER_MAP_CLIENT_ID",
                    "enableAnalytics": True,
                    "enableNetworkLogs": False,
                    "enableCrashlytics": True,
                    "mapDefaultLocation": {
                        "latitude": 35.8242238,
                        "longitude": 127.1479532,
                        "zoom": 15
                    }
                }
            
            # 초기 값 저장
            save_json(file_path, env_data)
        
        return jsonify({
            'status': 'success',
            'data': env_data
        })
    
    except Exception as e:
        logger.error(f"플러터 환경변수 요청 오류: {e}")
        return jsonify({
            'status': 'error', 
            'message': f'환경변수 가져오기 오류: {str(e)}'
        }), 500

# AI 분석 서버용 환경변수 확인 엔드포인트
@app.route('/api/ai-config', methods=['GET'])
def get_ai_config():
    """
AI 서버 구성 설정을 확인하는 엔드포인트
    """
    try:
        # AI 서버 환경변수 확인
        result = {
            'google_vision_configured': False,
            'roboflow_configured': False,
            'missing_configs': []
        }
        
        # AI 서버 dotenv 파일 확인
        ai_config = ENV_FILES_CONFIG.get('ai-analysis-server')
        if ai_config:
            ai_env_data = parse_dotenv(ai_config['path'])
            all_vars = {}
            for section in ai_env_data:
                all_vars.update(ai_env_data[section])
            
            # Google Vision 구성 확인
            if 'GOOGLE_APPLICATION_CREDENTIALS' in all_vars:
                cred_path = all_vars['GOOGLE_APPLICATION_CREDENTIALS']
                if os.path.exists(cred_path):
                    result['google_vision_configured'] = True
                else:
                    result['missing_configs'].append('GOOGLE_APPLICATION_CREDENTIALS path does not exist')
            else:
                result['missing_configs'].append('GOOGLE_APPLICATION_CREDENTIALS not set')
            
            # Roboflow 구성 확인
            if 'ROBOFLOW_API_KEY' in all_vars and 'ROBOFLOW_WORKSPACE_URL' in all_vars:
                api_key = all_vars['ROBOFLOW_API_KEY']
                workspace = all_vars['ROBOFLOW_WORKSPACE_URL']
                if api_key and api_key != 'your-api-key' and workspace and workspace != 'your-workspace-url':
                    result['roboflow_configured'] = True
                else:
                    result['missing_configs'].append('ROBOFLOW credentials contain default values')
            else:
                missing = []
                if 'ROBOFLOW_API_KEY' not in all_vars:
                    missing.append('ROBOFLOW_API_KEY')
                if 'ROBOFLOW_WORKSPACE_URL' not in all_vars:
                    missing.append('ROBOFLOW_WORKSPACE_URL')
                result['missing_configs'].append(f'Missing Roboflow settings: {", ".join(missing)}')
        
        return jsonify({
            'status': 'success',
            'data': result
        })
    
    except Exception as e:
        logger.error(f"AI 구성 확인 오류: {e}")
        return jsonify({
            'status': 'error', 
            'message': f'AI 구성 확인 오류: {str(e)}'
        }), 500

def update_flutter_urls_from_domain(domain_config):
    """도메인 설정을 기반으로 Flutter 환경 파일들의 URL을 자동 업데이트"""
    try:
        domains = domain_config.get('domains', {})
        
        # 각 환경별로 Flutter 설정 업데이트
        env_mappings = {
            'development': 'flutter-app-dev',
            'staging': 'flutter-app-staging', 
            'production': 'flutter-app-prod'
        }
        
        for env_type, flutter_service_id in env_mappings.items():
            flutter_config = ENV_FILES_CONFIG.get(flutter_service_id)
            
            if not flutter_config:
                continue
                
            flutter_path = flutter_config['path']
            flutter_data = parse_json(flutter_path)
            
            if env_type in domains:
                domain_info = domains[env_type]
                protocol = domain_info.get('protocol', 'https')
                api_domain = domain_info.get('api_domain', '')
                file_domain = domain_info.get('file_domain', '')
                ai_domain = domain_info.get('ai_domain', '')
                
                # URL 자동 생성
                if api_domain:
                    flutter_data['mainApiBaseUrl'] = f"{protocol}://{api_domain}/api/v1"
                    flutter_data['legacyApiBaseUrl'] = f"{protocol}://{api_domain}"
                
                if file_domain:
                    flutter_data['fileServerUrl'] = f"{protocol}://{file_domain}"
                
                if ai_domain:
                    flutter_data['aiServerUrl'] = f"{protocol}://{ai_domain}/api/v1"
                
                # 업데이트된 데이터 저장
                save_json(flutter_path, flutter_data)
                logger.info(f"Flutter {env_type} URLs updated from domain config")
        
        return True
    except Exception as e:
        logger.error(f"Flutter URL 업데이트 오류: {e}")
        return False

@app.route('/api/update-domains', methods=['POST'])
def update_domains():
    """도메인 설정 업데이트 및 Flutter URL 자동 갱신"""
    try:
        # 도메인 설정 가져오기
        domain_config_path = ENV_FILES_CONFIG['domain-config']['path']
        domain_data = parse_json(domain_config_path)
        
        # 폼 데이터로 업데이트
        for key, value in request.form.items():
            if key.startswith('domain-config_'):
                config_key = key.replace('domain-config_', '')
                
                # 중첩된 키 처리 (예: domains.staging.api_domain)
                keys = config_key.split('.')
                current = domain_data
                for k in keys[:-1]:
                    if k not in current:
                        current[k] = {}
                    current = current[k]
                current[keys[-1]] = value
        
        # 도메인 설정 저장
        if save_json(domain_config_path, domain_data):
            # Flutter URL 자동 업데이트
            if update_flutter_urls_from_domain(domain_data):
                return jsonify({
                    'status': 'success', 
                    'message': '도메인 설정이 업데이트되었고, Flutter URL들이 자동으로 갱신되었습니다.'
                })
            else:
                return jsonify({
                    'status': 'warning', 
                    'message': '도메인 설정은 저장되었지만, Flutter URL 업데이트에 실패했습니다.'
                })
        else:
            return jsonify({'status': 'error', 'message': '도메인 설정 저장에 실패했습니다.'})
            
    except Exception as e:
        logger.error(f"도메인 업데이트 오류: {e}")
        return jsonify({'status': 'error', 'message': str(e)})

def test_database_connection(database_url):
    """데이터베이스 연결 테스트"""
    if not PSYCOPG2_AVAILABLE:
        return False, "psycopg2 라이브러리가 설치되지 않았습니다. pip install psycopg2-binary로 설치해주세요."
    
    try:
        # PostgreSQL URL 파싱
        if database_url.startswith('jdbc:postgresql://'):
            # JDBC URL에서 호스트, 포트, 데이터베이스 추출
            url_part = database_url.replace('jdbc:postgresql://', '')
            if '?' in url_part:
                url_part = url_part.split('?')[0]
            
            parts = url_part.split('/')
            host_port = parts[0]
            database = parts[1] if len(parts) > 1 else 'postgres'
            
            if ':' in host_port:
                host, port = host_port.split(':')
                port = int(port)
            else:
                host = host_port
                port = 5432
                
            # 기본 사용자명/비밀번호 사용 (환경변수에서 가져올 수도 있음)
            conn = psycopg2.connect(
                host=host,
                port=port,
                database=database,
                user='jb_user',  # 기본값, 실제로는 환경변수에서 가져와야 함
                password='jb_password',  # 기본값, 실제로는 환경변수에서 가져와야 함
                connect_timeout=5
            )
            conn.close()
            return True, "데이터베이스 연결 성공"
        else:
            return False, "지원하지 않는 데이터베이스 URL 형식"
    except Exception as e:
        return False, f"데이터베이스 연결 실패: {str(e)}"

def test_redis_connection(redis_host, redis_port=6379, redis_password=None):
    """Redis 연결 테스트"""
    if not REDIS_AVAILABLE:
        return False, "redis 라이브러리가 설치되지 않았습니다. pip install redis로 설치해주세요."
    
    try:
        r = redis_client.Redis(
            host=redis_host,
            port=redis_port,
            password=redis_password,
            socket_connect_timeout=5,
            socket_timeout=5
        )
        r.ping()
        return True, "Redis 연결 성공"
    except Exception as e:
        return False, f"Redis 연결 실패: {str(e)}"

def test_api_endpoint(url):
    """API 엔드포인트 연결 테스트"""
    try:
        response = requests.get(f"{url}/actuator/health", timeout=10)
        if response.status_code == 200:
            return True, f"API 서버 연결 성공 (상태: {response.status_code})"
        else:
            # health 엔드포인트가 없으면 기본 URL 테스트
            response = requests.get(url, timeout=10)
            if response.status_code < 500:
                return True, f"API 서버 연결 성공 (상태: {response.status_code})"
            else:
                return False, f"API 서버 오류 (상태: {response.status_code})"
    except requests.exceptions.Timeout:
        return False, "API 서버 연결 시간 초과"
    except requests.exceptions.ConnectionError:
        return False, "API 서버에 연결할 수 없음"
    except Exception as e:
        return False, f"API 서버 연결 실패: {str(e)}"

def test_roboflow_connection(api_key, workspace_url=None):
    """Roboflow API 연결 테스트"""
    try:
        if not api_key or api_key in ['your_roboflow_api_key_here', 'your-api-key']:
            return False, "유효하지 않은 Roboflow API 키"
            
        # 기본 Roboflow API 엔드포인트 테스트
        headers = {'Authorization': f'Bearer {api_key}'}
        response = requests.get('https://api.roboflow.com/v1/projects', headers=headers, timeout=10)
        
        if response.status_code == 200:
            return True, "Roboflow API 연결 성공"
        elif response.status_code == 401:
            return False, "Roboflow API 키가 유효하지 않음"
        else:
            return False, f"Roboflow API 오류 (상태: {response.status_code})"
    except Exception as e:
        return False, f"Roboflow API 연결 실패: {str(e)}"

def test_naver_map_api(client_id):
    """네이버 지도 API 연결 테스트"""
    try:
        if not client_id or client_id in ['your_naver_map_client_id_here', 'YOUR_NAVER_MAP_CLIENT_ID']:
            return False, "유효하지 않은 네이버 지도 클라이언트 ID"
            
        # 네이버 지도 Geocoding API 테스트 (간단한 쿼리)
        headers = {'X-NCP-APIGW-API-KEY-ID': client_id}
        params = {'query': '서울시청'}
        
        response = requests.get(
            'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode',
            headers=headers,
            params=params,
            timeout=10
        )
        
        if response.status_code == 200:
            return True, "네이버 지도 API 연결 성공"
        elif response.status_code == 401:
            return False, "네이버 지도 API 키가 유효하지 않음"
        elif response.status_code == 403:
            return False, "네이버 지도 API 접근 권한 없음"
        else:
            return False, f"네이버 지도 API 오류 (상태: {response.status_code})"
    except Exception as e:
        return False, f"네이버 지도 API 연결 실패: {str(e)}"

def test_jwt_secret(jwt_secret):
    """JWT 시크릿 유효성 테스트"""
    try:
        if not jwt_secret:
            return False, "JWT 시크릿이 설정되지 않음"
        
        if len(jwt_secret) < 32:
            return False, "JWT 시크릿이 너무 짧음 (최소 32자 필요)"
        
        if jwt_secret in ['your-super-secret-jwt-key-min-32-chars', 'change-me']:
            return False, "기본값 JWT 시크릿 사용 중 (보안 위험)"
        
        return True, "JWT 시크릿 유효"
    except Exception as e:
        return False, f"JWT 시크릿 테스트 실패: {str(e)}"

@app.route('/api/global-env', methods=['GET'])
def get_global_env():
    """글로벌 환경변수 목록 및 현재 값 반환"""
    try:
        global_env_status = {}
        
        for key, config in GLOBAL_ENV_KEYS.items():
            current_value = get_global_env_value(key)
            global_env_status[key] = {
                'value': current_value,
                'description': config['description'],
                'required': config['required'],
                'used_by': config['used_by'],
                'primary_service': config['primary_service'],
                'is_dummy': is_dummy_value(current_value) if current_value else True
            }
        
        return jsonify({
            'status': 'success',
            'data': global_env_status
        })
    except Exception as e:
        logger.error(f"글로벌 환경변수 조회 오류: {e}")
        return jsonify({
            'status': 'error',
            'message': f'글로벌 환경변수 조회 실패: {str(e)}'
        })

@app.route('/api/domain-config', methods=['GET'])
def get_domain_config():
    """도메인 설정 정보를 반환합니다."""
    try:
        domain_config = load_domain_config()
        return jsonify({
            'status': 'success',
            'data': domain_config
        })
    except Exception as e:
        app.logger.error(f"도메인 설정 로드 중 오류: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': f"도메인 설정 로드 실패: {str(e)}"
        }), 500

@app.route('/api/env/<env_name>', methods=['GET'])
def get_env_config(env_name):
    """Flutter 앱을 위한 환경 설정 정보를 반환합니다."""
    try:
        # 지원되는 환경 이름 확인
        valid_envs = ['development', 'staging', 'production']
        if env_name not in valid_envs and env_name not in ['dev', 'prod']:
            return jsonify({
                'status': 'error',
                'message': f"유효하지 않은 환경 이름입니다. 지원되는 환경: {', '.join(valid_envs)}"
            }), 400
        
        # dev, prod와 같은 짧은 형식 매핑
        env_mapping = {
            'dev': 'development',
            'prod': 'production'
        }
        
        # 환경 이름 정규화
        normalized_env = env_mapping.get(env_name, env_name)
        
        # 도메인 설정 로드
        domain_config = load_domain_config()
        if 'domains' not in domain_config or normalized_env not in domain_config['domains']:
            return jsonify({
                'status': 'error',
                'message': f"{normalized_env} 환경 설정을 찾을 수 없습니다."
            }), 404
            
        # 환경 설정 가져오기
        env_domain = domain_config['domains'][normalized_env]
        global_settings = domain_config.get('global_settings', {})
        
        # Flutter 환경 JSON 파일 확인 및 로드
        flutter_json_path = f"{app.config['DATA_DIR']}/flutter/{env_name}.json"
        flutter_config = {}
        
        if os.path.exists(flutter_json_path):
            with open(flutter_json_path, 'r', encoding='utf-8') as f:
                flutter_config = json.load(f)
        
        # 도메인 설정을 기반으로 URL 구성
        protocol = env_domain.get('protocol', 'http')
        api_domain = env_domain.get('api_domain', 'localhost:8080')
        file_domain = env_domain.get('file_domain', 'localhost:12020')
        ai_domain = env_domain.get('ai_domain', 'localhost:8086')
        
        api_path = global_settings.get('api_path', '/api/v1')
        ai_path = global_settings.get('ai_path', '/api/v1')
        
        # 안드로이드 에뮬레이터에서는 localhost 대신 10.0.2.2를 사용
        if normalized_env == 'development':
            api_domain = api_domain.replace('localhost', '10.0.2.2')
            file_domain = file_domain.replace('localhost', '10.0.2.2')
            ai_domain = ai_domain.replace('localhost', '10.0.2.2')
            
            # API 게이트웨이 활성화 시 API와 AI 요청은 게이트웨이를 통해 라우팅
            baseUrl = f"{protocol}://10.0.2.2:9000"
            apiUrl = baseUrl
            aiServerUrl = f"{baseUrl}/ai"
            fileServerUrl = f"{protocol}://{file_domain}"
        else:
            baseUrl = f"{protocol}://{api_domain}"
            apiUrl = baseUrl
            aiServerUrl = f"{protocol}://{ai_domain}"
            fileServerUrl = f"{protocol}://{file_domain}"
        
        # 기본 환경 설정
        env_config = {
            'baseUrl': flutter_config.get('baseUrl', baseUrl),
            'apiUrl': flutter_config.get('apiUrl', apiUrl),
            'fileServerUrl': flutter_config.get('fileServerUrl', fileServerUrl),
            'aiServerUrl': flutter_config.get('aiServerUrl', aiServerUrl),
            'apiPath': flutter_config.get('apiPath', api_path),
            'aiPath': flutter_config.get('aiPath', ai_path),
            'environment': normalized_env,
            'mapApiKey': flutter_config.get('mapApiKey', 'YOUR_MAP_API_KEY'),
            'naverClientId': flutter_config.get('naverClientId', 'YOUR_NAVER_CLIENT_ID'),
            'enableDebugLogs': flutter_config.get('enableDebugLogs', normalized_env != 'production'),
            'enableNetworkLogs': flutter_config.get('enableNetworkLogs', normalized_env != 'production'),
            'enableCrashlytics': flutter_config.get('enableCrashlytics', normalized_env == 'production'),
            'mapDefaultLocation': flutter_config.get('mapDefaultLocation', {
                'latitude': 35.8242238,
                'longitude': 127.1479532,
                'zoom': 15.0,
            }),
        }
        
        return jsonify({
            'status': 'success',
            'data': env_config
        })
    except Exception as e:
        app.logger.error(f"Flutter 환경 설정 로드 중 오류: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': f"환경 설정 로드 실패: {str(e)}"
        }), 500

@app.route('/api/global-env', methods=['POST'])
def update_global_env():
    """글로벌 환경변수 값 업데이트 (모든 관련 서비스에 동기화)"""
    try:
        data = request.get_json()
        key = data.get('key')
        value = data.get('value')
        
        if not key or key not in GLOBAL_ENV_KEYS:
            return jsonify({
                'status': 'error',
                'message': '유효하지 않은 글로벌 환경변수 키입니다.'
            })
        
        # 글로벌 환경변수 값 동기화
        if set_global_env_value(key, value):
            return jsonify({
                'status': 'success',
                'message': f'글로벌 환경변수 {key}가 모든 관련 서비스에 동기화되었습니다.',
                'updated_services': GLOBAL_ENV_KEYS[key]['used_by']
            })
        else:
            return jsonify({
                'status': 'error',
                'message': '글로벌 환경변수 동기화에 실패했습니다.'
            })
            
    except Exception as e:
        logger.error(f"글로벌 환경변수 업데이트 오류: {e}")
        return jsonify({
            'status': 'error',
            'message': f'글로벌 환경변수 업데이트 실패: {str(e)}'
        })

@app.route('/api/test-connection', methods=['POST'])
def test_connection():
    """필수값 연결 테스트 API"""
    try:
        data = request.get_json()
        service_id = data.get('service_id')
        field_name = data.get('field_name')
        field_value = data.get('field_value')
        
        if not service_id or not field_name or not field_value:
            return jsonify({
                'status': 'error',
                'message': '필수 파라미터가 누락되었습니다.'
            })
        
        # 서비스별 필드별 테스트 로직
        success = False
        message = "테스트 실패"
        
        # 데이터베이스 연결 테스트
        if field_name in ['DATABASE_URL']:
            success, message = test_database_connection(field_value)
        
        # Redis 연결 테스트
        elif field_name in ['REDIS_HOST']:
            success, message = test_redis_connection(field_value)
        
        # API 엔드포인트 테스트
        elif field_name in ['mainApiBaseUrl', 'aiServerUrl', 'fileServerUrl', 'AI_SERVICE_URL', 'MAIN_API_URL', 'FILE_SERVICE_URL']:
            success, message = test_api_endpoint(field_value)
        
        # Roboflow API 테스트
        elif field_name in ['ROBOFLOW_API_KEY']:
            success, message = test_roboflow_connection(field_value)
        
        # 네이버 지도 API 테스트
        elif field_name in ['naverMapClientId']:
            success, message = test_naver_map_api(field_value)
        
        # JWT 시크릿 테스트
        elif field_name in ['JWT_SECRET']:
            success, message = test_jwt_secret(field_value)
        
        # 도메인 연결 테스트
        elif 'domain' in field_name.lower():
            if field_value.startswith('http'):
                success, message = test_api_endpoint(field_value)
            else:
                # HTTP 프로토콜 추가해서 테스트
                protocol = 'https' if 'production' in service_id or 'staging' in service_id else 'http'
                test_url = f"{protocol}://{field_value}"
                success, message = test_api_endpoint(test_url)
        
        else:
            return jsonify({
                'status': 'info',
                'message': f'{field_name}에 대한 자동 테스트가 지원되지 않습니다.'
            })
        
        return jsonify({
            'status': 'success' if success else 'error',
            'message': message,
            'field_name': field_name,
            'test_result': success
        })
        
    except Exception as e:
        logger.error(f"연결 테스트 오류: {e}")
        return jsonify({
            'status': 'error',
            'message': f'테스트 중 오류가 발생했습니다: {str(e)}'
        })

def load_domain_config():
    """
    domain-config.json 파일을 로드하고 파싱합니다. 
    파일이 없는 경우 기본 설정으로 생성합니다.
    """
    domain_config_path = f"{app.config['DATA_DIR']}/domain-config.json"
    
    # 파일이 없는 경우 기본 설정 생성
    if not os.path.exists(domain_config_path):
        default_config = {
            'domains': {
                'development': {
                    'display_name': 'Development (로컬)',
                    'api_domain': 'localhost:8080',
                    'file_domain': 'localhost:12020',
                    'ai_domain': 'localhost:8086',
                    'protocol': 'http'
                },
                'staging': {
                    'display_name': 'Staging (스테이징)',
                    'api_domain': 'staging-api.yourcompany.com',
                    'file_domain': 'staging-file.yourcompany.com',
                    'ai_domain': 'staging-ai.yourcompany.com',
                    'protocol': 'https'
                },
                'production': {
                    'display_name': 'Production (운영)',
                    'api_domain': 'api.yourcompany.com',
                    'file_domain': 'file.yourcompany.com',
                    'ai_domain': 'ai.yourcompany.com',
                    'protocol': 'https'
                }
            },
            'global_settings': {
                'base_domain': 'yourcompany.com',
                'api_path': '/api/v1',
                'ai_path': '/api/v1'
            }
        }
        
        os.makedirs(os.path.dirname(domain_config_path), exist_ok=True)
        with open(domain_config_path, 'w', encoding='utf-8') as f:
            json.dump(default_config, f, indent=2, ensure_ascii=False)
        
        logger.info("기본 도메인 설정이 생성되었습니다.")
        return default_config
    
    # 파일이 있는 경우 로드
    with open(domain_config_path, 'r', encoding='utf-8') as f:
        return json.load(f)

@app.route('/api/domain-config', methods=['GET'])
def get_domain_config():
    """도메인 설정 정보를 반환합니다."""
    try:
        domain_config = load_domain_config()
        return jsonify({
            'status': 'success',
            'data': domain_config
        })
    except Exception as e:
        logger.error(f"도메인 설정 로드 중 오류: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': f"도메인 설정 로드 실패: {str(e)}"
        }), 500

@app.route('/api/env/<env_name>', methods=['GET'])
def get_env_config(env_name):
    """Flutter 앱을 위한 환경 설정 정보를 반환합니다."""
    try:
        # 지원되는 환경 이름 확인
        valid_envs = ['development', 'staging', 'production']
        if env_name not in valid_envs and env_name not in ['dev', 'prod']:
            return jsonify({
                'status': 'error',
                'message': f"유효하지 않은 환경 이름입니다. 지원되는 환경: {', '.join(valid_envs)}"
            }), 400
        
        # dev, prod와 같은 짧은 형식 매핑
        env_mapping = {
            'dev': 'development',
            'prod': 'production'
        }
        
        # 환경 이름 정규화
        normalized_env = env_mapping.get(env_name, env_name)
        
        # 도메인 설정 로드
        domain_config = load_domain_config()
        if 'domains' not in domain_config or normalized_env not in domain_config['domains']:
            return jsonify({
                'status': 'error',
                'message': f"{normalized_env} 환경 설정을 찾을 수 없습니다."
            }), 404
            
        # 환경 설정 가져오기
        env_domain = domain_config['domains'][normalized_env]
        global_settings = domain_config.get('global_settings', {})
        
        # Flutter 환경 JSON 파일 확인 및 로드
        flutter_json_path = f"{app.config['DATA_DIR']}/flutter/{env_name}.json"
        flutter_config = {}
        
        if os.path.exists(flutter_json_path):
            with open(flutter_json_path, 'r', encoding='utf-8') as f:
                flutter_config = json.load(f)
        
        # 도메인 설정을 기반으로 URL 구성
        protocol = env_domain.get('protocol', 'http')
        api_domain = env_domain.get('api_domain', 'localhost:8080')
        file_domain = env_domain.get('file_domain', 'localhost:12020')
        ai_domain = env_domain.get('ai_domain', 'localhost:8086')
        
        api_path = global_settings.get('api_path', '/api/v1')
        ai_path = global_settings.get('ai_path', '/api/v1')
        
        # 안드로이드 에뮬레이터에서는 localhost 대신 10.0.2.2를 사용
        if normalized_env == 'development':
            api_domain = api_domain.replace('localhost', '10.0.2.2')
            file_domain = file_domain.replace('localhost', '10.0.2.2')
            ai_domain = ai_domain.replace('localhost', '10.0.2.2')
            
            # API 게이트웨이 활성화 시 API와 AI 요청은 게이트웨이를 통해 라우팅
            baseUrl = f"{protocol}://10.0.2.2:9000"
            apiUrl = baseUrl
            aiServerUrl = f"{baseUrl}/ai"
            fileServerUrl = f"{protocol}://{file_domain}"
        else:
            baseUrl = f"{protocol}://{api_domain}"
            apiUrl = baseUrl
            aiServerUrl = f"{protocol}://{ai_domain}"
            fileServerUrl = f"{protocol}://{file_domain}"
        
        # 기본 환경 설정
        env_config = {
            'baseUrl': flutter_config.get('baseUrl', baseUrl),
            'apiUrl': flutter_config.get('apiUrl', apiUrl),
            'fileServerUrl': flutter_config.get('fileServerUrl', fileServerUrl),
            'aiServerUrl': flutter_config.get('aiServerUrl', aiServerUrl),
            'apiPath': flutter_config.get('apiPath', api_path),
            'aiPath': flutter_config.get('aiPath', ai_path),
            'environment': normalized_env,
            'mapApiKey': flutter_config.get('mapApiKey', 'YOUR_MAP_API_KEY'),
            'naverClientId': flutter_config.get('naverClientId', 'YOUR_NAVER_CLIENT_ID'),
            'enableDebugLogs': flutter_config.get('enableDebugLogs', normalized_env != 'production'),
            'enableNetworkLogs': flutter_config.get('enableNetworkLogs', normalized_env != 'production'),
            'enableCrashlytics': flutter_config.get('enableCrashlytics', normalized_env == 'production'),
            'mapDefaultLocation': flutter_config.get('mapDefaultLocation', {
                'latitude': 35.8242238,
                'longitude': 127.1479532,
                'zoom': 15.0,
            }),
        }
        
        return jsonify({
            'status': 'success',
            'data': env_config
        })
    except Exception as e:
        logger.error(f"Flutter 환경 설정 로드 중 오류: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': f"환경 설정 로드 실패: {str(e)}"
        }), 500

if __name__ == '__main__':
    # 데이터 디렉토리 생성
    os.makedirs('/app/data', exist_ok=True)
    os.makedirs('/app/data/flutter-app', exist_ok=True)
    os.makedirs('/app/data/flutter', exist_ok=True)  # Flutter 환경 설정 디렉토리 생성
    app.config['DATA_DIR'] = '/app/data'  # 데이터 디렉토리 설정
    app.run(host='0.0.0.0', port=8888, debug=True)