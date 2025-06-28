#!/usr/bin/env python3
"""
전북 현장 보고 시스템 - Roboflow AI 분석 서비스
실제 이미지 분석 및 결과 처리를 위한 통합 모듈
"""

import os
import json
import time
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from roboflow import Roboflow
import requests
from PIL import Image
import io
from pathlib import Path

# 설정 관리자 임포트
try:
    from config_manager import load_config, AppConfig
    CONFIG_MANAGER_AVAILABLE = True
except ImportError:
    CONFIG_MANAGER_AVAILABLE = False
    print("⚠️ config_manager 모듈을 찾을 수 없습니다. 기본 설정을 사용합니다.")

# =============================================================================
# 설정 정보 (실제 배포 시 환경변수나 설정 파일로 관리)
# =============================================================================

# 기본 설정 (설정 관리자가 없을 때 사용)
DEFAULT_ROBOFLOW_CONFIG = {
    "api_key": os.getenv("ROBOFLOW_API_KEY", "YOUR_PRIVATE_KEY"),
    "workspace_id": os.getenv("ROBOFLOW_WORKSPACE", "jeonbuk-reports"),
    "project_id": os.getenv("ROBOFLOW_PROJECT", "integrated-detection"),
    "model_version": int(os.getenv("ROBOFLOW_VERSION", "1")),
    "confidence_threshold": int(os.getenv("CONFIDENCE_THRESHOLD", "50")),
    "overlap_threshold": int(os.getenv("OVERLAP_THRESHOLD", "30"))
}

# 클래스 매핑 정보
CLASS_MAPPINGS = {
    # 영문 클래스명 -> 한국어 클래스명
    'road_damage': '도로 파손',
    'pothole': '포트홀', 
    'illegal_dumping': '무단 투기',
    'graffiti': '낙서',
    'broken_sign': '간판 파손',
    'broken_fence': '펜스 파손',
    'street_light_out': '가로등 고장',
    'manhole_damage': '맨홀 손상',
    'sidewalk_crack': '인도 균열',
    'tree_damage': '나무 손상',
    'construction_issue': '공사 문제',
    'traffic_sign_damage': '교통표지판 손상',
    'building_damage': '건물 손상',
    'water_leak': '누수',
    'electrical_hazard': '전기 위험',
    'other_public_issue': '기타 공공 문제'
}

# 카테고리 매핑
CATEGORY_MAPPINGS = {
    'road_damage': '도로/교통',
    'pothole': '도로/교통',
    'traffic_sign_damage': '도로/교통',
    'illegal_dumping': '환경/위생',
    'graffiti': '환경/위생',
    'water_leak': '상하수도',
    'street_light_out': '전기/조명',
    'electrical_hazard': '전기/조명',
    'broken_sign': '건축물',
    'building_damage': '건축물',
    'broken_fence': '공원/시설물',
    'manhole_damage': '공원/시설물',
    'sidewalk_crack': '공원/시설물',
    'tree_damage': '공원/시설물',
    'construction_issue': '공사/안전'
}

# 우선순위 매핑
PRIORITY_MAPPINGS = {
    'electrical_hazard': '긴급',
    'water_leak': '긴급', 
    'construction_issue': '긴급',
    'road_damage': '높음',
    'pothole': '높음',
    'manhole_damage': '높음',
    'street_light_out': '보통',
    'traffic_sign_damage': '보통',
    'building_damage': '보통',
    'broken_sign': '보통',
    'broken_fence': '보통',
    'sidewalk_crack': '보통',
    'illegal_dumping': '낮음',
    'graffiti': '낮음',
    'tree_damage': '낮음',
    'other_public_issue': '낮음'
}

# =============================================================================
# 데이터 클래스 정의
# =============================================================================

@dataclass
class BoundingBox:
    """바운딩 박스 정보"""
    x: float
    y: float
    width: float
    height: float
    
    @property
    def left(self) -> float:
        return self.x - (self.width / 2)
    
    @property
    def top(self) -> float:
        return self.y - (self.height / 2)
    
    @property
    def right(self) -> float:
        return self.x + (self.width / 2)
    
    @property
    def bottom(self) -> float:
        return self.y + (self.height / 2)

