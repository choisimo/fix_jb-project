from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import os
import logging

app = Flask(__name__)
CORS(app)

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 데이터 디렉토리 설정
DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data')
FLUTTER_ENV_DIR = os.path.join(DATA_DIR, 'flutter')

def load_domain_config():
    """도메인 설정 파일을 로드하거나 기본값 생성"""
    domain_config_path = os.path.join(DATA_DIR, 'domain-config.json')
    
    # 디렉토리가 없으면 생성
    os.makedirs(DATA_DIR, exist_ok=True)
    os.makedirs(FLUTTER_ENV_DIR, exist_ok=True)
    
    if os.path.exists(domain_config_path):
        try:
            with open(domain_config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"도메인 설정 파일 로드 실패: {str(e)}")
    
    # 기본 도메인 설정
    default_config = {
        "domains": {
            "development": {
                "display_name": "Development (로컬)",
                "api_domain": "localhost:8080",
                "file_domain": "localhost:12020",
                "ai_domain": "localhost:8086",
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
    
    # 기본값 저장
    try:
        with open(domain_config_path, 'w', encoding='utf-8') as f:
            json.dump(default_config, f, indent=2, ensure_ascii=False)
        logger.info(f"기본 도메인 설정 파일이 생성되었습니다: {domain_config_path}")
        return default_config
    except Exception as e:
        logger.error(f"기본 도메인 설정 파일 생성 실패: {str(e)}")
        return default_config

@app.route('/api/env/<env_name>', methods=['GET'])
def get_env_config(env_name):
    """Flutter 앱을 위한 환경 설정 정보를 반환합니다."""
    try:
        # 지원되는 환경 이름 확인
        valid_envs = ['development', 'staging', 'production']
        if env_name not in valid_envs and env_name not in ['dev', 'prod']:
            return jsonify({
                'status': 'error',
                'message': f'유효하지 않은 환경 이름입니다. 지원되는 환경: {", ".join(valid_envs)}'
            }), 400
        
        # dev, prod와 같은 짧은 형식 매핑
        env_mapping = {
            'dev': 'development',
            'prod': 'production'
        }
        
        # 환경 이름 정규화
        normalized_env = env_mapping.get(env_name, env_name)
        
        # Flutter 환경 JSON 파일 확인 및 로드
        flutter_json_path = os.path.join(FLUTTER_ENV_DIR, f'{normalized_env}.json')
        
        if os.path.exists(flutter_json_path):
            with open(flutter_json_path, 'r', encoding='utf-8') as f:
                flutter_config = json.load(f)
                return jsonify({
                    'status': 'success',
                    'data': flutter_config
                })
        else:
            # 도메인 설정 파일 로드 시도
            domain_config = load_domain_config()
            
            if 'domains' not in domain_config or normalized_env not in domain_config['domains']:
                return jsonify({
                    'status': 'error',
                    'message': f'{normalized_env} 환경 설정을 찾을 수 없습니다.'
                }), 404
                
            # 환경 설정 가져오기
            env_domain = domain_config['domains'][normalized_env]
            global_settings = domain_config.get('global_settings', {})
            
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
                baseUrl = f'{protocol}://10.0.2.2:9000'
                apiUrl = baseUrl
                aiServerUrl = f'{baseUrl}/ai'
                fileServerUrl = f'{protocol}://{file_domain}'
            else:
                baseUrl = f'{protocol}://{api_domain}'
                apiUrl = baseUrl
                aiServerUrl = f'{protocol}://{ai_domain}'
                fileServerUrl = f'{protocol}://{file_domain}'
            
            # 기본 환경 설정
            env_config = {
                'baseUrl': baseUrl,
                'apiUrl': apiUrl,
                'fileServerUrl': fileServerUrl,
                'aiServerUrl': aiServerUrl,
                'apiPath': api_path,
                'aiPath': ai_path,
                'environment': normalized_env,
                'mapApiKey': 'YOUR_MAP_API_KEY',
                'naverMapClientId': 'YOUR_NAVER_CLIENT_ID',
                'enableDebugLogs': normalized_env != 'production',
                'enableNetworkLogs': normalized_env != 'production',
                'enableCrashlytics': normalized_env == 'production',
                'mapDefaultLocation': {
                    'latitude': 35.8242238,
                    'longitude': 127.1479532,
                    'zoom': 15.0,
                }
            }
            
            # 환경 설정 파일 저장
            os.makedirs(os.path.dirname(flutter_json_path), exist_ok=True)
            with open(flutter_json_path, 'w', encoding='utf-8') as f:
                json.dump(env_config, f, indent=2, ensure_ascii=False)
                
            return jsonify({
                'status': 'success',
                'data': env_config,
                'message': f'환경 설정 파일이 생성되었습니다: {flutter_json_path}'
            })
    
    except Exception as e:
        logger.error(f"환경 설정 로드 실패: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': f'환경 설정 로드 실패: {str(e)}'
        }), 500

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
        logger.error(f"도메인 설정 로드 실패: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': f'도메인 설정 로드 실패: {str(e)}'
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """서비스 상태 확인 엔드포인트"""
    return jsonify({
        'status': 'success',
        'message': 'Flutter 환경 변수 서비스가 정상적으로 실행 중입니다.'
    })

if __name__ == '__main__':
    # 데이터 디렉토리 초기화
    os.makedirs(DATA_DIR, exist_ok=True)
    os.makedirs(FLUTTER_ENV_DIR, exist_ok=True)
    
    # 도메인 설정 로드
    load_domain_config()
    
    # 서버 시작
    port = int(os.environ.get('PORT', 8889))
    app.run(host='0.0.0.0', port=port, debug=True)
