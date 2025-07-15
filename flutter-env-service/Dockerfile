FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# 포트 노출
EXPOSE 8889

# 실행
CMD ["gunicorn", "--bind", "0.0.0.0:8889", "app:app"]