@dataclass 
class DetectedObject:
    """감지된 객체 정보"""
    class_name: str
    confidence: float
    bounding_box: BoundingBox
    
    @property
    def korean_name(self) -> str:
        return CLASS_MAPPINGS.get(self.class_name, self.class_name)
    
    @property
    def confidence_percent(self) -> str:
        return f"{self.confidence:.1f}%"
    
    @property
    def category(self) -> str:
        return CATEGORY_MAPPINGS.get(self.class_name, '기타')
    
    @property 
    def priority(self) -> str:
        return PRIORITY_MAPPINGS.get(self.class_name, '보통')

@dataclass
class AnalysisResult:
    """AI 분석 결과"""
    image_path: str
    detections: List[DetectedObject]
    confidence: float
    processing_time: float
    raw_response: Dict
    
    @property
    def has_detections(self) -> bool:
        return len(self.detections) > 0
    
    @property
    def summary(self) -> str:
        if not self.has_detections:
            return "감지된 객체 없음"
        
        classes = [d.korean_name for d in self.detections]
        unique_classes = list(set(classes))
        return f"감지된 객체: {', '.join(unique_classes)} ({len(self.detections)}개)"
    
    @property
    def recommended_category(self) -> str:
        """가장 신뢰도 높은 객체의 카테고리 반환"""
        if not self.has_detections:
            return '기타'
        
        highest_confidence = max(self.detections, key=lambda x: x.confidence)
        return highest_confidence.category
    
    @property
    def recommended_priority(self) -> str:
        """가장 높은 우선순위 반환"""
        if not self.has_detections:
            return '보통'
        
        priorities = ['긴급', '높음', '보통', '낮음']
        detected_priorities = [d.priority for d in self.detections]
        
        for priority in priorities:
            if priority in detected_priorities:
                return priority
        return '보통'

# =============================================================================
# Roboflow AI 분석 서비스 클래스
# =============================================================================

