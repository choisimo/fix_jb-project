# Kafka Docker 컨테이너 실행 가이드

## 🔍 현재 상황 분석

사용자의 `docker ps` 출력을 보면 다음 컨테이너들이 실행 중입니다:
- MongoDB (포트 27017)
- Redis (포트 6379) 
- MariaDB (포트 13306)
- AI Service (포트 8000)
- Prometheus, Loki, Promtail

**하지만 Kafka와 Zookeeper 컨테이너가 없습니다.**

## 🚀 Kafka 컨테이너 시작하기

### 1단계: Docker 명령어 접근 확인

먼저 Docker 명령어에 접근할 수 있는 터미널에서 다음을 실행하세요:

```bash
# Docker가 실행 중인지 확인
docker --version

# 현재 실행 중인 컨테이너 확인
docker ps
```

### 2단계: Kafka 컨테이너 시작

프로젝트 루트 디렉토리(`/home/nodove/workspace/fix_jeonbuk`)로 이동한 후:

```bash
# 디렉토리 이동
cd /home/nodove/workspace/fix_jeonbuk

# Docker Compose로 Kafka 서비스 시작
docker compose up -d
# 또는 구버전의 경우
docker-compose up -d
```

### 3단계: 컨테이너 상태 확인

```bash
# Kafka 관련 컨테이너 확인
docker ps | grep -E "(kafka|zookeeper)"

# 로그 확인
docker logs kafka
docker logs zookeeper
```

## 🔧 Docker Compose 설정 확인

현재 `docker-compose.yml` 파일:

```yaml
version: '3'

services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.3.0
    container_name: zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    networks:
      - jeonbuk_net

  kafka:
    image: confluentinc/cp-kafka:7.3.0
    container_name: kafka
    ports:
      - "9092:9092"
    depends_on:
      - zookeeper
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: 'zookeeper:2181'
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:29092,PLAINTEXT_HOST://0.0.0.0:9092
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
    networks:
      - jeonbuk_net

networks:
  jeonbuk_net:
    driver: bridge
```

## 🐛 일반적인 오류 및 해결책

### 1. 포트 충돌 오류
```bash
# 포트 9092가 사용 중인지 확인
netstat -tulpn | grep 9092
# 또는
lsof -i :9092

# 포트를 사용하는 프로세스 종료
sudo kill -9 <PID>
```

### 2. Zookeeper 연결 오류
```bash
# Zookeeper 컨테이너가 먼저 시작되었는지 확인
docker logs zookeeper

# Kafka가 Zookeeper에 연결되었는지 확인
docker logs kafka | grep -i zookeeper
```

### 3. 네트워크 오류
```bash
# Docker 네트워크 확인
docker network ls
docker network inspect jeonbuk_net
```

## 🧪 Kafka 연결 테스트

Kafka가 정상적으로 시작되면 다음으로 테스트할 수 있습니다:

### Python에서 연결 테스트
```python
from confluent_kafka import Producer, Consumer
import json

# Producer 테스트
producer = Producer({'bootstrap.servers': 'localhost:9092'})
producer.produce('test_topic', 'Hello Kafka!')
producer.flush()

# Consumer 테스트
consumer = Consumer({
    'bootstrap.servers': 'localhost:9092',
    'group.id': 'test_group',
    'auto.offset.reset': 'earliest'
})
consumer.subscribe(['test_topic'])
```

## 🔄 서비스 재시작 명령어

문제가 계속되면 다음 명령어로 서비스를 재시작하세요:

```bash
# 모든 컨테이너 중지
docker compose down

# 볼륨과 함께 완전 정리
docker compose down -v

# 다시 시작
docker compose up -d

# 실시간 로그 확인
docker compose logs -f
```

## 📋 체크리스트

- [ ] Docker 서비스가 실행 중인가?
- [ ] 포트 9092가 사용 가능한가?
- [ ] Zookeeper 컨테이너가 정상 시작되었는가?
- [ ] Kafka 컨테이너가 Zookeeper에 연결되었는가?
- [ ] 네트워크 설정이 올바른가?
- [ ] 방화벽이 포트를 차단하지 않는가?

## 🆘 추가 도움이 필요한 경우

1. 컨테이너 로그를 확인하여 구체적인 오류 메시지를 찾으세요
2. Docker 데스크톱이 실행 중인지 확인하세요 (Windows/Mac의 경우)
3. 시스템 리소스(메모리, 디스크)가 충분한지 확인하세요
