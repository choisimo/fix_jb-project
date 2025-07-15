FROM python:3.9-slim

WORKDIR /app

# 필요한 시스템 패키지 설치 및 Docker CLI 설치
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Docker 그룹 생성 (GID는 호스트와 맞춤)
RUN groupadd -g 961 docker

# Python 패키지 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 앱 코드 복사
COPY app.py .
COPY app/ ./app/

# 데이터 디렉토리 생성
RUN mkdir -p /app/data

# root 사용자를 docker 그룹에 추가
RUN usermod -a -G docker root

EXPOSE 8888

CMD ["python", "app.py"]