class RoboflowAnalysisService:
    """Roboflow AI 분석 서비스"""
    
    def __init__(self, config: Optional[Dict] = None):
        """초기화"""
        # 설정 로드
        if CONFIG_MANAGER_AVAILABLE and config is None:
            try:
                app_config = load_config()
                self.config = {
                    "api_key": app_config.roboflow.api_key,
                    "workspace_id": app_config.roboflow.workspace_id,
                    "project_id": app_config.roboflow.project_id,
                    "model_version": app_config.roboflow.model_version,
                    "confidence_threshold": app_config.roboflow.confidence_threshold,
                    "overlap_threshold": app_config.roboflow.overlap_threshold
                }
            except Exception as e:
                print(f"⚠️ 설정 관리자 로드 실패, 기본 설정 사용: {e}")
                self.config = DEFAULT_ROBOFLOW_CONFIG
        else:
            self.config = config or DEFAULT_ROBOFLOW_CONFIG
            
        self.rf = None
        self.model = None
        self._initialize_roboflow()
    
    def _initialize_roboflow(self) -> bool:
        """Roboflow 서비스 초기화"""
        try:
            print("🤖 Roboflow 서비스 초기화 중...")
            
            # API 키 유효성 검사
            if not self._validate_api_key():
                raise ValueError("유효하지 않은 API 키입니다")
            
            # Roboflow 객체 생성
            self.rf = Roboflow(api_key=self.config["api_key"])
            
            # 프로젝트 및 모델 가져오기
            workspace = self.rf.workspace(self.config["workspace_id"])
            project = workspace.project(self.config["project_id"])
            self.model = project.version(self.config["model_version"]).model
            
            print("✅ Roboflow 서비스 초기화 완료")
            return True
            
        except Exception as e:
            print(f"❌ Roboflow 초기화 실패: {e}")
            return False
    
    def _validate_api_key(self) -> bool:
        """API 키 유효성 검사"""
        api_key = self.config["api_key"]
        return (api_key and 
                api_key != "YOUR_PRIVATE_KEY" and 
                len(api_key) > 10)
    
    def test_connection(self) -> bool:
        """API 연결 테스트"""
        try:
            print("🔍 API 연결 테스트 중...")
            
            if not self.model:
                print("❌ 모델이 초기화되지 않았습니다")
                return False
            
            # 테스트용 더미 이미지 생성 (1x1 픽셀)
            test_image = Image.new('RGB', (1, 1), color='white')
            test_buffer = io.BytesIO()
            test_image.save(test_buffer, format='JPEG')
            test_buffer.seek(0)
            
            # 임시 파일로 저장
            test_path = "temp_test_image.jpg"
            with open(test_path, 'wb') as f:
                f.write(test_buffer.getvalue())
            
            try:
                # API 호출 테스트
                result = self.model.predict(
                    test_path,
                    confidence=self.config["confidence_threshold"],
                    overlap=self.config["overlap_threshold"]
                ).json()
                
                print("✅ API 연결 성공")
                print(f"📊 응답 형식: {type(result)}")
                return True
                
            finally:
                # 임시 파일 삭제
                if os.path.exists(test_path):
                    os.remove(test_path)
                    
        except Exception as e:
            print(f"❌ API 연결 실패: {e}")
            return False
    
    def analyze_image(self, image_path: str) -> Optional[AnalysisResult]:
        """이미지 분석 실행"""
        start_time = time.time()
        
        try:
            print(f"🤖 이미지 분석 시작: {image_path}")
            
            # 모델 초기화 확인
            if not self.model:
                raise RuntimeError("모델이 초기화되지 않았습니다. API 키와 프로젝트 설정을 확인해주세요.")
            
            # 파일 존재 여부 확인
            if not os.path.exists(image_path):
                raise FileNotFoundError(f"이미지 파일을 찾을 수 없습니다: {image_path}")
            
            # 파일 크기 확인
            file_size = os.path.getsize(image_path)
            print(f"📄 파일 크기: {file_size:,} bytes")
            
            if file_size > 10 * 1024 * 1024:  # 10MB 제한
                print("⚠️ 파일 크기가 너무 큽니다 (10MB 초과)")
                return None
            
            # 모델 예측 실행
            print("🔄 AI 분석 중...")
            prediction = self.model.predict(
                image_path,
                confidence=self.config["confidence_threshold"],
                overlap=self.config["overlap_threshold"]
            ).json()
            
            # 결과 파싱
            result = self._parse_prediction(image_path, prediction, start_time)
            
            print(f"✅ 분석 완료: {result.summary}")
            print(f"⏱️ 처리 시간: {result.processing_time:.2f}초")
            
            return result
            
        except Exception as e:
            processing_time = time.time() - start_time
            print(f"❌ 분석 실패 ({processing_time:.2f}초): {e}")
            return None
    
    def _parse_prediction(self, image_path: str, prediction: Dict, start_time: float) -> AnalysisResult:
        """예측 결과 파싱"""
        detections = []
        
        # 예측 결과에서 객체 정보 추출
        predictions = prediction.get('predictions', [])
        print(f"📊 원시 예측 수: {len(predictions)}")
        
        for pred in predictions:
            try:
                detection = DetectedObject(
                    class_name=pred['class'],
                    confidence=pred['confidence'] * 100,  # 백분율로 변환
                    bounding_box=BoundingBox(
                        x=pred['x'],
                        y=pred['y'], 
                        width=pred['width'],
                        height=pred['height']
                    )
                )
                detections.append(detection)
                print(f"  🎯 {detection.korean_name}: {detection.confidence_percent}")
                
            except KeyError as e:
                print(f"⚠️ 예측 데이터 파싱 오류: {e}")
                continue
        
        # 신뢰도별 정렬 (높은 순)
        detections.sort(key=lambda x: x.confidence, reverse=True)
        
        # 평균 신뢰도 계산
        avg_confidence = sum(d.confidence for d in detections) / len(detections) if detections else 0
        
        processing_time = time.time() - start_time
        
        return AnalysisResult(
            image_path=image_path,
            detections=detections,
            confidence=avg_confidence,
            processing_time=processing_time,
            raw_response=prediction
        )
    
    def batch_analyze(self, image_paths: List[str]) -> List[AnalysisResult]:
        """여러 이미지 일괄 분석"""
        results = []
        
        print(f"📦 일괄 분석 시작: {len(image_paths)}개 이미지")
        
        for i, path in enumerate(image_paths, 1):
            print(f"\n📷 [{i}/{len(image_paths)}] {os.path.basename(path)}")
            result = self.analyze_image(path)
            if result:
                results.append(result)
        
        print(f"\n✅ 일괄 분석 완료: {len(results)}/{len(image_paths)} 성공")
        return results
    
    def export_results(self, results: List[AnalysisResult], output_path: str = "analysis_results.json"):
        """분석 결과를 JSON 파일로 내보내기"""
        try:
            export_data = []
            
            for result in results:
                export_data.append({
                    "image_path": result.image_path,
                    "processing_time": result.processing_time,
                    "average_confidence": result.confidence,
                    "recommended_category": result.recommended_category,
                    "recommended_priority": result.recommended_priority,
                    "detections": [
                        {
                            "class_name": d.class_name,
                            "korean_name": d.korean_name,
                            "confidence": d.confidence,
                            "category": d.category,
                            "priority": d.priority,
                            "bounding_box": {
                                "x": d.bounding_box.x,
                                "y": d.bounding_box.y,
                                "width": d.bounding_box.width,
                                "height": d.bounding_box.height
                            }
                        } for d in result.detections
                    ],
                    "raw_response": result.raw_response
                })
            
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(export_data, f, ensure_ascii=False, indent=2)
            
            print(f"💾 결과 저장 완료: {output_path}")
            
        except Exception as e:
            print(f"❌ 결과 저장 실패: {e}")

# =============================================================================
# 메인 실행 부분
# =============================================================================

def main():
    """메인 실행 함수"""
    import argparse
    
    parser = argparse.ArgumentParser(description="전북 현장 보고 시스템 - Roboflow AI 분석")
    parser.add_argument('--test', action='store_true', help='테스트 모드로 실행')
    parser.add_argument('--image', type=str, help='분석할 이미지 파일 경로')
    parser.add_argument('--batch', type=str, help='배치 분석할 폴더 경로')
    parser.add_argument('--check-config', action='store_true', help='설정 확인')
    parser.add_argument('--test-backend', action='store_true', help='백엔드 연동 테스트')
    
    args = parser.parse_args()
    
    print("🚀 전북 현장 보고 시스템 - Roboflow AI 분석")
    print("=" * 60)
    
    # 설정 확인 모드
    if args.check_config:
        check_configuration()
        return
    
    # 백엔드 테스트 모드
    if args.test_backend:
        test_backend_connection()
        return
    
    # 테스트 모드 - 모의 데이터로 실행
    if args.test:
        run_test_mode()
        return
    
    # 실제 API 모드
    service = RoboflowAnalysisService()
    
    if not service.model:
        print("\n❌ Roboflow 서비스 초기화에 실패했습니다.")
        print("\n[해결 방법]")
        print("1. .env 파일의 ROBOFLOW_API_KEY를 실제 키로 변경")
        print("2. ROBOFLOW_WORKSPACE, ROBOFLOW_PROJECT 확인")
        print("3. 인터넷 연결 상태 확인")
        print("\n💡 테스트 모드로 먼저 실행해보세요: python roboflow_test.py --test")
        return
    
    # API 연결 테스트
    if not service.test_connection():
        print("\n❌ API 연결에 실패했습니다.")
        return
    
    # 단일 이미지 분석
    if args.image:
        if os.path.exists(args.image):
            result = service.analyze_image(args.image)
            print_analysis_result(result)
        else:
            print(f"❌ 이미지 파일을 찾을 수 없습니다: {args.image}")
        return
    
    # 배치 분석
    if args.batch:
        if os.path.exists(args.batch):
            image_files = []
            for ext in ['.jpg', '.jpeg', '.png']:
                image_files.extend(Path(args.batch).glob(f"*{ext}"))
            
            if image_files:
                results = service.batch_analyze([str(f) for f in image_files])
                print_batch_results(results)
            else:
                print(f"❌ 폴더에서 이미지 파일을 찾을 수 없습니다: {args.batch}")
        else:
            print(f"❌ 폴더를 찾을 수 없습니다: {args.batch}")
        return
    
    # 기본 실행 - 사용법 출력
    print("\n📖 사용법:")
    print("  python roboflow_test.py --test                    # 테스트 모드")
    print("  python roboflow_test.py --image image.jpg         # 단일 이미지 분석")
    print("  python roboflow_test.py --batch ./images/         # 배치 분석")
    print("  python roboflow_test.py --check-config            # 설정 확인")
    print("  python roboflow_test.py --test-backend            # 백엔드 테스트")

def check_configuration():
    """설정 확인 함수"""
    print("🔍 설정 확인 중...")
    
    # 환경변수 확인
    env_vars = {
        'ROBOFLOW_API_KEY': os.getenv('ROBOFLOW_API_KEY'),
        'ROBOFLOW_WORKSPACE': os.getenv('ROBOFLOW_WORKSPACE'), 
        'ROBOFLOW_PROJECT': os.getenv('ROBOFLOW_PROJECT'),
        'ROBOFLOW_VERSION': os.getenv('ROBOFLOW_VERSION', '1')
    }
    
    print("\n📋 환경변수 상태:")
    for key, value in env_vars.items():
        if value and value != 'your_private_api_key_here':
            print(f"✅ {key}: 설정됨")
        else:
            print(f"❌ {key}: 누락 또는 기본값")
    
    # 설정 파일 확인
    config_files = ['.env', 'config.json']
    print("\n📁 설정 파일:")
    for config_file in config_files:
        if os.path.exists(config_file):
            print(f"✅ {config_file}: 존재")
        else:
            print(f"❌ {config_file}: 없음")

def test_backend_connection():
    """백엔드 연결 테스트"""
    print("🔌 백엔드 연결 테스트 중...")
    
    backend_url = os.getenv('BACKEND_URL', 'http://localhost:8080')
    
    try:
        import requests
        response = requests.get(f"{backend_url}/api/v1/ai/health", timeout=5)
        
        if response.status_code == 200:
            print(f"✅ 백엔드 연결 성공: {backend_url}")
        else:
            print(f"⚠️ 백엔드 응답 오류: {response.status_code}")
            
    except ImportError:
        print("❌ requests 패키지가 필요합니다: pip install requests")
    except Exception as e:
        print(f"❌ 백엔드 연결 실패: {e}")
        print(f"   URL: {backend_url}")
        print("   백엔드가 실행 중인지 확인하세요")

def run_test_mode():
    """테스트 모드 실행"""
    print("🧪 테스트 모드로 실행 중...")
    
    # 모의 분석 결과 생성
    test_scenarios = [
        {
            "image": "도로_파손_샘플.jpg",
            "detections": [
                {"class": "pothole", "confidence": 0.85, "korean": "포트홀"}
            ],
            "category": "도로 관리",
            "priority": "높음"
        },
        {
            "image": "환경_문제_샘플.jpg", 
            "detections": [
                {"class": "illegal_dumping", "confidence": 0.72, "korean": "무단 투기"}
            ],
            "category": "환경 관리",
            "priority": "낮음"
        },
        {
            "image": "시설물_파손_샘플.jpg",
            "detections": [
                {"class": "broken_sign", "confidence": 0.78, "korean": "간판 파손"}
            ],
            "category": "시설 관리", 
            "priority": "보통"
        }
    ]
    
    print("\n📊 모의 분석 결과:")
    print("=" * 50)
    
    for i, scenario in enumerate(test_scenarios, 1):
        print(f"\n📷 테스트 {i}: {scenario['image']}")
        print(f"🎯 카테고리: {scenario['category']}")
        print(f"📌 우선순위: {scenario['priority']}")
        print("🔍 감지된 객체:")
        
        for detection in scenario['detections']:
            print(f"   - {detection['korean']} ({detection['confidence']*100:.1f}%)")
    
    print(f"\n✅ 테스트 모드 완료! {len(test_scenarios)}개 시나리오 실행됨")
    print("\n💡 실제 API 사용을 위해서는 .env 파일에 실제 API 키를 설정하세요")

def print_analysis_result(result):
    """단일 분석 결과 출력"""
    print(f"\n📷 이미지: {os.path.basename(result.image_path)}")
    print(f"⏱️ 처리시간: {result.processing_time:.2f}초")
    print(f"🎯 권장 카테고리: {result.recommended_category}")
    print(f"📌 권장 우선순위: {result.recommended_priority}")
    print(f"📋 {result.summary}")

def print_batch_results(results):
    """배치 분석 결과 출력"""
    print(f"\n📊 배치 분석 결과 ({len(results)}개 이미지)")
    print("=" * 50)
    
    for result in results:
        print_analysis_result(result)
        print("-" * 30)

if __name__ == "__main__":
    main()
